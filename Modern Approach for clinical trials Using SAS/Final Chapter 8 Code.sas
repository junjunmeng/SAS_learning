*** 8.1 ***;

%macro conemaxsim(ntrt=,r0=,r1=,r2=,r3=,r4=,r5=,r6=,r7=,r8=,npergrp=,pdrop=,seed=);
   data sims (keep = subject treatment dose response);
      format treatment $8.;
      subject = 0;
      %do trt = 0 %to &ntrt;
         do i = 1 to &npergrp;
            subject = subject + 1;
            if &trt = 0 then do;
               treatment = "Placebo";
               dose = 0;
            end;
            else do;
               treatment = "Active";
               dose = 3**(&trt -1);
            end;
            response = 0.35*rannor(floor(&seed)) + &&r&trt;
            dropout = ranbin(floor(&seed), 1, &pdrop);
            if dropout = 0 then output;
         end;
      %end;
   run;
  
   proc sort data = sims; 
      by dose;
   run;

   proc means data = sims;
      var response;
      output out=sumstat mean=mean sum = sum n=n std=sd; 
      by dose;   
   run;

   data sumstat(keep = mean dose n sd);
      set sumstat;
   run;
%mend;

%conemaxsim(ntrt=5, r0=0.02, r1=0.075, r2=.10, r3=.16, r4=.20, r5=.25, npergrp=75, pdrop=.10, seed=35123);

*** 8.2 ***;

/** Proc MCMC syntax sets the dataset to output posterior summaries , sets
number of monte carlo iterations along with the seed, parameters to monitor,
plots to monitor autocorrelation and thining ***/

proc mcmc data = sims outpost = emax_out nmc = 50000 nbi = 1000 seed = 3746
   monitor = (_parms_ var_subj std_subj ed50 lned50)
   nthin = 3 stats(percent=2.5 5 10 15 50 75 95 97.5) dic;
   ods output PostSummaries=summaries PostIntervals=intervals;
   parm e0 emax tau lned50; /** sets parameters **/
   /** Setting prior for each parameter ***/
   prior e0~normal(mean=0, precision=10);
   prior emax~normal(mean=0.20, precision=10);
   prior tau ~gamma(shape=0.001, scale=0.001);
   prior lned50 ~normal(mean=0.69, precision=0.4);
   beginnodata;
      /** Setting residual variance ***/
      var_subj = 1/tau;
      std_subj = sqrt(var_subj);
      /** Ed50 ***/
      ed50 = exp(lned50);
      /** Calculating the posterior predictive distribution ***/
      Preddist outpred=predout nsim=5000 covariates=Sumstat;
   endnodata;
   mu = e0 + (emax*dose)/(ed50 + dose);
   model response ~ normal(mean=mu, precision=tau );
   title;
run;

*** 8.3 ***;

%conemaxsim(ntrt=5, r0=0.02, r1=0.075, r2=.10, r3=.16, r4=.20, r5=.25, npergrp=100,pdrop=.10,seed=9865);

proc mcmc data = sims outpost = emax_out nmc = 80000 nbi = 1000 seed = 3746
monitor = (_parms_ var_subj std_subj ed50) nthin =3 stats(percent=2.5 5 10 15 50 95 97.5) dic;
ods output PostSummaries=summaries PostIntervals=intervals;
   parm e0 emax tau  ed50; /** sets parameters **/
   /** Setting prior for each parameter ***/
   prior e0 ~normal(mean=0, precision=.01);
   prior emax ~normal(mean=0.15, precision=1);
   prior tau ~ gamma(shape=0.001, scale=0.001); 
   prior ed50 ~ uniform(0, 20);
   beginnodata; 
      /** Setting residual variance ***/
      var_subj = 1/tau;
      std_subj = sqrt(var_subj);
      /** Calculating mean for each dose ***/
      Preddist outpred=predout nsim=5000 covariates=Sumstat;
   Endnodata;
   mu = e0 + (emax*dose)/(ed50 + dose);
   model response ~ normal(mean=mu, precision=tau);
   title;
run;

proc mcmc data = sims outpost = emax_out nmc = 80000 nbi = 1000 seed = 3746
monitor = (_parms_ var_subj std_subj ed50) nthin =3 stats(percent=2.5 5 10 15 50 95 97.5) dic;
ods output PostSummaries=summaries PostIntervals=intervals;
   parm e0 emax tau  ed50; /** sets parameters **/
   /** Setting prior for each parameter ***/
   prior e0 ~normal(mean=0, precision=.01);
   prior emax ~normal(mean=0.15, precision=1);
   prior tau ~ gamma(shape=0.001, scale=0.001); 
   prior ed50 ~ uniform(0, 81);
   beginnodata; 
      /** Setting residual variance ***/
      var_subj = 1/tau;
      std_subj = sqrt(var_subj);
      /** Calculating mean for each dose ***/
      Preddist outpred=predout nsim=5000 covariates=Sumstat;
   Endnodata;
   mu = e0 + (emax*dose)/(ed50 + dose);
   model response ~ normal(mean=mu, precision=tau);
   title;
run;


*** 8.4 ***;

%macro binemaxsim(ntrt=,p0=,p1=,p2=,p3=,p4=,p5=,p6=,p7=,p8=,npergrp=,pdrop=,seed=);
   data sims (keep = subject treatment dose response);
      format treatment $8.;
   subject = 0;
   %do trt = 0 %to &ntrt;
      do i = 1 to &npergrp;
        subject = subject + 1;
        if &trt = 0 then do;
           treatment = "Placebo";
           dose = 0;
        end;
        else do;
           treatment = "Active";
           dose = 3**(&trt -1);
        end;    
        response = ranbin(floor(&seed), 1, &&p&trt);
        dropout = ranbin(floor(&seed), 1, &pdrop);
        if dropout = 0 then output;
      end;
   %end;
   run;

   proc freq noprint data = sims;
      table response * dose / norow nopercent out=sum_dt outpct;
   run;

   data sum_dt (keep = response dose count total pct_col);
      set sum_dt;
      total = round((count / pct_col)*100,1);
      if response = 1;
   run;

   proc print data = sum_dt;
   run;
%mend;

%binemaxsim(ntrt=3,p0=.35,p1=.4,p2=.5,p3=.55,npergrp=60,pdrop=.15, seed=1234);

*** 8.5 ***;

proc mcmc data = sum_dt outpost = emax_out nmc = 150000 nbi = 10000 seed = 123456
          monitor = (_parms_ ed50 preddose1 preddose3 preddose9 pipred0 pipred1 pipred3 pipred9)
          stats(percent = 2.5 5 10 50 90 95 97.5)=(interval summary);
  ods output PostIntervals = intervals;
  ods output PostSummaries = summaries;
  parm e0 emax ed50;
  prior e0 ~normal(mean=-0.45,var=4);
  prior emax ~normal(mean=0,var=4);
  prior ed50 ~uniform(0,15);

  beginnodata;
     preddose1 = exp(e0+(emax*1)/(ed50+1))/(1+exp(e0+(emax*1)/(ed50+1)))
               - exp(e0+(emax*0)/(ed50+0))/(1+exp(e0+(emax*0)/(ed50+0)));
     preddose3 = exp(e0+(emax*3)/(ed50+3))/(1+exp(e0+(emax*3)/(ed50+3)))
               - exp(e0+(emax*0)/(ed50+0))/(1+exp(e0+(emax*0)/(ed50+0)));
     preddose9 = exp(e0+(emax*9)/(ed50+9))/(1+exp(e0+(emax*9)/(ed50+9)))
               - exp(e0+(emax*0)/(ed50+0))/(1+exp(e0+(emax*0)/(ed50+0)));

     pipred0 = exp(e0+(emax*0)/(ed50+0))/(1+exp(e0+(emax*0)/(ed50+0)));
     pipred1 = exp(e0+(emax*1)/(ed50+1))/(1+exp(e0+(emax*1)/(ed50+1)));
     pipred3 = exp(e0+(emax*3)/(ed50+3))/(1+exp(e0+(emax*3)/(ed50+3)));
     pipred9 = exp(e0+(emax*9)/(ed50+9))/(1+exp(e0+(emax*9)/(ed50+9)));
  endnodata;

  eta = e0 + ((emax*dose)/ (ed50+dose));
  expeta = exp(eta);
  p = expeta/(1+expeta);
  model count ~ binomial(total, p);
run;

*** 8.6 ***;

proc sort data = summaries;
  by parameter;
run;

proc sort data = intervals;
  by parameter;
run;

data combined (drop=alpha);
  merge summaries intervals;
    by parameter;
run;

data _plot;
  retain logite0 .;
  set combined;
  if parameter = 'e0' then do;
    logite0 = mean;
    e0 = exp(mean)/(exp(mean)+1);
    call symput("e_0", put(e0, best8.));
  end;
  else if parameter = 'ed50' then call symput("ed_50", put(mean, best8.));
  else if parameter = 'emax' then do;
    temp = (exp(mean+logite0)/(exp(mean+logite0)+1));
    call symput("maxeffect", put(temp, best8.));
  end;
  else if parameter = 'pipred0' then dose = 0;
  else if parameter = 'pipred1' then dose = 1;
  else if parameter = 'pipred3' then dose = 3;
  else if parameter = 'pipred9' then dose = 9;
  if parameter in ('pipred0', 'pipred1', 'pipred3', 'pipred9');
run;

data plot_dt;
  label pct_col = "Observed Proportion";
  label mean    = "Posterior Proportion";
  merge _plot sum_dt;
    by dose;
  dose_jit = dose + 0.1;
  pct_col = pct_col / 100;
run;

proc sgplot data = plot_dt;
  *title1 "Observed and Emax Posterior Estimates for SRI Response";
  *title2 "with 95% Highest Posterior Density Intervals";
  scatter x = dose_jit y = pct_col / markerattrs=(symbol=circlefilled color=red) name="scat1";
  scatter x = dose y = mean / yerrorlower = hpdlower yerrorupper = hpdupper markerattrs=(symbol=circlefilled color=black) errorbarattrs=(color=black) name = "scat2";
  series  x = dose y = mean / lineattrs=(pattern=solid color = black);
  xaxis values = (0 1 3 9 ) label = "Dose" offsetmin=0.03 offsetmax=0.03;
  yaxis values = (0 to 1 by 0.2) label = "Proportion of SRI Responders";
  refline &e_0 &maxeffect / axis = y;
  keylegend "scat1" "scat2" / title = " " noborder;
run;