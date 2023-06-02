*---------------------------------------------------------------*;
* TDM.sas creates the SDTM TA, TD, TE, TI, TS, and TV datasets and 
* saves them as a permanent SAS datasets to the target libref.
*---------------------------------------------------------------*;

options source;
**** define common SAS setings;
%include "C:common.sas";

 
**** CREATE EMPTY TA DATASET CALLED EMPTY_TA;
%make_empty_dataset(metadatafile=C:SDTM_metadata\SDTM_METADATA.xls,dataset=TA)

proc import 
  datafile="C:trialdesign.xls"
  out=ta 
  dbms=excelcs
  replace;
  sheet='TA';
run;

**** SET EMPTY DOMAIN WITH ACTUAL DATA;
data ta;
  set EMPTY_TA
      ta;
run;

**** SORT DOMAIN ACCORDING TO METADATA AND SAVE PERMANENT DATASET;
%make_sort_order(metadatafile=C:SDTM_METADATA.xls,dataset=TA)

proc sort
  data=ta(keep = &TAKEEPSTRING)
  out=target.ta;
    by &TASORTSTRING;
run;


**** CREATE EMPTY TD DATASET CALLED EMPTY_TD;
%make_empty_dataset(metadatafile=C:SDTM_METADATA.xls,dataset=TD)

proc import 
  datafile="C:trialdesign.xls"
  out=td
  dbms=excelcs
  replace;
  sheet='TD';
run;

**** SET EMPTY DOMAIN WITH ACTUAL DATA;
data td;
  set EMPTY_TD
      td;
run;

**** SORT DOMAIN ACCORDING TO METADATA AND SAVE PERMANENT DATASET;
%make_sort_order(metadatafile=C:SDTM_METADATA.xls,dataset=TD)

proc sort
  data=td(keep = &TDKEEPSTRING)
  out=target.td;
    by &TDSORTSTRING;
run;


**** CREATE EMPTY TE DATASET CALLED EMPTY_TE;
%make_empty_dataset(metadatafile=C:SDTM_METADATA.xls,dataset=TE)

proc import 
  datafile="C:trialdesign.xls"
  out=te
  dbms=excelcs
  replace;
  sheet='TE';
run;

**** SET EMPTY DOMAIN WITH ACTUAL DATA;
data te;
  set EMPTY_TE
      te;
run;

**** SORT DOMAIN ACCORDING TO METADATA AND SAVE PERMANENT DATASET;
%make_sort_order(metadatafile=C:SDTM_METADATA.xls,dataset=TE)

proc sort
  data=te(keep = &TEKEEPSTRING)
  out=target.te;
    by &TESORTSTRING;
run;



**** CREATE EMPTY TI DATASET CALLED EMPTY_TI;
%make_empty_dataset(metadatafile=C:SDTM_METADATA.xls,dataset=TI)

proc import 
  datafile="C:trialdesign.xls"
  out=ti 
  dbms=excelcs
  replace;
  sheet='TI';
run;

**** SET EMPTY DOMAIN WITH ACTUAL DATA;
data ti;
  set EMPTY_TI
      ti;
run;

**** SORT DOMAIN ACCORDING TO METADATA AND SAVE PERMANENT DATASET;
%make_sort_order(metadatafile=C:SDTM_METADATA.xls,dataset=TI)

proc sort
  data=ti(keep = &TIKEEPSTRING)
  out=target.ti;
    by &TISORTSTRING;
run;



**** CREATE EMPTY TS DATASET CALLED EMPTY_TS;
%make_empty_dataset(metadatafile=C:SDTM_METADATA.xls,dataset=TS)

proc import 
  datafile="C:trialdesign.xls"
  out=ts 
  dbms=excelcs
  replace;
  sheet='TS';
run;

**** SET EMPTY DOMAIN WITH ACTUAL DATA;
data ts;
  set EMPTY_TS
      ts;
run;

**** SORT DOMAIN ACCORDING TO METADATA AND SAVE PERMANENT DATASET;
%make_sort_order(metadatafile=C:SDTM_METADATA.xls,dataset=TS)

proc sort
  data=ts(keep = &TSKEEPSTRING)
  out=target.ts;
    by &TSSORTSTRING;
run;



**** CREATE EMPTY TV DATASET CALLED EMPTY_TV;
%make_empty_dataset(metadatafile=C:SDTM_METADATA.xls,dataset=TV)

proc import 
  datafile="C:trialdesign.xls"
  out=tv 
  dbms=excelcs
  replace;
  sheet='TV';
run;

**** SET EMPTY DOMAIN WITH ACTUAL DATA;
data tv;
  set EMPTY_TV
      tv;
run;

**** SORT DOMAIN ACCORDING TO METADATA AND SAVE PERMANENT DATASET;
%make_sort_order(metadatafile=C:SDTM_METADATA.xls,dataset=TV)

proc sort
  data=tv(keep = &TVKEEPSTRING)
  out=target.tv;
    by &TVSORTSTRING;
run;
