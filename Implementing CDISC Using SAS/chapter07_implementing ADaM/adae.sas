*---------------------------------------------------------------*;
* ADAE.sas creates the ADaM ADAE-structured data set
* for AE data (ADAE), saved to the ADaM libref.
*---------------------------------------------------------------*;

%include "setup.sas";


**** CREATE EMPTY ADAE DATASET CALLED EMPTY_ADAE;
options mprint ;*symbolgen;
%let metadatafile=&path/chapter07/adam_metadata.xlsx;
%make_empty_dataset(metadatafile=&metadatafile,dataset=ADAE)


proc sort
  data = adam.adsl
  (keep = usubjid siteid country age agegr1 agegr1n sex race trtsdt trt01a trt01an saffl)
  out = adsl;
    by usubjid;
    
data adae;
  length relgr1 $15.;
  merge sdtm.ae (in = inae) adsl (in = inadsl);
    by usubjid ;
    
        if inae and not inadsl then
          put 'PROB' 'LEM: Subject missing from ADSL?-- ' usubjid= inae= inadsl= ;
        
        rename trt01a    = trta
               trt01an   = trtan
        ;               
        if inadsl and inae;
        
        %dtc2dt(aestdtc, prefix=ast, refdt=trtsdt);
        %dtc2dt(aeendtc, prefix=aen, refdt=trtsdt);

        if index(AEDECOD, 'PAIN')>0 or AEDECOD='HEADACHE' then
          CQ01NAM = 'PAIN EVENT';
        else
          CQ01NAM = '          ';
          
        aereln = input(put(aerel, $aereln.), best.);
        aesevn = input(put(aesev, $aesevn.), best.);
        relgr1n = (aereln>0); ** group related events (AERELN>0);
        relgr1  = put(relgr1n, relgr1n.);
        
        * Event is considered treatment emergent if it started on or after ;
        * the treatment start date.  Assume treatment emergent if the start;
        * date is missing (and the end date is either also missing or on or;
        *  after the treatment start date)                                 ;
        trtemfl = put((astdt>=trtsdt or (astdt<=.z  and not(.z<aendt<trtsdt))), _0n1y.);
        if astdt>=trtsdt then
          trtemfl = 'Y';
        format astdt aendt yymmdd10.;
run;

** assign variable order and labels;
data adae;
  retain &adaeKEEPSTRING;
  set EMPTY_adae adae;
run;

**** SORT adae ACCORDING TO METADATA AND SAVE PERMANENT DATASET;
%make_sort_order(metadatafile=&metadatafile, dataset=ADAE)

proc sort
  data=adae(keep = &adaeKEEPSTRING)
  out=adam.adae;
    by &adaeSORTSTRING;
run;        

