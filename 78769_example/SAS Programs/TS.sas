/*create a libref called RAW pointing to the pathway under E drive*/
libname RAW "E://users/tiany";
/*proc import to import raw Tiral Arm(TA) data in excel to SAS*/
PROC IMPORT OUT= RAW.TS DATAFILE= "E://users/tiany/sdtm_raw.xlsx" 
            DBMS=xlsx REPLACE;
     SHEET="TS"; 
     GETNAMES=YES;
RUN;
data Final;
	set RAW.TS(rename=(STUDYID=STUDYID_ DOMAIN=DOMAIN_ TSSEQ=TSSEQ_  TSPARMCD=TSPARMCD_ TSPARM=TSPARM_ 
     TSVAL=TSVAL_ TSVALNF=TSVALNF_ TSVCDREF=TSVCDREF_));
		length DOMAIN $2 TSPARMCD $8 TSSEQ 8.STUDYID $20  TSVCDREF $20  
		TSPARM $40 TSVAL TSVALNF  $100;
		STUDYID = strip(STUDYID_);
		DOMAIN  = strip(DOMAIN_);
		TSSEQ=TSSEQ_;
		TSPARMCD=strip(TSPARMCD_); 
		TSPARM=strip(TSPARM_);
    	TSVAL=strip(TSVAL_);
		TSVALNF=strip(TSVALNF_);
		TSVCDREF=strip(TSVCDREF_);

		format _all_;
		informat _all_;
run;
libname SDTM "E://users/tiany";
data SDTM.TS(label="Trial Summary");
   attrib
	STUDYID		label = "Study Identifier"                     length = $20
	DOMAIN		label = "Domain Abbreviation"                  length = $2
    TSSEQ       label = "Sequence Number"                      length = 8
    TSPARMCD    label = "Trial Summary Parameter"              length = $40
	TSPARM      label = "Parameter Value"                      length = $40
	TSVAL       label = "Parameter Value"                      length = $100
	TSVALNF     label = "Parameter Null Flavor"                length = $100
    TSVCDREF    label = "Name of the Reference Terminology"    length = $20
    ;
   set Final;
   keep STUDYID	DOMAIN TSSEQ TSPARMCD TSPARM TSVAL TSVALNF TSVCDREF
	;
run;
