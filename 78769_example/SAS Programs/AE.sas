/*create a libref called RAW pointing to the pathway under E drive*/
libname RAW "E://users/tiany";
/*proc import to import raw Adverse Events(AE) data in excel to SAS*/
PROC IMPORT OUT= RAW.AE DATAFILE= "E://users/tiany/sdtm_raw.xlsx" 
            DBMS=xlsx REPLACE;
     SHEET="AE"; 
     GETNAMES=YES;
RUN;
/*Begin writing SAS program ae.sas*/
/*show structure of the raw AE dataset*/
proc contents data=RAW.AE;
run;
/*Assign the character value from “Mild”, “Moderate” and “Severe” to character value “1”, “2” and “3” for variable AETOXGR with Proc Format*/
proc format;
 value $AETOXGR
 "Mild"="1"
 "Moderate"="2"
 "Severe"="3"
;
quit;

data AE1;
/*Specify length for standard variables*/
  length STUDYID AESTDTC AEENDTC AEBODSYS $20 
         DOMAIN AESER AESCONG AESDISAB AESDTH AESHOSP AESMIE AETOXGR $2 
         USUBJID AEENRTPT AEENTPT $40 
         AELLTCD AEPTCD AEHLTCD AEHLGTCD 8 
         AETERM AEDECOD AEHLT AEHLGT $200 
         AELLT $100
		 AEACN AEREL AEOUT $50;
   set RAW.AE(rename=(AETERM=AETERM_ AEACN=AEACN_ AESER=AESER_ AEREL=AEREL_ AEOUT=AEOUT_ AESCONG=AESCONG_ 
                      AESDISAB=AESDISAB_ AESDTH=AESDTH_ AESHOSP=AESHOSP_ AESMIE=AESMIE_));
   DOMAIN="AE";
   STUDYID="ABC-001";
   USUBJID=STRIP(STUDYID)||"-"||STRIP(SITEID)||"-"||STRIP(SUBJID); 
   /*Derive AETERM, AELLT, AELLTCD, AEDECOD , AEPTCD , AEHLT , AEHLTCD , AEHLGT , AEHLGTCD , AEBODSYS , AEACN , AEOUT*/
   AETERM=strip(upcase(AETERM_));
   AELLT=strip(upcase(LLT));
   AELLTCD=LLTCD;
   AEDECOD=strip(upcase(PT));
   AEPTCD=PT_CD;
   AEHLT=strip(upcase(HLT));
   AEHLTCD=HLTCD;
   AEHLGT=strip(upcase(HLGT));
   AEHLGTCD=HLGTCD;
   AEBODSYS=strip(upcase(SOC));
   AEACN=strip(upcase(AEACN_));
   AEOUT=strip(upcase(AEOUT_));
   /*Derive AESER, AESCONG, AESDISAB, AESDTH, AESHOSP, AESMIE */
   if AESER_="Yes" then AESER="Y";
     else if AESER_="No" then AESER="N";
   if AEREL_="Yes" then AEREL="Y";
     else if AEREL_="No" then AEREL="N";

   if AESCONG_="Yes" then AESCONG="Y";
     else if AESCONG_="No" then AESCONG="N";
   if AESDISAB_="Yes" then AESDISAB="Y";
     else if AESDISAB_="No" then AESDISAB="N";
   if AESDTH_="Yes" then AESDTH="Y";
     else if AESDTH_="No" then AESDTH="N";
   if AESHOSP_="Yes" then AESHOSP="Y";
     else if AESHOSP_="No" then AESHOSP="N";
   if AESMIE_="Yes" then AESMIE="Y";
     else if AESMIE_="No" then AESMIE="N";
	 /*Format AETOXGR, AESTDTC, AEENDTC */
   AETOXGR=put(AESEV, AETOXGR.);
   AESTDTC=put(AESDAT,yymmdd10.);
   AEENDTC=put(AEENDAT,yymmdd10.);
   /*Derive AEENRTPT*/
   if missing(AEENDTC) and AEOUT = "NOT RECOVERED OR NOT RESOLVED" then AEENRTPT = "ONGOING";
     else if missing(AEENDTC) and AEOUT = "UNKNOWN" then AEENRTPT = "UNKNOWN";
   if AEENRTPT in("ONGOING", "UNKNOWN") then AEENTPT = "END OF STUDY";
   keep STUDYID AESTDTC AEENDTC DOMAIN AESER AESCONG AESDISAB AESDTH AESHOSP AEBODSYS
        USUBJID AEENRTPT AEENTPT AELLTCD AEPTCD AEHLTCD AEHLGTCD AETERM AEDECOD AEHLT AEHLGT 
        AELLT AEACN AEREL AEOUT AETOXGR AESMIE ;
 run;
 /*Sort dataset AE1 by USUBJID, AESTDTC, AEENDTC, AETERM */
 proc sort data=AE1 out=AE2;
   by USUBJID AESTDTC AEENDTC AETERM;
 run;
 /*Derive AESEQ*/
 data FINAL;
   set AE2;
   by USUBJID AESTDTC AEENDTC AETERM;
   if FIRST.USUBJID then AESEQ=0;
   AESEQ+1;
   output;
   format _all_;
   informat _all_;
run;
libname SDTM "E://users/tiany";
data SDTM.AE(label="Adverse Event");
/*Assign variable attributes such as label and length to conform with SDTM.AE Specification 
(these will also be the same attributes as the SDMT IG).*/
   attrib
	STUDYID  label = "Study Identifier"                        length = $20
	DOMAIN   label = "Domain Abbreviation"                     length = $2
	USUBJID  label = "Unique Subject Identifier"               length = $40
	AESEQ	 label = "Sequence Number"                         length = 8
	AETERM   label = "Reported Term for the Adverse Event"     length = $200
	AELLT    label = "Lowest Level Term"                       length = $100
	AELLTCD  label = "Lowest Level Term Code"                  length = 8
	AEDECOD  label = "Dictionary-Derived Term"                 length = $200
	AEPTCD   label = "Preferred Term Code"                     length = 8
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
	AESHOSP  label = "Requires or Prolongs Hospitalization"    length = $2
	AESMIE   label = "Other Medically Important Serious Event" length = $2
	AETOXGR  label = "Standard Toxicity Grade"                 length = $2
	AESTDTC  label = "Start Date/Time of Adverse Event"        length = $20
	AEENDTC  label = "End Date/Time of Adverse Event"          length = $20
    AEENRTPT label = "End Relative to Reference Time Point"    length = $40
	AEENTPT  label = "End Reference Time Point"                length = $40

	;
   set FINAL;
	;
run;



