*** Program 6.1 ***;

%macro polyorth(fich_in=);
     data _null_;
          set &fich_in nobs=k ;
          call symput ("nlevel", put(k,8.0));
     run;
     data niv;
          length level $8. ;
          do i=1 to &nlevel. ;
             level="level " || trim(left(i));
             output niv;
          end;
     run;
     data deg;
          do i=1 to %eval(&nlevel.-1);
             degree="deg. " || trim(left(i));
             output deg;
          end;
      run;
  
      proc iml;
           start;
            use &fich_in. ;
            read all var{dose} into x;
            use niv ;
            read all var{level} into labco;
            use deg ;
            read all var{degree} into labro;
            degmax=nrow(x)-1;
            p=orpol(x,degmax);
            pp=p[,2:ncol(p)]`;
            create poly from pp [rowname=labro colname=labco];
            append from pp [rowname=labro];
            finish;
            run;
     quit;
     title1 "Orthogonal
     polynomial coefficient contrasts" ;
     title2 "-------------------------------------------";
     title3 " ";
     proc print data=poly noobs label;
          label labro="Polynomial degree";
     run;
 %mend polyorth;

data pol ;
     input dose @@;
     cards;
     0 2.5 5 12.5 25 75
     ;
run;
%polyorth(fich_in=pol);

*** Program 6.2 ***;

*****Simulation of the dataset: continuous outcome variable;
data dose;
    input dose@@;
    datalines;
0 2.5 5 10 20
;
run;

%macro simu(n=, sd=, e0=10, emax=80, ed50=5.5, h=1, outdst=dstcon);
    ** n is the sample size in each dose group;
    proc sql noprint;
       select count(dose)into:ngrp
       from dose;
    quit;
    %let ngrp= &ngrp.;

    data _null_;
        set dose;
        mean=&e0.+(&emax.*dose**&h.)/(dose**&h. + &ed50.**&h.);
        call symput(compress("mean"||put(_n_, 1.)), compress(mean));
        call symput(compress("dose"||put(_n_, 1.)), compress(dose));
    run;

    %do i=1 %to &ngrp.; %put **** Group &i. **** &&mean&i.; %end;

    data &outdst.;
      %do i=1 %to &ngrp.;
          group=&i.;
          mean=&&mean&i.;
          dose=&&dose&i.;
          do n=1 to &n.;
             resp=&&mean&i.+ &sd. *rannor(1500); **Seed number 1500 is used;
             output;
          end;
     %end;
    run;
%mend;

%simu(n=60, sd=10, e0=10, emax=80, ed50=5.5, h=1, outdst=dstcon);

*** Program 6.3 ***;

*****fit 4-parameter Emax model using PROC NLMIXED procedure;
proc nlmixed data=dstcon alpha=0.05;
   ***set up initial values;
   parms  e0=10 emax=80 ed50=5.5 h=1 v=400;
   *****specify that ed50 must be positive;
   bounds ed50>0;
   ****define model;
   if dose=0 then eta = e0;
   else eta = e0 + ((emax*dose**h)/(ed50**h+dose**h));
   model resp ~ normal(eta, v);

   *****estimate the difference in means;
   estimate "Diff Means (dose 20mg -placebo)" 
                        e0+((emax*20**h)/(ed50**h+20**h))-e0;
   estimate "Diff Means (dose 10mg -placebo)"  
                        e0+((emax*10**h)/(ed50**h+10**h))-e0;
   estimate "Diff Means (dose 5 mg -placebo)"  
                        e0+((emax*5**h)/(ed50**h+5**h))-e0;
   estimate "Diff Means (dose 2.5mg- placebo)" 
                        e0+((emax*2.5**h)/(ed50**h+2.5**h))-e0;

   predict eta out=etahat;
   *****output estimations;
   *****dataset est has output for estimate of the mean differences;
   *****dataset parms has output for parameters: e0 emax ed50 h;
   ods output AdditionalEstimates=est
              ParameterEstimates=parms;
run;

*** Program 6.4 ***;

data dose;
    input dose@@;
    datalines;
0 2.5 5 10 20
;
run;
%polyorth(fich_in=dose);

*** Program 6.5 ***;

/** PoC with trend contrast accounting for equal/unequal spacing **/
title "General linear model for PoC hypothesis testing";
proc glm data=dstcon;
     class group;
     model resp = group ;
     contrast "Trend contrast" group
              -0.47434 -0.31623 -0.15811 0.15811 0.79057;
run;

*** Program 6.6 ***;

*****simulation of the dataset: binary outcome variable;
data dose;
    input dose@@;
    datalines;
0 2.5 5 10 20
;
run;

%macro simu(n=, e0=-1.39, emax=3.54, ed50=5.5, h=1);

    proc sql noprint;
       select count(dose)into:ngrp 
       from dose;
    quit;
    %let ngrp= &ngrp. ; 
    
    data _null_;
         set dose;
         pai=exp(&e0.+((&emax.*dose**&h.)/(&ed50.**&h.+dose**&h.)))/
             (1+exp(&e0.+((&emax.*dose**&h.)/(&ed50.**&h.+dose**&h.))));
         call symput(compress( "pai" ||put(_n_, 1. )), compress(pai) ) ;
         call symput(compress( "dose" ||put(_n_, 1. )), compress(dose) ) ;
    run ;
    %do i=1 %to &ngrp.; %put *** Group &i. **** &&pai&i.; %end;
 
    proc iml ;
         prob= { %do i=1 %to &ngrp.; &&pai&i. %end; };
         p = repeat(prob,&n.);   /* repeat row n times: n/group */
         call streaminit( 321 ); /* call randseed(321) to set seed number; */
         x = rand( "Bernoulli" , p);
         create MyData from x;   /* create data set */   
         append from x;          /* write data in vectors */
         close MyData;           /* close the data set */
     quit;

     data mydata;                /* add an observation number for transpose*/
          set mydata;
          id=_n_;
     run;
    
     proc transpose data=mydata out=mydatat ;
          var col1-col&ngrp. ;
          by id;
     run;

     data xdose;             /* add the different COLn to retreive the dose*/
          set dose;
          _name_= compress("COL" || put(_n_, 1. ));
     run;

     proc sql noprint;        /* retrieve the dose for the different groups*/ 
          create table dstbin as 
           select a.id as obs, a.col1 as resp, b.dose
           from mydatat a left join xdose b
           on a._name_=b._name_ 
           order by b.dose, a.id;
          
          create table resp as
           select dose, sum(resp) as count, count(*) as n, 
                  sum(resp)/count(*) as pai
           from dstbin
           group by dose ;
     quit;
     
     proc print data =resp; 
     run ;
%mend;

%simu(n=60, e0=-1.39, emax=3.54, ed50=5.5, h=1);

*** Program 6.7 ***;

*****fit 4-parameter Emax model using PROC NLMIXED procedure;
proc print data=resp;run;

proc nlmixed data=resp alpha=0.05 ;
   *****specify that ed50 must be positive;
   bounds ed50>0;

   *****define models;
   if dose=0 then eta = e0;
   else eta = e0 + ((emax*dose**h)/(ed50**h+dose**h));
   expeta = exp(eta);
   p = expeta/(1+expeta);
   model count ~ binomial(n, p);

   *****estimate the difference in proportions (dose group-control group);
   estimate "Diff Props (20 mg - control group)" 
             exp(e0+(emax*20**h/(ed50**h+20**h)))/(1+exp(e0+
             (emax*20**h /(ed50**h+20**h))))-exp(e0)/(1+exp(e0));

   estimate "Diff Props (10 mg - control group)" 
             exp(e0+(emax*10**h/(ed50**h+10**h)))/(1+exp(e0+
             (emax*10**h /(ed50**h+10**h))))
             - exp(e0)/(1 + exp(e0));
   estimate "Diff Props (5 mg - control group)" 
             exp(e0+(emax*5**h/(ed50**h+5**h)))/(1+exp(e0+
             (emax*5**h /(ed50**h+5**h))))- exp(e0)/(1 + exp(e0));
   estimate "Diff Props (2.5 mg - control group)" 
             exp(e0+(emax*2.5**h /(ed50**h+2.5**h)))/(1+exp(e0+
             (emax*2.5**h /(ed50**h+2.5**h))))-exp(e0)/(1+exp(e0));

   predict p out=etahat;
   *****output estimations;
   *****data est will have output for estimate statement;
   *****data parms will have output for parameters;
   ods output AdditionalEstimates=est
              ParameterEstimates=parms;
run;
