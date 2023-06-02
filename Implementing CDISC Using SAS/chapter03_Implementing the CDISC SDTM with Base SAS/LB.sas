*---------------------------------------------------------------*;
* LB.sas creates the SDTM LB dataset and saves it
* as a permanent SAS datasets to the target libref.
*---------------------------------------------------------------*;
%include "C:common.sas";


**** CREATE EMPTY DM DATASET CALLED EMPTY_LB;
%make_empty_dataset(metadatafile=C:SDTM_METADATA.xls,dataset=LB)
 

**** DERIVE THE MAJORITY OF SDTM LB VARIABLES;
options missing = ' ';
data lb;
  set EMPTY_LB
      source.labs; 

      studyid = 'XYZ123';
      domain = 'LB';
      usubjid = left(uniqueid);
      lbcat = put(labcat,$lbcat_labs_labcat.);
      lbtest = put(labtest,$lbtest_labs_labtest.);
      lbtestcd = put(labtest,$lbtestcd_labs_labtest.);
      lborres = left(put(nresult,best.));
      lborresu = left(colunits);
      lbornrlo = left(put(lownorm,best.));
      lbornrhi = left(put(highnorm,best.));

      **** create standardized results;
      lbstresc = lborres;
      lbstresn = nresult;
      lbstresu = lborresu;
      lbstnrlo = lownorm;
      lbstnrhi = highnorm;

      **** urine glucose adjustment;
      if lbtest = 'Glucose' and lbcat = 'URINALYSIS' then
        do;
          lborres = left(put(nresult,uringluc_labs_labtest.));
	  lbornrlo = left(put(lownorm,uringluc_labs_labtest.));
	  lbornrhi = left(put(highnorm,uringluc_labs_labtest.));
	  lbstresc = lborres;
	  lbstresn = .;
	  lbstnrlo = .;
	  lbstnrhi = .;
        end;

	if lbtestcd = 'GLUC' and lbcat = 'URINALYSIS' and lborres = 'POSITIVE' then
	  lbnrind = 'HIGH';
	else if lbtestcd = 'GLUC' and lbcat = 'URINALYSIS' and lborres = 'NEGATIVE' then
	  lbnrind = 'NORMAL';
	else if lbstnrlo ne . and lbstresn ne . and 
             round(lbstresn,.0000001) < round(lbstnrlo,.0000001) then
          lbnrind = 'LOW';
    else if lbstnrhi ne . and lbstresn ne . and 
            round(lbstresn,.0000001) > round(lbstnrhi,.0000001) then
      lbnrind = 'HIGH';
    else if lbstnrhi ne . and lbstresn ne . then
      lbnrind = 'NORMAL';

    visitnum = month;
    visit = put(month,visit_labs_month.);
    if visit = 'Baseline' then
      lbblfl = 'Y';
    else
      lbblfl = ' ';

    if visitnum < 0 then
      epoch = 'SCREENING';
    else
      epoch = 'TREATMENT';

    lbdtc = put(labdate,yymmdd10.); 
run;

 
proc sort
  data=lb;
    by usubjid;
run;

**** CREATE SDTM STUDYDAY VARIABLES;
data lb;
  merge lb(in=inlb) target.dm(keep=usubjid rfstdtc);
    by usubjid;

    if inlb;

    %make_sdtm_dy(date=lbdtc) 
run;


**** CREATE SEQ VARIABLE;
proc sort
  data=lb;
    by studyid usubjid lbcat lbtestcd visitnum;
run;

data lb;
  retain &LBKEEPSTRING;
  set lb(drop=lbseq);
    by studyid usubjid lbcat lbtestcd visitnum; 

    if not (first.visitnum and last.visitnum) then
      put "WARN" "ING: key variables do not define an unique record. " usubjid=;

    retain lbseq 0;
    lbseq = lbseq + 1;
		
    label lbseq = "Sequence Number";
run;


**** SORT LB ACCORDING TO METADATA AND SAVE PERMANENT DATASET;
%make_sort_order(metadatafile=C:SDTM_METADATA.xls,dataset=LB)

proc sort
  data=lb(keep = &LBKEEPSTRING)
  out=target.lb;
    by &LBSORTSTRING;
run;
