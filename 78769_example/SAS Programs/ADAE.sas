/*Begin writing SAS program merge SDTM.AE and ADAM.ADSL.sas*/
data ADAE1;
  merge SDTM.AE(in=a) ADAM.ADSL(in=b drop=STUDYID);
  by USUBJID;
  if a and b;
run;
data FINAL;
  set ADAE1;
  length TRTEMFL PREFL ASTDTF $1 ASTDT AENDT 8. ;
  /*Derive ASTDT, AENDT */
  ASTDT=input(substr(AESTDTC,1,10),yymmdd10.);
  AENDT=input(substr(AEENDTC,1,10),yymmdd10.);
  format ASTDT AENDT yymmdd10.;

  /*Derive TRTEMFL, PREFL, FUPFL, EMDESC*/
	 if TRTSDT <= ASTDT <= TRTEDT then do;
        TRTEMFL = "Y";
		EMDESC = "T";
	 end;
     if . < ASTDT < TRTSDT then do; 
       PREFL = "Y";
       EMDESC = "P"; 
     end;
	 else if ASTDT > TRTEDT and TRTEDT^=. then do; 
       FUPFL = "Y"; 
	   EMDESC= "A";
	 end;
	 if nmiss(ASTDT,TRTSDT)=0 then ASTDY=ASTDT-TRTSDT+(ASTDT>=TRTSDT);
 /*Derive ASTDTF*/
	if length(AESTDTC) >= 10 then ASTDTF="";
	else if length(AESTDTC)=7 then ASTDTF="D";
    else if length(AESTDTC)=4 then ASTDTF="M";
    
   /*Derive TRTP, TRTA*/
	TRTA=TRT01A; 
	TRTP=TRT01P;    
 run;
 libname ADAM "E://users/tiany";
data ADAM.ADAE(label="Adverse Event Anaysis Dataset");
/*Assign variable attributes such as label and length to conform with 
ADAM.ADSL Specification (these will also be the same attributes as the ADAM IG).*/ 
   attrib
	STUDYID  label = "Study Identifier"                        length = $20
	USUBJID  label = "Unique Subject Identifier"               length = $40
	AESEQ	 label = "Sequence Number"                         length = 8
	AETERM   label = "Reported Term for the Adverse Event"     length = $200
	AELLT    label = "Lowest Level Term"                       length = $100
	AELLTCD  label = "Lowest Level Term Code"                  length = 8
	AEDECOD  label = "Dictionary-Derived Term"                 length = $200
	AEPTCD   label = "Preferred Term Code"                     length = 8
    ASTDT   label = "Analysis Start Date"                     length = 8
	ASTDTF   label = "Analysis Start Date Imputation Flag"     length = $1
	AEENDTC  label = "End Date/Time of Adverse Event"          length = $20
	AENDT    label = "Analysis Start Date"                      length = 8
	ASTDY     label = "Analysis Start Relative Day"             length = 8
	TRTEMFL  label = "Treatment Emergent Analysis Flag"     length = $1
	PREFL    label = "Pre-treatment Flag"                     length = $1
	FUPFL    label = "Follow-Up Flag"                         length = $1
	EMDESC   label = "Description of Treatment Emergent "     length = $20
	AEHLT    label = "High Level Term"                         length = $200
	AEHLTCD  label = "High Level Term Code"                    length = 8
	AEHLGT   label = "High Level Group Term"                   length = $200
	AEHLGTCD label = "High Level Group Term Code"              length = 8
	AEBODSYS label = "Body System or Organ Class"              length = $20
	AESER    label = "Serious Event"                           length = $2
	AEACN    label = "Action Taken with Study Treatment"       length = $50
	AEREL    label = "Causality"                               length = $50
	AEOUT    label = "Outcome of Adverse Event"                length = $50
    AESCONG  label = "Congenital Anomaly or Birth Defect"      length = $2
	AESDISAB label = "Persist or Significant Disability"       length = $2
	AESDTH   label = "Results in Death"                        length = $2
	;
   set FINAL;
   keep STUDYID USUBJID AESEQ AETERM AELLT AELLTCD AEDECOD AEPTCD ASTDT ASTDTF AEENDTC AENDT
        ASTDY TRTEMFL PREFL FUPFL EMDESC AEHLT AEHLTCD AEHLGT AEHLGTCD
		AEBODSYS AESER AEACN AEREL AEOUT AESCONG AESDISAB AESDTH
	; 
run;

