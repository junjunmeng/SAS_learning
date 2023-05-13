*--------------------------------------------------------------;
* Test/demonstrate the horizontalize macro with:
*   1) A TTE example with two types of PFS (PI and IRC) and OS 
*   2) A response confirmation example for AML
*
*--------------------------------------------------------------;

%include "..\macros\horizontalize.sas";

*------------------;
* TTE example;
*------------------;
libname library "g:\2nd-edition\programs\chapter10" extendobscounter=no;

data adtte;
  set library.adtte;
    where paramcd in('OS', 'PFS', 'PFS_PI');
    *paramcd = compress(paramcd,'_');
run;

options mprint ;*symbolgen mlogic;
%horizontalize(indata=adtte, 
               outdata=tte, 
               xposeby=paramcd, 
               carryonvars=adt cnsr evntdesc);
   
data library.ttex;
  set __temp;
  *drop visit visitnum param;
	format OS_adt PFS_adt PFS_PI_adt date9.;
run;

  

*------------------;
* ADLB example;
*------------------;
data adlb;
  set library.adlb;
    where paramcd in('PLATS', 'NEUTS', 'BLASTS') and avisitn in(1.28, 2.28);
    ady = 1;
    label ady = "Analysis Study Day"
          ;
run;

%horizontalize(indata=adlb, 
               outdata=adrsconf, 
               xposeby=paramcd avisitn, 
               carryonvars=adt ady,
               sortby=usubjid);
   
data __temp;
  set __temp;
        *keep usubjid avisit avisitn BLASTS BLASTS_adt BLASTS_ady NEUTS NEUTS_adt 
             NEUTS_ady PLATS PLATS_adt PLATS_ady;
        *format BLASTS_adt NEUTS_adt PLATS_adt date9.;
run;

data library.adrsconf;
  set __temp;
    *by usubjid avisitn;
	  
	  	*drop paramcd aval;
endsas;
	