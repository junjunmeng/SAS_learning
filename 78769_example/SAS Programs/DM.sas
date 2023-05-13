
/*Begin writing SAS program dm.sas*/
/*show structure of the raw DM dataset*/

libname RAW "E://users/tiany";

/*proc import to import raw Demographics(DM) data in excel to SAS*/
PROC IMPORT OUT= RAW.DM DATAFILE= "E://users/tiany/sdtm_raw.xlsx" 
            DBMS=xlsx REPLACE;
     SHEET="DM"; 
     GETNAMES=YES;
RUN;

/*Begin writing SAS program dm.sas*/

/*show structure of the raw DM dataset*/
proc contents data=RAW.DM;
run;
/*Create the 1st set of DM variables using existing variables from RAW.DM*/
data DM1;
/*Specify length for standard variables*/ 
  length STUDYID ARMCD $20  ETHNIC $60 SEX $2 COUNTRY $4 BRTHDTC $20 RACE $100  ;
  set RAW.DM (rename=(COUNTRY=COUNTRY_ SEX=SEX_ AGEU=AGEU_ ETHNIC=ETHNIC_));
    
/*Derive SITEID, BRTHDTC and COUNTRY*/

  SITEID=SITE;
  BRTHDTC=put(BRTHDAT,yymmdd10.);
  if COUNTRY_="United States" then COUNTRY="USA";
  /*Derive SEX*/
  if SEX_="Female" then SEX="F";
  else if SEX_="Male" then SEX="M";
  else if SEX_="Unknown" then SEX="U";
  else if SEX_="Undifferentiated" then SEX="UNDIFFERENTIATED";
  
  
/*Derive ETHNIC AND AGEU*/

  ETHNIC=upcase(ETHNIC_);
  AGEU=upcase(AGEU_);
 
/*Derive RACE*/

  if cmiss(RACE_WHITE, RACE_BLACK, RACE_HAWAIIAN, RACE_ASIAN, RACE_AINDIAN,RACE_NOREPORT, RACE_UNKNOWN, RACE_OTHER)=7 then do;
  	if not missing(RACE_AINDIAN) then RACE="AMERICAN INDIAN OR ALASKA AMERICAN";
  else  if not missing(RACE_ASIAN) then RACE="ASIAN";
  else  if not missing(RACE_BLACK) then RACE="BLACK OR AFRICAN AMERICAN";
  else  if not missing(RACE_HAWAIIAN) then RACE="NATIVE HAWAIIAN OR OTHER PACIFIC ISLANDERS";
  else  if not missing(RACE_WHITE) then RACE="WHITE";
  else  if not missing(RACE_NOREPORT) then RACE="NOT REPORTED";
  else	if not missing(RACE_UNKNOWN) then RACE="UNKNOWN";
  else  if not missing(RACE_OTHER) then RACE=" ";
	end;

  else if 8-cmiss(RACE_WHITE, RACE_BLACK, RACE_HAWAIIAN, RACE_ASIAN, RACE_AINDIAN,RACE_NOREPORT, RACE_UNKNOWN, RACE_OTHER)>1 then RACE="MULTIPLE";
 
  /*Create SUPPDM Domain*/                                   

  if RACE="MULTIPLE" then do;
    if not missing(RACE_AINDIAN) then RACE1="AMERICAN INDIAN OR ALASKA AMERICAN";
	else if not missing(RACE_ASIAN) then RACE2="ASIAN";
	else if not missing(RACE_BLACK) then RACE3="BLACK OR AFRICAN AMERICAN";
	else if not missing(RACE_HAWAIIAN) then RACE4="NATIVE HAWAIIAN OR OTHER PACIFIC ISLANDERS";
    else if not missing(RACE_WHITE) then RACE5="WHITE";
	else if not missing(RACE_NOREPORT) then RACE6="NOT REPORTED";
	else if not missing(RACE_UNKNOWN) then RACE7="UNKNOWN";
    else if not missing(RACE_OTHER) then RACE8=" ";
 end;

  if not missing(race_other) then RACEOTH="OTHER";
  ARMCD="DRUG A";
run;
/*Dropping records with the same ARMCD in order to merge back with DM variables)*/
/*import TA domain in order to catch variable ARM from TA*/
PROC IMPORT OUT= RAW.TA DATAFILE= "E://users/tiany/sdtm_raw.xlsx" 
            DBMS=xlsx REPLACE;
     SHEET="TA"; 
     GETNAMES=YES;
RUN;
/*Remove duplicate records with the same ARM)*/
proc sort data=RAW.TA out=TA(keep=armcd arm) nodupkey;
	by ARMCD;
run;
/*Merge DM1 with TA domain using ARMCD*/
proc sql;
	create table DM2 as select a.*,b.ARM length 200 from DM1 a left join TA b on a.ARMCD=b.ARMCD;
quit;


PROC IMPORT OUT=RAW.EX DATAFILE= "E://users/tiany/sdtm_raw.xlsx"
            DBMS=xlsx REPLACE;
     SHEET="EX";
     GETNAMES=YES;
RUN; 

/*Create RFSTDTC and RFENDTC from EX domain*/

data EX1;
   set RAW.EX(keep=SUBJID EXSTDAT);
  EXDTS=datepart(EXSTDAT);
  EXTMS=timepart(EXSTDAT);
  EXDTS_DT=put(EXDTS,yymmdd10.);
  EXDTS_TM=put(EXTMS,time8.);
  EXSTDTC=strip(EXDTS_DT)||"T"||strip(EXDTS_TM);
run;
data EX2(rename=(EXSTDTC=RFSTDTC))
     EX3(rename=(EXSTDTC=RFENDTC));
    set EX1;
	by SUBJID EXSTDTC;
    if first.SUBJID then output EX2;
	if last.SUBJID then output EX3;
run;
proc sql;
    create table DM3 as select a.*,b.RFSTDTC from DM2 a left join EX2 b on a.SUBJID=b.SUBJID;
	create table DM4 as select a.*,b.RFENDTC from DM3 a left join EX3 b on a.SUBJID=b.SUBJID;
quit;

data Final;
/*Defining DOMAIN, STUDYID, USUBJID, ACTARM, ACTARMCD*/
   set DM4;
   length ACTARMCD ARMCD $20. ARM ACTARM $200.;
   DOMAIN="DM";
   STUDYID="ABC-001";
   USUBJID=STRIP(STUDYID)||"-"||STRIP(SITEID)||"-"||STRIP(SUBJID);  
   ACTARM=strip(ARM);
   ACTARMCD = ARMCD;   
   format _all_;
   informat _all_;
run;
libname SDTM "E://users/tiany";
data SDTM.DM(label="Demographics");
/*Assign variable attributes such as label and length to conform with SDTM.DM Specification 
(these will also be the same attributes as the SDTM IG).*/
   attrib
	STUDYID		label = "Study Identifier"                   length = $20
	DOMAIN		label = "Domain Abbreviation"                length = $2
	USUBJID		label = "Unique Subject Identifier"          length = $40
	SUBJID		label = "Subject Identifier for the Study"   length = $20
	RFSTDTC		label = "Subject Reference Start Date/Time"  length = $20
	RFENDTC		label = "Subject Reference End Date/Time"    length = $20
	BRTHDTC     label = "Date/Time of Birth"                 length = $20
	SITEID		label = "Study Site Identifier"              length = $10
	AGE			label = "Age"                                length = 8
	AGEU		label = "Age Units"                          length = $10
	SEX			label = "Sex"                                length = $2
	RACE		label = "Race"                               length = $100
	ETHNIC		label = "Ethnicity"                          length = $60
	ARM			label = "Description of Planned Arm"         length = $200
	ARMCD		label = "Planned Arm Code"                   length = $20
	ACTARMCD	label = "Actual Arm Code"                    length = $20
	ACTARM		label = "Description of Actual Arm"          length = $200
	COUNTRY		label = "Country"                            length = $4
	;
  set Final;
   keep STUDYID	DOMAIN USUBJID SUBJID RFSTDTC RFENDTC BRTHDTC SITEID AGE AGEU SEX RACE 
        ETHNIC ARMCD ARM ACTARMCD ACTARM COUNTRY	
	;
run;

/*suppdm*/

data SUPPDM;
/*Create SUPPxx Variables which will always be QNAM, QLABEL, QVAL, QORIG, IDVAR, IDVARVAL and RDOMAIN. */  
  set Final;
  length RDOMAIN $2. IDVAR $8. QNAM USUBJID IDVARVAL QLABEL $40. QORIG QVAL $100.;
    RDOMAIN="DM";
    IDVAR="";
	IDVARVAL="";
	QORIG="CRF";
  if RACE="MULTIPLE"  and ^missing(RACE_AINDIAN) then do;
	QNAM="RACE1";
	QLABEL="American Indian/Alaska Native";
	QVAL="AMERICAN INDIAN OR ALASKA NATIVE";
	output;
 end;
  if RACE="MULTIPLE"  and ^missing(RACE_ASIAN) then do;
	QNAM="RACE2";
	QLABEL="ASIAN";
	QVAL="ASIAN";
	output;
 end;
  if RACE="MULTIPLE"  and ^missing(RACE_BLACK) then do;
	QNAM="RACE3";
	QLABEL="Black or African American";
	QVAL="BLACK OR AFRICAN AMERICAN";
	output;
 end;
  if RACE="MULTIPLE"  and ^missing(RACE_HAWAIIAN) then do;
	QNAM="RACE4";
	QLABEL="Native Hawaiian/Pacific Islander";
	QVAL="NATIVE HAWAIIAN OR OTHER PACIFIC ISLANDER";
	output;
 end;
  if RACE="MULTIPLE"  and ^missing(RACE_WHITE) then do;
	QNAM="RACE5";
	QLABEL="White";
	QVAL="WHITE";
	output;
 end;
  if RACE="MULTIPLE"  and ^missing(RACE_NOREPORT) then do;
	QNAM="RACE6";
	QLABEL="Not reported";
	QVAL="NOT REPORTED";
	output;
 end;
  if RACE="MULTIPLE"  and ^missing(RACE_UNKNOWN) then do;
	QNAM="RACE7";
	QLABEL="Unknown";
	QVAL="UNKNOWN";
	output;
 end;
  if RACE="MULTIPLE"  and ^missing(RACE_OTHER) then do;
	QNAM="RACE8";
	QLABEL="Other";
	QVAL="OTHER";
	output;
 end;
   QORIG="CRF";
 
run;
libname SDTM "E://users/tiany";
data SDTM.SUPPDM(label="Supplimental Qualifiers for DM");
/*Assign variable attributes such as label and length to conform with SDTM.SUPPDM Specification 
(these will also be the same attributes as the SDTM IG).*/
   attrib
	STUDYID		label = "Study Identifier"                     length = $20
	RDOMAIN		label = "Related Domain Abbreviation"          length = $2
	USUBJID		label = "Unique Subject Identifier"            length = $40
	IDVAR		label = "Identifying Variable"                 length = $8
	IDVARVAL	label = "Identifying Variable Value"           length = $40
    QNAM		label = "Qualifier Variable Name"              length = $40
    QLABEL		label = "Qualifier Variable Label"             length = $40
    QVAL		label = "Data Value"                           length = $100
    QORIG		label = "Origin"                               length = $100
	;
  set SUPPDM ;
   keep STUDYID	RDOMAIN USUBJID IDVAR IDVARVAL QNAM QLABEL QVAL QORIG
	;
run;
  





  


