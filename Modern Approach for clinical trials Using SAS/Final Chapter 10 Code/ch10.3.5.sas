/*  Description::   Section 3.5: Asymptotic variance of three RAR procedures
   Program::      ch10.3.5.sas
    Author::         Gaurav Sharma
    Date::        2/23/15
    Description:: This program should reproduce Figure 2 of the paper 
*/

proc fcmp outlib = sasuser.ch35.lib;

*Lower Bound for the asymptotic variance for RSIHR allocation;
function LB (p_E, p_C);
   q_E=1-p_E; q_C=1-p_C;
   return(1/4/(sqrt(p_E)+sqrt(p_C))**3*(p_C*q_E/sqrt(p_E)+p_E*q_C/sqrt(p_C)));
endsub;

*Asymptotic variance of DBCD for RSIHR allocation;
function var_DBCD (p_E, p_C, gamma);
   return(sqrt(p_E*p_C)/(sqrt(p_E)+sqrt(p_C))**2/(1+2*gamma) + 2*(1+gamma)/(1+2*gamma)*LB(p_E,p_C));
endsub;

run;
/* Section 3.5: Asymptotic variance of three RAR procedures - Finish Defining Functions*/

options cmplib = sasuser.ch35;

*Figure 2;

data simul;

p_C = 0.4;
do i = 1 to 71;
   p_E = 0.19+i*.01;

   v_SMLE=var_DBCD(p_E, p_C, 0);
   v_DBCD=var_DBCD(p_E, p_C, 2);
   v_ERADE=LB(p_E, p_C);
   output;
end;
run;

ods rtf file="Figure2.rtf" style=&rtfstyle startpage=never;

goptions reset=all device=png hsize=8in vsize=10in
         xmax=20cm ymax=15cm
         xpixels=900 ypixels=900
         ftext='SAS Monospace'
         htext=3pct goutmode=replace ;
title;

data test;                                                                                                                              
 title_text="DO NOT PRINT";  
   output;                  
run; 

proc report data=test nowd noheader style(report)={frame=void outputwidth=100%};      
Title 'Figure 2';

column title_text;                                                                                                                    
  define title_text / noprint;
run;  
title;

proc sgplot data=simul;
   series x=p_E y=v_SMLE /lineattrs=(color=black pattern=1 thickness=3) legendlabel = "SMLE" name= "pred1";
   series x=p_E y=v_DBCD /lineattrs=(color=black pattern=2 thickness=3) legendlabel = "DBCD(gamma=2)" name= "pred2";
   series x=p_E y=v_ERADE /lineattrs=(color=black pattern=20 thickness=3) legendlabel = "ERADE" name= "pred3";
   xaxis label = "Probability of success on E";
   yaxis label = "Asymptotic variance" values=(0 to 1 by 0.2);
   title1 "Asymptotic variance of the sample proportion";
   title2 "(Probability of success on C =0.40)";
   keylegend "pred1" "pred2" "pred3";
run;
quit;


ods rtf close;
ods listing;
