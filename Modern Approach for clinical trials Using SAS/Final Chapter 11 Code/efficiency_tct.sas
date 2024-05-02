/*Macros (%simnorm and %simgamma)are developed for calculating required sample size for a certain power based on */
/*Formula (6) in "On the efficiency of targeted clinical trials" by Maitournam et al.*/
/*%simnorm is for the case when treatment response follows normal distribution*/
/*simgamma is for the case when treatment response follows gamma distribution*/
/*alpha: significance level, power: 1-beta*/
/*seed1 and seed2: randomization seed used for generating random numbers*/
/*mux,muy: mean of treatment response for control and experimental group*/
/*stdx, stdy: standard deviation of treatment response for control and experimental group*/
/*p1: probability that a control outcome is less than a treatment outcome*/
/*p2: probability that a control outcome is simultaneously less than two independent treatment outcomes*/
/*p3: probability that a treatment outcome is simultaneously greater than two independent control outcomes*/

%macro MSpower(beta, p1, p2, p3, alpha);
   data result;   
      delta=1-(&alpha/2);      
      za=quantile('Normal', delta);      
      p1=&p1; p2=&p2; p3=&p3;alpha=&alpha;      
      do i= 1 to 10000;      
         nsize=i;
         denum=(i**2)*( p1*(1-p1) + (i-1)*(p2 + p3 - 2*(p1**2)) );
         den=sqrt(denum);
         a=(0.5* (i**2) + za*sqrt((i**2)*(2*i + 1)/12) - 0.5 - (i**2)*p1)/den;   
         beta= CDF('Normal', a);
         power=1-beta;
         output;      
         if beta<=&beta then i=10001;      
      end;   
   run;

   data result2;
      set result end =_end;   
      end=_end;      
      if end;      
      if beta>&beta then do;
        warning=1;
        nsize2=">10000";
      end;
      else do;
        nsize2=compress(nsize);
      end;      
      label nsize2='sample size';
    run;

   proc format;
      value wa 1='required sample size greater than 10000';
   run;
   
   proc print noobs label;
     var nsize2 p1 p2 p3 alpha beta power warning;
     format warning wa.;
   run;
%mend MSpower;

%MSpower(0.2, 0.7, 0.6, 0.4, 0.05);



%macro simnorm(seed1, seed2, mux, muy, stdx, stdy, beta, simN=10000, alpha=0.05);
   data x;
      call streaminit(&seed1); 
      do i=1 to &simN;
         x=rand('normal', &mux, &stdx);
         output;
      end;
   run;
   
   data y;
      call streaminit(&seed2); 
      do i=1 to &simN;
         y=rand('normal', &muy, &stdy);
         output;
      end;
   run;
   
   data one;
      merge x y;      
      if x<y then flag=1;
      else flag=0;
   run;
   
   proc means noprint data=one;
      var flag;
      output out=p1 mean=p1;
   run;
   
   data _null_;
      set p1;      
      call symput('p1', compress(trim(p1)));
   run;   
   
   data _null_;
      sy1=&seed2 +1;
      call streaminit(sy1); 
      y1=rand('normal', &muy, &stdy);
      output;      
      call symput('y1', compress(trim(y1)));
   run;
   
   data _null_;
      sy2=&seed2 +2;
      call streaminit(sy2); 
      y2=rand('normal', &muy, &stdy);
      output;      
      call symput('y2', compress(trim(y2)));
   run;
   
   data x;
      set x;      
      if x<&y1 and x<&y2 then flag=1;
      else flag=0;
   run;
   
   proc means noprint data=x;
      var flag;
      output out=p2 mean=p2;
   run;
   
   data _null_;
      set p2;      
      call symput('p2', compress(trim(p2)));
   run;
   
   data _null_;
      sx1=&seed1 +1;
      call streaminit(sx1); 
      x1=rand('normal', &mux, &stdx);
      output;      
      call symput('x1', compress(trim(x1)));
   run;
      
   data _null_;
      sx2=&seed1 +2;
      call streaminit(sx2); 
      x2=rand('normal', &mux, &stdx);
      output;      
      call symput('x2', compress(trim(x2)));
   run;
   
   data y;
      set y;      
      if y>&x1 and y>x2 then flag=1;
      else flag=0;
   run;
   
   proc means noprint data=y;
      var flag;
      output out=p3 mean=p3;
   run;
   
   data _null_;
      set p3;      
      call symput('p3', compress(trim(p3)));
   run;
   
   title 'Normal Distribution';     
   %MSpower(&beta., &p1., &p2., &p3., &alpha.);   
%mend simnorm;

%simnorm(seed1=1, seed2=100, mux=5, muy=8, stdx=2, stdy=1.5, beta=0.2, simN=10000, alpha=0.05); 



%macro simgamma(seed1, seed2, mux, muy, stdx, stdy, beta, simN=10000, alpha=0.05);   
   data temp;
      ax=round((&mux**2)/(&stdx**2), 0.0001);
      bx=round(&mux/(&stdx**2), 0.0001);      
      ay=round((&muy**2)/(&stdy**2), 0.0001);
      by=round(&muy/(&stdy**2), 0.0001);
   run;  
   
   data _null_;
      set temp;
      call symput('ax', compress(trim(ax)));
      call symput('bx', compress(trim(bx)));
      call symput('ay', compress(trim(ay)));
      call symput('by', compress(trim(by)));
   
   run;
      
   data x;
      set temp;
      call streaminit(&seed1);       
      do i=1 to &simN;      
         x=rand('gamma', ax);
         x=x/bx;
         output;      
      end;
   run;
   
   data y;
      set temp;
      call streaminit(&seed2);      
      do i=1 to &simN;     
         y=rand('gamma', ay);
         y=y/by;
         output;     
      end;
   run;
   
   data one;
      merge x y;     
      if x<y then flag=1;
      else flag=0;
   run;
   
   proc means noprint data=one;
      var flag;
      output out=p1 mean=p1;
   run;
   
   data _null_;
      set p1;     
      call symput('p1', compress(trim(p1)));
   run;
     
   data _null_;
      sy1=&seed2 +1;
      call streaminit(sy1);    
      y1=rand('gamma', &ay);
      y1=y1/&by;
      output;      
      call symput('y1', compress(trim(y1)));
   run;
   
   data _null_;
      sy2=&seed2 +2;
      call streaminit(sy2); 
      y2=rand('gamma', &ay);
      y1=y1/&by;
      output;      
      call symput('y2', compress(trim(y2)));
   run;
   
   data x;
      set x;      
      if x<&y1 and x<&y2 then flag=1;
      else flag=0;
   run;
   
   proc means noprint data=x;
      var flag;
      output out=p2 mean=p2;
   run;
   
   data _null_;
      set p2;      
      call symput('p2', compress(trim(p2)));
   run;   
   
   data _null_;
      sx1=&seed1 +1;
      call streaminit(sx1); 
      x1=rand('gamma', &ax);
      x1=x1/&bx;
      output;      
      call symput('x1', compress(trim(x1)));
   run;   
   
   data _null_;
      sx2=&seed1 +2;
      call streaminit(sx2);
      x2=rand('gamma', &ax);
      x2=x2/&bx;
      output;      
      call symput('x2', compress(trim(x2)));
   run;
   
   data y;
      set y;      
      if y>&x1 and y>x2 then flag=1;
      else flag=0;
   run;
   
   proc means noprint data=y;
      var flag;
      output out=p3 mean=p3;
   run;
   
   data _null_;
      set p3;      
      call symput('p3', compress(trim(p3)));      
   run;
        
   title 'Gamma Distribution';   
   %MSpower(&beta., &p1., &p2., &p3., &alpha.);
%mend simgamma;

%simgamma(1, 100, 25, 35,5, 5, 0.2, simN=10000, alpha=0.05);