* SAS Program 3.1;
proc power;
   twosamplemeans test=diff 
   meandiff=0.02 stddev=0.045 
   alpha=0.025, sides=1 power=0.9 ntotal=.;
run;

* SAS Program 3.2;
proc power;
   twosamplefreq test=fisher 
   groupproportions=(0.4 0.07) groupns=(50 25)
   alpha=0.025 sides=1 power=.;
run;

* SAS Program 3.3;
proc power;
   twosamplesurvival test=logrank 
   groupmedsurvtimes=(6 8.25) 
   accrualtime=12 
   totaltime=24
   power=0.9 
   alpha=0.025 sides=1
   ntotal=.;
run;

* SAS Program 3.4;
proc seqdesign altref=0.02 errspend stopprob;
   hpdesignforfh: design nstages=5 method=peto(z=3) alt=upper stop=reject 
   alpha=0.025 beta=0.1; 
   samplesize model=twosamplemean (stddev=0.045);
run;

* SAS Program 3.5;
ods graphics on;
proc seqdesign pss stopprob errspend;
   pocdesignforfh: design nstages=4 method=poc alt=upper alpha=0.025; 
   obfdesignforfh: design nstages=4 method=obf alt=upper alpha=0.025; 
   samplesize model=twosamplemean (stddev=0.045 meandiff=0.02 weight=1);
run;
ods graphics off;

* SAS Program 3.6;
ods graphics on;
proc seqdesign plots=boundary(hscale=samplesize) boundaryscale=mle;
   pocdesignforfh: design nstages=4 method=poc alt=upper alpha=0.025; 
   obfdesignforfh: design nstages=4 method=obf alt=upper alpha=0.025; 
   samplesize model=twosamplemean (stddev=0.045 meandiff=0.02 weight=1);
run; 
ods graphics off;

ods graphics on;
proc seqdesign plots=boundary(hscale=samplesize) boundaryscale=score;
   triangularforfh: design nstages=4 alt=upper alpha=0.025 beta=0.1 stop=both
   method(alpha)=tri(tau=1) method(beta)=tri(tau=1);
   samplesize model=twosamplemean (stddev=0.045 meandiff=0.02 weight=1); 
run; 
ods graphics off;

* Data simulated for SAS Program 3.7;
data stage1data;
   input trt outcome;
   cards;
   0 0
   0 1
   0 0
   0 0
   0 0 
   0 0
   1 0
   1 1
   1 1
   1 0
   1 1
   1 1
   1 0
   1 0
   1 0
   1 1
   1 1
;
run;

data stage2data;
   input trt outcome;
   cards;
   0 0
   0 1
   0 0
   0 0
   0 0 
   0 0
   0 0
   0 0
   0 0
   0 0
   0 0
   1 0
   1 1
   1 1
   1 0
   1 1
   1 1
   1 0
   1 0
   1 0
   1 1
   1 1
   1 0
   1 1
   1 1
   1 1
   1 0
   1 1
   1 0
   1 1
   1 0
   1 1
;
run;

* SAS Program 3.7;
ods graphics on;
proc seqdesign boundaryscale=mle plots=all;
   pocobfdesignforpso: design nstages=4 alt=upper alpha=0.025 beta=0.14 stop=both   
   method(alpha)=poc method(beta)=obf; 
   samplesize model=twosamplefreq (nullprop=0.07 prop=0.4 test=prop weight=2); 
   ods output Boundary=boundaryinfo1;
run; 
ods graphics off;

proc print data=stage1data; run;

* ods exclude ModelInfo NObs ModelFit ConvergenceStatus ParameterEstimates;
proc genmod data=stage1data; 
   model outcome=trt; 
   ods output ParameterEstimates=paraest;
run;

data paraest1;
   set paraest;
   if parameter='trt';
   _scale_='MLE';
   _stage_=1;
   keep _scale_ _stage_ parameter estimate stderr;
run;

proc print data=paraest1; run;

ods graphics on;
* ods exclude TestPlot ErrSpend;
proc seqtest boundary=boundaryinfo1 parms(testvar=trt)=paraest1
   infoadj=none boundaryscale=mle errspend plots=errspend;
   ods output Test=boundaryinfo2;
run;
ods graphics off;

/* stage2data contains cumulative data up to end of stage 2 */
* ods exclude ModelInfo NObs ModelFit ConvergenceStatus ParameterEstimates;
proc genmod data=stage2data;
   model outcome=trt;
   ods output ParameterEstimates=paraest;
run;

data paraest2;
   set paraest;
   if parameter='trt';
   _scale_='MLE';
   _stage_=2;
   keep _scale_ _stage_ parameter estimate stderr;
run;

proc print data=paraest2; run;

* ods exclude Design ParameterEstimates;
proc seqtest boundary=boundaryinfo2 parms(testvar=trt)=paraest2
   infoadj=none boundaryscale=mle;
   ods output Test=boundaryinfo3;
run;

* SAS Program 3.8;
ods graphics on;
proc seqdesign boundaryscale=mle plots=all;
   gammadesignforpso: design nstages=4 alt=upper alpha=0.025 beta=0.14
   stop=both method(alpha)=errfuncgamma(gamma=0.5) 
   method(beta)=errfuncgamma(gamma=1.5); 
   samplesize model=twosamplefreq (nullprop=0.07 prop=0.4 test=prop weight=2);
run; 
ods graphics off;

* SAS Program 3.9;
ods graphics on;
proc seqdesign boundaryscale=stdz plots=all;
   rhodesignforcan1: design nstages=4 method=errfuncpow(rho=0.3) alt=upper
   stop=reject alpha=0.025 beta=0.1; 
   rhodesignforcan2: design nstages=4 method=errfuncpow(rho=0.9) alt=upper 
   stop=reject alpha=0.025 beta=0.1; 
   rhodesignforcan3: design nstages=4 method=errfuncpow(rho=1.5) alt=upper 
   stop=reject alpha=0.025 beta=0.1; 
   samplesize model=twosamplesurvival (nullmedsurvtime=6 medsurvtime=8.25 
   acctime=12 totaltime=24);
run; 
ods graphics off;

ods graphics on;
proc seqdesign boundaryscale=stdz plots=all;
   rhodesignforcan1: design nstages=4 method=errfuncpow(rho=0.3) alt=upper
   stop=reject alpha=0.025 beta=0.1; 
   rhodesignforcan2: design nstages=4 method=errfuncpow(rho=0.9) alt=upper 
   stop=reject alpha=0.025 beta=0.1; 
   rhodesignforcan3: design nstages=4 method=errfuncpow(rho=1.5) alt=upper 
   stop=reject alpha=0.025 beta=0.1; 
   samplesize model=twosamplesurvival (nullmedsurvtime=6  medsurvtime=8.25 
   acctime=12 accrual=exp(parm=-0.1) loss=exp(hazard=0.05));
run; 
ods graphics off;

* SAS Program 3.10;
/* Fixed-sample design for phase Stage 1 testing, default: beta=0.1 */
proc seqdesign; 
   stage1fixed: design nstages=1 alt=twosided alpha=0.05; 
   samplesize model=twosamplesurv(nullhazard=1.8 1.0 hazard=1.0);
run;

/* Three-stage sequential design for Stage 1 testing 1.8 criterion */ 
ods graphics on;
proc seqdesign errspend pss stopprob boundaryscale=mle plots=all;
   stage1power: design nstages=3 method=errfuncpow(rho=3) alt=twosided 
   alpha=0.05 info=cum(0.5 0.75 1); 
   samplesize model=twosamplesurv(nullhazard=1.8 1.0 hazard=1.0); 
   ods output Boundary=test_interim1;
run; 
ods graphics off;

/* Analysis of Stage 1 data */ 
proc phreg data=T2DM;
   model weeks*event(0)=treatment;
   ods output ParameterEstimates=parms_interim1; 
run;

data parms_interim1; 
   set parms_interim1; 
   where parameter='Treatment';
   parameter=-parameter+0.5878; 
   _scale_='MLE'; 
   _stage_=1; 
   keep _scale_ _stage_ parameter estimate stderr;
run;

proc seqtest boundary=test_interim1 parms(testvar=treatment)=parms_interim1
   infoadj=none boundaryscale=mle;
   ods output Test=test_interim2; 
run;

/* Interim analysis of 1.3 criterion at end of Stage 1 (20% info) 
   and interim analyses at 50% and 75% for Stage 2 */ 
ods graphics on;
proc seqdesign errspend pss stopprob boundaryscale=mle plots=all;
   stage2power: design nstages=4 method=errfuncpow(rho=3) alt=twosided 
   alpha=0.05 info=cum(0.2 0.5 0.75 1); 
   samplesize model=twosamplesurv(nullhazard=1.3 1.0 hazard=1.0); 
   ods output Boundary=combtest_interim1;
run; 
ods graphics off;

* SAS Program 3.11;
ods graphics on;
proc seqtest boundary=boundaryinfo1 parms(testvar=trt)=paraest1
   infoadj=none boundaryscale=mle condpower(cref=0.5, 1, 1.25) predpower     
   plots=condpower;
   ods output Test=boundaryinfo2;
run;
ods graphics off;
ods graphics on;
proc seqtest boundary=boundaryinfo2 parms(testvar=trt)=paraest2
   infoadj=none boundaryscale=mle condpower(cref=0.5, 1, 1.25) predpower     
   plots=condpower;
   ods output Test=boundaryinfo3;
run;
ods graphics off;
