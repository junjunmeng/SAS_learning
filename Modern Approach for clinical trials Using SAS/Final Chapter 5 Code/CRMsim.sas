/******************************************************************
This SAS macro implements the continual reassessment method (CRM). 
This code is for the simulation purpose to replicate a large number 
of trials.

Created by Ruitao Lin and Guosheng Yin on January 5, 2015
*******************************************************************/

%macro CRMsim(skeleton,target=0.3,ncohort=10,cohortsize=3,toxstop=0.9,ntrial=1000);
proc iml;
use &skeleton.;
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

ndose=nrow(p);
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

call quad(marginal, "posterior", {.M .P}) eps=1E-4 peak=-3 scale=0.5;  /* default: PEAK=1 */
phat={};
do j=1 to ndose;
call quad(phatj,"posttoxf",{.M .P}) eps=1E-4 peak=-3 scale=0.5;
phatj=phatj/marginal;
phat=phat//phatj;
end;

lb=log(log(&target)/log(p[1]));

call quad(povertox,"posterior",-35||lb) eps=1E-4 peak=-3 scale=0.5;
povertox=povertox/marginal;

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
%mend CRMsim;

/* Setup for the simulation study:
   1st col: Prespecified Skeleton for each dose level
   2nd col: True toxicity rate for each dose level
*/

data skeleton1;
input p ptrue;
datalines;
0.02 0.05
0.08 0.14
0.12 0.18
0.20 0.20
0.30 0.23
0.50 0.30
;
run;

data skeleton2;
input p ptrue;
datalines;
0.01 0.05
0.05 0.14
0.14 0.18
0.22 0.20
0.26 0.23
0.30 0.30
;
run;

data skeleton3;
input p ptrue;
datalines;
0.10 0.05
0.20 0.14
0.30 0.18
0.40 0.20
0.50 0.23
0.60 0.30
;
run;

data skeleton4;
input p ptrue;
datalines;
0.20 0.05
0.30 0.14
0.40 0.18
0.50 0.20
0.60 0.23
0.65 0.30
;
run;

%CRMsim(skeleton1);
%CRMsim(skeleton2);
%CRMsim(skeleton3);
