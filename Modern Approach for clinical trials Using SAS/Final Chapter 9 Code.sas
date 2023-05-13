/******************************************************************
This SAS code illustrates the simple randomization procedure.

Created by Ruitao Lin and Guosheng Yin on January 5, 2015
*******************************************************************/

%macro SimpleRandomize(n,groupdata,seed);
   proc iml;
      use &groupdata.;
      read all;
      call randseed(&seed);


      u=j(&n,1);
      prob=ratio/sum(ratio);
      agroup=j(&n,1);
      call randgen(u, "Uniform");
      cprob = j(nrow(group),1);
      do j=1 to nrow(group);
         cprob[j]=sum(prob[1:j]);
      end;

      do j=1 to &n;
         k=1;
         do while (u[j]>cprob[k]);
            k=k+1;
         end;
         agroup[j]=k;
      end;
      group=group[agroup];

      create SimpleRandomization var {group}; /** create data set **/
      append; 
   quit;

   proc print data=SimpleRandomization;
   run;

   proc freq data=SimpleRandomization;
      tables group;
   run; 
%mend SimpleRandomize;


data ThreeArm;
   input group $ ratio;
   datalines;
A 1
B 1
C 2
;
run;

%SimpleRandomize(n=100,groupdata=ThreeArm,seed=6);





/******************************************************************
This SAS macro implements the randomization procedure of the 
biased coin design (BCD).

Created by Ruitao Lin and Guosheng Yin on January 5, 2015
*******************************************************************/

/* f(x)=1-x <- probability of assignment to A */
/* g(x)=x <- probability of assignment to B */
/* where x = (diff in num of subjects in each trt)/(total num of subjects) */

%macro BCDrandomize(n1, n2, seed);
   data Assignment;
   %let numer=%EVAL(&n1-&n2);
   %let denom=%EVAL(&n1+&n2);

   /* assign subject to B with probability x, A with prob 1-x */
   %if %SYSEVALF(&n1=0) & %SYSEVALF(&n2=0) %then %let DiffRatio = %SYSEVALF(0);
   %else %let DiffRatio = %SYSEVALF(&numer/&denom);
   %let Allocprob = %SYSEVALF(1/2-&DiffRatio/2);
   %let RandNum = %SYSFUNC(ranuni(&seed)); *uniform[0,1] random var;
   %if %SYSEVALF(&RandNum <= &Allocprob) %then %let Assign=A;
   %else %let Assign=B;
   /* create subject num var */
   %let AssignNum = %EVAL(&n1+&n2+1);
   groupA = &n1;
   groupB = &n2;
   allop = &Allocprob;
   newGroup = "&Assign";

   label groupA = "Number in arm A"
   groupB = "Number in arm B"
   allop = "Allocation probability to arm A"
   newGroup = "Next assignment";
   run;

   proc print data=Assignment label noobs; 
   run;
%mend BCDrandomize;

%BCDrandomize(n1=0,n2=0,seed=123);

%BCDrandomize(n1=5,n2=10,seed=123);


*******************;
*******************;
*******************;

proc plan seed=3;
   factors Block=2 random Sequence=4 ordered / noprint;
   treatments Treatment=4;
   output out=PermutedBlock Treatment cvals=('A' 'A' 'B' 'B') random;
run;

proc sort data = PermutedBlock;
   by block sequence;
run;

proc print data = PermutedBlock;
run; 

*******************;
*******************;
*******************;


proc plan seed=123;
   factors Block=1 random Gender=2 ordered Pressure=3 ordered Sequence=4 ordered/noprint;
   treatments Treatment=4 random;
   output out=StratifiedRandomization Gender cvals=('Male' 'Female') ordered
          Pressure cvals=('High' 'Normal' 'Low') ordered
             Treatment cvals=('A' 'A' 'B' 'B') random;
run;

proc print data = StratifiedRandomization;
run; 




/******************************************************************

Implementation of covariate-adaptive allocation by minimization.

*******************************************************************/

data TreatedPatients;
   input group $ 1 gender tumorstage;
   datalines;
A 1 1
A 1 1
A 1 1
A 1 1
A 1 1
A 1 1
A 1 1
A 1 2
A 1 2
A 2 2
A 2 2
A 2 2
A 2 2
A 2 2
A 2 2
A 2 2
A 2 2
A 2 3
A 2 3
B 1 1
B 1 1
B 1 1
B 1 1
B 1 1
B 1 1
B 1 2
B 2 2
B 2 2
B 2 2
B 2 2
B 2 2
B 2 2
B 2 2
B 2 2
B 2 2
B 2 2
B 2 2
B 2 2
B 2 3
B 2 3
;
run;


data FactorWeight;
   input w;
   datalines;
1
1
;
run;

%macro MinimizationRandomize(TreatedPatients,NewPatient,FactorWeight,p,seed);
   proc iml;
      use &TreatedPatients.;
      read all into X;
      use &TreatedPatients.;
      read all var {group};
      use &NewPatient.;
      read all into Y;
      use  &FactorWeight.;
      read all;
      call randseed(&seed);

      X=X//Y;

      imA=0;
      groupA=group//'A';

      do i=1 to ncol(X);
         do j=1 to max(X[,i]);
            imA=imA+w[i]*abs(sum(groupA[loc(X[,i]=j)]='A')-sum(groupA[loc(X[,i]=j)]='B'));
         end;
      end;

      imB=0;
      groupB=group//'B';

      do i=1 to ncol(X);
         do j=1 to max(X[,i]);
            imB=imB+w[i]*abs(sum(groupB[loc(X[,i]=j)]='A')-sum(groupB[loc(X[,i]=j)]='B'));
         end;
      end;
      print imA imB;

      u=1;
      call randgen(u, "Uniform");

      if (imA<=imB & u<=&p) then 
      call symput('newgroup','A');
      if (imA<=imB & u>&p) then 
      call symput('newgroup','B');
      if (imA>imB & u<=&p) then 
      call symput('newgroup','B');
      if (imA>imB & u>&p) then 
      call symput('newgroup','A');

      NextGroup=symget("newgroup");;
      print NextGroup;
   quit;

   data &NewPatient.;
      length group $ 1;
      group=symget("newgroup");
      set &NewPatient.;
   run;

   proc print data=&TreatedPatients.;
   run;

   data &TreatedPatients.;
      set &TreatedPatients. &Newpatient.;
   run;

   proc print data=&TreatedPatients.;
   run;
%mend MinimizationRandomize;


* 1st subject: male, tumor I;
data NewPatient;
   input gender tumorstage;
   datalines;
1 1
;
run;

%MinimizationRandomize(TreatedPatients,NewPatient,FactorWeight,p=0.75,seed=6);

* 2nd subject: male, tumor II;
data NewPatient;
   input gender tumorstage;
   datalines;
1 2
;
run;

%MinimizationRandomize(TreatedPatients,NewPatient,FactorWeight,p=0.75,seed=6);

* 3rd subject: female, tumor II;
data NewPatient;
   input gender tumorstage;
   datalines;
2 2
;
run;

%MinimizationRandomize(TreatedPatients,NewPatient,FactorWeight,p=0.75,seed=6);




/******************************************************************
This SAS macro implements the model-based optimal adaptive 
randomization procedure (Atkinson, 1999).

Created by Ruitao Lin and Guosheng Yin on January 5, 2015
*******************************************************************/

data TreatedPatients;
   input Intercept Gender Pressure Severity Treatment;
   *Pressure: blood pressure;
   *Severity: Severity score;
   datalines;
1  0  1.16 -0.80  1
1  1  1.84  2.25  1
1  1  0.41 -1.38  0
1  0  0.99  1.12  1
1  1 -1.18 -0.30  0
1  1  1.47 -0.94  0
1  1 -1.16  0.24  1
1  1  1.92 -1.29  1
1  0  1.13 -0.77  0
1  1 -0.42  0.69  0
1  1 -0.17 -0.59  1
1  1 -0.73  1.22  1
1  1 -0.00 -0.59  0
1  1  1.26 -0.45  0
1  0 -0.48  2.23  1
1  1 -0.58 -2.29  0
1  1  0.06 -0.69  1
1  1 -0.09  1.10  1
1  1  0.23 -1.63  1
1  0  0.37 -2.23  0
;
run;

%macro ModelOptRandomize(TreatedPatients,NewPatient,gamma,seed); 
   proc iml;
      use &TreatedPatients.;
      read all into X;
      use &NewPatient.;
      read all into Z;
      n=nrow(X);
      call randseed(&seed);

      X[,ncol(X)]=-(X[,ncol(X)]=0)+(X[,ncol(X)]=1);
      delta=X[,ncol(X)];
      X=X[,1:(ncol(X)-1)];
      L=delta`*X*inv(X`*X)*X`*delta;
      R=Z*inv(X`*X)*X`*delta/n;
      p=(1-R)**&gamma/((1-R)**&gamma+(1+R)**&gamma);

      call randgen(u, "Uniform");
      trt=u<p;
      *if trt=0 then trt=-1;
      call symputx("trt",trt);
   quit;

   data &NewPatient.;
      set &NewPatient.;
      Treatment=&trt;
      output;
   run;

   proc append base=&TreatedPatients. data=&NewPatient.;
   run;
%mend ModelOptRandomize;

data NewPatient1;
   input Intercept Gender Pressure Severity;
   datalines;
1  0   0.20   -1.98
;
run;

data NewPatient2;
   input Intercept Gender Pressure Severity;
   datalines;
1  1   -0.80   -0.30
;
run;

data NewPatient3;
   input Intercept Gender Pressure Severity;
   datalines;
1  1   0.15   2.50
;
run;

%ModelOptRandomize(TreatedPatients,NewPatient1,gamma=5,seed=6);
%ModelOptRandomize(TreatedPatients,NewPatient2,gamma=5,seed=6);
%ModelOptRandomize(TreatedPatients,NewPatient3,gamma=5,seed=6);

proc print data=TreatedPatients;
run;





/******************************************************************
This SAS macro implements the randomized play-the-winner procedure.

Created by Ruitao Lin and Guosheng Yin on January 10, 2015
*******************************************************************/

%macro RPWrandomize(n1,y1,n2,y2,m,alpha,beta,seed);
   proc iml;
      call randseed(&seed);
      /* # of balls of type A */
      n1ball=&m+&y1*&alpha+(&n2-&y2)*&alpha+&y2*&beta+(&n1-&y1)*&beta;
      /* # of balls of type B */
      n2ball=&m+&y2*&alpha+(&n1-&y1)*&alpha+&y1*&beta+(&n2-&y1)*&beta;
      /* Probability that next drawn ball is A */
      p1=n1ball/(n1ball+n2ball);
      /* Assign the next patient based on p */
      Assignment=j(1);
      call randgen(Assignment, "BERNOULLI",p1);
      if Assignment=1 then Assignment='A';
      else Assignment='B';
      print p1[colname="Allocation probability to arm A" label=""]
      Assignment[colname="Next assignment" label=""];
   quit;
%mend RPWrandomize;

%RPWrandomize(n1=20,y1=14,n2=13,y2=5,m=0,alpha=1,beta=0,seed=123);





/******************************************************************
This SAS macro implements the Neyman allocation procedure 
(Only for dichotomous outcomes).

Created by Ruitao Lin and Guosheng Yin on January 10, 2015
*******************************************************************/

%macro NeymanRandomize(n1,y1,n2,y2,seed);
   proc iml;
      call randseed(&seed);
      /* Estimate of p1 */
      p1=&y1/&n1;
      /* Estimate of p2 */
      p2=&y2/&n2;
      /* Neyman’s allocation ratio */
      r1=sqrt(p1*(1-p1)/p2/(1-p2));
      p1=r1/(1+r1);
      /* Assign the next patient based on p */
      Assignment=j(1);
      call randgen(Assignment, "BERNOULLI",p1);
      if Assignment=1 then Assignment='A';
      else Assignment='B';
      print p1[colname="Allocation probability to arm A" label=""]
      Assignment[colname="Next assignment" label=""];
   quit;
%mend NeymanRandomize;

%NeymanRandomize(n1=20,y1=14,n2=13,y2=5,seed=123);




/******************************************************************
This SAS macro implements the Optimal allocation procedure 
(Only for dichotomous outcomes).

Created by Ruitao Lin and Guosheng Yin on January 10, 2015
*******************************************************************/

%macro OptimalRandomize(n1,y1,n2,y2,seed);
   proc iml;
      call randseed(&seed);
      /* Estimate of p1 */
      p1=&y1/&n1;
      /* Estimate of p2 */
      p2=&y2/&n2;
      /* Neynman allocation ratio */
      r1=sqrt(p1/p2);
      p1=r1/(1+r1);
      /* Assign the next patient based on p */
      Assignment=j(1);
      call randgen(Assignment, "BERNOULLI",p1);
      if Assignment=1 then Assignment='A';
      else Assignment='B';
      print p1[colname="Allocation probability to arm A" label=""]
      Assignment[colname="Next assignment" label=""];
   quit;
%mend OptimalRandomize;

%OptimalRandomize(n1=20,y1=14,n2=13,y2=5,seed=123);





/******************************************************************
This SAS macro implements response adaptive randomization (RAR)
methods.

The simulation code compares four RAR procedures:
(1) Equal randomization
(2) Randomized play-the-winner rule
(3) Neyman's allocation
(4) Optimal response adaptive randomization

Created by Ruitao Lin and Guosheng Yin on January 5, 2015
*******************************************************************/

%macro RARsim(p1,p2,n,nsim,seed);
   proc iml;
      result=j(4,5,.);
      call randseed(&seed);
      * Equal randomization;
      r={};
      power=0;
      tf={};
      do i = 1 to &nsim;
      n1=j(1,1,.);
      call randgen(n1,'BINOMIAL',0.5,&n);
      n2=&n-n1;
      y1=j(1,1,.);
      y2=j(1,1,.);
      call randgen(y1,'BINOMIAL',&p1,n1);
      call randgen(y2,'BINOMIAL',&p2,n2);
      r=r//n1/&n;
      * Adjust the estimate of success rate, c.f. Rosenberger et al., 2002;
      p1hat=(y1+1)/(n1+2);
      p2hat=(y2+1)/(n2+2);
      T=(p1hat-p2hat)/sqrt(p1hat*(1-p1hat)/n1+p2hat*(1-p2hat)/n2);
      power=power+(abs(T)>1.96)/&nsim;
      tf=tf//(&n-y1-y2);
      end;

      result[1,1]=mean(r);
      result[1,2]=sqrt(var(r));
      result[1,3]=power;
      result[1,4]=mean(tf);
      result[1,5]=sqrt(var(tf));

      *Randomized Play-the-Winner Design;

      r={};
      power=0;
      tf={};
      do i = 1 to &nsim;
      n1=0;
      y1=0;
      y2=0;
      nball1=0;
      nball2=0;
      alpha=1;
      beta=0;
      q=0.5;
      do j = 1 to &n;
      call randgen(z,'BERNOULLI',q);
      * generate treatment indicator, if z=1 then next patient is assigned to arm 1;
      n1=n1+z;
      call randgen(yy,'BERNOULLI',&p1*z+&p2*(1-z));
      y1=y1+yy*z;
      y2=y2+yy*(1-z);
      if z=yy then 
      do;
      nball1=nball1+alpha;
      nball2=nball2+beta;
      end;
      else
      do;
      nball2=nball2+alpha;
      nball1=nball1+beta;
      end;
      q=nball1/(nball1+nball2);
      end;
      n2=&n-n1;
      r=r//n1/&n;
      * Adjust the estimate of success rate, c.f. Rosenberger et al., 2002;
      p1hat=(y1+1)/(n1+2);
      p2hat=(y2+1)/(n2+2);
      T=(p1hat-p2hat)/sqrt(p1hat*(1-p1hat)/n1+p2hat*(1-p2hat)/n2);
      power=power+(abs(T)>1.96)/&nsim;
      tf=tf//(&n-y1-y2);
      end;

      result[2,1]=mean(r);
      result[2,2]=sqrt(var(r));
      result[2,3]=power;
      result[2,4]=mean(tf);
      result[2,5]=sqrt(var(tf));

      *Neyman allocation ratio;
      r={};
      power=0;
      tf={};
      do i = 1 to &nsim;
      n1=0;
      y1=0;
      y2=0;
      q=0.5;
      do j = 1 to &n;
      call randgen(z,'BERNOULLI',q);
      * generate treatment indicator, if z=1 then next patient is assigned to arm 1;
      n1=n1+z;
      call randgen(yy,'BERNOULLI',&p1*z+&p2*(1-z));
      y1=y1+yy*z;
      y2=y2+yy*(1-z);

      n2=j-n1;
      * Adjust the estimate of success rate, c.f. Rosenberger et al., 2002;
      p1hat=(y1+1)/(n1+2);
      p2hat=(y2+1)/(n2+2);

      q=sqrt(p1hat*(1-p1hat))/(sqrt(p1hat*(1-p1hat))+sqrt(p2hat*(1-p2hat)));
      end;
      r=r//n1/&n;
      T=(p1hat-p2hat)/sqrt(p1hat*(1-p1hat)/n1+p2hat*(1-p2hat)/n2);
      power=power+(abs(T)>1.96)/&nsim;
      tf=tf//(&n-y1-y2);

      end;

      result[3,1]=mean(r);
      result[3,2]=sqrt(var(r));
      result[3,3]=power;
      result[3,4]=mean(tf);
      result[3,5]=sqrt(var(tf));

      *Optimal Allocation;
      r={};
      power=0;
      tf={};
      do i = 1 to &nsim;
      n1=0;
      y1=0;
      y2=0;
      q=0.5;
      do j = 1 to &n;
      call randgen(z,'BERNOULLI',q);
      * generate treatment indicator, if z=1 then next patient is assigned to arm 1;
      n1=n1+z;
      call randgen(yy,'BERNOULLI',&p1*z+&p2*(1-z));
      y1=y1+yy*z;
      y2=y2+yy*(1-z);

      n2=j-n1;
      * Adjust the estimate of success rate, c.f. Rosenberger et al., 2002;
      p1hat=(y1+1)/(n1+2);
      p2hat=(y2+1)/(n2+2);

      q=sqrt(p1hat)/(sqrt(p1hat)+sqrt(p2hat));
      end;
      r=r//n1/&n;
      T=(p1hat-p2hat)/sqrt(p1hat*(1-p1hat)/n1+p2hat*(1-p2hat)/n2);
      power=power+(abs(T)>1.96)/&nsim;
      tf=tf//(&n-y1-y2);

      end;

      result[4,1]=mean(r);
      result[4,2]=sqrt(var(r));
      result[4,3]=power;
      result[4,4]=mean(tf);
      result[4,5]=sqrt(var(tf));

      rnames={ER,RPW,NR,OR};
      cnames={'ratio','sd_ratio','error','#failure','sd_#failure'};
      print result[rowname=rnames colname=cnames];
   quit;
%mend RARsim;

%RARsim(p1=0.2,p2=0.2,n=200,nsim=5000,seed=123);




/******************************************************************
This SAS macro implements the Bayesian response-adaptive 
randomization procedure.

Created by Ruitao Lin and Guosheng Yin on January 10, 2015
*******************************************************************/

%macro BayesianRandomize(n1,y1,n2,y2,alpha1=0.5,beta1=0.5,alpha2=0.5,beta2=0.5,Gamma=1,design=1,N=150,seed=123);
   proc iml;
      call randseed(&seed);
      /* Posterior probability that treatment A is superior to treatment B */
      /* Using MCMC approximation to compute the probability */
      posta=j(10000,1);
      postb=j(10000,1);
      call randgen(posta, "BETA",&y1+&alpha1,&n1-&y1+&beta1);
      call randgen(postb, "BETA",&y2+&alpha2,&n2-&y2+&beta2);
      lambda=sum(posta>postb)/10000;

      if &design=1 then Gamma=&Gamma;
      else Gamma=(&n1+&n2)/&N/2;

      p1=lambda##Gamma/(lambda##Gamma+(1-lambda)##Gamma);
      Assignment=j(1);
      call randgen(Assignment, "BERNOULLI",p1);
      if Assignment=1 then Assignment='A';
      else Assignment='B';
      print Gamma p1[colname="Allocation probability to arm A" label=""]
      Assignment[colname="Next assignment" label=""];
   quit;
%mend BayesianRandomize;

%BayesianRandomize(n1=20,y1=14,n2=13,y2=5,alpha1=0.5,beta1=0.5,alpha2=0.5,beta2=0.5,design=1,Gamma=1,seed=123);
%BayesianRandomize(n1=20,y1=14,n2=13,y2=5,alpha1=0.5,beta1=0.5,alpha2=0.5,beta2=0.5,design=2,N=150,seed=123);
