/*create a libref called RAW pointing to the pathway under E drive*/
libname RAW "E://users/tiany";

/*proc import to import raw Exposure(EX0 data in excel to SAS*/
PROC IMPORT OUT= RAW.EX DATAFILE= "E://users/tiany/sdtm_raw.xlsx" 
            DBMS=xlsx REPLACE;
     SHEET="EX"; 
     GETNAMES=YES;
RUN;
/*Begin writing SAS program ex.sas*/
/*show structure of the raw EX dataset*/
proc contents data=RAW.EX;
run;
/*Create the 1st set of EX variables using existing variables from RAW.EX*/
data EX1;
/*Specify length for standard variables*/
   length EXSTDTC EXENDTC EXREFID $20. EXTRT $100;
   /*Rename EXDOSU, EXDOSE, EXDOSFRQ, EXROUTE EXREFID*/
  set RAW.EX(rename=(EXDOSU=EXDOSU_ EXDOSE=EXDOSE_ EXDOSFRQ=EXDOSFRQ_ EXROUTE=EXROUTE_ EXREFID=EXREFID_));
  /*Define DOMAIN, USUBJID, EXCAT, EXDOSFRM */
/*Derive EXTRT, EXDOSU, EXDOSE, EXDOSFRQ, EXROUTE,EXREFID, EXDTS, EXTMS */

  DOMAIN="EX";
  USUBJID=STRIP(STUDYID)||"-"||STRIP(SITEID)||"-"||STRIP(SUBJID);
  if index(upcase(FORM),"DRUG A")>0 then EXTRT="DRUG A";
  EXCAT="DOSING";
  EXDOSU=upcase(strip(EXDOSU_));
  EXDOSE=EXDOSE_;
  EXDOSFRM="TABLET";
  EXDOSFRQ=upcase(strip(EXDOSFRQ_));
  EXROUTE=upcase(strip(EXROUTE_));
  EXREFID=strip(put(EXREFID_,best.));
  EXDTS=datepart(EXSTDAT);
  EXTMS=timepart(EXSTDAT);
  /*Format EXDTS_DT, EXDTS_TM , EXDTE_DT , EXDTE_TM */
/*Derive EXDTE , EXTME , EXSTDTC , EXENDTC */

  EXDTS_DT=put(EXDTS,yymmdd10.);
  EXDTS_TM=put(EXTMS,time8.);

  EXDTE=datepart(EXENDAT);
  EXTME=timepart(EXENDAT);
  EXDTE_DT=put(EXDTE,yymmdd10.);
  EXDTE_TM=put(EXTME,time8.);
 
  EXSTDTC=strip(EXDTS_DT)||"T"||strip(EXDTS_TM);
  EXENDTC=strip(EXDTE_DT)||"T"||strip(EXDTE_TM);
run;
/*Sort dataset EX1 by USUBJID, EXSTDTC, EXENDTC, EXTRT, EXDOSE */
proc sort data=EX1 out=EX2;
   by USUBJID EXSTDTC EXENDTC EXTRT EXDOSE ;
run;
/*Derive EXSEQ*/
data Final;
  set EX2;
  length EXSEQ 8.;
  by USUBJID EXSTDTC EXENDTC EXTRT EXDOSE ;
  if FIRST.USUBJID then EXSEQ=0;
  EXSEQ+1;
  output;
  format _all_;
  informat _all_;
run;

libname SDTM "E://users/tiany";
data SDTM.EX(label="Exposure");
/*Assign variable attributes such as label and length to conform with SDTM.EX Specification 
(these will also be the same attributes as the SDMT IG).*/
   attrib

	STUDYID     label = "Study Identifier"                    length = $20
	DOMAIN	label = "Domain Abbreviation"                   length = $2
	USUBJID	label = "Unique Subject Identifier"           length = $40
	EXSEQ		label = "Sequence Number"                     length = 8
	EXREFID		label = "Reference ID"                     length = $20
	EXTRT	      label = "Name of Treatment"                   length = $100
	EXCAT	      label = "Category of Treatment"               length = $40
	EXDOSE      label = "Dose"                                length = 8
	EXDOSU      label = "Dose Units"                          length = $40
	EXDOSFRM    label = "Dose Form"                           length = $20
	EXDOSFRQ    label = "Dosing Frequency per Interval"       length = $20
	EXROUTE	label = "Route of Administration"             length = $40
	EXSTDTC      label = "Start Date/Time of Treatment"       length = $40
	EXENDTC      label = "End Date/Time of Treatment"         length = $40
	;
  set Final;
   keep STUDYID DOMAIN USUBJID EXSEQ EXREFID EXTRT EXCAT EXDOSE EXDOSU EXDOSFRM EXDOSFRQ EXROUTE EXSTDTC EXENDTC;
run;
