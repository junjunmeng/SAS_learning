/*create a libref called RAW pointing to the pathway under E drive*/
libname RAW "E://users/tiany";
/*proc import to import raw EG data in excel to SAS*/
PROC IMPORT OUT= RAW.LB DATAFILE= "E://users/tiany/sdtm_raw.xlsx" 
            DBMS=xlsx REPLACE;
     SHEET="LB"; 
     GETNAMES=YES;
RUN;
/* Begin writing SAS program lb.sas*/
/*show structure of the raw LB dataset*/
proc contents data=RAW.LB; 
run;

data LB1;
  length USUBJID VISIT $40.;
  set RAW.LB(where=(LBYN="Y") rename=(STUDYID=STUDYID_  LBNRIND=LBNRIND_ LBFAST=LBFAST_ LBORRES=LBORRES_ LBORNRLO=LBORNRLO_
                     LBORNRHI=LBORNRHI_ ));
  DOMAIN="LB";
  STUDYID=strip(STUDYID_);
  USUBJID=STRIP(STUDYID)||"-"||STRIP(SITEID)||"-"||STRIP(SUBJID);
  if ^missing(LBDAT) and ^missing(LBTIM) then LBDTC=put(LBDAT,yymmdd10.)||"T"||put(LBTIM,tod5.);
     else if ^missing(LBDAT) and missing(LBTIM) then LBDTC=strip(put(LBDAT,yymmdd10.));
	 else if missing(LBDAT) and ^missing(LBTIM) then LBDTC="-----T"||put(LBTIM,tod5.);
  LBNRIND=upcase(strip(LBNRIND_));
  LBFAST=upcase(strip(LBFAST_));
  LBORRES=strip(put(LBORRES_,best.));
  LBORRESU=upcase(strip(LBORRESU));
  LBORNRLO=strip(put(LBORNRLO_,best.));
  LBORNRHI=strip(put(LBORNRHI_,best.));

  if index(upcase(EVENT),"SCREENING") then VISIT="SCREENING";
   else if index(upcase(EVENT),"FOLLOW UP") then VISIT="FOLLOW-UP";
   else if index(upcase(EVENT),"DAY") then VISIT="DAY "||strip(substr(upcase(EVENT),length(EVENT)-1));
   else VISIT=strip(upcase(EVENT));

 run;
 libname RAW "E://users/tiany";
/*proc import to import raw EG data in excel to SAS*/
PROC IMPORT OUT= RAW.LB_CONVERTION DATAFILE= "E://users/tiany/LB_conversion.xlsx" 
            DBMS=xlsx REPLACE;
     SHEET="CONVERSION"; 
     GETNAMES=YES;
RUN;
/*pull the LBSTRESU, CONVERTION from RAW.LB_CONVERTION*/
 proc sql noprint;
   create table LB2 as 
     select a.*, b.ORIGINAL_UNIT, b.STANDARD_UNIT, b.CONVERSION from LB1 as a
	   left join RAW.LB_CONVERTION as b
	   on a.LBCAT=b.LBCAT and a.LBTESTCD=b.LBTESTCD and a.LBORRESU=b.ORIGINAL_UNIT
	 order by STUDYID, USUBJID, LBCAT, LBTESTCD, LBDTC
	 ;
quit;
data LB3;
  length LBSTRESN  LBSTNRLO LBSTNRHI 8 LBSTRESU LBSTRESC LBTEST LBTESTCD $40.;
  set LB2(rename=(LBSTRESC=LBSTRESC_ LBSTRESN=LBSTRESN_ LBSTRESU=LBSTRESU_ LBSTNRLO=LBSTNRLO_ LBSTNRHI=LBSTNRHI_
                  LBTESTCD=LBTESTCD_ LBTEST=LBTEST_));
   if substr(LBORRES,1,1)=">" then do;
     LBSTRESN=input(substr(LBORRES,2),best.)*CONVERSION;
	 LBSTRESC=">"||strip(put(LBSTRESN,best.));
   end;
   if substr(LBORRES,1,1)="<" then do;
     LBSTRESN=input(substr(LBORRES,2),best.)*CONVERSION;
	 LBSTRESC="<"||strip(put(LBSTRESN,best.));
   end;
   if substr(LBORRES,1,2)=">=" then do;
     LBSTRESN=input(substr(LBORRES,3),best.)*CONVERSION;
	 LBSTRESC=">="||strip(put(LBSTRESN,best.));
   end;
   if substr(LBORRES,1,2)="<=" then do;
     LBSTRESN=input(substr(LBORRES,3),best.)*CONVERSION;
	 LBSTRESC="<="||strip(put(LBSTRESN,best.));
   end;
   else if ^missing(LBORRES) then do;
     LBSTRESN=input(LBORRES,best.)*CONVERSION;
	 LBSTRESC=strip(put(LBSTRESN,best.));
  end;
   LBSTNRHI=input(LBORNRHI,best.)*CONVERSION;
   LBSTNRLO=input(LBORNRHI,best.)*CONVERSION;
   if ^missing(CONVERSION) and ^missing(STANDARD_UNIT) then LBSTRESU=STANDARD_UNIT;
   LBTEST=upcase(strip(LBTEST_));
   LBTESTCD=upcase(strip(LBTESTCD_));



run;
proc sort data=LB3;by USUBJID; run;
proc sort data=SDTM.EX out=EX(keep=USUBJID EXSTDTC) nodupkey; by USUBJID;run;
data LB4;
/*Derive LBDTC, EXSTDTM*/
  merge LB3(in=a) EX(in=b keep=USUBJID EXSTDTC);
  by USUBJID;
  if length(LBDTC)>=10 then LBDTM=input(substr(LBDTC,1,16),e8601dt.);
  if length(EXSTDTC)>=10 then EXSTDTM=input(substr(EXSTDTC,1,16),e8601dt.);
run;

/* select the condition when LBDTM is on or before EXSTDTM and non-missing LBSTRESC, 
then create the baseline flag “Y” for the last non-missing result for each LBTESTCD.*/
/*Sort dataset LB4 by USUBJID, LBTESTCD, LBDTC */

proc sort data=LB4 out=BASEFL1;
   by USUBJID LBTESTCD LBDTC;
   where (LBDTM<=EXSTDTM and ^missing(LBSTRESC));
run;
data BASEFL2;
   set BASEFL1;
   /*Derive LBBLFL*/
   by USUBJID LBTESTCD LBDTC ;
   if last.LBTESTCD then LBBLFL="Y";
   keep USUBJID LBTESTCD LBDTC LBBLFL;
run;
proc sort data=BASEFL2;
  by USUBJID LBTESTCD LBDTC;
run;
proc sort data=LB4;
   by USUBJID LBTESTCD LBDTC;
run;

data LB5;
/*Merge LB4 and BASEFL2*/
  merge LB4(in=a rename=(LBCLSIG=LBCLSIG_)) BASEFL2(in=b);
  by USUBJID LBTESTCD LBDTC;
  if a;
  if LBSTRESC="ABNORMAL" then do;	
     if LBCLSIG_="No" then LBCLSIG="N";	
     else if LBCLSIG_="Yes" then LBCLSIG="Y";	
  end;
 else LBCLSIG="";	
  
run;
/*Sort dataset LB5 and SDTM.TV*/
proc sort data=LB5; by VISIT; run;
proc sort data=SDTM.TV out=TV(keep=VISIT VISITNUM) nodupkey; by VISIT;run;
/*Merge LB5 with TV to derive VISITNUM*/
data LB6;
  merge LB5(in=a) TV(in=b);
  by VISIT;
  if a;
run;
proc sort data=LB6; by USUBJID LBTESTCD LBDTC VISIT; run;
/*Derive LBSEQ*/
data Final; 
   set LB6;
     by USUBJID LBTESTCD LBDTC VISIT;
     if first.USUBJID then LBSEQ = 0;
     LBSEQ+1;
  output;
  format _all_;
  informat _all_;
run;

  
libname SDTM "E://users/tiany";
data SDTM.LB(label="LABROTORY TEST");
/*Assign variable attributes such as label and length to conform with SDTM.LB Specification 
(these will also be the same attributes as the SDMT IG).*/
   attrib
	STUDYID		 label = "Study Identifier"                          length = $20
	DOMAIN		 label = "Domain Abbreviation"                       length = $2
	USUBJID		 label = "Unique Subject Identifier"                 length = $40
	LBSEQ		 label = "Sequence Number"                           length = 8
	LBTESTCD	 label = "Lab Test or Examination Short Name"        length = $40
	LBTEST		 label = "Lab Test or Examination Name"              length = $40
	LBCAT	     label = "Category for Lab Test"                     length = $40
	LBORRES		 label = "Result or Finding in Original Units"       length = $20
	LBORRESU     label = "Original Units"                            length = $40
	LBORNRLO	 label = "Reference Range Lower Limit in Orig Unit " length = $40
	LBORNRHI	 label = "Reference Range Upper Limit in Orig Unit " length = $40
	LBSTRESC	 label = "Character Result/Finding in Std Format"    length = $40
	LBSTRESN     label = "Numeric Result/Finding in Standard Units"  length = 8
	LBSTRESU     label = "Standard Units"                            length = $40
	LBSTNRLO     label = "Reference Range Lower Limit-Std Units"     length = 8
	LBSTNRHI     label = "Reference Range Upper Limit-Std Units"     length = 8
	LBNRIND      label = "Reference Range for Char Rslt-Std Units"   length = $40
	LBBLFL		 label = "Baseline Flag"                             length = $2
	LBDTC        label = "Date/Time of Specimen Collection"          length = $40
	VISIT        label = "Visit Name"                                length = $40
	VISITNUM     label = "Visit Number"                              length = 8
	
	;
  set Final;
   keep STUDYID	DOMAIN USUBJID LBSEQ LBTESTCD LBTEST LBCAT LBORRES LBORRESU
        LBORNRLO LBORNRHI LBSTRESC LBSTRESN LBSTRESU LBSTNRLO LBSTNRHI LBNRIND 
		LBBLFL LBDTC VISIT VISITNUM 
	;
run;

  
 
