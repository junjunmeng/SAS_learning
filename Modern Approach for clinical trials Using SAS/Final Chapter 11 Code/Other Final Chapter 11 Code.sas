*** 11.4 ***;

%macro power(pe, pc, alpha, N);
   data result;
      pe=&pe;
      pc=&pc;
      alpha=&alpha;
      N=&N;
      b=1-&alpha;
      pbar=(pe+pc)/2;
      za=quantile('Normal', b);
      num=(pe-pc)-za*sqrt(pbar*(1-pbar)*4/N);
      den=sqrt(pe*(1-pe)*2/N+pc*(1-pc)*2/N);
      a=num/den;
      power=CDF('Normal', a);
   run;

   proc print noobs;
      var pe pc N alpha power;
   run;
%mend power;

%power(0.5, 0.2, 0.05, 100);

*** 11.5 ***;
%macro events(delta, alpha, beta, pi);
   data result;
      alpha=&alpha;
      power=1-&beta;
      delta=&delta;
      pi=&pi;
      za=quantile('Normal', 1-&alpha);
      zb=quantile('Normal', 1-&beta);
      logd=log(&delta);
      D=4*((za+zb)/logd)**2;
      Ds=D/(pi**2);

      label delta='hazard ratio';
      label pi="treatment effect fraction";
      label Ds='events required';
   run;

   proc print noobs label;
      var alpha power delta pi Ds;
   run;
%mend events;

%events(2, 0.05, 0.2, 0.8);

*** 11.10 ***;
%macro subpower(f,alpha_a, beta_a, es_ratio, alpha_g);  
   data result;
      f=&f;
      alpha_a=&alpha_a;
      beta_a=&beta_a;
      es_ratio=&es_ratio;
      za=quantile('Normal', 1-&alpha_a);
      zb=quantile('Normal', 1-&beta_a);
      zag=quantile('Normal', 1-&alpha_g);
      d=sqrt(&f)*es_ratio*(za+zb)-zag;
      sub_power=CDF('Normal', d);
      label es_ratio="effect size ratio";
      label f="sample size ratio";
   run;

   proc print noobs label;
      var f alpha_a beta_a es_ratio sub_power;
   run;
%mend subpower;
%subpower(0.5, 0.04, 0.2, 2, 0.01);
