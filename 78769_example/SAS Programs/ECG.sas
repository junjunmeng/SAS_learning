/*create a libref called RAW pointing to the pathway under E drive*/
libname RAW "E://users/tiany";
/*proc import to import raw EG data in excel to SAS*/
PROC IMPORT OUT= RAW.EG DATAFILE= "E://users/tiany/sdtm_raw.xlsx" 
            DBMS=xlsx REPLACE;
     SHEET="EG"; 
     GETNAMES=YES;
RUN;
/*Begin writing SAS program eg.sas*/
/*show structure of the raw EG dataset*/
proc contents data=RAW.EG; 
run;

/*Assign the character values from “HR”, “INTP”, “PR”, “QRS”, “QT”, “QTca” 
to character values “Heart Rate”, “Interpretation”, “PR Interval”, “QRS Interval”, 
“QT Interval” and “QT Interval” for variable EGTESTCD using Proc Format*/

proc format;
  value $EGTESTCD
     "HR"="Heart Rate"
	 "INTP"="Interpretation"
	 "PR"="PR Interval"
	 "QRS"="QRS Interval"
	 "QT"="QT Interval"
	 "QTca"="QTca Interval"
	 ;
quit;
data EG1;
/*Specify length for standard variables*/
   length INTP $300. USUBJID $40. HR PR QRS QT QTca $200. VISIT $40.;
   /*Rename STUDYID EGMETHOD*/
   set RAW.EG(rename=(STUDYID=STUDYID_ EGMETHOD=EGMETHOD_));
   /*Define DOMAIN*/
   DOMAIN="EG";
   /*Derive STUDYID , USUBJID , EGREFID */
   STUDYID=strip(STUDYID_);
   USUBJID=STRIP(STUDYID)||"-"||STRIP(SITEID)||"-"||STRIP(SUBJID);

   EGMETHOD=upcase(strip(EGMETHOD_));
   EGREFID=strip(put(FSEQ,best.));
   
/*Derive HR, PR, QRS, QT, QTca, INTP*/

   HR=catx("~",Coalescec(put(EGHRMN_EGORRES,best.),"_null_"),EGHRMN_EGORRESU);
   PR=catx("~",Coalescec(put(PRSB_EGORRES,best.),"_null_"),PRSB_EGORRESU);
   QRS=catx("~",Coalescec(put(QRSAG_EGORRES,best.),"_null_"),QRSAG_EGORRESU);
   QT=catx("~",Coalescec(put(QTAG_EGORRES,best.),"_null_"),QTAG_EGORRESU);
   QTca=catx("~",Coalescec(put(QTCAAG_EGORRES,best.),"_null_"),QTCAAG_EGORRESU);
   INTP=catx("~",INTP_EGORRES,EGORRES);
   /*Derive VISIT*/
   if index(upcase(EVENT),"SCREENING") then VISIT="SCREENING";
   else if index(upcase(EVENT),"FOLLOW UP") then VISIT="FOLLOW-UP";
   else if index(upcase(EVENT),"DAY") then VISIT="DAY "||strip(substr(upcase(EVENT),length(EVENT)-1));
   else VISIT=strip(upcase(EVENT));

run;
/*Sort dataset EG1 by STUDYID, DOMAIN, USUBJID, EGREFID, VISIT, EGDAT */
proc sort data=EG1; 
    by STUDYID DOMAIN USUBJID EGMETHOD EGREFID VISIT EGDAT ;
run;
/*Transpose dataset EG1 with HR, PR, QRS, QT, QTca, INTP */
proc transpose data=EG1 out=EG2;
   by STUDYID DOMAIN USUBJID EGMETHOD EGREFID VISIT EGDAT;
   var  HR PR QRS QT QTca INTP;
run;
data EG3;
/*Specify length for standard variables*/
  length EGDTC EGTEST $20. EGTESTCD $8. EGORRESU $40.  EGORRES  EGSTRESC $100.;
  set EG2;
  /*Derive EGTESTCD, EGSTRESC, EGORRES, EGCAT, EGPOS, EGORRESU, EGSTRESC */
  EGTESTCD=upcase(strip(_name_));
  EGTEST=put(EGTESTCD,$EGTESTCD.);
   if _name_="INTP" then do;
    EGSTRESC=upcase(strip(scan(col1,1,"~")));
    if index(col1,"~") then EGORRES=upcase(strip(scan(col1,2,"~")));
      else EGORRES=EGSTRESC;
   end;

   else if _name_^="INTP" then do;
     if EGTESTCD="HR" then EGCAT="MEASUREMENT";
	  else if EGTESTCD in ("PR","QRS","QT","QTCA") then EGCAT="INTERVAL";
	 if EGTESTCD in ("HR","PR","QRS","QT","QTCA") then EGPOS="SUPINE";
	  EGORRES=strip(scan(col1,1,"~"));
	  EGORRESU=strip(scan(col1,2,"~"));
	  EGSTRESC=EGORRES;
   end;
    /*Derive EGDTC*/
   EGD=datepart(EGDAT);
   EGM=timepart(EGDAT);
   EGDTC_DT=put(EGD,yymmdd10.);
   EGDTC_TM=put(EGM,tod8.);
   EGDTC=strip(EGDTC_DT)||"T"||strip(EGDTC_TM);
run;
/*Sort dataset EG3 by USUBJID*/
proc sort data=EG3;by USUBJID; run;

/*Sort dataset SDTM.EX by USUBJID without duplicate values*/
proc sort data=SDTM.EX out=EX(keep=USUBJID EXSTDTC) nodupkey; by USUBJID;run;
data EG4;
/*Merge dataset EG3 and EX*/
  merge EG3(in=a) EX(in=b keep=USUBJID EXSTDTC);
  by USUBJID;
  /*Derive EGDTM and EXSTDTM*/
  if length(EGDTC)>=10 then EGDTM=input(substr(EGDTC,1,16),e8601dt.);
  if length(EXSTDTC)>=10 then EXSTDTM=input(substr(EXSTDTC,1,16),e8601dt.);
run;
/*Select the condition when EGDTM is on or before EXSTDTM and no-missing EGSTRESC to 
create the baseline flag with a value of “Y” for the last non-missing result for each EGTESTCD.*/
/*Sort dataset EG4 by USUBJID, EGTESTCD,EGDTC */
proc sort data=EG4 out=BASEFL1;
   by USUBJID EGTESTCD EGDTC;
   where (EGDTM<=EXSTDTM and ^missing(EGSTRESC));
run;
data BASEFL2;
   set BASEFL1;
   /*Derive EGBLFL*/
   by USUBJID EGTESTCD EGDTC ;
   if last.EGTESTCD then EGBLFL="Y";
   keep USUBJID EGTESTCD EGDTC EGBLFL;
run;
/*Sort dataset BASEFL2 by USUBJID, EGTESTCD, EGDTC */
proc sort data=BASEFL2;
  by USUBJID EGTESTCD EGDTC;
run;
/*Sort dataset EG4 by USUBJID, EGTESTCD, EGDTC */
proc sort data=EG4;
   by USUBJID EGTESTCD EGDTC;
run;
data EG5;
/*Merge dataset EG4 and BASEFL2*/
  merge EG4(in=a) BASEFL2(in=b);
  by USUBJID EGTESTCD EGDTC;
  if a;
run;
proc sort data=EG5; by VISIT; run;
proc sort data=SDTM.TV out=TV(keep=VISIT VISITNUM) nodupkey; by VISIT;run;
data EG6;
/*Merge dataset EG5 and TV*/
  merge EG5(in=a) TV(in=b);
  by VISIT;
  if a;
run;
/*Sort dataset EG6 by USUBJID, EGCAT, EGTESTCD, EGDTC, VISIT */

proc sort data=EG6; by USUBJID EGCAT EGTESTCD EGDTC VISIT ; run;
/*Derive EGSEQ*/
data Final; 
   set EG6;
     by USUBJID EGCAT EGTESTCD EGDTC VISIT;
     if first.USUBJID then EGSEQ = 0;
     EGSEQ+1;
  output;
  format _all_;
  informat _all_;

run;
  
libname SDTM "E://users/tiany";
data SDTM.EG(label="Demographics");
/*Assign variable attributes such as label and length to conform with SDTM.EG Specification 
(these will also be the same attributes as the SDMT IG).*/
   attrib
	STUDYID		 label = "Study Identifier"                          length = $20
	DOMAIN		 label = "Domain Abbreviation"                       length = $2
	USUBJID		 label = "Unique Subject Identifier"                 length = $40
	EGSEQ		 label = "Sequence Number"                           length = 8
	EGREFID	     label = "ECG Reference ID"                          length = $20
	EGTESTCD	 label = "ECG Test or Examination Short Name"        length = $20
	EGTEST		 label = "ECG Test or Examination Name"              length = $20
	EGCAT	     label = "Category for ECG"                          length = $20
	EGPOS		 label = "ECG POSITION OF SUBJECTS"                  length = $20
	EGORRES		 label = "Result or Finding in Original Units"       length = $100
	EGORRESU     label = "Original Units"                            length = $40
	EGSTRESC	 label = "Character Result/Finding in Std Format"    length = $100
    EGMETHOD	 label = "Method of ECG Test"                        length = $40
	EGBLFL		 label = "Baseline Flag"                             length = $60
	VISIT        label = "Visit Name"                            length = $40
    VISITNUM     label = "Visit Number"                         length = 8

	EGDTC        label = "Date/Time of ECG"                          length = $40
	
	;
  set Final;
   keep STUDYID	DOMAIN USUBJID EGSEQ EGREFID EGTESTCD
		EGTEST	EGCAT EGPOS	EGORRES EGORRESU EGSTRESC EGMETHOD
        EGBLFL VISIT VISITNUM EGDTC 
	;
run;











 
  




















