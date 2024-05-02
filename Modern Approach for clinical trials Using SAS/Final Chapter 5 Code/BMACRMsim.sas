/******************************************************************
This SAS macro implements the Bayesian model averaging continual 
reassessment method (BMA-CRM). This code is for the simulation 
purpose to replicate a large number of trials.

Created by Ruitao Lin and Guosheng Yin on January 5, 2015
*******************************************************************/

%macro BMACRMsim(skeleton,priormodel,truerate,target=0.3,ncohort=10,cohortsize=3,toxstop=0.9,ntrial=1000);
proc iml;
use &skeleton.;
read all into skeleton;

use &truerate.;
read all;

use &priormodel.;
read all;

call randseed(123);

/* posterior=likelihood * prior */
start posterior(alpha) global(y,d,p);
sigma2=2;
lik=1;
nn=nrow(y);
aa=sum(y);

if aa=0 then 
do;
do k=1 to nn;
pi=(p[d[k]])##exp(alpha);
lik=lik*((1-pi)##(1-y[k]));
end;
end;

else
do;
do k=1 to nn;
pi=(p[d[k]])##exp(alpha);
lik=lik*(pi##(y[k]))*((1-pi)##(1-y[k]));
end;
end;

lik=lik*exp(-0.5*alpha*alpha/sigma2);
return(lik);
finish;

/* used to calculate the posterior mean of pi */
start posttoxf(alpha) global(j,y,d,p);
post=p[j]##exp(alpha)*posterior(alpha);
return(post);
finish; 

/*ntrial=1000;
target=0.3;
toxstop=0.9; /* toxicity stopping boundary */
/*ncohort=10;
cohortsize=3;*/

nmodel=nrow(priormodel);
ndose=nrow(ptrue);
pihat={};
doseselect={};

ntox=repeat(0,ndose,1);
ntrted=repeat(0,ndose,1);
doseselect=repeat(0,ndose,1);
nstop=0;

do trial=1 to &ntrial.;

y={};
d={};
dosecurr=1;
stop=0;
do i=1 to &ncohort.;

u = j(&cohortsize,1); /* allocate */
call randgen(u, "Uniform"); /* u ~ U[0,1] */
u=u<ptrue[dosecurr];
y=y//u;
d=d//repeat(dosecurr,&cohortsize,1);
ntox[dosecurr]=ntox[dosecurr]+sum(u)/&ntrial.;
ntrted[dosecurr]=ntrted[dosecurr]+&cohortsize/&ntrial;

marginalm={};
povertoxm={};
phatm=repeat(0,ndose,nmodel);
do md=1 to nmodel;
 
p=skeleton[,md];
 
lb=log(log(&target)/log(p[1]));
call quad(marginal, "posterior", {.M .P}) eps=1E-4 peak=-3 scale=0.5;  /* default: PEAK=1 */
marginalm=marginalm//marginal;
 
do j=1 to ndose;
call quad(phatj,"posttoxf",{.M .P}) eps=1E-4 peak=-3 scale=0.5;
phatj=phatj/marginal;
phatm[j,md]=phatj;
end;

call quad(povertox,"posterior",-35||lb) eps=1E-4 peak=-3 scale=0.5;
povertox=povertox/marginal;
povertoxm=povertoxm//povertox;
end;

posmodel=marginalm#priormodel/sum(marginalm#priormodel);
phat=phatm*posmodel;
povertox=sum(povertoxm#posmodel);

if povertox>&toxstop then
do;
stop=1;
i=&ncohort+1;
end;

diff=abs(phat-&target);
dosebest=diff[>:<];

if dosebest>dosecurr then
  if dosecurr<ndose then do;
dosecurr=dosecurr+1;
end;

if dosebest<dosecurr then
  if dosecurr>1 then do;
dosecurr=dosecurr-1;
end;
end;
if stop=1 then nstop=nstop+1;
if stop=0 then doseselect[dosebest]=doseselect[dosebest]+1;

end;

doseselect=doseselect/&ntrial*100;
nstop=nstop/&ntrial*100;
dose=1:ndose;
dose=dose`;
print dose ptrue doseselect ntox ntrted nstop;
quit;
%mend BMACRMsim;


/* Prespecified skeleton:
   Four skeletons are used in this example,
   each column corresponds to a skeleton.
*/
data skeleton;
input p1 p2 p3 p4;
datalines;
0.02 0.01 0.10 0.20
0.08 0.05 0.20 0.30
0.12 0.14 0.30 0.40
0.20 0.22 0.40 0.50
0.30 0.26 0.50 0.60
0.50 0.30 0.60 0.65
;
run;

/* Prior probability for each skeleton */
data priormodel;
input priormodel;
datalines;
0.25
0.25
0.25
0.25
;
run;

/* True toxicity rate for each dose level */
data truerate;
input ptrue;
datalines;
0.05
0.14
0.18
0.20
0.23
0.30
;
run;

%BMACRMsim(skeleton,priormodel,truerate);

