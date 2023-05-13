*---------------------------------------------------------------*;
* AE.sas creates the SDTM AE dataset and saves it
* as permanent SAS datasets to the target libref.
*---------------------------------------------------------------*;
%include "C:common.sas";
 
**** CREATE EMPTY DM DATASET CALLED EMPTY_AE;
%make_empty_dataset(metadatafile=C:SDTM_METADATA.xls,dataset=AE)
 

**** DERIVE THE MAJORITY OF SDTM AE VARIABLES;
options missing = ' ';
data ae;
  set EMPTY_AE
  source.adverse(rename=(aerel=_aerel aesev=_aesev));

    studyid = 'XYZ123';
    domain = 'AE';
    usubjid = left(uniqueid);
    aeterm = left(aetext);
    aedecod = left(prefterm);
    aeptcd = left(ptcode);
    aellt = left(llterm);
    aelltcd = left(lltcode);
    aehlt = left(hlterm);
    aehltcd = left(hltcode);
    aehlgt = left(hlgterm);
    aehlgtcd = left(hlgtcod);
    aesoc = left(bodysys);
    aebodsys = aesoc;
    aebdsycd = left(soccode);
    aesoccd = aebdsycd;

    aesev = put(_aesev,aesev_adverse_aesev.);
    aeacn = put(aeaction,acn_adverse_aeaction.);
    aerel = put(_aerel,aerel_adverse_aerel.);
    aeser = put(serious,$ny_adverse_serious.);
    aestdtc = put(aestart,yymmdd10.);
    aeendtc = put(aeend,yymmdd10.);
    epoch = 'TREATMENT';
    if aeser = 'Y' then
      aeslife = 'Y';
run;

 
proc sort
  data=ae;
    by usubjid;
run;

**** CREATE SDTM STUDYDAY VARIABLES;
data ae;
  merge ae(in=inae) target.dm(keep=usubjid rfstdtc);
    by usubjid;

    if inae;

    %make_sdtm_dy(date=aestdtc); 
    %make_sdtm_dy(date=aeendtc); 
run;


**** CREATE SEQ VARIABLE;
proc sort
  data=ae;
    by studyid usubjid aedecod aestdtc aeendtc;
run;

data ae;
  retain &AEKEEPSTRING;
  set ae(drop=aeseq);
    by studyid usubjid aedecod aestdtc aeendtc;

    if not (first.aeendtc and last.aeendtc) then
      put "WARN" "ING: key variables do not define an unique record. " usubjid=;

    retain aeseq 0;
    aeseq = aeseq + 1;
		
    label aeseq = "Sequence Number";
run;



**** SORT AE ACCORDING TO METADATA AND SAVE PERMANENT DATASET;
%make_sort_order(metadatafile=C:SDTM_METADATA.xls,dataset=AE)


proc sort
  data=ae(keep = &AEKEEPSTRING)
  out=target.ae;
    by &AESORTSTRING;
run;
