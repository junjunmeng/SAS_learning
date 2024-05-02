/*  Description::   Implementing RAR in practice
               Example 1 - Three Cohort Example (macroname - %threecohortexample)
               Example 2 - Two Cohort Sequential Example (macroname - %twocohortsequentialexample)
   Program::      ch10.7.2.sas
    Author::         Gaurav Sharma
    Date::        6/1/15
    Description:: Implementing RAR in practice (DBCD(gamma) targeting RSIHR allocation)(to address the Editor's last comment)
*/

/* Implementing RAR in practice - Start Defining Functions */
proc fcmp outlib = sasuser.RARseq.lib;

*DBCD allocation function;
function DBCD (rho, prop, gamma);
   return(rho*(rho/prop)**gamma/(rho*(rho/prop)**gamma + (1-rho)*((1-rho)/(1-prop))**gamma));
endsub;

run;

options cmplib = sasuser.RARseq;



/* Three Cohort Example: &n patients will be randomized into the trial, 
      1st cohort (&n1 patients) are randomized to E or C using PBD with block size 2*&m_0, responses generated from Bernoulli with &p_E or &p_C.  
      2nd cohort (&n2 patients) are randomized to E or C using DBCD (given data from Cohort 1), responses generated from Bernoulli with &p_E or &p_C
      3rd cohort (&n3 patients) are randomized to E or C using DBCD (given data from Cohorts 1 and 2)
      The value of gamma is kept fixed = 2.
*/
%macro threecohortexample(seed,n1,n2,n3, m_0, p_E, p_C);
%let n = %eval(&n1 + &n2 + &n3);

data example1;

seed=&seed;n=&n; m_0=&m_0; p_E=&p_E; p_C=&p_C;

*do it = 1 to &iters;
   array trt[&n]; array resp[&n]; array prod[&n]; array negprod[&n];

   do i = 1 to n;
      trt[i] = .; resp[i] = .; prod[i] = .; negprod[i] = .;
   end;

do i = 1 to &n;
/*Cohort 1*/
   if (i le &n1) then do;
      N_E = sum(of trt1-trt&n); N_C = i-1-N_E; unif = ranuni(seed);
      S_E=sum(of prod1-prod&n); S_C=sum(of negprod1-negprod&n);

      if i = 1 then do;
         N_E = 0; N_C = 0; S_E = 0; S_C = 0; *since N_E, N_C, S_E and S_C are missing for the first row replace it with 0;
      end;

      p_E_est=(S_E+.5)/(N_E+1);
      p_C_est=(S_C+.5)/(N_C+1);
      rho_est=sqrt(p_E_est)/(sqrt(p_E_est)+sqrt(p_C_est));

      pr = (m_0+m_0*floor((i-1)/2/m_0)-N_E)/(2*m_0+2*m_0*floor((i-1)/2/m_0)-(i-1));
      trt[i]=(unif<pr); trt_new = trt[i];
      resp[i]= RAND('BINOMIAL',trt[i]*p_E+(1-trt[i])*p_C,1); resp_new = resp[i];
      prod[i] = trt[i]*resp[i]; negprod[i] = (1-trt[i])*resp[i];
      prod_new = prod[i]; negprod_new = negprod[i];
   end;

/*Cohort 2*/
   if (i = &n1 + 1) then do;
   N_E = sum(of trt1-trt&n); N_C = i-1-N_E;
   S_E=sum(of prod1-prod&n); S_C=sum(of negprod1-negprod&n);

   p_E_est=(S_E+.5)/(N_E+1);
   p_C_est=(S_C+.5)/(N_C+1);
   rho_est=sqrt(p_E_est)/(sqrt(p_E_est)+sqrt(p_C_est));
   pr = DBCD(rho_est, N_E/(N_E+N_C),2);
   end;

   if (&n1+1 le i le &n1+&n2) then do;
      unif = ranuni(seed);
      trt[i]=(unif<pr); trt_new = trt[i];
      resp[i]= RAND('BINOMIAL',trt[i]*p_E+(1-trt[i])*p_C,1); resp_new = resp[i];
      prod[i] = trt[i]*resp[i]; negprod[i] = (1-trt[i])*resp[i];
      prod_new = prod[i]; negprod_new = negprod[i];
   end;

/*Cohort 3*/
   if (i = &n1 + &n2 + 1) then do;
   N_E = sum(of trt1-trt&n); N_C = i-1-N_E;
   S_E=sum(of prod1-prod&n); S_C=sum(of negprod1-negprod&n);

   p_E_est=(S_E+.5)/(N_E+1);
   p_C_est=(S_C+.5)/(N_C+1);
   rho_est=sqrt(p_E_est)/(sqrt(p_E_est)+sqrt(p_C_est));
   pr = DBCD(rho_est, N_E/(N_E+N_C),2);
   end;
   if (&n1+&n2+1 le i le &n1+&n2+&n3) then do;
      unif = ranuni(seed);
      trt[i]=(unif<pr); trt_new = trt[i];
      resp[i]= RAND('BINOMIAL',trt[i]*p_E+(1-trt[i])*p_C,1); resp_new = resp[i];
      prod[i] = trt[i]*resp[i]; negprod[i] = (1-trt[i])*resp[i];
      prod_new = prod[i]; negprod_new = negprod[i];

   end;
   output;

end;
*end; /*end iters loop*/

keep i trt_new resp_new prod_new negprod_new N_E N_C S_E S_C pr;
run;

title1 "Example 1";
footnote "Three Cohort Example: &n patients will be randomized into the trial, 
1st cohort (&n1 patients) are randomized to E or C using PBD with block size 2*&m_0, responses generated from Bernoulli with &p_E or &p_C.  
2nd cohort (&n2 patients) are randomized to E or C using DBCD (given data from Cohort 1), responses generated from Bernoulli with &p_E or &p_C.
3rd cohort (&n3 patients) are randomized to E or C using DBCD (given data from Cohorts 1 and 2)";

ods listing close;
ods rtf file="Threecohortexample.rtf" style=&rtfstyle;

proc report data=example1 split='|' headline center nowd;
  columns i pr trt_new;
  define i        / display "Sequence" center;
  define pr       / display "Probability" center;
  define trt_new     / display "Allocation" center;
run;

ods rtf close;
ods listing;
%mend;


/* Two Cohort Sequential Example: A total of &n1 + &n2 patients will be randomized into the trial as follows:
        1st cohort (&n1 patients) are randomized to E or C using PBD with block size 2*&m_0,
          their responses are generated from Bernoulli with &p_E or &p_C.
        After that, allocation is sequential: every patient is randomized to E or C using DBCD 
        (given data from all previous patients, assuming responses are instantaneous),
        and every patient's response is generated from Bernoulli with &p_E or &p_C
        (immediately after treatment is assigned)
      The value of gamma is kept fixed = 2.
*/

%macro twocohortsequentialexample(seed,n1,n2, m_0, p_E, p_C);
%let n = %eval(&n1 + &n2);

data example2;

seed=&seed;n=&n; m_0=&m_0; p_E=&p_E; p_C=&p_C;

*do it = 1 to &iters;
   array trt[&n]; array resp[&n]; array prod[&n]; array negprod[&n];

   do i = 1 to n;
      trt[i] = .; resp[i] = .; prod[i] = .; negprod[i] = .;
   end;

do i = 1 to &n;
/*Cohort 1*/
   if (i le &n1) then do;
      N_E = sum(of trt1-trt&n); N_C = i-1-N_E; unif = ranuni(seed);
      S_E=sum(of prod1-prod&n); S_C=sum(of negprod1-negprod&n);

      if i = 1 then do;
         N_E = 0; N_C = 0; S_E = 0; S_C = 0; *since N_E, N_C, S_E and S_C are missing for the first row replace it with 0;
      end;

      p_E_est=(S_E+.5)/(N_E+1);
      p_C_est=(S_C+.5)/(N_C+1);
      rho_est=sqrt(p_E_est)/(sqrt(p_E_est)+sqrt(p_C_est));

      pr = (m_0+m_0*floor((i-1)/2/m_0)-N_E)/(2*m_0+2*m_0*floor((i-1)/2/m_0)-(i-1));
      trt[i]=(unif<pr); trt_new = trt[i];
      resp[i]= RAND('BINOMIAL',trt[i]*p_E+(1-trt[i])*p_C,1); resp_new = resp[i];
      prod[i] = trt[i]*resp[i]; negprod[i] = (1-trt[i])*resp[i];
      prod_new = prod[i]; negprod_new = negprod[i];
   end;

/*Cohort 2*/
   if (&n1+1 le i le &n1+&n2) then do;
      N_E = sum(of trt1-trt&n); N_C = i-1-N_E;
      S_E=sum(of prod1-prod&n); S_C=sum(of negprod1-negprod&n);

      p_E_est=(S_E+.5)/(N_E+1);
      p_C_est=(S_C+.5)/(N_C+1);
      rho_est=sqrt(p_E_est)/(sqrt(p_E_est)+sqrt(p_C_est));
      pr = DBCD(rho_est, N_E/(N_E+N_C),2);

      unif = ranuni(seed);
      trt[i]=(unif<pr); trt_new = trt[i];
      resp[i]= RAND('BINOMIAL',trt[i]*p_E+(1-trt[i])*p_C,1); resp_new = resp[i];
      prod[i] = trt[i]*resp[i]; negprod[i] = (1-trt[i])*resp[i];
      prod_new = prod[i]; negprod_new = negprod[i];
   end;
   output;

end;
*end; /*end iters loop*/

keep i trt_new resp_new prod_new negprod_new N_E N_C S_E S_C pr;
run;

title1 "Example 2";
footnote "Two Cohort Sequential Example: A total of &n patients will be randomized into the trial as follows: 
1st cohort (&n1 patients) are randomized to E or C using PBD with block size 2*&m_0, responses generated from Bernoulli with &p_E or &p_C. 
After that, allocation is sequential: every patient is randomized to E or C using DBCD (given data from all previous patients, assuming responses are instantaneous), 
and every patients response is generated from Bernoulli with &p_E or &p_C (immediately after treatment is assigned)";
ods listing close;
ods rtf file="Twocohortsequentialexample.rtf" style=&rtfstyle;

proc report data=example2 split='|' headline center nowd;
  columns i pr trt_new;
  define i        / display "Sequence" center;
  define pr       / display "Probability" center;
  define trt_new     / display "Allocation" center;
run;

ods rtf close;
ods listing;
%mend;

/*CHANGEME - Design Parameters for Example 1 with three cohorts*/
%threecohortexample(seed=123,n1=20,n2=20,n3=20, m_0=2, p_E=.4, p_C=.2);
/*END CHANGEME*/

/*CHANGEME - Design Parameters for Example 2 with two cohorts*/
%twocohortsequentialexample(seed=123,n1=20,n2=40, m_0=2, p_E=.4, p_C=.2);
/*END CHANGEME*/





