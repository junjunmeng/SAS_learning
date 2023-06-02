*---------------------------------------------------------------*;
* ADTTE.sas creates the ADaM BDS-structured data set
* for a time-to-event analysis (ADTTE), saved to the ADaM libref.
*---------------------------------------------------------------*;

%include "setup.sas";

**** CREATE EMPTY ADTTE DATASET CALLED EMPTY_ADTTE;
options mprint ;*symbolgen;
%let metadatafile=&path/chapter07/adam_metadata.xlsx;
%make_empty_dataset(metadatafile=&metadatafile, dataset=ADTTE)

proc sort
  data = adam.adsl
  (keep = studyid usubjid siteid country age agegr1 agegr1n sex race randdt trt01p trt01pn 
          ittfl trtedt)
  out = adtte;
    by usubjid;
    
proc sort
  data = adam.adef
  (keep = usubjid paramcd chg adt visitnum xpseq)
  out = adef;
    where paramcd='XPPAIN' and visitnum>0 and abs(chg)>0;
    by usubjid adt;
    
data adef;
  set adef;
    by usubjid adt;
    
        drop paramcd visitnum;
        if first.usubjid;
run;
            
proc sort
  data = adam.adae
  (keep = usubjid cq01nam astdt trtemfl aeseq)
  out = adae;
    where cq01nam ne '' and trtemfl='Y';
    by usubjid astdt;
run;

** keep only the first occurence of a pain event;
data adae;
  set adae;
    by usubjid astdt;
    
        if first.usubjid;
run;        

** get the sequence number for the last EX record;
proc sort
  data = sdtm.ex
  (keep = usubjid exseq)
  out = lstex
  nodupkey;
    by usubjid exseq;

data lstex;
  set lstex;
    by usubjid exseq;
    	if last.usubjid;

data adtte;
  merge adtte (in = inadtte rename=(randdt=startdt)) 
        adef  (in = inadef) 
        adae  (in = inadae) 
        lstex (in = inlstex)
        ;
    by usubjid ;
    
        retain param "Time to first pain relief (days)" 
               paramcd "TTPNRELF"
        ;
        rename trt01p    = trtp
               trt01pn   = trtpn
        ;               

        length srcvar $10. srcdom $4.;

        if (.<chg<0) and (adt<astdt or not inadae) then
          do;
            cnsr = 0;
            adt  = adt;
            evntdesc = put(cnsr, evntdesc.) ;
            srcdom = 'ADEF';
            srcvar = 'XPDY';
            srcseq = xpseq;
          end;
        else if chg>0 and (adt<astdt or not inadae) then
          do;
            cnsr = 1;
            adt  = adt;
            evntdesc = put(cnsr, evntdesc.) ;
            srcdom = 'XP';
            srcvar = 'XPDY';
            srcseq = xpseq;
          end;
        else if (.<astdt<adt) then
          do;
            cnsr = 2;
            adt  = astdt;
            evntdesc = put(cnsr, evntdesc.) ;
            srcdom = 'ADAE';
            srcvar = 'ASTDY';
            srcseq = aeseq;
          end;
        else 
          do;
            cnsr = 3;    
            adt  = trtedt;
            evntdesc = put(cnsr, evntdesc.) ;
            srcdom = 'ADSL';
            srcvar = 'TRTEDT';
            srcseq = .;
          end;

        aval = adt - startdt + 1;
        
        format startdt adt yymmdd10.;
run;

** assign variable order and labels;
data adtte;
  retain &adtteKEEPSTRING;
  set EMPTY_adtte adtte;
run;

**** SORT adtte ACCORDING TO METADATA AND SAVE PERMANENT DATASET;
%make_sort_order(metadatafile=&metadatafile, dataset=ADTTE)

proc sort
  data=adtte(keep = &adtteKEEPSTRING)
  out=adam.adtte;
    by &adtteSORTSTRING;
run;        

