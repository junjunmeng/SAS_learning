/******************************************************************
This SAS macro implements the fractional continual reassessment 
method (fCRM). This code is for the trial conduct purpose (one
single trial).

Created by Ruitao Lin and Guosheng Yin on January 5, 2015
*******************************************************************/

data currentdata;
   input doselevel DLT followup entrydate timetoevent;
   informat entrydate timetoevent date7.;
   datalines;
   1 0 0 01Jan11 01Apr11
   1 0 0 02Jan11 02Apr11
   1 0 0 15Jan11 15Apr11
   2 0 0 01Feb11 02May11
   2 0 0 03Feb11 05May11
   2 1 0 20Feb11 13Apr11
   3 1 1 03Mar11 20Apr11
   3 0 1 07Mar11 10May11
   3 0 1 10Mar11 10May11
   3 0 1 01Apr11 10May11
   3 1 1 02Apr11 28Apr11
   3 0 1 02Apr11 10May11
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

%macro fCRM(currentdata,skeleton,currenttime,tau=90,target=0.3,toxstop=0.9);
   proc iml;
      use &skeleton.;
      read all;
      use &currentdata.;
      read all;

      start posterior(alpha) global(DLT,doselevel,p);
         sigma2=2;
         lik=1;
         nn=nrow(DLT);
         aa=sum(DLT);

         if aa=0 then do;
            do k=1 to nn;
               pi=(p[doselevel[k]])##exp(alpha);
               lik=lik*((1-pi)##(1-DLT[k]));
            end;
         end;
         else do;
            do k=1 to nn;
               pi=(p[doselevel[k]])##exp(alpha);
               lik=lik*(pi##(DLT[k]))*((1-pi)##(1-DLT[k]));
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

      currenttime=inputn(&currenttime.,'date7.');

      ndose=nrow(p);
      doseselect={};
      dosecurr=doselevel[nrow(doselevel)];

      stop=0;
      Time=DLT#(timetoevent-entrydate)+(1-DLT)#((1-followup)#&tau+followup#(timetoevent-entrydate));

      if sum(DLT)=0 then do;
         if dosecurr<ndose then dosenext=dosecurr+1;
      end;
      else do;
         create survivaldata var{Time DLT};
            append;
         close survivaldata;

         *** Need to specify directory of file ***;
         %include "KM.sas";

         use survivalcurve;
            read all;
         close survivalcurve;
         *compute S(&tau);
         k = loc( Time<=&tau ); 
         k=k[ncol(k)];
         stau=SURVIVAL[k];
         if missing(stau)=1 then stau=min(SURVIVAL);

         print stau;
         *compute S(t) for censored data;
         do j=1 to nrow(DLT);
         if (followup[j]=1) then
            if (DLT[j]=0) then do;
               k=loc( Time<=(timetoevent[j]-entrydate[j]) );
               k=k[ncol(k)];
               st=SURVIVAL[k];
               if missing(st)=1 then st=min(SURVIVAL);
               DLT[j]=(st-stau)/st;
            end;
         end;

         imputedDLT=DLT;

         print imputedDLT;
         /* posterior=likelihood * prior */

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

         if povertox>&toxstop then do;
            stop=1;
         end;

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
      end;

      if stop=1 then dosenext="The trial should be terminated early";

      print dosenext[colname='doselevel level for next cohort'];

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

   proc sgplot data = skeleton;
      vline doselevel / response = p markers legendlabel='p' markerattrs=(symbol=circlefilled size=10pt) lineattrs=(pattern = solid); 
      vline doselevel / response = pi markers legendlabel='pi' markerattrs=(symbol=trianglefilled size=10pt) lineattrs=(pattern = solid);
      yaxis min = 0 max = 1 label="Toxicity Probability";
      xaxis label="Dose Level";
      refline &target / axis=y label="Toxicity Target" LABELLOC= INSIDE LABELPOS= min lineattrs=(pattern = shortdash);
      keylegend / location=inside noborder;
   run;
%mend fCRM;


%fCRM(currentdata,skeleton,'10May11',tau=90,target=0.3,toxstop=0.9);
