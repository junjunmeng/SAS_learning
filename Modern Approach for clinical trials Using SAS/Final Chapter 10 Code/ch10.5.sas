/*  Description::   Section 5: Sample size and power for RAR
   Program::      ch10.5.sas
    Author::         Gaurav Sharma
    Date::        2/23/15
    Description:: This program should reproduce Table 4 of the paper
*/

/* Section 5: Sample size and power for RAR - Start Defining Functions */
proc fcmp outlib = sasuser.ch5.lib;

*Power for the fixed allocation design;
function fix_power(p_E, p_C, n, rho, alpha);
   d=(p_E-p_C)/sqrt(p_E*(1-p_E)/rho/n + p_C*(1-p_C)/(1-rho)/n);
   return(1-cdf('NORMAL',quantile('NORMAL',1-alpha/2)-d) + cdf('NORMAL',-quantile('NORMAL',1-alpha/2)-d));
endsub;

*Average power;
function pow (p_E, p_C, rho, tau, alpha, n, x);
   pi = CONSTANT('PI');
   return(cdf('NORMAL',(p_E-p_C)/sqrt(p_E*(1-p_E)/(rho*n+tau*sqrt(n)*x) + p_C*(1-p_C)/((1-rho)*n-tau*sqrt(n)*x)) - quantile('NORMAL',1-alpha))*exp(-x**2/2)/sqrt(2*pi));
endsub;

*Function to perform numerical integration;
function integrate (p_E, p_C, rho, tau, alpha, n, a, b);
  eps = 1e-6 ;
  jmax = 15 ;
  reldiff = eps + 1 ;
  
  fa=pow(p_E, p_C, rho, tau, alpha, n, a) ;
  fb=pow(p_E, p_C, rho, tau, alpha, n, b) ;
  newint = .5 * (b - a) * (fa + fb) ;
  newsimp = newint ;
  oldsimp = newsimp ;

  oldint = newint ;
  reldiff = 1 + eps ;
  it = 1 ;
  qsimp = 0 ;

  do j = 1 to jmax while (qsimp = 0 ) ;

     tnm = it ;
     del = (b - a) / tnm ;

     sumfun = 0 ;
     x = a + .5 * del ;

     do i = 1 to it ;

        fx=pow(p_E, p_C, rho, tau, alpha, n, x) ;
        sumfun = sumfun + fx ;
        x = x + del ;

     end ;

     newint = .5 * (newint + (b - a) * sumfun / tnm) ;

     reldiff = abs((newint - oldint) / oldint) ;
     newsimp = (4 * newint - oldint) / 3 ;
     if (abs(newsimp - oldsimp) < eps * abs(oldsimp)) then qsimp = 1 ;
     oldsimp = newsimp ;
     oldint = newint ;
     it = it * 2 ;

  end ;

  *if (j >= jmax & qsimp = 0) then do ;
  *stop ;
  *end ;

  return(newsimp);
endsub;

function avg_power (design$, n, p_E, p_C, alpha);
   if (design='CRD') then do;
     rho=1/2; tau=1/2;
     ans=integrate(p_E, p_C, rho, tau, alpha, n, -5, 5);
   end;
   if (design='ERADE') then do;
     rho=sqrt(p_E)/(sqrt(p_E)+sqrt(p_C)); tau=sqrt(1/4/(sqrt(p_E)+sqrt(p_C))**3*(p_C*(1-p_E)/sqrt(p_E)+p_E*(1-p_C)/sqrt(p_C)));
     ans=integrate(p_E, p_C, rho, tau, alpha, n, -10,10);
   end;
   return(ans);
endsub;
   
*Sample size to achieve given power for the fixed design;
function n_fixed (design$, p_E, p_C, alpha, beta);
   if (design='CRD') then rho=1/2;
   if (design='RSIHR') then rho=sqrt(p_E)/(sqrt(p_E)+sqrt(p_C));
   return(ceil((p_E*(1-p_E)/rho + p_C*(1-p_C)/(1-rho))*(quantile('NORMAL',1-alpha)+quantile('NORMAL',1-beta))**2/(p_E-p_C)**2));
endsub;

*Sample size to achieve given average power;
function n_avg(design$, p_E, p_C, alpha, beta);
   if (design='CRD') then do;
     rho=1/2; tau=1/2; n=n_fixed('CRD', p_E, p_C, alpha, beta);
     do while(avg_power('CRD', n, p_E, p_C, alpha)<=1-beta);
      n=n+1;
     end;
   end;
   if (design='ERADE') then do;
     rho=sqrt(p_E)/(sqrt(p_E)+sqrt(p_C)); tau=sqrt(1/4/(sqrt(p_E)+sqrt(p_C))**3*(p_C*(1-p_E)/sqrt(p_E)+p_E*(1-p_C)/sqrt(p_C))); 
     n=n_fixed('RSIHR', p_E, p_C, alpha, beta);
     do while(avg_power('ERADE', n, p_E, p_C, alpha)<=1-beta);
      n=n+1;
     end;
   end;
   return(n);
endsub;

*Sample size to achieve given power with given probability;
function n_prob (design$, p_E, p_C, alpha, beta, xi);
   if (design='CRD') then do;
      rho=1/2; tau=1/2; n=n_fixed('CRD', p_E, p_C, alpha, beta);
        do while (
         ((p_E*(1-p_E)/(rho*n-quantile('NORMAL',1-xi/2)*tau*sqrt(n)) + p_C*(1-p_C)/((1-rho)*n+quantile('NORMAL',1-xi/2)*tau*sqrt(n)) >= 
         ((p_E-p_C)/(quantile('NORMAL',1-alpha)+quantile('NORMAL',1-beta)))**2)) |
         ((p_E*(1-p_E)/(rho*n+quantile('NORMAL',1-xi/2)*tau*sqrt(n)) + p_C*(1-p_C)/((1-rho)*n-quantile('NORMAL',1-xi/2)*tau*sqrt(n)) >=
         ((p_E-p_C)/(quantile('NORMAL',1-alpha)+quantile('NORMAL',1-beta)))**2))
         ); 
          n=n+1;
      end;
   end;
   if (design='ERADE') then do;
      rho=sqrt(p_E)/(sqrt(p_E)+sqrt(p_C)); tau=sqrt(1/4/(sqrt(p_E)+sqrt(p_C))**3*(p_C*(1-p_E)/sqrt(p_E)+p_E*(1-p_C)/sqrt(p_C)));
      n=n_fixed('RSIHR', p_E, p_C, alpha, beta);
       do while (
         ((p_E*(1-p_E)/(rho*n-quantile('NORMAL',1-xi/2)*tau*sqrt(n)) + p_C*(1-p_C)/((1-rho)*n+quantile('NORMAL',1-xi/2)*tau*sqrt(n)) >= 
         ((p_E-p_C)/(quantile('NORMAL',1-alpha)+quantile('NORMAL',1-beta)))**2)) |
         ((p_E*(1-p_E)/(rho*n+quantile('NORMAL',1-xi/2)*tau*sqrt(n)) + p_C*(1-p_C)/((1-rho)*n-quantile('NORMAL',1-xi/2)*tau*sqrt(n)) >=
         ((p_E-p_C)/(quantile('NORMAL',1-alpha)+quantile('NORMAL',1-beta)))**2))
         ); 
       n=n+1;
      end;
   end;
   return(n);
endsub;

run;
/* Section 5: Sample size and power for RAR - Finish Defining Functions*/

options cmplib = sasuser.ch5;

data simul;
length design $5;
   do i = 1 to 4;
      do j = 1 to 2;
         p_E = (4+i)/10;
         if j = 1 then do;
         design = 'CRD';
         tar = 0.5;
         fixed = n_fixed('CRD', p_E, .4, .025, .1);
         avg = n_avg('CRD', p_E, .4, .025, .1);
         prob = n_prob('CRD', p_E, .4, .025, .1, .05);
         end;
         else do;
         design = 'ERADE';
         tar = sqrt(p_E)/(sqrt(p_E)+sqrt(0.4));
         fixed = n_fixed('RSIHR', p_E, .4, .025, .1);
         avg = n_avg('ERADE', p_E, .4, .025, .1);
         prob = n_prob('ERADE', p_E, .4, .025, .1, .05);
         end;
         output;
      end;
   end;
run;

data simul1;
   set simul;
   p_E_C = p_E|| ", 0.4";
run;

title1 "Table 4";
footnote;
ods escapechar='^';

ods listing close;
ods rtf file="Table4.rtf" style=&rtfstyle;

proc report data=simul1 split='|' headline center nowd;
  columns p_E_C design tar fixed avg prob;

  define p_E_C       / display center "p^{sub E}, p^{sub C}";
  define design   / display center "Design";
  define tar   / display "Target Allocation" center format=4.2;
  define fixed    / display "n^{sub I}" center;
  define avg      / display "n^{sub II}" center;
  define prob     / display "n^{sub III}" center;
run;

ods rtf close;
ods listing;
