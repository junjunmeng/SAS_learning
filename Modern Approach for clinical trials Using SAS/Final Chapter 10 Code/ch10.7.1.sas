/*  Description::   Section 7: Redesigning a clinical trial (Connor et al, 1994)
   Program::      ch10.7.1.sas
    Author::         Gaurav Sharma
    Date::        2/23/15
    Description:: This program should reproduce Table 5 of the paper (seed is to be fixed)
               Change the design parameter below, SEE "CHANGEME" below (after the macro rand_seq is defined)
*/

/* Section 7: Redesigning a clinical trial (Connor et al, 1994) - Start Defining Functions */

proc fcmp outlib = sasuser.ch7.lib;

*Randomization probability for ERADE;
function pr_ERADE (alpha, rho, prop);
   return(alpha*rho*(prop>rho) + rho*(prop=rho) + (1-alpha*(1-rho))*(prop<rho));
endsub;

*Weighted Optimality allocation;
function g (rho, p_E, p_C, w);
   q_E=1-p_E; q_C=1-p_C;
   r=p_C*q_C/p_E/q_E;
   return(w/(1-w)*(p_E-p_C)/min(q_E,q_C)*(sqrt(r)+1)**2-((r-1)*rho**2+2*rho-1)/rho**2/(1-rho)**2);
endsub;

function rho_WO (p_E, p_C, w);
   N = 1; c = .5; a = .001; b = .999;
   do while ((abs(g(c, p_E, p_C, w))<.001) or (N <= 10));
   c = (a + b)/2; * new midpoint;
     N = N + 1; * increment step counter;
     if (sign(g (c, p_E, p_C, w)) = sign(g (a, p_E, p_C, w))) then a = c;
      else b = c; * new interval;
   end;
   return(c);
endsub;

*Neyman allocation;
function rho_Neyman(p_E, p_C);
   return( sqrt(p_E*(1-p_E))/(sqrt(p_E*(1-p_E))+sqrt(p_C*(1-p_C))));
endsub; 

*RSIHR allocation;
function rho_RSIHR(p_E, p_C);
   return( sqrt(p_E)/(sqrt(p_E)+sqrt(p_C)));
endsub; 

run;
/* Section 7: Redesigning a clinical trial (Connor et al, 1994) - Finish Defining Functions*/

options cmplib = sasuser.ch7;

%macro rand_seq(design, n, m_0, p_E, p_C, gamma, alpha,iters,out);

data simul;
   seed = &seed; n=&n; m_0=&m_0; p_E=&p_E; p_C=&p_C; alpha=&alpha; design = "&design";

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

   if design = "CRD" then pr = 1/2;
   else if design = "PBD" then pr = (m_0+m_0*floor((i-1)/2/m_0)-N_E)/(2*m_0+2*m_0*floor((i-1)/2/m_0)-(i-1));
   else if design = "RSIHR" then do;
      rho_est=rho_RSIHR(p_E_est, p_C_est);
      if (i<=2*m_0) then pr = (m_0-N_E)/(2*m_0-(i-1));
      else pr=pr_ERADE(alpha, rho_est, N_E/(N_E+N_C));
   end;
   else do;
      rho_est=rho_WO(p_E_est, p_C_est,1/2);
      if (i<=2*m_0) then pr=(m_0-N_E)/(2*m_0-(i-1));
      else pr=pr_ERADE(alpha, rho_est, N_E/(N_E+N_C));
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


/*CHANGEME - parameters of the design*/
%let seed = 123;
%let p_E = .917;
%let p_C = .745;
%rand_seq(CRD, n=477, m_0=2, p_E=&p_E, p_C=&p_C, alpha=.5,iters=10000,out=CRD);
%rand_seq(PBD, n=477, m_0=2, p_E=&p_E, p_C=&p_C, alpha=.5,iters=10000,out=PBD);
%rand_seq(RSIHR, n=477, m_0=2, p_E=&p_E, p_C=&p_C, alpha=.5,iters=10000,out=RSIHR);
%rand_seq(WO, n=477, m_0=2, p_E=&p_E, p_C=&p_C, alpha=.5,iters=10000,out=WO);
/*END CHANGEME*/

data all;
   set pbd crd rsihr wo;
run;

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
   'a1' = "Allocation proportion for E - Mean (SD)"
   'a2' = "Number on E - Mean (SD)"
   'a3' = "Number on E - Min-Max"
   'a4' = "Treatment Failures - Mean (SD)"
   'a5' = "Treatment Failures - Min-Max"
   'a6' = "Parameter Estimate (p_E) - Mean (SD)"
   'a7' = "Parameter Estimate (p_E) - MSE"
   'a8' = "Parameter Estimate (p_C)- Mean (SD)"
   'a9' = "Parameter Estimate (p_C)- MSE"
   'a91' = "Estimated Treatment Difference - Mean (SD)"
   'a92' = "Estimated Treatment Difference - MSE"
   ;
run;

%macro summary(p_E,p_C);
data summ1;
   set summ;
   a1 = put(prop_mean,4.3)|| " " || COMPRESS("(" ||put(prop_sd,4.3)||")");
   a2 = put(N_E_mean,6.2)|| " " || COMPRESS("(" ||put(N_E_sd,6.2)||")");
   a3 = COMPRESS(put(N_E_min,3.)|| "-" || put(N_E_max,3.));

   a4 = put(F_mean,6.2)|| " " || COMPRESS("(" ||put(F_sd,6.2)||")");
   a5 = COMPRESS(put(F_min,3.)|| "-" || put(F_max,3.));

   a6 = put(p_E_est_mean,6.4)|| " " || COMPRESS("(" ||put(p_E_est_sd,6.4)||")");
   a7 = put((p_E_est_mean - (&p_E))**2 + p_E_est_sd**2,6.4);

   a8 = put(p_C_est_mean,6.4)|| " " || COMPRESS("(" ||put(p_C_est_sd,6.4)||")");
   a9 = put((p_C_est_mean - (&p_C))**2 + p_C_est_sd**2,6.4);

   a91 = put(diff_est_mean,6.4)|| " " || COMPRESS("(" ||put(diff_est_sd,6.4)||")");
   a92 = put((diff_est_mean - (&p_E-&p_C))**2 + diff_est_sd**2,6.4);


run;

proc transpose data = summ1 out=summ2;
   by out;
   var a1 a2 a3 a4 a5 a6 a7 a8 a9 a91 a92;
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

title1 "Table 5";
footnote;

ods listing close;
ods rtf file="Table5.rtf" style=&rtfstyle;

proc report data=summ3 split='|' headline center nowd;
  columns _NAME_ pbd crd rsihr wo;
  format _NAME_ $rowf.;
  define _NAME_      / display '' center order=internal left style(header)=[just=center];
  define pbd   / display center;
  define crd   / display center;
  define rsihr    / display center;
  define wo    / display "Compound Optimal" center;
run;

ods rtf close;
ods listing;


