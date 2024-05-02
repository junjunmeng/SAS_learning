/*  Description::   Section 4.1: Simulating a single RAR procedure
   Program::      ch10.4.1.sas
    Author::         Gaurav Sharma
    Date::        2/23/15
    Description:: This program should reproduce Table 2 of the paper (seed is to be fixed)
               Change the design parameter below, SEE "CHANGEME" below
*/

/*START CHANGEME - Design parameters*/
%let seed = 123;  *Fix the seed here;
%let n = 40;   *number of patients;
%let m_0=5;    *Trial starts with randomizing 2*m_0 patients (m_0 is some small positive integer;
%let p_E=.7;   *Probability of Success on E;
%let p_C=.4;   *Probability of Success on C;
/*END CHANGEME*/


/* Section 4.1: Simulating a single RAR procedure - Start Defining Functions */
proc fcmp outlib = sasuser.ch41.lib;

*DBCD allocation function;
function DBCD (rho, prop, gamma);
   return(rho*(rho/prop)**gamma/(rho*(rho/prop)**gamma + (1-rho)*((1-rho)/(1-prop))**gamma));
endsub;

run;
/* Section 4.1: Simulating a single RAR procedure - Finish Defining Functions*/

options cmplib = sasuser.ch41;

*Table 2;
data simul;
retain i N_E N_C S_E S_C p_E_est p_C_est rho_est pr trt_new resp_new;
   seed = &seed; n = &n; m_0=&m_0; p_E=&p_E; p_C=&p_C;
   array trt[&n]; array resp[&n]; array prod[&n]; array negprod[&n];
do i = 1 to n;
   N_E = sum(of trt1-trt&n); N_C = i-1-N_E; unif = ranuni(seed);
   if i = 1 then do;
      N_E = 0; N_C = 0; *since N_E and N_C are missing for the first row replace it with 0;
   end;
   if (i<=2*m_0) then do; *Balanced permuted block randomization; 
      pr=(m_0-N_E)/(2*m_0-(i-1));
      trt[i]=(unif<pr); trt_new = trt[i];
   end;
   else do; *Response-adaptive randomization; 
      S_E=sum(of prod1-prod&n);
      S_C=sum(of negprod1-negprod&n);
      p_E_est=(S_E+.5)/(N_E+1);
      p_C_est=(S_C+.5)/(N_C+1);
      rho_est=sqrt(p_E_est)/(sqrt(p_E_est)+sqrt(p_C_est));
      pr=DBCD(rho_est,N_E/i,2);
      trt[i]=(unif<pr); trt_new = trt[i];
   end;
   resp[i]= RAND('BINOMIAL',trt[i]*p_E+(1-trt[i])*p_C,1); resp_new = resp[i];
   prod[i] = trt[i]*resp[i]; negprod[i] = (1-trt[i])*resp[i];
   output;
end;
keep i N_E N_C S_E S_C p_E_est p_C_est rho_est pr trt_new resp_new;
run;


title1 "Table 2";
footnote;
ods escapechar='^';


ods listing close;
ods rtf file="Table2.rtf" style=&rtfstyle;

proc report data=simul split='|' headline center nowd;
  columns i N_E N_C S_E S_C p_E_est p_C_est rho_est pr trt_new resp_new;
  define i     / display center "Patient";
  define N_E   / display center "N^{sub E,m-1}";
  define N_C   / display center "N^{sub C,m-1}";
  define S_E   / display center "S^{sub E,m-1}";
  define S_C   / display center "S^{sub C,m-1}";
  define p_E_est     / display center format=4.2 "p^{sub E,m-1}";
  define p_C_est     / display center format=4.2 "p^{sub C,m-1}";
  define rho_est     / display center format=4.2 "^{unicode 03C1}^{sub m-1}";
  define pr    / display center format=4.2 "^{unicode 03A6}^{sub m,E}";
  define trt_new     / display center "^{unicode 03B4}^{sub m}";
  define resp_new    / display center "Y^{sub m}";
run;

ods rtf close;
ods listing;
