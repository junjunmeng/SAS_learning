*** 3.1 ***;
proc seqdesign altref=0.0288 errspend;
   OneSidedErrorSpending: design nstages=2
   method(alpha)=errfuncobf
   method(beta)=errfuncgamma(gamma=-4)
   alt=upper stop=both(betaboundary=nonbinding)
   alpha=0.025 beta=0.20;
   samplesize model=twosamplefreq(nullprop=0.09 test=prop);
   ods output Boundary=Bnd_Prop;
run;

*** 3.2 ***;
%macro SSR_EFF(nSamp=,alpha=,beta=, cont=, trt=,pc=,ptrt=, delta=, Nmax=, r=,t=, c1=, c2=,b1=,titl=);
   data SSR_EFF; 
   /*** r= randomization allocation ***/
   /*** total sample size by n and total numbers of subjects in each
   group by n1 = (1 - r)n and n2 = rn so that the fraction of subjects
   the active arm is r and total sample size is **/
   eSize=abs((&delta.)/((&pc.*(1-&pc.)+&ptrt.*(1-&ptrt.))/2)**0.5);
   nFixed=2*ceil(2*((probit(1-&alpha.)+probit(1-&beta.))/eSize)**2); 
   /** Total Sample Size at the Interim Analysis**/
   n1=ceil(&t.*nfixed);
   n2=nFixed-n1; 
   c_seed1=1736; t_seed1=6214;
   c_seed2=7869; t_seed2=9189;   

   do i=1 To &nSamp;
      n11=round((1-&r.)*n1);
      n12=round(&r.*n1);
      cont1=Ranbin(c_seed1,N11,&cont.)/n11;
      trt1=Ranbin(t_seed1,N12,&trt.)/n12;
      deltahat1=trt1-cont1;
      pbar1=(cont1*n11+trt1*n12)/(n11 + n12);
      se1=sqrt(pbar1*(1-pbar1)*(1/n11+1/n12));
      z1=deltahat1/se1;
      improve=((trt1-cont1)/cont1)*100;         
      rejectho=0;estop=0;fstop=0;power=0;
      if Z1 > &c1. then do;
         rejectho=1; 
         ESTOP=1;
         nfinal=n1;
      end;
      if Z1 < &b1. then do;
         rejectho=0; 
         FSTOP=1;
         nfinal=n1;
      end;
      if &b1. =< Z1 < &c1. then do;
         eRatio=abs(&delta/(abs(deltahat1)+0.0000001));
         n_adj=(eRatio**2)*nfixed;
         nFinal=Min(&Nmax,Max(nfixed,n_adj)); 
         nFinal=Min(&Nmax,Max(nfixed,n_adj)); 
      end;
      w1=sqrt(n1/(n1+n2));
      w2=sqrt(n2/(n1+n2));

      /***** Simulate Data for Stage II *******/;
      cont2=.;
      trt2=.;
      z2=.;
      zchw=z1;
      if nfinal > n1 then do;
         n21=round((1-&r.)*(nfinal-n1));
         n22=round(&r.*(nfinal-n1));
         n2=n21+n22;
         cont2=Ranbin(c_seed1,N21,&cont.)/n21;
         trt2=Ranbin(t_seed1,N22,&trt.)/n22;
         deltahat2=trt2-cont2;
         pbar2=(cont2*n21+trt2*n22)/(n21 + n22);
         se2=sqrt(pbar2*(1-pbar2)*(1/n21+1/n22));
         z2=deltahat2/se2;
         ZCHW=w1*Z1+w2*Z2;
      end;
      if ZCHW > &c2. then rejectho=1;
      else rejectho=rejectho; 
      output;
   end;
   run;

   title "&titl";
   proc means data=SSR_EFF;
      var rejectho nfinal estop  fstop nfixed;
   run;
%mend SSR_EFF;

/** 32% improvement - GSD**/
%SSR_EFF(nSamp=10000,alpha=0.025,beta=0.2, cont=0.09, trt=0.1188,pc=0.09,ptrt=0.1188, delta=0.0288,
          Nmax=3532, r=0.5,t=0.5, c1=2.963, c2=1.969,b1=0.011,titl=GSD with 32% Improvement under HA);

%SSR_EFF(nSamp=100000,alpha=0.025,beta=0.2, cont=0.1188, trt=0.1188,pc=0.09,ptrt=0.1188, delta=0.0288,
          Nmax=3532, r=0.5,t=0.5, c1=2.963, c2=1.969,b1=0.011,titl=GSD with 32% Improvement under H0);

 /** 34% improvement - GSD**/
%SSR_EFF(nSamp=10000,alpha=0.025,beta=0.2, cont=0.09, trt=0.1206,pc=0.09,ptrt=0.1188, delta=0.0288,
          Nmax=3532, r=0.5,t=0.5, c1=2.963, c2=1.969,b1=0.028,titl=GSD with 34% Improvement under HA);

%SSR_EFF(nSamp=100000,alpha=0.025,beta=0.2, cont=0.09, trt=0.09,pc=0.09,ptrt=0.1188, delta=0.0288,
          Nmax=3532, r=0.5,t=0.5, c1=2.963, c2=1.969,b1=0.028,titl=GSD with 34% Improvement under H0);


/** 36% improvement - GSD**/
%SSR_EFF(nSamp=10000,alpha=0.025,beta=0.2, cont=0.09, trt=0.1224,pc=0.09,ptrt=0.1188, delta=0.0288,
          Nmax=3532, r=0.5,t=0.5, c1=2.963, c2=1.969,b1=0.041,titl=GSD with 36% Improvement under HA);

%SSR_EFF(nSamp=10000,alpha=0.025,beta=0.2, cont=0.09, trt=0.09,pc=0.09,ptrt=0.1188, delta=0.0288,
          Nmax=3532, r=0.5,t=0.5, c1=2.963, c2=1.969,b1=0.041,titl=GSD with 36% Improvement under H0);

        
 /** 38% improvement - GSD**/
%SSR_EFF(nSamp=10000,alpha=0.025,beta=0.2, cont=0.09, trt=0.1242,pc=0.09,ptrt=0.1188, delta=0.0288,
          Nmax=3532, r=0.5,t=0.5, c1=2.963, c2=1.969,b1=0.048,titl=GSD with 38% Improvement under HA);

%SSR_EFF(nSamp=10000,alpha=0.025,beta=0.2, cont=0.09, trt=0.09,pc=0.09,ptrt=0.1188, delta=0.0288,
          Nmax=3532, r=0.5,t=0.5, c1=2.963, c2=1.969,b1=0.048,titl=GSD with 38% Improvement under H0);

/** 40% improvement - GSD**/
%SSR_EFF(nSamp=10000,alpha=0.025,beta=0.2, cont=0.09, trt=0.1260,pc=0.09,ptrt=0.1188, delta=0.0288,
          Nmax=3532, r=0.5,t=0.5, c1=2.963, c2=1.969,b1=0.052,titl=GSD with 40% Improvement under HA);

%SSR_EFF(nSamp=10000,alpha=0.025,beta=0.2, cont=0.09, trt=0.09,pc=0.09,ptrt=0.1188, delta=0.0288,
          Nmax=3532, r=0.5,t=0.5, c1=2.963, c2=1.969,b1=0.052,titl=GSD with 40% Improvement under H0);

/** 32% improvement - SSR**/
%SSR_EFF(nSamp=10000,alpha=0.025,beta=0.2, cont=0.09, trt=0.1188,pc=0.09,ptrt=0.1260, delta=0.0360,
          Nmax=5000, r=0.5,t=0.5, c1=2.963, c2=1.969,b1=0.011,titl=GSD with 32% Improvement under HA);

%SSR_EFF(nSamp=100000,alpha=0.025,beta=0.2, cont=0.09, trt=0.09,pc=0.09,ptrt=0.1260, delta=0.0360,
          Nmax=5000, r=0.5,t=0.5, c1=2.963, c2=1.969,b1=0.011,titl=SSR with 32% Improvement under H0);

        /** 34% improvement - SSR**/
%SSR_EFF(nSamp=10000,alpha=0.025,beta=0.2, cont=0.09, trt=0.1206,pc=0.09,ptrt=0.1260, delta=0.0360,
          Nmax=5000, r=0.5,t=0.5, c1=2.963, c2=1.969,b1=0.028,titl=SSR with 34% Improvement under HA);

%SSR_EFF(nSamp=100000,alpha=0.025,beta=0.2, cont=0.09, trt=0.09,pc=0.09,ptrt=0.1260, delta=0.0360,
          Nmax=5000, r=0.5,t=0.5, c1=2.963, c2=1.969,b1=0.028,titl=SSR with 34% Improvement under H0);

*** 3.3 ***;

proc seqdesign altref=0.19 errspend pss(cref=0 0.5 1)
   stopprob(cref=0 0.5 1)
   plots=(asn power errspend)
   boundaryscale=stdZ;
   OneSidedErrorSpending: design nstages=2
   method(alpha)=ERRFUNCGAMMA(GAMMA=-4)
   alt=upper stop=reject
   alpha=0.025 beta=0.2 info=cum(1 2);
   samplesize model=twosamplemean(stddev=1 weight=1);
run;

*** 3.4 ***;

%Macro SSR_CP(nSamp=,alpha=,beta=, sigma=, cont=, trt=, delta=, Nmax=, r=,t=, c1=, c2=,titl=);
   data SSR;
      /*** r= randomization allocation ***/
      /*** total sample size by n and total numbers of subjects in each group by
      n1 = (1 - r)n and n2 = rn so that the fraction of subjects in the active arm
      is r and total sample size is **/
      esize=(&delta.)/&sigma.;
      nFixed=2*ceil(2*((probit(1-&alpha.)+probit(1-&beta.))/eSize)**2);
      /** Total Sample Size at the Interim Analysis**/
      n1=ceil(&t.*nfixed);
      n2=nFixed-n1;
      c_seed1=1736; t_seed1=6214;
      c_seed2=7869; t_seed2=9189;
      do i=1 To &nSamp;
         n11=round((1-&r.)*n1);
         n12=round(&r.*n1);
         cont1 = Rannor(c_seed1)*&sigma./Sqrt(n11)+&cont.;
         trt1 = Rannor(t_seed1)*&sigma./Sqrt(n12)+&trt.;
         deltahat1=trt1-cont1;
         se1=&sigma.*sqrt(1/(n1*&r.*(1-&r.)));
         Z1=deltahat1/se1;
         /*** Calculate Conditional Power ***/
         cp=1-probnorm(&c2.*sqrt(1+(n1/(nfixed-n1)))-Z1*(n1/(nfixed-n1))-
         (deltahat1*sqrt(&r.*(1-&r.))*sqrt(nfixed-n1)/&sigma.));
         if cp < 0.3 then zone="UNFAVORABLE";
         else if 0.3 =< cp =< 0.8 then zone="PROMISING";
         else if (cp > 0.8) and Z1 < &c1 then zone="FAVORABLE";
         else if (cp > 0.8) and Z1 >= &c1 then zone="EFFICACY";
         n2tilda=nfixed;
         w1=sqrt(n1/(n1+n2));
         w2=sqrt(n2/(n1+n2));
         if zone in ("PROMISING") then do;
            a=&c2. / w2;
            zbt=Probit(1-&beta.);
            k=w1/w2;
            n2tilda=(n1*(((a+zbt)/z1)-k)**2)+n1;
         end;
         *if zone in ("PROMISING") then do; 
         *   n2tilda=&Nmax; 
         *end;         
         n2tilda=n2tilda;rejectho=0;estop=0;
         if zone in("EFFICACY") then do;
            n2tilda=n1;
            rejectho=1;
            zchw=z1;
            estop=1;
         end;
         if n2tilda > &nmax. then nfinal=&nmax.;
         else nfinal=n2tilda;
         /***** Simulate Data for Stage II *******/;
         cont2=.;trt2=.;z2=.;zchw=z1;
         if nfinal > n1 then do;
            n21=round((1-&r.)*(nfinal-n1));
            n22=round(&r.*(nfinal-n1));
            cont2 = Rannor(c_seed2)*&sigma./Sqrt(n21)+&cont.;
            trt2 = Rannor(t_seed2)*&sigma./Sqrt(n22)+&trt.;
            deltahat2=trt2-cont2;
            se2=&sigma.*sqrt(1/((nfinal-n1)*&r.*(1-&r.)));
            Z2=deltahat2/se2;
            ZCHW=w1*Z1+w2*Z2;
         end;
         if ZCHW > &c2. then rejectho=1;
         else rejectho=rejectho;
         output;
      end;
   run;

   /** Calculating the power and average sample size **/
   ods listing close;
   PROC MEANS DATA=SSR;
      CLASS Zone;
      VAR nfinal rejectho estop;
      OUTPUT OUT=Results MEAN=AveSS Power ESTOP ;
   RUN;
   data results;
      set results;
      if _type_="0" then zone="Overall";
      else Zone=Zone;
      drop _type_ _freq_ ;
   run;
   ods listing;
   title "&titl";
      Proc Print data=Results noobs;
   run;
   /** Calculating the number of times in the promizing zone **/
   title " Zone Frequency - &titl";
   proc freq data=ssr;
      tables zone;
   run;
%mend SSR_CP;

   /**********************************************/
   *Group Sequential Design with Pessimistic Delta*
   /**********************************************/


/***  GSD Design with 0.25 treatment difference **/   
%SSR_CP(nSamp=1000000,alpha=0.025,beta=0.2, sigma=1, cont=0, trt=0.25, delta=0.19,
          Nmax=870, r=0.5,t=0.5, c1=2.963, c2=1.969,titl=GSD Design with 0.25 treatment difference);
   
 /***  GSD Design with 0.24 treatment difference **/ 
%SSR_CP(nSamp=1000000,alpha=0.025,beta=0.2, sigma=1, cont=0, trt=0.24, delta=0.19,
          Nmax=870, r=0.5,t=0.5, c1=2.963, c2=1.969,titl=GSD Design with 0.24 treatment difference);
   
/***  GSD Design with 0.23 treatment difference **/ 
%SSR_CP(nSamp=1000000,alpha=0.025,beta=0.2, sigma=1, cont=0, trt=0.23, delta=0.19,
          Nmax=870, r=0.5,t=0.5, c1=2.963, c2=1.969,titl=GSD Design with 0.23 treatment difference);
   
/***  GSD Design with 0.22 treatment difference **/ 
%SSR_CP(nSamp=1000000,alpha=0.025,beta=0.2, sigma=1, cont=0, trt=0.22, delta=0.19,
          Nmax=870, r=0.5,t=0.5, c1=2.963, c2=1.969,titl=GSD Design with 0.22 treatment difference);
   
/***  GSD Design with 0.21 treatment difference **/ 
%SSR_CP(nSamp=1000000,alpha=0.025,beta=0.2, sigma=1, cont=0, trt=0.21, delta=0.19,
          Nmax=870, r=0.5,t=0.5, c1=2.963, c2=1.969,titl=GSD Design with 0.21 treatment difference);
   
/***  GSD Design with 0.20 treatment difference **/ 
%SSR_CP(nSamp=1000000,alpha=0.025,beta=0.2, sigma=1, cont=0, trt=0.20, delta=0.19,
          Nmax=870, r=0.5,t=0.5, c1=2.963, c2=1.969,titl=GSD Design with 0.20 treatment difference);
   
/***  GSD Design with 0.19 treatment difference **/ 
%SSR_CP(nSamp=1000000,alpha=0.025,beta=0.2, sigma=1, cont=0, trt=0.19, delta=0.19,
          Nmax=870, r=0.5,t=0.5, c1=2.963, c2=1.969,titl=GSD Design with 0.19 treatment difference);

   
   /**********************************************/
   *Sample Size Re-estimation with Optimistic Delta*
   /**********************************************/
   
/***  SSR Design with 0.25 treatment difference **/;  
%SSR_CP(nSamp=1000000,alpha=0.025,beta=0.2, sigma=1, cont=0, trt=0.25, delta=0.25,
          Nmax=1008, r=0.5,t=0.5, c1=2.963, c2=1.969,titl=SSR Design with 0.25 treatment difference);

/***  SSR Design with 0.24 treatment difference **/;  
%SSR_CP(nSamp=1000000,alpha=0.025,beta=0.2, sigma=1, cont=0, trt=0.24, delta=0.25,
          Nmax=1008, r=0.5,t=0.5, c1=2.963, c2=1.969,titl=SSR Design with 0.24 treatment difference);
           
/***  SSR Design with 0.23 treatment difference **/;  
%SSR_CP(nSamp=1000000,alpha=0.025,beta=0.2, sigma=1, cont=0, trt=0.23, delta=0.25,
          Nmax=1008, r=0.5,t=0.5, c1=2.963, c2=1.969,titl=SSR Design with 0.23 treatment difference);

/***  SSR Design with 0.22 treatment difference **/;  
%SSR_CP(nSamp=1000000,alpha=0.025,beta=0.2, sigma=1, cont=0, trt=0.22, delta=0.25,
          Nmax=1008, r=0.5,t=0.5, c1=2.963, c2=1.969,titl=SSR Design with 0.22 treatment difference);
   
/***  SSR Design with 0.21 treatment difference **/;  
%SSR_CP(nSamp=1000000,alpha=0.025,beta=0.2, sigma=1, cont=0, trt=0.21, delta=0.25,
          Nmax=1008, r=0.5,t=0.5, c1=2.963, c2=1.969,titl=SSR Design with 0.21 treatment difference);

/***  SSR Design with 0.20 treatment difference **/;  
%SSR_CP(nSamp=1000000,alpha=0.025,beta=0.2, sigma=1, cont=0, trt=0.20, delta=0.25,
          Nmax=1008, r=0.5,t=0.5, c1=2.963, c2=1.969,titl=SSR Design with 0.20 treatment difference);

/***  SSR Design with 0.19 treatment difference **/;  
%SSR_CP(nSamp=1000000,alpha=0.025,beta=0.2, sigma=1, cont=0, trt=0.19, delta=0.25,
          Nmax=1008, r=0.5,t=0.5, c1=2.963, c2=1.969,titl=SSR Design with 0.19 treatment difference);
 

*** 3.5 ***;
 
proc seqdesign altref=0.15;
   OneSidedFixedSample: design nstages=1
   alt=upper alpha=0.025 beta=0.10;
   samplesize model=twosamplefreq(nullprop=0.15 test=prop);
run;

*** 3.6 ***;

proc seqdesign altref=0.15;
   OneSidedErrorSpending: design nstages=4
   method(alpha)=errfuncobf
   alt=upper  stop=reject
   alpha=0.025 beta=0.10;
   samplesize model=twosamplefreq(nullprop=0.15 test=prop);
   ods output Boundary=Bnd_Count;
run;

*** 3.7 ***;

%macro monitor(dat=,estimate=,stderr=,Stage=,tit=, Boundary=, Parms=,test= );
   data parms_&dat;
      Parameter="Trt";
      Estimate=&estimate.;
      Stderr=&stderr.;
      _Scale_="mle";
      _Stage_=&stage;
   Run;

   title;
   proc seqtest Boundary=&boundary
      Parms(Testvar=Trt)=&parms
      infoadj=prop errspendmin=0.001
      boundaryscale=stdz errspend
      plots=errspend pss;
      ods output Test=&test;
   run;
%mend monitor;

%monitor(dat=count1,estimate=0.01677,stderr=0.0781,Stage=1,Boundary=Bnd_Count,parms=Parms_Count1,test=Test_Count1);
%monitor(dat=count2,estimate=0.10330,stderr=0.0585,Stage=2,Boundary=Test_Count1,parms=Parms_Count2,test=Test_Count2);
%monitor(dat=count3,estimate=0.11000,stderr=0.0472,Stage=3,Boundary=Test_Count2,parms=Parms_Count3,test=Test_Count3);
