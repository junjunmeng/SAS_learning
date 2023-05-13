/**********************************************************************************************
 * This macro is used to calculate the Bayesian type I error and power under the general      *
 * Bayesian survival meta-experimental design setting.                                        *
 *                                                                                            *
 * 1. Historical Data sets                                                                    *
 * K: trial ID;                                                                               *
 * y: total subject year duration;                                                            *
 * v: total number of censoring events;                                                       *
 * x: treatment indicator (0=control arm, 1=experimental arm);                                *
 *                                                                                            *
 * 2. Current Data sets                                                                       *
 * K: trial ID;                                                                               *
 * n: total number of samples;                                                                *
 * p: proportion in control arm or treatment arm;                                             *
 * r: annualized event rates;                                                                 *
 * TD: trial duration;                                                                        *
 * TA: accrual time;                                                                          *
 *                                                                                            *
 * 3. Variables                                                                               *
 * N_curr: the number of current studies;                                                     *
 * N_hist: the number of historical studies;                                                  *
 * delta: prespecified non-inferiority design margin;                                         *
 * eta0: user choice Bayesian credible level;                                                 *
 * NMCS: the number of markov chain monte carlo (MCMC) samples;                               *
 * nbi: the number of burn-in samples in each simulation;                                     *
 * a0: a discounting paramter;                                                                *
 * REP: the total number of simulation dataset;                                               *
 * sigma0: initial variance of the parameter gamma0;                                          *
 * sigma1: initial variance of the parameter gamma1;                                          *
 * tau0: initial variances of theta_0k in historical datasets;                                *
 * tau:  initial variances of theta_k in current datasets;                                    *
 * SEEDGEN: initial seed number;                                                              *
 * OUTPUT: name of the output text file (rtf);                                                *
 *                                                                                            *
 * Written by Yeongjin Gwon under supervision of Ming-Hui Chen, May 8, 2015                   *
 **********************************************************************************************/

%macro BSMED(hist,curr,delta,eta0,NMCS,nbi,a0,REP,sigma0,sigma1,tau0,tau,SEEDGEN,OUTPUT);

/* Checking error message for parameters and the number of simulation */
%if (&delta<0 or &delta=) %then %do;
  %put ERROR: Invalid design value or missing for delta;
  %return;
%end;
%if (&eta0<0 or &eta0>1.00 or &eta0=) %then %do;
  %put ERROR: Invalid design value or missing for eta0;
  %return;
%end;
%if (&a0<0 or &a0>1.00 or &a0=) %then %do;
  %put ERROR: Invalid value or missing for discounting parameter a0;
  %return;
%end;
%if (&sigma0<=0 or &sigma0=) %then %do;
  %put ERROR: Invalid value or missing for sigma0;
  %return;
%end;
%if (&sigma1<=0 or &sigma1=) %then %do;
  %put ERROR: Invalid value or missing for sigma1;
  %return;
%end;
%if (&tau0<=0 or &tau0=) %then %do;
  %put ERROR: Invalid value or missing for tau0;
  %return;
%end;
%if (&tau<=0 or &tau=) %then %do;
  %put ERROR: Invalid value or missing for tau;
  %return;
%end;
%if (&NMCS<=0 or &NMCS= or &nbi<0 or &nbi= or &REP<=0 or &REP=) %then %do;
  %put ERROR: Invalid the value or missing for simulation;
  %return;
%end;

/* Error Checking: Input data and variables */
%if &hist ^= %then %do;
  proc contents data=&hist noprint out=histout order=VARNUM;
  run;

  proc sql noprint;
    select count(*) into :ncol_hist
      from histout;
  quit;

  %if &ncol_hist<4 or &ncol_hist>4 %then %do;
    %put ERROR: Wrong number of Input Variables in historical data;
    %return;
  %end;

  proc sql noprint;
    select NAME into :var1 
      from histout where (VARNUM=1);
    select NAME into :var2
      from histout where (VARNUM=2);
    select NAME into :var3
      from histout where (VARNUM=3);
    select NAME into :var4
      from histout where (VARNUM=4);
  quit;

  %if &var1 ^= K %then %do;
    %put ERROR: Invalid input variable for historical data;
    %return;
  %end; 
  %if &var2 ^= y %then %do;
    %put ERROR: Invalid input variable for total year subject duration;
    %return;
  %end; 
  %if &var3 ^= v %then %do;
    %put ERROR: Invalid input variable for total number of events;
    %return;
  %end; 
  %if &var4 ^= x %then %do;
    %put ERROR: Invalid input variable for trial arms;
    %return;
  %end; 
%end;

proc contents data=&curr noprint out=currout order=VARNUM;
run;

proc sql noprint;
  select count(*) into :ncol_curr
    from currout;
quit;

%if &ncol_curr<6 or &ncol_curr>6 %then %do;
  %put ERROR: Wrong number of Input Variables for current data;
  %return;
%end;

proc sql noprint;
  select NAME into :var1 
     from currout where (VARNUM=1);
  select NAME into :var2
     from currout where (VARNUM=2);
  select NAME into :var3
     from currout where (VARNUM=3);
  select NAME into :var4
     from currout where (VARNUM=4);
  select NAME into :var5
     from currout where (VARNUM=5);
  select NAME into :var6
     from currout where (VARNUM=6);
quit;

%if &var1 ^= K %then %do;
  %put ERROR: Invalid input variable for current studies;
  %return;
%end; 
%if &var2 ^= n %then %do;
  %put ERROR: Invalid input variable for the number of sample sizes;
  %return;
%end; 
%if &var3 ^= p %then %do;
  %put ERROR: Invalid input variable for the proprotion of subjects;
  %return;
%end; 
%if &var4 ^= r %then %do;
  %put ERROR: Invalid input variable for annualized event rates in control arm;
  %return;
%end; 
%if &var5 ^= TA %then %do;
  %put ERROR: Invalid input variable for trial accrual times;
  %return;
%end; 
%if &var6 ^= TD %then %do;
  %put ERROR: Invalid input variable for trial duration;
  %return;
%end; 

/* Generate sets of seed numbers */
data seeds;
   retain seed;
   seed=&SEEDGEN; 
   do is=0 to 1;
     do im = 1 to &REP;
       call ranuni(seed,X1);
      seedv1=seed;
       call ranuni(seed,X1);
      seedv2=seed;
       output;
     end;
   end;
   keep is im seedv1 seedv2;
run;

/* Checking error message for HIST and CURR data */

%if (&hist= or &hist=hist1 or &hist=hist2 or &hist=hist3 or &hist=hist4 or &hist=hist5) %then %do;
  %if (&curr=curr or &curr=curr1) %then %do;
    data inputcurr;
      set &curr;
     group = "curr";
    run;

    proc univariate data=inputcurr noprint;
     var K;
    output out=outcurr max=Kmax;
    run;

    data _null_;
      set outcurr;
       %global N_curr;
      call symput("N_curr",left(put(Kmax,8.)));
    run;
  %end;
  %else %do;
    %put ERROR: Invalid input data;
   %return;
  %end;

  %if &hist ^= %then %do;
    data hist_experiment;
     set &hist;
     group = "hist";
     keep K y v x group;
    run;

    proc univariate data=hist_experiment noprint;
     var K;
    output out=outhist max=Kmax;
    run;

    data _null_;
      set outhist;
        %global N_hist;
      call symput("N_hist",left(put(Kmax,8.)));
    run;
  %end;

  data current_null;
   set inputcurr;
   gamma0=log(-log(1-r));
  run;

  proc means data=current_null mean noprint;
   var gamma0;
   output out=sumcurrent(keep=g0mean) mean=g0mean;
  run;

  data current_null;
    set current_null;
    if _n_=1 then set sumcurrent;
  run;

  data current_null(drop=gamma0);
   set current_null;
   tk=0;
   if K<=&N_curr then tk=log(-log(1-r))-g0mean;
  run;

  data current_new;
   set current_null;
    n1=int(p*n);
   n2=n-n1;
   p1=p;
   p2=1-p;
   if n1>0 then x=0; output;
    if n2>0 then x=1; output;
  run;

  data current_new (drop=n1 n2 p1 p2);
   set current_new;
   if x=0 then do;
      n=n1; p=p1;
   end;
   if x=1 then do;
      n=n2; p=p2;
   end;
  run;
%end;
%else %do;
  %put ERROR: Invalid Input data names;
  %return;
%end;

/* Reproduce input data and design values */
data design;
   delta=&delta;     /* Design margin */
   a0=&a0;           /* Power parameter */
   eta0=&eta0;       /* User defined Credible Level */
   sigma0=&sigma0;      /* Initial Variance of Gamma0 */ 
   sigma1=&sigma1;      /* Initial Variance of Gamma1 */
   tau0=&tau0;       /* Initial Variance of theta_0k */  
   tau =&tau;        /* Initial Variance of theta_k */
run;

%do s=0 %to 1;
   data current&s;
      set current_new;
      gamma0=g0mean;
      if &s=0 then do;
         gamma1=log(&delta);
         end;
      else do;
         gamma1=0;
      end;
      theta_k=tk;
      lambda=exp(gamma0+gamma1*x+theta_k);      /* Mean of failure time */
   run;
%end;

%do s=0 %to 1;
  %do m=1 %to &REP;
   data seedsm;
    set seeds;
     if is=&s and im=&m;
   run;

   data _null_;
     set seedsm;
      %global seedg;
      %global seedmc;
    call symput("seedg",left(put(seedv1,best16.)));
    call symput("seedmc",left(put(seedv2,best16.)));
   run;
 
   data current_sim;
      set current&s;
         y=0;
         v=0;
         call streaminit(&seedg);
         do i=1 to n;
            yi= -log(RAND('UNIFORM'))/lambda ;  /* Generate a sample from EXP(lambda)*/
            if TA=0 then do;
                  TAi=0;
            end;
            else do;
                  TAi=RAND('UNIFORM')*TA;          /* Generate Accural Times */
               end;
                ci=TD-TAi;          
            if yi<=ci then do;
               vi=1;
                timei=yi;
            end;
            else do;
               vi=0;
               timei=ci;
            end;
            y=y+timei;
            v=v+vi;
         end;
      output;
      keep K x y v group;     
      run;

      %if (&hist ^= and &a0>0 and &a0<=1) %then %do;
         data newdata;
         set current_sim hist_experiment;
         run;
      %end;
      %else %do;
         data newdata;
         set current_sim;
         run;
      %end;

      proc sort data=newdata out=sort_newdata;
         by group K x;
      run;

      ods graphics on;
      ods exclude all;
      proc mcmc data=sort_newdata outpost=postout nmc=&NMCS nbi=&nbi seed=&seedmc MAXTUNE=30 
                  plots=none statistics=none diagnostics=none;
        %if (&hist ^= and &a0>0.00 and &a0<=1.00) %then %do;
           %if &N_hist > 1 %then %do; 
                array theta_h[%eval(&N_hist-1)];
              %end;
           %if &N_curr > 1 %then %do;
             array theta_c[%eval(&N_curr-1)];
              %end;
        %end;
        %if (&hist= or &a0=0.00) %then %do;
          %if &N_curr > 1 %then %do;
             array theta_c[%eval(&N_curr-1)];
            %end;
        %end;
          %if (&hist ^= and &a0>0.00 and &a0<=1.00) %then %do;
          %if &N_hist > 1 %then %do;
            parms theta_h: 0;
            %end;
          %else %do;    /* deal with N_hist=1 */
            parms theta_h 0;
          %end;
          %if &N_curr > 1 %then %do;
            parms theta_c: 0;
          %end;
          %else %do;    /* deal with N_curr=1 */
            parms theta_c 0;
          %end;
        %end;
        %if (&hist= or &a0=0.00) %then %do;
          %if &N_curr > 1 %then %do;
            parms theta_c: 0;
          %end;
          %else %do;    /* deal with N_curr=1 */
            parms theta_c 0;
          %end;
        %end;

         parms gamma0 gamma1;
         prior gamma0   ~ n(0,var=&sigma0);
         prior gamma1   ~ n(0,var=&sigma1);

            %if (&hist ^= and &a0>0.00 and &a0<=1.00) %then %do;
           %if &N_hist > 1 %then %do;
             prior theta_h: ~ n(0,var=&tau0);
           %end;
           %else %do;   /* deal with N_hist=1 */
             prior theta_h ~ n(0,var=&tau0);
           %end;
              %if &N_curr > 1 %then %do;
                prior theta_c: ~ n(0,var=&tau);
              %end;
           %else %do;      /* deal with N_curr=1 */
                prior theta_c ~ n(0,var=&tau);
           %end;
         %end;
         %if (&hist= or &a0=0.00) %then %do;
              %if &N_curr > 1 %then %do;
                prior theta_c: ~ n(0,var=&tau);
              %end;
           %else %do;      /* deal with N_curr=1 */
                prior theta_c ~ n(0,var=&tau);
           %end;
         %end;

         begincnst;
            discounta0=&a0;
         endcnst;
 
         tk=0;
            %if (&hist ^= and &a0>0.00 and &a0<=1.00) %then %do;   /* for the group = "hist" */
            %if (&N_hist > 1 and &N_curr > 1) %then %do;
              if group eq "hist" then do;
                  if K < &N_hist then tk=theta_h[K];
               else do;
                 tk=0;
                 do j=1 to %eval(&N_hist-1);
                   tk=tk-theta_h[j];
                 end;
               end;
              end;
                 else do;        /* for the group = "curr" */
               if K < &N_curr then tk=theta_c[K];
                  else do;
                    tk=0;
                    do j = 1 to %eval(&N_curr-1);
                      tk=tk-theta_c[j];
                    end;
                  end;
              end;
             %end;
                %if (&N_hist > 1 and &N_curr = 1) %then %do;
              if group eq "hist" then do;
                  if K < &N_hist then tk=theta_h[K];
               else do;
                 tk=0;
                 do j=1 to %eval(&N_hist-1);
                   tk=tk-theta_h[j];
                 end;
               end;
              end;
              else do;
                tk=theta_c;
              end;
             %end;
            %if (&N_hist = 1 and &N_curr = 1) %then %do;
              if group eq "hist" then do;
                  tk=theta_h;
              end;
              else do;
                tk=theta_c;
              end;
            %end;
            %if (&N_hist = 1 and &N_curr > 1) %then %do;
              if group eq "hist" then do;
                  tk=theta_h;
              end;
              else do;
                if K < &N_curr then tk=theta_c[K];
                    else do;
                      tk=0;
                      do j = 1 to %eval(&N_curr-1);
                        tk=tk-theta_c[j];
                      end;
                    end;
              end;
                  %end;
            %end;
         %if (&hist= or &a0=0.00) %then %do;
           discounta0=0;
           %if &N_curr > 1 %then %do;
            if K < &N_curr then tk=theta_c[K];
               else do;
                 tk=0;
                 do j = 1 to %eval(&N_curr-1);
                   tk=tk-theta_c[j];
                 end;
               end;
           %end;
           %else %do;
            tk=theta_c;
           %end;
            %end;

         regmean=gamma0+gamma1*x+tk;
         loglik=v*regmean-exp(regmean)*y;
         if (group eq "hist") then do;
            loglik=discounta0*loglik;
         end;
         model general(loglik);
      run;
      ods graphics off;

/* Calculation of Type I error and Power */
      data indicator(keep=proportion);
         set postout;
      proportion=(exp(gamma1)<&delta);
      run;

/* Get the proportion of exp(gamma1)<delta from the posterior sample of gamma1 */
      proc means data=indicator n mean noprint;
         var proportion;
         output out=outpower mean=pfhat;
      run;

      data outpower;
         set outpower;
         simid=&m;
         keep simid pfhat;
      run;

      %if &m=1 %then %do;
         data proportion&s;
            set outpower;
         run;
      %end;
      %else %do;
         data proportion&s;
               set proportion&s outpower;
         run;
      %end;
   %end;
%end;

/* Obtain Bayesian Power based on defalut level and user defined level */
data Type1Error;
   set proportion0;
   keep pfhat BP1 BP2 BP3 BP4;
   BP1=0;BP2=0;BP3=0;BP4=0;
   if pfhat>=0.90  then BP1=1;            /* Defalut Bayesian Credible Level 0.90 */
   if pfhat>=0.95  then BP2=1;            /* Defalut Bayesian Credible Level 0.95 */
   if pfhat>=0.975 then BP3=1;            /* Defalut Bayesian Credible Level 0.975 */
   if pfhat>=&eta0 then BP4=1;            /* Defalut Bayesian Credible Level 0.96 */
run;

data CURRENT;
   set &curr;
   TF=TD-TA;
run;

data BayesianPower;
   set proportion1;
   keep pfhat BP1 BP2 BP3 BP4;
   BP1=0;BP2=0;BP3=0;BP4=0;
   if pfhat>=0.90  then BP1=1;            /* Defalut Bayesian Credible Level 0.90 */
   if pfhat>=0.95  then BP2=1;            /* Defalut Bayesian Credible Level 0.95 */
   if pfhat>=0.975 then BP3=1;            /* Defalut Bayesian Credible Level 0.975 */
   if pfhat>=&eta0  then BP4=1;        /* Defalut Bayesian Credible Level 0.96 */
run;

ods select all;
%if &output = %then %do;
   ods rtf file="BSMED_Output&a0..rtf" startpage=now;
%end;
%if &output ^= %then %do;
   ods rtf file="&output..rtf" startpage=now;
%end;
%if &hist ^= %then %do; 
   proc report data=hist_experiment nowd center split='|' headline headskip

      style(report)=[font_face='Times New Roman' font_size=11pt] 
      style(column)=[font_face='Times New Roman' font_size=11pt]
      style(lines) =[font_face='Times New Roman' font_size=11pt just=c font_weight=bold foreground=black background=GRAYB8];

      columns K y v x;
      define  K / "Trial ID"                    display;
      define  y / "Total subject year duration" display format=comma10.0;
      define  v / "Total number of events"      display;
      define  x / "Trial arm"                   display;
      title 'Reproducing Historical Data';

   run;
%end;

/* Reproducing Current Data */
proc report data=CURRENT nowd center split='|' headline headskip 

   style(report)=[font_face='Times New Roman' font_size=11pt] 
    style(column)=[font_face='Times New Roman' font_size=11pt]
    style(lines) =[font_face='Times New Roman' font_size=11pt just=c font_weight=bold foreground=black background=GRAYB8];

    columns K n p r TA TD TF;
   define  K  / "Trial ID"                          display;
   define  n  / "Total Sample Size"                         display format=comma10.0;
    define  p  / "Proportion in Control Arm"              display format=4.2;
    define  r  / "Annualized Event Rates in Control Arm"  display;
   define  TA / "Accrual Time"                         display;
    define  TD / "Trial Duration"                         display;
   define  TF / "Minimum Follow-up Time"                  display;
    title 'Reproducing Current Data';

run;

/* Output of Design Values and Initial Parameters */
proc report data=design nowd center split='|' headline headskip 

   style(report)=[font_face='Times New Roman' font_size=11pt] 
    style(column)=[font_face='Times New Roman' font_size=11pt]
    style(lines) =[font_face='Times New Roman' font_size=11pt just=c font_weight=bold foreground=black background=GRAYB8];

    columns delta a0 eta0 sigma0 sigma1 tau0 tau;
   define  delta / "Design Margin"                        display;
   define  a0 / "Discounting parameter a0"                display;
   define  eta0 / "User defined Bayesian Credible Level"    display;
   define  sigma0 / "Initial Variance of Gamma0"             display;
   define  sigma1 / "Initial Variance of Gamma1"              display;
   define  tau0 / "Initial Variance of theta_0k"             display;
   define  tau / "Initial Variance of theta_k"             display;
    title 'Design Values and Initial Prior Parameters';

run;

proc report data=Type1Error nowd center split='|' headline headskip 

   style(report)=[font_face='Times New Roman' font_size=11pt] 
    style(column)=[font_face='Times New Roman' font_size=11pt]
    style(lines) =[font_face='Times New Roman' font_size=11pt just=c font_weight=bold foreground=black background=GRAYB8];

    columns BP1 BP2 BP3 BP4;
    define  BP1 / "Type I with Bayesian Credible Level 0.90"           mean format=6.4;
   define  BP2 / "Type I with Bayesian Credible Level 0.95"           mean format=6.4;
   define  BP3 / "Type I with Bayesian Credible Level 0.975"         mean format=6.4;
   define  BP4 / "Type I with Bayesian Credible Level &eta0."        mean format=6.4;
    title "Type I Error for the Bayesian Meta-survival Design with &REP simulated datasets";

run;

proc report data=BayesianPower nowd center split='|' headline headskip 

   style(report)=[font_face='Times New Roman' font_size=11pt] 
    style(column)=[font_face='Times New Roman' font_size=11pt]
    style(lines) =[font_face='Times New Roman' font_size=11pt just=c font_weight=bold foreground=black background=GRAYB8];

    columns BP1 BP2 BP3 BP4;
    define  BP1 / "Power with Bayesian Credible Level 0.90"           mean format=6.4;
   define  BP2 / "Power with Bayesian Credible Level 0.95"           mean format=6.4;
   define  BP3 / "Power with Bayesian Credible Level 0.975"         mean format=6.4;
   define  BP4 / "Power with Bayesian Credible Level &eta0."         mean format=6.4;
    title "Power for the Bayesian Meta-survival Design with &REP simulated datasets";

run;
ods rtf close;
%mend BSMED;

