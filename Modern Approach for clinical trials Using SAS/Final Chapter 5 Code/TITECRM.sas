/******************************************************************
This SAS macro implements the time-to-event continual reassessment 
method (TITE-CRM). This code is for the trial conduct purpose (one
single trial).

Created by Ruitao Lin and Guosheng Yin on January 5, 2015
*******************************************************************/

data currentdata;
   input doselevel DLT followup entrydate date7.;
   datalines;
   1 0 0 01Jan11 
   1 0 0 02Jan11 
   1 0 0 15Jan11 
   2 0 1 01Feb11 
   2 0 1 05Feb11 
   2 1 1 20Feb11
   3 1 1 03Mar11
   3 0 1 07Mar11
   3 0 1 10Mar11
   ;
run;

data skeleton;
   input p;
   datalines;
   0.1
   0.2
   0.3
   0.4
   0.5
   0.6
   ;
run;

%macro TITECRM(currentdata,skeleton,currenttime,tau=90,target=0.3,toxstop=0.9);
   proc iml;
      use &skeleton.;
      read all;
      use &currentdata.;
      read all;
      currenttime=inputn(&currenttime.,'date7.');
      ndose=nrow(p);
      doseselect={};
      dosecurr=doselevel[nrow(doselevel)];
      w=(followup=0)+(followup=1)#(currenttime-entrydate)/&tau;
      stop=0;

      start posterior(alpha) global(DLT,doselevel,p,w);
         sigma2=2;
         lik=1;
         nn=nrow(DLT);
         aa=sum(DLT);

         if aa=0 then do;
            do k=1 to nn;
               pi=(p[doselevel[k]])##exp(alpha);
               lik=lik*((1-w[k]*pi)##(1-DLT[k]));
            end;
         end;
         else do;
            do k=1 to nn;
               pi=(p[doselevel[k]])##exp(alpha);
               lik=lik*((w[k]*pi)##(DLT[k]))*((1-w[k]*pi)##(1-DLT[k]));
            end;
         end;

         lik=lik*exp(-0.5*alpha*alpha/sigma2);
         return(lik);
      finish;

      /* used to calculate the posterior mean of pi */
      start posttoxf(alpha) global(j,DLT,doselevel,p);
         post=p[j]##exp(alpha)*posterior(alpha);
         return(post);
      finish; 

      call quad(marginal, "posterior", {.M .P}) eps=1E-4 peak=-1 scale=0.5;  /* default: PEAK=1 */
      pi={};
      do j=1 to ndose;
         call quad(pij,"posttoxf",{.M .P}) eps=1E-4 peak=-1 scale=0.5;
         pij=pij/marginal;
         pi=pi//pij;
      end;

      lb=log(log(&target)/log(p[1]));

      call quad(povertox,"posterior",-35||lb) eps=1E-4 peak=-1 scale=0.5;
      povertox=povertox/marginal;
      if povertox>&toxstop then stop=1;
      diff=abs(pi-&target);
      dosebest=diff[>:<];
      if dosebest>dosecurr then
         if dosecurr<ndose then do;
         dosenext=dosecurr+1;
      end;
      if dosebest<dosecurr then
         if dosecurr>1 then do;
         dosenext=dosecurr-1;
      end;

      if stop=1 then dosenext="The trial should be terminated early";
      *title "dose for next patient";
      print dosenext;

      doselevel=1:ndose;
      doselevel=doselevel`;
      create doselevel from doselevel[colname="doselevel"];
      append from doselevel;

      create pi from pi[colname="pi"];
      append from pi;
   quit;

   data &skeleton.; 
      merge &skeleton. pi doselevel;
   run;

   *title "Skeleton Versus Estimated Toxicity Probability";
   proc sgplot data = skeleton;
      vline doselevel / response = p markers legendlabel='p' markerattrs=(symbol=circlefilled size=10pt) lineattrs=(pattern = solid); 
      vline doselevel / response = pi markers legendlabel='pi' markerattrs=(symbol=trianglefilled size=10pt) lineattrs=(pattern = solid);
      yaxis min = 0 max = 1 label="Toxicity Probability";
      xaxis label="Dose Level";
      refline &target / axis=y label="Toxicity Target" LABELLOC= INSIDE LABELPOS= min lineattrs=(pattern = shortdash);
      keylegend / location=inside noborder;
   run;
%mend TITECRM;

%TITECRM(currentdata,skeleton,'20Apr11',tau=90,target=0.3,toxstop=0.9);
