/*create a libref called RAW pointing to the pathway under E drive*/
libname RAW "E://users/tiany";
/*proc import to import raw Tiral Arm(TA) data in excel to SAS*/
PROC IMPORT OUT= RAW.TE DATAFILE= "E://users/tiany/sdtm_raw.xlsx" 
            DBMS=xlsx REPLACE;
     SHEET="TE"; 
     GETNAMES=YES;
RUN;


data Final;
	set RAW.TE(rename=(STUDYID=STUDYID_ DOMAIN=DOMAIN_ ETCD=ETCD_ ELEMENT=ELEMENT_ TESTRL=TESTRL_
	 TEENRL=TEENRL_ )); 
	where DOMAIN_="TE";
	length STUDYID $20. DOMAIN $2. ETCD $8. TESTRL TEENRL ELEMENT $100.  ; 
	STUDYID=STUDYID_;
	DOMAIN=DOMAIN_;
	ETCD=ETCD_;
	ELEMENT=ELEMENT_;
	TESTRL=TESTRL_;
	TEENRL=TEENRL_;

	format _all_;
	informat _all_;

run;

libname SDTM "E://users/tiany";
data SDTM.TE(label="Trial Element");
   attrib
	STUDYID		label = "Study Identifier"                    length = $20
	DOMAIN		label = "Domain Abbreviation"                 length = $2
	ETCD        label = "Element Code"                        length = $8
	ELEMENT     label = "Description of Element"              length = $100
	TESTRL      label = "Rule for Start of Element"           length = $100
	TEENRL      label = "Rule for End of Element"             length = $100
;
  set Final;
   keep STUDYID	DOMAIN ETCD ELEMENT TESTRL TEENRL 
	;
run;
