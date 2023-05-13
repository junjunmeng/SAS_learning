** run all ADaM programs and then convert them to XPTs;
%let sasroot=%sysget(sasroot);
%let sysin = %sysfunc(getoption(sysin));
%let path=%substr(&sysin,1,%index(%upcase(&sysin),\CHAPTER07\)-1);
%let progpath=&path\chapter07\;
options xsync xwait nomstored extendobscounter=NO; *symbolgen;

x "'&sasroot/sas' &progpath/adsl.sas      -nosplash";
x "'&sasroot/sas' &progpath/adae.sas      -nosplash";
x "'&sasroot/sas' &progpath/adef.sas      -nosplash";
x "'&sasroot/sas' &progpath/adtte.sas      -nosplash";

%include "..\macros\xpt_macros.sas";
%let outdir=&path\chapter07\xpt;
%let  indir=&path\chapter07;
%toexp(&indir, &outdir);

** validate the data sets;
%include "..\macros\run_p21v.sas";
%run_p21v(type=ADaM, sources=&path\chapter07\xpt, files=*.xpt, define=N, ctdatadate=2014-09-26, make_bat=N);
