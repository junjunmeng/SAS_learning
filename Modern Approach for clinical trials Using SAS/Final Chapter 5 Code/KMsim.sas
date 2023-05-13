/******************************************************************
This is part of the SAS macro fCRMsim.sas

Created by Ruitao Lin and Guosheng Yin on January 5, 2015
*******************************************************************/

submit;
Proc lifetest data=survivaldata plots=none outsurv=survivalcurve NOPRINT;
   time timeyy*y(0);
run;
endsubmit;
