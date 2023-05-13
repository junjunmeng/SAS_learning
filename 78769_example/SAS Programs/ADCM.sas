
/*Begin writing SAS program merge SDTM.CM and ADAM.ADSL.sas*/

data ADCM1;
  merge SDTM.CM(in=a) ADAM.ADSL(in=b drop=STUDYID);
  by USUBJID;
  if a and b;
run;
data ADCM2;
  set ADCM1;
  length ADURU $20 ONTRTFL PREFL ASTDTF $1 ASTDT AENDT ADURN 8. ;
  /*Derive ASTDT, AENDT */
  ASTDT=input(substr(CMSTDTC,1,10),yymmdd10.);
  AENDT=input(substr(CMENDTC,1,10),yymmdd10.);
  format ASTDT AENDT yymmdd10.;

 /*Derive ONTRTFL, PREFL, FUPFL, EMDESC*/
	 if TRTSDT <= ASTDT <= TRTEDT then ONTRTFL = "Y";
	 else if . < ASTDT < TRTSDT then PREFL = "Y";
	 else if ASTDT > TRTEDT and TRTEDT^=. then  FUPFL = "Y"; 
/*Derive ASTDY*/	
	 if nmiss(ASTDT,TRTSDT)=0 then ASTDY=ASTDT-TRTSDT+(ASTDT>=TRTSDT);
/*Derive ASTDTF*/
	if length(CMSTDTC) >= 10 then ASTDTF="";
	else if length(CMSTDTC)=7 then ASTDTF="D";
    else if length(CMSTDTC)=4 then ASTDTF="M";
/*Derive ADURN, ADURU*/
	if cmiss(CMSTDTC,CMENDTC)=0 then ADURN=AENDT-ASTDT+1; 
	if ADURN>1 then ADURU="DAYS";
	else if ADURN=1 then ADURU="DAY";
	else ADURU="";
    
/*Derive TRTP, TRTA*/
	TRTA=TRT01A; 
	TRTP=TRT01P;    
 run;
 proc sort data=ADCM2; by USUBJID CMTRT ASTDT AENDT CMDECOD CMSEQ;run;
 /*Derive ASEQ*/
data Final; 
   set ADCM2;
     by USUBJID CMTRT ASTDT AENDT CMDECOD CMSEQ; 
     if first.USUBJID then ASEQ = 0;
     ASEQ+1;
  output;
run;
 libname ADAM "E://users/tiany";
data ADAM.ADCM(label="Concomitant Medication Anaysis Dataset");
/*Assign variable attributes such as label and length to conform 
with ADAM.ADSL Specification (these will also be the same attributes as the ADAM IG).*/ 
   attrib
	STUDYID  label = "Study Identifier"                        length = $20
	USUBJID  label = "Unique Subject Identifier"               length = $40
	CMSEQ    label = "Sequence Number"                         length = 8
	ASEQ	 label = "Analysis Sequence Number"                length = 8
	CMDECOD  label = "Dictionary-Derived Term"                 length = $200
    ASTDT   label = "Analysis Start Date"                      length = 8
	ASTDTF   label = "Analysis Start Date Imputation Flag"     length = $1
	ONTRTFL  label = "On Treatment Record Flag "               length = $1
	PREFL    label = "Pre-treatment Flag"                      length = $1
	FUPFL    label = "Follow-Up Flag"                          length = $1
	AENDT    label = "Analysis Start Date"                      length = 8
	ASTDY     label = "Analysis Start Relative Day"             length = 8
    CMTRT	label = "Reported name of drug, Medication or Therapy" length = $200
	CMINDC	label = "Indication"                                  length = $200
	CMROUTE label = "Route of Administration"                     length = $40
	CMSTDTC	label = "Start Date/Time of Medication"               length = $20
	CMENDTC	label = "End Date/Time of Medication"                 length = $20
	CMENRTPT label = "End Relative to Reference Time Point"       length = $20
	;
   set FINAL;
   keep STUDYID USUBJID CMSEQ CMDECOD ASTDT ASTDTF ONTRTFL 
        PREFL FUPFL AENDT ASTDY CMTRT CMINDC CMROUTE CMSTDTC CMENDTC CMENRTPT
	; 
run;

