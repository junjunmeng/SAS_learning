/*Begin writing SAS program merge SDTM.EG and ADAM.ADSL.sas*/
data ADEG1;
  merge SDTM.EG(in=a) ADAM.ADSL(in=b drop=STUDYID);
  by USUBJID;
  if a and b;
run;
/*Derive PARAM*/
proc sql;
    create table ADEG2 as select distinct EGTEST,EGORRESU from ADEG1 where EGORRESU ne '';
quit;
 
data ADEG3;
    length PARAM  $40;
    set ADEG2;
    PARAM=strip(EGTEST)||" ("||strip(EGORRESU)||")";
    keep EGTEST PARAM;
run;
 
proc sql;
/*Left Join PARAM from ADEG1 with ADEG3 when the same EGTEST*/
    create table ADEG4 as select a.*,b.PARAM from ADEG1 as a left join ADEG3 as b on a.EGTEST=b.EGTEST;
	/*Map USUBJID, EGTESTCD, and the number of USUBJID from ADEG4 to ADEG5*/
    create table ADEG5 as select USUBJID,EGTESTCD,count(USUBJID) as count from ADEG4 
     group by USUBJID,EGTESTCD;
	 /*Left Join ADEG4 with ADEG5 when the USUBJID and EGTESTCD are the same */
    create table ADEG6 as select a.*,b.count from ADEG4 as a left join ADEG5 as b 
    on a.USUBJID=b.USUBJID and a.EGTESTCD=b.EGTESTCD;
quit;
   
/*Derive DTYPE*/
data ADEG7;
	set ADEG6(where=(EGTESTCD^="INTP"));
	length DTYPE $20;
	EGSTRESN=input(EGSTRESC,best.);
	by USUBJID EGTESTCD;
	if first.EGTESTCD then do; SUM=EGSTRESN; N=1;end;
	else do ;SUM+EGSTRESN;N+1;end;
     output;
	if last.EGTESTCD then do; DTYPE="AVERAGE"; FLAG=1;output; end;
run;

/*Derive EGSTRESN and EGSTRESC*/

data ADEG8;
	set ADEG7;
	if DTYPE="AVERAGE" then do;
		if SUM ne . then do;
			EGSTRESN_MEAN=SUM/N;
			EGSTRESC=strip(put(EGSTRESN,best.));
		end;
		else  do;
		 EGSTRESN=.;
		 EGSTRESC="";
		end;
	end;
run;
/*Set ADEG8 and ADEG6 with EGTESTCD=”INTP”*/
data ADEG9;
  set ADEG8 ADEG6(where=(EGTESTCD="INTP"));
run;

/*Sort dataset ADEG9 by USUBJID, EGTESTCD, EGDTC */
proc sort data=ADEG9;
	by USUBJID EGTESTCD EGDTC;
run;
data ADEG10;
  set ADEG9;
 /*Derive ADT, ATM, ADTM */
  length PARAMCD $8. AVALC $40.;
    if length(EGDTC)=10 then do;ADT=input(EGDTC,yymmdd10.);ATM=.;ADTM=.;end;
	if length(EGDTC)>10 then do;ADTM=input(EGDTC,is8601dt.);ADT=datepart(ADTM);ATM=timepart(ADTM);end;
    format ADTM is8601dt. ADT yymmdd10. ATM time5.; 
  
 /*Derive ADY */
	if nmiss(ADT,TRTSDT)=0 then ADY=ADT-TRTSDT+(ADT>=TRTSDT);

   /*Derive APHASE,EMDESC*/
	if (ADT<=TRTSDT and ATM=.) or (ADT^=. and ATM^=. and ADTM<=TRT01SDTM) then do;
        APHASE="Screening";
		EMDESC="P";
	end;
	if (ADT > TRTSDT and ATM =.) or (ADT^=. and ATM^=. and ADTM>TRT01SDTM) then do;
	    APHASE="Treatment";
		EMDESC="T";
	 end;
	 if (ADT > TRTEDT and ATM =.) or (ADT^=. and ATM^=. and ADTM>TRT01EDTM) then do ;
	    APHASE="Follow-Up";
		EMDESC="A";
	end;

 /*Derive PARAMCD */
  if EGTEST='Interpretation' then PARAM=strip(EGTEST);   
  else PARAM=PARAM; 
  PARAMCD=strip(EGTESTCD);


/*Derive AVAL and AVALC */
    if PARAMCD^='INTP' and DTYPE='AVERAGE' then AVAL=EGSTRESN_MEAN;
	else if PARAMCD^='INTP' and DTYPE='' then AVAL=EGSTRESN;
	else if PARAMCD='INTP' then AVAL=.;
 
    if PARAMCD='INTP' then AVALC=strip(EGSTRESC);
	else if PARAMCD^='INTP' then AVALC='';

/*Derive TRTP, TRTA */
	TRTP=TRT01P; 
    TRTA=TRT01A; 
 
run;
/*Derive ABLFL */
data ADEG10;
  set ADEG10;
  NUMBER=_n_;
run;
/*Sort dataset ADEG10 by USUBJID, PARAMCD, ADT, ADTM, DTYPE */ 
proc sort data=ADEG10;
  by USUBJID PARAMCD ADT ADTM DTYPE;
run;
/*Filter the condition of baseline flag */
data BASE;
  set ADEG10(where=(EMDESC="P" and (AVAL ne . or AVALC ne '')  and (.<ADT<=TRTSDT) and COUNT>1));
  by USUBJID PARAMCD ADT ADTM DTYPE;
run;

 /*if the last PARAMCD then ABLFL sets to “Y” */ 
data ABLFL;
	set BASE;
	by USUBJID PARAMCD ADT ADTM DTYPE;
	if last.PARAMCD; ABLFL="Y";
run;
/*Left Join ADEG10 with ABLFL */
proc sql;
	create table ADEG11 as select a.*,b.ABLFL from ADEG10 as a left join ABLFL as b on a.NUMBER=b.NUMBER;
quit;
/*Derive variable Base */
proc sql;
	create table ADEG12 as select a.*,b.AVAL as BASE from ADEG11 as a
    left join ADEG11(where=(ABLFL='Y')) as b on a.USUBJID=b.USUBJID and a.PARAMCD=b.PARAMCD;
quit;
 /*Derive variable CHG*/
data ADEG13;
	set ADEG12;
    if n(AVAL,BASE)=2 and ABLFL ne "Y"  then CHG=AVAL-BASE;
	if ABLFL^="Y" and EMDESC="P" then do; CHG=.;end;
run;

/*Derive variable AVISIT and AVISITN*/
data ADEG14;
  set ADEG13;
  length AVISIT $40. AVISITN 8. ;

    if PARAMCD ne "INTP" then do;
        if ABLFL="Y" then do; 
         AVISIT="Baseline";
         AVISITN=0;
        end;

	else if index(VISIT,"FOLLOW-UP") then do; 
        AVISIT="Follow-up"; 
        AVISITN=100;
        end;
       else do;
	     AVISIT=strip(VISIT);
		 AVISITN=input(compress(AVISIT,,"kd"),best.);
	   end;
	end;
run;
/*Sort dataset ADEG14*/
proc sort data=ADEG14; by USUBJID PARAMCD ADT ATM DTYPE EGSEQ;run;
/*Derive ASEQ*/
data Final; 
   set ADEG14;
     by USUBJID PARAMCD ADT ATM DTYPE EGSEQ; 
     if first.USUBJID then ASEQ = 0;
     ASEQ+1;
  output;


run;


libname ADAM "E://users/tiany";
data ADAM.ADEG(label="ECG Test Results Analysis Datasets");
/*Assign variable attributes such as label and length to 
conform with ADAM.ADSL Specification 
(these will also be the same attributes as the ADAM IG).*/ 
   attrib
	STUDYID		label = "Study Identifier"                   length = $20
	USUBJID		label = "Unique Subject Identifier"          length = $40
	SUBJID		label = "Subject Identifier for the Study"   length = $20
	EGSEQ		label = "Sequence Number"                    length = 8
    ASEQ		label = "Analysis Sequence Number"           length = 8
	TRTP		label = "Planned Treatment"                  length = $40
	TRTA		label = "Actual Treatment"                   length = $40
	ADT			label = "Analysis Date"                      length = 8
	ATM		    label = "Analysis Time"                      length = 8
	ADTM		label = "Analysis Date and Time"             length = 8
	ADY		    label = "Analysis Relative Day"              length = 8
	AVISIT		label = "Analysis Visit"                    length = $40
	AVISITN     label = "Analysis Visit (N)"                length = 8
	APHASE      label = "PHASE"                             length = $40
	PARAM		label = "Parameter"                         length = $40
	PARAMCD		label = "Parameter Code"                   length = $8
	AVAL	    label = "Analysis Value"                    length = 8
	AVALC		label = "Analysis Value (C)"                length = $40
	ABLFL		label = "Baseline Record Flag"              length = $1
	BASE		label = "Baseline Value"                    length = 8
	CHG		    label = "Change from Baseline"              length = 8
	DTYPE 	    label = "Derivation Type"                   length = $20
	EMDESC      label = "Description of Treatment Emergent" length = $20
	EGORRES     label = "Result of Finding in Original Units" length = $100
    EGORRESU    label = "Original Units"                       length = $40
	EGSTRESC    label = "Character Result/ Finding in Std Format" length = $100
	VISIT       label = "Visit Name"                         length = $40
	VISITNUM    label = "Visit Number"                       length = 8
    EGDTC       label = "Date/Time of ECG"                   length = $40
	

	;
  set Final;
   keep STUDYID USUBJID SUBJID EGSEQ ASEQ TRTP TRTA ADT ATM ADTM ADY AVISIT AVISITN APHASE PARAM PARAMCD
        AVAL AVALC ABLFL BASE CHG DTYPE EMDESC EGORRES EGORRESU EGSTRESC VISIT VISITNUM EGDTC	
	;
run;
