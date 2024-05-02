/*create a libref called RAW pointing to the pathway under E drive*/
libname RAW "E://users/tiany";
/*proc import to import raw ENDDOSE data in excel to SAS*/
PROC IMPORT OUT= RAW.DS DATAFILE= "E://users/tiany/sdtm_raw.xlsx" 
            DBMS=xlsx REPLACE;
     SHEET="DS"; 
     GETNAMES=YES;
RUN;
/*Begin writing SAS program ds.sas*/
/*show structure of the raw  DS dataset*/
proc contents data=RAW.DS;
run;
/*termination- end of dosing*/   

/*Create the 1st set of DS variables using existing variables from RAW.DS*/

data DS1;
   set RAW.DS;
   /*Define DOMAIN, STUDYID, SITEID,USUBJID,DSSTDTC*/
   DOMAIN="DS";
   STUDYID="ABC-001";
   SITEID=SITE;
   USUBJID=STRIP(STUDYID)||"-"||STRIP(SITEID)||"-"||STRIP(SUBJID);  
   DSCAT="DISPOSITION EVENT";
   DSSTDTC=strip(put(DSSTDAT,yymmdd10.));
   /*Derive DSTERM*/
   if upcase(DSDECOD)="COMPLETED" then DSTERM="COMPLETED";
   else if upcase(DSDECOD)="ADVERSE EVENT" then DSTERM="ADVERSE EVENT";
   else if upcase(DSDECOD)="DEATH" then DSTERM="DEATH";
   else if upcase(DSDECOD)="Lost To Follow-Up" then DSTERM="Lost To Follow-Up";
   else if upcase(DSDECOD)="PREGANCY" then DSTERM="PREGANCY";
   else if upcase(DSDECOD)="PROGRESSIVE DISEASE" then DSTERM="PROGRESSIVE DISEASE"; 
   else if upcase(DSDECOD)="PROTOCOL DEVIATION" then DSTERM="PROTOCOL DEVIATION";  
   else if upcase(DSDECOD)="SCREEN FAILURE" then DSTERM="SCREEN FAILURE";   
   else if upcase(DSDECOD)="SITE TERMINATED BY SPONSOR" then DSTERM="SITE TERMINATED BY SPONSOR";  
   else if upcase(DSDECOD)="STUDY TERMINATED BY SPONSOR" then DSTERM="STUDY TERMINATED BY SPONSOR";  
   else if upcase(DSDECOD)="WITHDRAWN BY SUBJECT" then DSTERM="WITHDRAWN BY SUBJECT"; 
   else if upcase(DSDECOD)="OTHER" then DSTERM="OTHER";   
run;
/*Sort dataset DS1 by USUBJID, DSSTDTC, DSDECOD*/
proc sort data=DS1 out=DS2;
  by USUBJID DSSTDTC DSDECOD;
run;
/*Derive DSSEQ*/
data Final;
  set DS2;
  length DSSEQ 8.;
  by USUBJID DSSTDTC DSDECOD;
  if FIRST.USUBJID then DSSEQ=0;
  DSSEQ+1;
  output;
  format _all_;
  informat _all_;
run;
libname SDTM "E://users/tiany";
data SDTM.DS(label="Disposition");
/*Assign variable attributes such as label and length to conform with SDTM.DS Specification 
(these will also be the same attributes as the SDMT IG).*/
   attrib
	STUDYID		label = "Study Identifier"                        length = $20
	DOMAIN		label = "Domain Abbreviation"                     length = $2
	USUBJID		label = "Unique Subject Identifier"               length = $40
	DSSEQ		label = "Sequence Number"                         length = 8
	DSTERM	    label = "Reported Term for the Disposition Event" length = $200
	DSDECOD	    label = "Standardized Disposition Term"           length = $200
	DSCAT		label = "Category for Disposition Event"          length = $40
	DSSTDTC		label = "Start Date/Time of Disposition Event"    length = $20
   ;
  set Final;
   keep STUDYID	DOMAIN USUBJID DSSEQ DSTERM DSDECOD DSCAT DSSTDTC
   ;
run;



  



      
      
      
