/*create a libref called RAW pointing to the pathway under E drive*/
libname RAW "E://users/tiany";
/*proc import to import raw Tiral Arm(TA) data in excel to SAS*/
PROC IMPORT OUT= RAW.TA DATAFILE= "E://users/tiany/sdtm_raw.xlsx" 
            DBMS=xlsx REPLACE;
     SHEET="TA"; 
     GETNAMES=YES;
RUN;

data Final;
	set RAW.TA(rename=(STUDYID=STUDYID_ DOMAIN=DOMAIN_ ARMCD=ARMCD_ ARM=ARM_ TAETORD=TAETORD_
	ETCD=ETCD_ ELEMENT=ELEMENT_ TABRANCH=TABRANCH_ TATRANS=TATRANS_ EPOCH=EPOCH_)); 
	where DOMAIN_="TA";
	length STUDYID ARMCD $ 20 EPOCH $60. DOMAIN $2. ARM TABRANCH TATRANS $100. ETCD $8. ELEMENT $100.; 
	STUDYID=strip(STUDYID_);
	DOMAIN=strip(DOMAIN_);
	ARMCD=strip(ARMCD_);
	ARM=strip(ARM_);
	TAETORD=TAETORD_;	
	ETCD=strip(ETCD_);
	ELEMENT=strip(ELEMENT_);
	TABRANCH=strip(TABRANCH_);
	TATRANS=TATRANS_;
	EPOCH=strip(EPOCH_);
	format _all_;
	informat _all_;
run;

libname SDTM "E://users/tiany";
data SDTM.TA(label="Trial Arm");
   attrib
	STUDYID		label = "Study Identifier"                    length = $20
	DOMAIN		label = "Domain Abbreviation"                 length = $2
	ARM			label = "Description of Planned Arm"          length = $100
	ARMCD		label = "Planned Arm Code"                    length = $20
	TAETORD 	label = "Planned Order of Element within Arm" length = 8
	ETCD        label = "Element Code"                        length = $8
	ELEMENT     label = "Description of Element"              length = $100
	TABRANCH    label = "BRANCH"                              length = $100
	TATRANS     label = "Transition Rule"                     length = $100
	EPOCH       label = "Epoch"                               length = $60
;
  set Final;
   keep STUDYID	DOMAIN ARM ARMCD TAETORD ETCD ELEMENT TABRANCH TATRANS EPOCH 
	;
run;
