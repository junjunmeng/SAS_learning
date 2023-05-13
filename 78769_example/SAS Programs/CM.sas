/*create a libref called RAW pointing to the pathway under E drive*/
libname RAW "E://users/tiany";
/*proc import to import raw Concomitant Medication data in excel to SAS*/
PROC IMPORT OUT= RAW.CM DATAFILE= "E://users/tiany/sdtm_raw.xlsx" 
            DBMS=xlsx REPLACE;
     SHEET="CM"; 
     GETNAMES=YES;
RUN;
/* Begin writing SAS program cm.sas*/
/*show structure of the raw CM dataset*/
proc contents data=RAW.CM;
run;
/*Create the 1st set of CM variables using existing variables from RAW.CM*/
data CM1;
/*Specify length for standard variables*/
  length STUDYID CMSTDTC CMENDTC CMENRTPT $20. DOMAIN $2. USUBJID CMCAT CMROUTE $40. CMTRT CMINDC $200.;
  /*Rename STUDYID, CMTRT, CMINDC, CMDOSU, CMROUTE , CMDOSFRM , CMDOSFRQ, CMDECOD */
  set RAW.CM(where=(CMYN="Y") rename=(STUDYID=STUDYID_ CMTRT=CMTRT_ CMINDC=CMINDC_ CMDOSU=CMDOSU_
             CMROUTE=CMROUTE_ CMDOSFRM=CMDOSFRM_ CMDOSFRQ=CMDOSFRQ_ CMDECOD=CMDECOD_));
  /*Define DOMAIN, CMCAT*/
  DOMAIN="CM";
  /*Derive STUDYID, USUBJID, CMROUTE, CMDOSU, CMDOSFRM, CMDOSFRQ */
  STUDYID=strip(STUDYID_);
  USUBJID=STRIP(STUDYID)||"-"||STRIP(SITEID)||"-"||STRIP(SUBJID);
  CMTRT=strip(CMTRT_);
  CMCAT="GENERAL";
  
  CMROUTE=strip(upcase(CMROUTE_));
  CMDOSU=strip(upcase(CMDOSU_));
  CMDOSFRM=strip(upcase(CMDOSFRM_));
  CMDOSFRQ=strip(upcase(CMDOSFRQ_));
  /*Format CMSTDTC, CMENDTC */
  CMSTDTC=put(CMSTDAT,yymmdd10.);
  CMENDTC=put(CMENDAT,yymmdd10.);
  /*Derive CMTRT, CMINDC, CMDECOD, CMENRTPT */
  CMTRT=strip(upcase(CMTRT_));
  CMINDC=strip(upcase(CMINDC_));
  CMDECOD=strip(upcase(CMDECOD_));
   if CMONGO^="" then CMENRTPT="ONGOING";
run;
/*Sort dataset CM1 by USUBJID, CMCAT, CMSTDTC, CMENDTC, CMTRT */
proc sort data=CM1 out=CM2; 
   by USUBJID CMCAT CMSTDTC CMENDTC CMTRT;
run;
/*Derive CMSEQ*/
data Final;
  set CM2;
  length CMSEQ 8.;
  by USUBJID CMCAT CMSTDTC CMENDTC CMTRT;
  if FIRST.USUBJID then CMSEQ=0;
  CMSEQ+1;
  output;
run;
libname SDTM "E://users/tiany";
data SDTM.CM(label="Concomitant and Prior Medication");
/*Assign variable attributes such as label and length to conform with SDTM.CM Specification 
(these will also be the same attributes as the SDMT IG).*/
   attrib
	STUDYID		label = "Study Identifier"                             length = $20
	DOMAIN		label = "Domain Abbreviation"                          length = $2
	USUBJID		label = "Unique Subject Identifier"                    length = $40
	SUBJID		label = "Subject Identifier for the Study"             length = $20
	CMSEQ		label = "Sequence Number"                              length = 8
	CMTRT		label = "Reported name of drug, Medication or Therapy" length = $200
	CMDECOD  	label = "Standardized Medication Name"                 length = $100
	CMCAT    	label = "Category for Medication"                      length = $40
	CMINDC		label = "Indication"                                   length = $200
	CMDOSU      label = "Dose Units"                                   length = $40
    CMDOSFRM    label = "Dose Form"                                    length = $40
    CMDOSFRQ    label = "Dose Frequency"                               length = $40
	CMROUTE  	label = "Route of Administration"                      length = $40
	CMSTDTC		label = "Start Date/Time of Medication"                length = $20
	CMENDTC		label = "End Date/Time of Medication"                  length = $20
	CMENRTPT	label = "End Relative to Reference Time Point"         length = $20
	
	;
  set Final ;
   keep STUDYID	DOMAIN USUBJID SUBJID CMSEQ CMTRT CMDECOD CMCAT CMDOSU CMDOSFRM CMDOSFRQ 
        CMINDC CMROUTE CMSTDTC CMENDTC CMENRTPT	
	;
run;





   

