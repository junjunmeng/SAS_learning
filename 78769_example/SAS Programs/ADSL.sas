
/*Begin writing SAS program sdtm.dm.sas*/
/*Demographic Variables*/
data dm1;
   set sdtm.dm;
   length AETHNIC $40.;
   if missing(ETHNIC) then AETHNIC = "NOT COLLECTED";
   else AETHNIC = ETHNIC;
    If RACE = "WHITE" then ARACE = "W"; 
    else if RACE = "BLACK OR AFRICAN AMERICAN" then ARACE = "B"; 
    else if RACE = "NATIVE HAWAIIAN OR OTHER PACIFIC ISLANDERS" then ARACE = "HP";
    else if RACE = "ASIAN" then ARACE = "A"; 
    else if RACE = "AMERICAN INDIAN OR ALASKA AMERICAN" then ARACE = "AA";
/*Derive TRTSDT, TRTSTM, TRTEDT, TRTETM */
	TRTSDT = input(substr(RFSTDTC,1,10),yymmdd10.);
	TRTSTM = input(substr(RFSTDTC,12),time5.);
	TRTEDT = input(substr(RFENDTC,1,10),yymmdd10.);
	TRTETM = input(substr(RFENDTC,12),time5.);
	format TRTSDT yymmdd10. TRTSTM time5. TRTEDT yymmdd10. TRTETM time5.;
	length TRT01P TRT01A $20.;
/*Derive TRT01P, TRT01A*/
	if ARMCD = "DRUG A" then TRT01P = "TRTA";
	if ACTARMCD = "DRUG A" then TRT01A = "TRTA";
 /*Derive SAFFL, FASFL */
	if ^missing(RFSTDTC) then do; 
     SAFFL="Y";
	 FASFL="Y";
	end;
    else do;
     SAFFL="N";
	 FASFL="N";
	end;     
run;
/*Merge dm2 and dm1 to catch DSDECOD, DSSTDTC*/
proc sql;
  create table dm2 as select a.*,b.DSDECOD,DSSTDTC from dm1 a left join sdtm.ds b on a.USUBJID=b.USUBJID;
quit;
data dm3;
  set dm2;
  length EOSDT 8 EOSSTT $20.;
  EOSDT = input(substr(DSSTDTC,1,10),yymmdd10.);
  if DSDECOD = "COMPLETED" then EOSSTT = "COMPLETED";
  else EOSSTT = "DISCONTINUED";
  format EOSDT yymmdd10.; 
run;
/*Sort dataset SDTM.EX by USUBJID, EXSTDTC without duplicate values*/
proc sort data=SDTM.EX out=ex nodupkey; 
   by USUBJID EXSTDTC EXENDTC;
run;
data ex1
     ex2;
  set ex;
  by USUBJID EXSTDTC EXENDTC;
  /*Create dataset ex1 if the first.USUBJID statement*/
/*Create dataset ex2 if the last.USUBJID statement*/

  if First.USUBJID then output ex1;
  if Last.USUBJID then output ex2;
run;
proc sql;

/*Create dataset dm4 and dm5*/

  create table dm4 as select a.*, b.EXSTDTC from dm3 a left join ex1 b on a.USUBJID=b.USUBJID;
  create table dm5 as select a.*, b.EXENDTC from dm4 a left join ex2 b on a.USUBJID=b.USUBJID;
quit; 
data Final;
  set dm5;
  /*Derive TRT01SDTM, TRT01SDT, TRT01EDTM, TRT01EDT */
  length TRT01SDTM TRT01SDT TRT01EDTM TRT01EDT 8.;
  TRT01SDTM = input(EXSTDTC, e8601dt.);
  TRT01SDT = input(substr(EXSTDTC,1,10),yymmdd10.);
  TRT01EDTM = input(EXENDTC, e8601dt.);
  TRT01EDT = input(substr(EXENDTC,1,10),yymmdd10.);
  format TRT01SDTM TRT01EDTM e8601dt. TRT01SDT TRT01EDT yymmdd10.;
run;


libname ADAM "E://users/tiany";
data ADAM.ADSL(label="Subject-Level Analysis Dataset");
/*Assign variable attributes such as label and length 
to conform with ADAM.ADSL Specification 
 (these will also be the same attributes as the ADAM IG).*/ 
   attrib
	STUDYID		label = "Study Identifier"                   length = $20
	USUBJID		label = "Unique Subject Identifier"          length = $40
	SUBJID		label = "Subject Identifier for the Study"   length = $20
	SITEID      label = "Study Site Identifier"              length = $10
	BRTHDTC     label = "Date/Time of Brith"                 length = $20
	AGE			label = "Age"                                length = 8
	AGEU		label = "Age Units"                          length = $10
	SEX			label = "Sex"                                length = $2
	RACE		label = "Race"                               length = $100
	ARACE		label = "Analysis Race"                       length = $100
	ETHNIC		label = "Ethnicity"                          length = $60
	AETHNIC		label = "Analysis Ethnicity"                  length = $60
	SAFFL       label = "Safety Population Flag"             length = $1
	FASFL       label = "Full Analysis Set Population Flag"  length = $1
	ARM			label = "Description of Planned Arm"         length = $200
	ARMCD		label = "Planned Arm Code"                   length = $20
	ACTARMCD	label = "Actual Arm Code"                    length = $20
	ACTARM		label = "Description of Actual Arm"          length = $200
	TRT01P		label = "Planned Treatment for Period 1"     length = $20
	TRT01A		label = "Actual Treatment for Period 1"      length = $20
	RFSTDTC		label = "Subject Reference Start Date/Time"  length = $20
	RFENDTC  	label = "Subject Reference End Date/Time"  length = $20
	TRTSDT      label = "Date of First Exposure to Treatment" length = 8
	TRTSTM      label = "Time of First Exposure to Treatment" length = 8
    TRT01SDTM   label = "Datetime of First Exposure in Period 1" length = 8
	TRT01SDT    label = "Date of First Exposure in Period 1" length = 8
	TRTEDT      label = "Date of Last Exposure to Treatment" length = 8
	TRTETM      label = "Time of Last Exposure to Treatment" length = 8
    TRT01EDTM   label = "Datetime of Last Exposure in Period 1" length = 8
	TRT01EDT    label = "Date of Last Exposure in Period 1" length = 8
	EOSSTT      label = "End of Study Status"                length = $20
	EOSDT       label = "End of Study"                       length = 8
	COUNTRY		label = "Country"                            length = $4
	;
  set Final;
   keep STUDYID USUBJID SUBJID SITEID BRTHDTC AGE AGEU SEX RACE ARACE 
        ETHNIC AETHNIC SAFFL FASFL ARM ARMCD ACTARMCD ACTARM TRT01P TRT01A RFSTDTC RFENDTC
        TRTSDT TRTSTM TRT01SDTM TRT01SDT TRTEDT TRTETM TRT01EDTM TRT01EDT EOSSTT EOSDT COUNTRY	
	;
run;
