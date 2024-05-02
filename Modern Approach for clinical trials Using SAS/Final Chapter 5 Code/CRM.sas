/******************************************************************
This SAS macro implements the continual reassessment method (CRM). 
This code is for the trial conduct purpose (one single trial).

Created by Ruitao Lin and Guosheng Yin on January 5, 2015
*******************************************************************/

%macro CRM(currentdata,skeleton,target=0.3,toxstop=0.9);
   proc iml;
      use &currentdata.;
      read all;
      use &skeleton.;
      read all;
      pihat={};
      ndose=nrow(p);
      dosecurr=doselevel[nrow(doselevel)];
      stop=0;
      /* posterior=likelihood * prior */
      start posterior(alpha) global(DLT,doselevel,p,cohortsize);
         sigma2=2;
         lik=1;
         nn=nrow(DLT);
         do k=1 to nn;
            pi=(p[doselevel[k]])##exp(alpha);
            lik=lik*(pi##(DLT[k]))*((1-pi)##(cohortsize[k]-DLT[k]));
         end;
         lik=lik*exp(-0.5*alpha*alpha/sigma2);
         return(lik);
      finish;

      /* used to calculate the posterior mean of pi */
      start posttoxf(alpha) global(j,DLT,doselevel,p,cohortsize);
         post=p[j]##exp(alpha)*posterior(alpha);
         return(post);
      finish; 

      call quad(marginal, "posterior", {.M .P}) eps=1E-4 peak=0.1;  

      pi={};
      do j=1 to ndose;
         call quad(pij,"posttoxf",{.M .P}) ;
         pij=pij/marginal;
         pi=pi//pij;
      end;

      lb=log(log(&target)/log(p[1]));
      call quad(povertox,"posterior",-35||lb) eps=1E-4 peak=0.1;
      povertox=povertox/marginal;

      if povertox>&toxstop then stop=1;

      diff=abs(pi-&target);
      dosebest=diff[>:<];
      dosenext=dosecurr;

      if dosebest>dosecurr then
         if dosecurr<ndose then do;
         dosenext=dosecurr+1;
      end;

      if dosebest<dosecurr then
         if dosecurr>1 then do;
         dosenext=dosecurr-1;
      end;

      if stop=1 then dosenext="The trial should be terminated early";
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
%mend CRM;

data currentdata;
   input DLT doselevel cohortsize;
   datalines;
   0 1 3
   1 2 3
   0 2 3
   2 3 3 
   0 2 3
   ;
run;

data skeleton;
   input p;
   datalines;
   0.05
   0.1
   0.25
   0.40
   0.55
   0.65
   ;
run;

%CRM(currentdata,skeleton);
