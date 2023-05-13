/******************************************************************
This is part of the SAS macro fCRM.sas

Created by Ruitao Lin and Guosheng Yin on January 5, 2015
*******************************************************************/
submit;
Proc lifetest data=survivaldata outsurv=survivalcurve NOPRINT;
   time Time*DLT(0);
run;
endsubmit;