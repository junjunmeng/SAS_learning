/*  Description::   Section 2: Optimal allocation
   Program::      ch10.2.sas
    Author::         Gaurav Sharma
    Date::        2/23/15
    Description:: This program reproduces Table 1 and Figure 1 of the paper
*/

/* Section 2: Optimal allocation - Start Defining Functions */

proc fcmp outlib = sasuser.ch2.lib;

* functions to compute Weighted Optimal allocation (Baldi Antognini and Giovagnoli, 2010 Biometrika);
function g (rho, p_E, p_C, w);
   q_E=1-p_E; q_C=1-p_C;
   r=p_C*q_C/p_E/q_E;
   return(w/(1-w)*(p_E-p_C)/min(q_E,q_C)*(sqrt(r)+1)**2-((r-1)*rho**2+2*rho-1)/rho**2/(1-rho)**2);
endsub;


function WO (p_E, p_C, w);
N = 1; c = .5; a = .001; b = .999;
do while ((abs(g(c, p_E, p_C, w))<.001) or (N <= 10));
c = (a + b)/2; * new midpoint;
  N = N + 1; * increment step counter;
  if (sign(g (c, p_E, p_C, w)) = sign(g (a, p_E, p_C, w))) then a = c;
   else b = c; * new interval;
end;
return(c);
endsub;



* Allocation proportion for a given design;
function prop (p_E, p_C, alloc$);
   if alloc='balanced' then p=1/2;
   if alloc='two' then p=2/3;
   if alloc='Neyman' then p=sqrt(p_E*(1-p_E))/(sqrt(p_E*(1-p_E))+sqrt(p_C*(1-p_C)));
   if alloc='RSIHR' then p=sqrt(p_E)/(sqrt(p_E)+sqrt(p_C));
   if alloc='score' then do;
      if p_E ne p_C then p=(p_E-2*p_C+sqrt(p_E**2-p_E*p_C+p_C**2))/3/(p_E-p_C);
      else p=1/2;
      end;
   if alloc='WO' then p=WO (p_E, p_C, 1/2);
   return(p);
endsub;

* Treatment failures;
function failures (p_E, p_C, rho, n);
   return(n*(rho*(1-p_E)+(1-rho)*(1-p_C)));
endsub;

* Power of the Wald test;
function pow (p_E, p_C, n, rho, alpha);
   d=(p_E-p_C)/sqrt(p_E*(1-p_E)/rho/n + p_C*(1-p_C)/(1-rho)/n);
   return(1-cdf('NORMAL',quantile('NORMAL',1-alpha/2)-d) + cdf('NORMAL',-quantile('NORMAL',1-alpha/2)-d));
endsub;

run;
/* Section 2: Optimal allocation - Finish Defining Functions*/

options cmplib = sasuser.ch2;

* Figure 1;
data simul;


p_C = 0.4;
do i = 1 to 71;
   p_E = 0.19+i*.01;

   pr_Neyman=prop(p_E, p_C, 'Neyman');
   pr_RSIHR=prop(p_E, p_C, 'RSIHR');
   pr_score=prop(p_E, p_C, 'score');
   pr_WO=prop(p_E, p_C, 'WO');
   pr_bal=prop(p_E, p_C, 'balanced');
   pr_uneq=prop(p_E, p_C, 'two');

   f_Neyman=failures(p_E, p_C, pr_Neyman, 100);
   f_RSIHR=failures(p_E, p_C, pr_RSIHR, 100);
   f_score=failures(p_E, p_C, pr_score, 100);
   f_WO=failures(p_E, p_C, pr_WO, 100);
   f_bal=failures(p_E, p_C, pr_bal, 100);
   f_uneq=failures(p_E, p_C, pr_uneq, 100);

   pow_Neyman=pow(p_E, p_C, 100, pr_Neyman, .05);
   pow_RSIHR=pow(p_E, p_C, 100, pr_RSIHR, .05);
   pow_score=pow(p_E, p_C, 100, pr_score, .05);
   pow_WO=pow(p_E, p_C, 100, pr_WO, .05);
   pow_bal=pow(p_E, p_C, 100, pr_bal, .05);
   pow_uneq=pow(p_E, p_C, 100, pr_uneq, .05);
   output;
end;
   drop i;
run;

ods rtf file="Figure1.rtf" style=&rtfstyle startpage=never;

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
Title 'Figure 1';

column title_text;                                                                                                                    
  define title_text / noprint;
run;  
title;

proc sgplot data=simul;
   series x=p_E y=pr_Neyman /lineattrs=(color=black pattern=1 thickness=3) legendlabel = "Neyman" name= "pred1";
   series x=p_E y=pr_RSIHR /lineattrs=(color=black pattern=2 thickness=3) legendlabel = "RSIHR" name= "pred2";
   series x=p_E y=pr_score /lineattrs=(color=black pattern=20 thickness=3) legendlabel = "Score" name= "pred3";
   series x=p_E y=pr_WO /lineattrs=(color=black pattern=24 thickness=3) legendlabel = "Compound Optimal (w=1/2)" name= "pred4";
   xaxis label = "Probability of success on E";
   yaxis label = "Allocation proportion to E";
   title1 "Allocation proportion to E";
   title2 "(Probability of success on C =0.40)";
   keylegend "pred1" "pred2" "pred3" "pred4";
run;
quit;

ods rtf close;
ods listing;

/*Table 1*/
data simul1;
   set simul;
   *where p_E in (0.2, 0.5, 0.6, 0.7, 0.8);
   a1 = put(pow_bal,4.2)|| " " || COMPRESS("(" ||put(f_bal,3.)||")");
   a2 = put(pow_uneq,4.2)|| " " || COMPRESS("(" ||put(f_uneq,3.)||")");
   a3 = put(pow_Neyman,4.2)|| " " || COMPRESS("(" ||put(f_Neyman,3.)||")");
   a4 = put(pow_RSIHR,4.2)|| " " || COMPRESS("(" ||put(f_RSIHR,3.)||")");
   a5 = put(pow_score,4.2)|| " " || COMPRESS("(" ||put(f_score,3.)||")");
   a6 = put(pow_WO,4.2)|| " " || COMPRESS("(" ||put(f_WO,3.)||")");
run;


title1 "Table 1";
footnote;
ods escapechar='^';

ods listing close;
ods rtf file="Table1.rtf" style=&rtfstyle;

proc report data=simul1 split='|' headline center nowd;
  columns p_E p_C a1 a2 a3 a4 a5 a6;

  define p_E   / display center "p^{sub E}";
  define p_C   / display center "p^{sub C}";
  define a1    / display "1:1" center;
  define a2    / display "2:1" center;
  define a3    / display "Neyman" center;
  define a4    / display "RSIHR" center;
  define a5    / display "Score" center;
  define a6    / display "Compound optimal (w = 1/2)" center;
run;

ods rtf close;
ods listing;
