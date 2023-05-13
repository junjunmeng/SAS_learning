/******************************************************************
This SAS macro implements the fractional continual reassessment 
method (fCRM). This code is for the simulation purpose to replicate 
a large number of trials.

Created by Ruitao Lin and Guosheng Yin on January 5, 2015
*******************************************************************/



data skeleton;
input p ptrue;
datalines;
0.1 0.15
0.2 0.30 
0.3 0.45
0.4 0.55
0.5 0.60
0.6 0.70
;
run;

%macro fCRMsim(skeleton,target=0.3,ncohort=12,tau=3,a=1,cohortsize=3,toxstop=0.9,ntrial=1000);
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


/*
&ntrial=1000;
&target=0.3;
&toxstop=0.9; 

&ncohort=12;
&cohortsize=3;
&tau=3;
&a=1;
*/

ndose=nrow(p);
pihat={};
doseselect={};
*lambda=-log(1-ptrue)/&tau; /*EXPONENTIAL*/

/*WEIBULL*/
/* 70% toxicitoes occur after the half of follow-up*/
/*0.3=1-0.7; 2=1/0.5(half)*/
lambda=(log(-log(1-ptrue))-log(-log(1-0.3*ptrue)))/log(2);
gamma=exp((log(&tau)*lambda-log(-log(1-ptrue)))/lambda);

currenttime=0;

ntox=repeat(0,ndose,1);
ntrted=repeat(0,ndose,1);
doseselect=repeat(0,ndose,1);
nstop=0;

do trial=1 to &ntrial;
y={};
d={};
timey={};
assesstime={};
dosecurr=1;
stop=0;
currenttime=1;
do i=1 to &ncohort;

* simulate data for current cohort;
u = j(&cohortsize,1); /* allocate */
d=d//repeat(dosecurr,&cohortsize,1);

/*EXPONENTIAL*/
/*
call randgen(u, "EXPONENTIAL"); 
u=u/lambda[dosecurr];
*/

/*WEIBULL*/
call randgen(u, "WEIBULL",lambda[dosecurr],gamma[dosecurr]); 

if (IsEmpty(loc(u>&tau))=0) then u[loc(u>&tau)]=&tau+0.1;
timey=timey//u;

assesstime=assesstime//j(&cohortsize,1,currenttime+&tau);
ntox[dosecurr]=ntox[dosecurr]+sum(u<=&tau)/&ntrial;
ntrted[dosecurr]=ntrted[dosecurr]+&cohortsize/&ntrial;

currenttime=currenttime+&a;
y=(timey<=(currenttime+&tau-assesstime))#(currenttime<assesstime)+(timey<&tau)#(assesstime<=currenttime);

if sum(y)=0 then 
do;
if dosecurr<ndose then dosecurr=dosecurr+1;
end;

else 
do;

timeyy=timey#y+(1-y)#((currenttime+&tau-assesstime)#(currenttime<assesstime)+timey#(assesstime<=currenttime));

create survivaldata var{timeyy y} ;
append;
close survivaldata;

*** Need to specify directory of file ***;
%include "KMsim.sas";

/*
submit;
Proc lifetest data=survivaldata plots=none outsurv=survivalcurve NOPRINT;
time timeyy*y(0);
run;
endsubmit;
*/

use survivalcurve;
read all;
close survivalcurve;
*compute S(&tau);
k = loc( timeyy<=&tau ); 
k=k[ncol(k)];
stau=SURVIVAL[k];
if missing(stau)=1 then stau=min(SURVIVAL);

*compute S(t) for censored data;
do j=1 to nrow(y);

if (currenttime<assesstime[j]) then
if (y[j]=0) then 
do;
k=loc( timeyy<=(currenttime+&tau-assesstime[j]) );
k=k[ncol(k)];
st=SURVIVAL[k];
if missing(st)=1 then st=min(SURVIVAL);
y[j]=(st-stau)/st;
end;
end;


call quad(marginal, "posterior", {.M .P}) eps=1E-4 peak=-1 scale=0.5;  /* default: PEAK=1 */
phat={};
do j=1 to ndose;
call quad(phatj,"posttoxf",{.M .P}) eps=1E-4 peak=-1 scale=0.5;
phatj=phatj/marginal;
phat=phat//phatj;
end;

lb=log(log(&target)/log(p[1]));

call quad(povertox,"posterior",-35||lb) eps=1E-4 peak=-1 scale=0.5;
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
end;

if stop=1 then nstop=nstop+1;
if stop=0 then 
do;
currenttime=&ncohort*&a+&tau;
y=(timey<=&tau);
call quad(marginal, "posterior", {.M .P}) eps=1E-4 peak=-1 scale=0.5;  /* default: PEAK=1 */
phat={};
do j=1 to ndose;
call quad(phatj,"posttoxf",{.M .P}) eps=1E-4 peak=-1 scale=0.5;
phatj=phatj/marginal;
phat=phat//phatj;
end;

diff=abs(phat-&target);
dosebest=diff[>:<];
doseselect[dosebest]=doseselect[dosebest]+1;
end;

end;

doseselect=doseselect/&ntrial*100;
nstop=nstop/&ntrial*100;
dose=1:ndose;
dose=dose`;
print dose ptrue doseselect ntox ntrted nstop;
quit;
%mend fCRMsim;

%fCRMsim(skeleton,ntrial=1000);


