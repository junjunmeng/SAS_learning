/*  Description::   Section 4.2: Simulating operating characteristics of various randomization procedures
   Program::      ch10.4.2.sas
    Author::         Gaurav Sharma
    Date::        2/23/15
    Description:: This program should reproduce Figure 3 and Table 3 of the paper (seed is to be fixed)
               Change the design parameter below, SEE "CHANGEME" below (after the macro rand_seq is defined)
*/

/* Section 4.2: Simulating operating characteristics of various randomization procedures - Start Defining Functions*/

proc fcmp outlib = sasuser.ch42.lib;

*DBCD allocation function;
function pr_DBCD (gamma, rho, prop);
   return(rho*(rho/prop)**gamma/( rho*(rho/prop)**gamma + (1-rho)*((1-rho)/(1-prop))**gamma));
endsub;

*ERADE allocation function;
function pr_ERADE (alpha, rho, prop);
   return(alpha*rho*(prop>rho) + rho*(prop=rho) + (1-alpha*(1-rho))*(prop<rho));
endsub;

run;
/* Section 4.2: Simulating operating characteristics of various randomization procedures - Finish Defining Functions*/

options cmplib = sasuser.ch42;

%macro rand_seq(design, n, m_0, p_E, p_C, gamma, alpha,iters,out);

data simul;
   seed = &seed; n=&n; m_0=&m_0; p_E=&p_E; p_C=&p_C; gamma=&gamma; alpha=&alpha; design = "&design";

do it = 1 to &iters;
   array trt[&n]; array resp[&n]; array prod[&n]; array negprod[&n];

   do i = 1 to n;
      trt[i] = .; resp[i] = .; prod[i] = .; negprod[i] = .;
   end;

do i = 1 to n;
   N_E = sum(of trt1-trt&n); N_C = i-1-N_E; unif = ranuni(seed);
   S_E=sum(of prod1-prod&n); S_C=sum(of negprod1-negprod&n);

   if i = 1 then do;
      N_E = 0; N_C = 0; S_E = 0; S_C = 0; *since N_E, N_C, S_E and S_C are missing for the first row replace it with 0;
   end;

   p_E_est=(S_E+.5)/(N_E+1);
   p_C_est=(S_C+.5)/(N_C+1);
   rho_est=sqrt(p_E_est)/(sqrt(p_E_est)+sqrt(p_C_est));

   if design = "CRD" then pr = 1/2;
   else if design = "PBD" then pr = (m_0+m_0*floor((i-1)/2/m_0)-N_E)/(2*m_0+2*m_0*floor((i-1)/2/m_0)-(i-1));
   else if design = "ERADE" then do;
      if (i<=2*m_0) then pr = (m_0-N_E)/(2*m_0-(i-1));
      else pr=pr_ERADE(alpha, rho_est, N_E/(N_E+N_C));
   end;
   else do;
      if (i<=2*m_0) then pr=(m_0-N_E)/(2*m_0-(i-1));
      else pr = pr_DBCD(gamma, rho_est, N_E/(N_E+N_C));
   end;
   trt[i]=(unif<pr); trt_new = trt[i];
   resp[i]= RAND('BINOMIAL',trt[i]*p_E+(1-trt[i])*p_C,1); resp_new = resp[i];
   prod[i] = trt[i]*resp[i]; negprod[i] = (1-trt[i])*resp[i];
   prod_new = prod[i]; negprod_new = negprod[i];
   output;
end;

end;
keep it i trt_new resp_new prod_new negprod_new N_E N_C S_E S_C pr;
run;

data simul1;
   set simul;
   negtrt_new = 1-trt_new;
   negresp_new = 1-resp_new;
run;

proc summary data = simul1;
   by it;
   var trt_new negtrt_new resp_new negresp_new prod_new negprod_new;
   output out=&out sum(trt_new) = trt sum(negtrt_new) = negtrt sum(resp_new) = resp sum(negresp_new) = negresp  sum(prod_new) = prod sum(negprod_new) = negprod;
run;

data &out;
   length out $5;
   set &out;
   N_E = trt;
   N_C = negtrt;
   F = negresp;
   p_E_est = prod/trt;
   p_C_est = negprod/negtrt;
   pp = (p_E_est + p_C_est)/2;
   diff_est = p_E_est - p_C_est;
   reject = (abs(diff_est/sqrt(pp*(1-pp)*&n/N_E/N_C))>1.96);
   out = "&out";
   var = N_E/&n;
run;
%mend;

/*CHANGEME - Design Parameters */
%let seed = 123;
%let p_E = .7;
%let p_C = .4;
%rand_seq(CRD, n=120, m_0=20,p_E=&p_E, p_C=&p_C, gamma=2, alpha=.5,iters=10000,out=CRD);
%rand_seq(PBD, n=120, m_0=20, p_E=&p_E, p_C=&p_C, gamma=2, alpha=.5,iters=10000,out=PBD);
%rand_seq(ERADE, n=120, m_0=20, p_E=&p_E, p_C=&p_C, gamma=2, alpha=.5,iters=10000,out=ERADE);
%rand_seq(DBCD, n=120, m_0=20, p_E=&p_E, p_C=&p_C, gamma=0, alpha=.5,iters=10000,out=SMLE);
%rand_seq(DBCD, n=120, m_0=20, p_E=&p_E, p_C=&p_C, gamma=2, alpha=.5,iters=10000,out=DBCD);
/*END CHANGEME*/

data all;
   set pbd crd smle dbcd erade;
run;


ods rtf file="Figure3.rtf" style=&rtfstyle startpage=never;

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
Title 'Figure 3';

column title_text;                                                                                                                    
  define title_text / noprint;
run;  
title;

proc sgplot data=all;
   vbox var / category=out nofill;
   title1 "Allocation proportion (distribution)";
   xaxis display=(nolabel);
   yaxis display=(nolabel);
run;
quit;

ods rtf close;
ods listing;


proc sort data = all; by out it; run;
proc summary data = all;
   by out;
   var var;
   output out=summ mean(var) = prop_mean std(var)=prop_sd 
               mean(N_E) = N_E_mean  std(N_E)=N_E_sd  min(N_E) = N_E_min max(N_E)=N_E_max
               mean(F) = F_mean  std(F)=F_sd  min(F) = F_min max(F)=F_max
               mean(p_E_est) = p_E_est_mean  std(p_E_est)=p_E_est_sd
               mean(p_C_est) = p_C_est_mean  std(p_C_est)=p_C_est_sd
               mean(diff_est) = diff_est_mean  std(diff_est)=diff_est_sd
               mean(reject) = reject_mean 
;
run;

proc format;
   value $rowf
   'a1' = "Target allocation proportion for E"
   'a2' = "Number on E - Mean (SD)"
   'a3' = "Number on E - Min-Max"
   'a4' = "Treatment Failures - Mean (SD)"
   'a5' = "Treatment Failures - Min-Max"
   'a6' = "Estimated Treatment Difference - Mean (SD)"
   'a7' = "Estimated Treatment Difference - MSE"
   'a8' = "Average Power of the Wald Test"
   ;
run;

%macro summary(p_E,p_C);
data summ1;
   set summ;
   a1 = put(prop_mean,4.2);
   a2 = put(N_E_mean,4.2)|| " " || COMPRESS("(" ||put(N_E_sd,3.)||")");
   a3 = COMPRESS(put(N_E_min,3.)|| "-" || put(N_E_max,3.));

   a4 = put(F_mean,4.2)|| " " || COMPRESS("(" ||put(F_sd,3.)||")");
   a5 = COMPRESS(put(F_min,3.)|| "-" || put(F_max,3.));

   a6 = put(diff_est_mean,4.2)|| " " || COMPRESS("(" ||put(diff_est_sd,3.)||")");
   a7 = put((diff_est_mean - (&p_E-&p_C))**2 + diff_est_sd**2,6.4);
   a8 = put(reject_mean,4.2);
run;

proc transpose data = summ1 out=summ2;
   by out;
   var a1 a2 a3 a4 a5 a6 a7 a8;
run;

data summ2;
   set summ2;
   rowvar = substr(_NAME_,2,1);
run;

proc sort data = summ2; by rowvar _NAME_; run;
proc transpose data = summ2 out= summ3;
   by rowvar _NAME_;
   id out;
   var col1;
run;
%mend;

%summary(&p_E, &p_C);

title1 "Table 3";
footnote;

ods listing close;
ods rtf file="Table3.rtf" style=&rtfstyle;

proc report data=summ3 split='|' headline center nowd;
  columns _NAME_ pbd crd smle dbcd erade;
  format _NAME_ $rowf.;
  define _NAME_      / display '' center order=internal left style(header)=[just=center];
  define pbd   / display center;
  define crd   / display center;
  define smle     / display center;
  define dbcd     / display center;
  define erade / display center;
run;

ods rtf close;
ods listing;
