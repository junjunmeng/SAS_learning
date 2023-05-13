libname RAW "E://users/tiany";
/*proc import to import raw Tiral Arm(TA) data in excel to SAS*/
PROC IMPORT OUT= RAW.TI DATAFILE= "E://users/tiany/sdtm_raw.xlsx" 
            DBMS=xlsx REPLACE;
     SHEET="TI"; 
     GETNAMES=YES;
RUN;


data Final;
	set RAW.TI(rename=(STUDYID=STUDYID_ DOMAIN=DOMAIN_ IETESTCD=IETESTCD_ IETEST=IETEST_ IECAT=IECAT_)); 
	where DOMAIN_="TI";
	length STUDYID $20. DOMAIN $2. IETESTCD IETEST $100. IECAT $40.; 
	STUDYID=strip(STUDYID_);
	DOMAIN=strip(DOMAIN_);
	IETESTCD=strip(IETESTCD_);
	IETEST=strip(IETEST_);
	IECAT=strip(IECAT_);

	format _all_;
	informat _all_;

run;

libname SDTM "E://users/tiany";
data SDTM.TI(label="Trial Inclusion/Exclusion Criteria");
   attrib
    STUDYID  label = "Study Identifier"                         length = $20
    DOMAIN   label = "Domain Abbreviation"                      length = $2
    IETESTCD label = "Inclusion/Exclusion Criterion Short Name" length = $100
    IETEST   label = "Inclusion/Exclusion Criterion"            length = $100
    IECAT    label = "Inclusion/Exclusion Category"             length = $40
;
  set Final;
   keep STUDYID DOMAIN IETESTCD IETEST IECAT 
;
run;
