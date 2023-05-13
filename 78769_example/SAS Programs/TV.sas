/*create a libref called RAW pointing to the pathway under E drive*/
libname RAW "E://users/tiany";
/*proc import to import raw Tiral Visit(TV) data in excel to SAS*/
PROC IMPORT OUT= RAW.TV DATAFILE= "E://users/tiany/sdtm_raw.xlsx" 
            DBMS=xlsx REPLACE;
     SHEET="TV"; 
     GETNAMES=YES;
RUN;

data Final;
	set RAW.TV(rename=(STUDYID=STUDYID_ DOMAIN=DOMAIN_ VISITNUM=VISITNUM_ VISIT=VISIT_ 
	      ARM=ARM_ ARMCD=ARMCD_ TVSTRL=TVSTRL_ )); 
	length STUDYID ARMCD $20. DOMAIN $2. ARM TVSTRL $100. VISIT $40.; 
	STUDYID=strip(STUDYID_);
	DOMAIN=strip(DOMAIN_);
	VISITNUM=VISITNUM_;
	VISIT=strip(VISIT_);
	ARM=strip(ARM_);
	ARMCD=strip(ARMCD_);
	TVSTRL=strip(TVSTRL_);

	format _all_;
	informat _all_;
run;

libname SDTM "E://users/tiany";
data SDTM.TV(label="Trial Visit");
   attrib
	STUDYID		label = "Study Identifier"                    length = $20
	DOMAIN		label = "Domain Abbreviation"                 length = $2
    VISITNUM    label = "Visit Number"                        length = 8
	VISIT       label = "Visit Name"                          length = $40
	ARM         label = "Planned Arm"                         length = $100
	ARMCD		label = "Planned Arm Code"                    length = $20
	TVSTRL      label = "Visit Start Rule"                    length = $100
	
;
  set Final;
   keep STUDYID	DOMAIN ARM ARMCD VISIT VISITNUM TVSTRL 
	;
run;
