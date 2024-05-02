
/****************************** Decision Macro****************************/
/*%Decision decides if moving on to ASD stage by chi-square test.*/
/*OutcomeInput: dataset containing information on treatment and outcome, format subect_id || treatment || outcome */
/*GeneInput: dataset containing information on genes, format subject_id || gene */
/*TPInput: dataset containing specified turning parameter candidates, format eta || OS_R || gene_G */


%macro Decision(outcome, gene, par, alpha1, seed);
   %global seedit;
   %let seedit = &seed;

   data outcome;
      set &outcome;
   run;

   data gene;
      set &gene;
   run;

   data par;
      set &par;
   run;

   proc freq data=Outcome;
   table response*treatment/chisq;
   output out=chisqtest chisq;
   run;

   data _null_;
   set  chisqtest;
   call symput ("chisq_pvalue",P_PCHI);
   run;
   /*If the chi-squre test is significant based on prespecified alpha1, then print result and abort*/
   /*Otherwise, need to move on to CVASD stage*/
   %if  &chisq_pvalue <&alpha1 %then %do; 
   title "Chi-square Test SIGNIFICANT";
   proc print data=chisqtest;
   run;
   %abort;
   %end;
%mend Decision;


/****************************** CV Macro****************************/
/*%CV splits input dataset "CVin" to training and validation cohorts for K-fold cross validation*/
/*K: K-fold cross-validation*/
/*CVin: the input dataset that needs to split*/
/*kk: kk^th training and validation cohorts */

%macro CV(CVin,kk,K);
   data CVset;
   set &CVin;
   order=_N_;
   run;

   data _null_; /*count the number of patients in CVin*/
   set CVset end=eof;
   count+1;
   if eof then call symput("nobs",count);
   run;

   title1;
   proc plan seed=&seedit;
   factors rand=&nobs;
   output out=random;
   run;

   data random;
   set random;
   order=_N_;
   run;

   data CVset;
   merge CVset random;
   by order;
   drop order;
   run;

   data _null_; 
   n_v=int(&nobs/&K);
   call symput("n_v",n_v);
   run;

   /*To ensure the macro work for the case when total number of patients N is not divisible by K :*/
   /*if kk<K, n_v patients in the validation cohort, if kk=K, N-n_v*(K-1) patients in the validation cohort;*/ 
   data ValidationSet; 
   set CVset;
   if &kk<&K then do;
   if rand<=&n_v*(&kk-1) or rand>&n_v*&kk then delete; 
   end;
   else do;
   if rand<=&n_v*(&kk-1) then delete; 
   end;
   v_ind=1;
   drop rand;
   run;

   data TrainSet; /*create training data set*/
   merge CVset validationset;
   by subjid;
   if v_ind=.;
   drop v_ind rand;
   run;
%mend CV;

/**************************** Train Macro ***********************/
/*%Train produces a data set "sig_set" containing significant genes*/
/*significant genes are obtained by running logistic regression on Training dataset "TrainSet"*/
/*GeneTotalNum: total number of genes in the input gene dataset;*/  
/*Each gene will be assigned a gene_number in the macro: from left to the right in the input gene dataset, the first gene will have gene_num=1, and so on*/
/*Therefore, the range of gene_num is 1--&GeneTotalNum*/
/*eta: the turning parameter*/

%macro Train(GeneTotalNum, eta) ;
   data sig_set;
   run;

   %do i=1 %to &GeneTotalNum;
      %let var=gene&i;

      data singlegene;
      set Gene;
      keep subjid &var;
      run;

      data singlegene_outcome;
      merge singlegene TrainSet(in=a);
      by subjid;
      rename &var=gene_var;
      if a;
      run;

     title1;
      proc logistic descending data=singlegene_outcome;
      class treatment;
      model response=treatment treatment*gene_var;
      ods output ParameterEstimates=beta_test;
      run;

      data _null_;
      set  beta_test;
      if Variable eq "gene_var*treatment" then do;
      call symput ("beta_pvalue",ProbChiSq);
      call symput ("beta_est",Estimate);
      end;
      if Variable eq "treatment" then call symput("lambda_est",Estimate);
      run;
      data tmp;
      beta_pvalue=&beta_pvalue;
      beta_est=&beta_est;
      lambda_est=&lambda_est;
      gene_num=&i;
      run;

      data sig_set;
      set sig_set tmp;
      run;
   %end;

   data sig_set; /*significant genes are defined as genes with significant interaction (p_value < eta) in single gene logistic regression*/
   set sig_set;
   if gene_num=. then delete;
   if beta_pvalue<&eta then gene_sig=1;
   else gene_sig=0;
   if gene_sig=0 then delete;
   keep beta_pvalue beta_est lambda_est gene_num;
   run;
%mend Train; 

/***************************** Validation Macro *****************************/
/*%Validate is for identifying sensitive patients in the validation cohort "Validationset"*/
/* The output data set sens_set contains the subject id of the sensitive patients in the validation cohort */
/*GeneTotalNum: total number of genes in the input gene dataset;*/
/*OS_R and gene_G: the turning parameter*/

%macro Validate (GeneTotalNum, OS_R, gene_G);
   data sens_set;
   set Validationset;
   keep subjid;
   run;

   proc sql;
   create table joint as
   select * from sens_set, sig_set;
   run;

   data joint;
   set joint;
   joint_ind=1;
   run;

   proc sort data=joint;
   by subjid;
   run;

   data joint;
   merge joint gene;
   by subjid;
   if joint_ind=. then delete;
   drop joint_ind;
   run;

   data _null_;
   nvar1=&GeneTotalNum;
   nvar=put(nvar1,8.);
   nvar=trim(left(nvar));
   lastvar="gene"||nvar;
   call symput("lastvar",lastvar);
   run;

   data joint; /*testing on the significant genes if the predictive new vs control arm odds ratio exceeds threshold &OS_R */
   set joint;
   array x{&GeneTotalNum} gene1-&lastvar;
   os=exp(lambda_est+beta_est*x{gene_num});
   if os>&OS_R then ind=1;
   else ind=0;
   run;

   proc sort data=joint;
   by subjid;
   run;

   data sens_set;/*counting number of significant genes having predictive odds ratio exceeds the threshold*/
   set joint;
   by subjid;
   if first.subjid then sum=0;
   sum=sum+ind;
   retain sum;
   run;

   data sens_set;
   set sens_set;
   if sum>=&gene_G then sens=1;
   if sum<&gene_G then delete;
   keep subjid sens;
   run;

   proc sort data=sens_set nodup;
   by subjid;
   run;

   title "Sensitive Subjects";
   proc print data = sens_set;
   run;
%mend Validate;


/***************************Comparision Macro************************************
/*%Comparison serves as a inner macro of the TP Macro*/
/* it calculates the P-value for comparing response rate between two treatment groups in sensitive subgroup for each set of turning parameters*/

%macro Comparison (sens_in);
   data sens_pt;
   set &sens_in;
   if sens=1;
   keep subjid treatment response;
   run;

   proc freq data=sens_pt;
   table response*treatment/chisq;
   output out=chisqtest chisq;
   run;

   data _null_;
   set  chisqtest;
   call symput ("comp_pvalue",P_PCHI);
   run;

   data p_tmp;
   comp_pvalue=&comp_pvalue;
   par_num=&jj;
   run;
%mend Comparison;


/***************************** TP Macro *****************************/
/*%TP is for choosing the best turning parameters from a pre-specified list of plausible turning parameters*/
/*the list of plausible truning parameters were put in the dataset Par, format eta || OS_R || gene_G */
/*The process is done by applying K-fold cross-validation on the dataset "TrainSet"*/

%macro TP (GeneTotalNum, K);
   data _null_; 
   set Par end=eof;
   count+1;
   if eof then call symput("npar",count);
   run;      

   data Trainin; /*perfrom K-fold CV on TrainSet*/
   set TrainSet;
   run;

   data p_par_set;
   run;

   %do jj=1 %to &npar;

      data _null_;
      set Par;
      if _N_=&jj then do;
      call symput("eta",compress(trim(eta))); 
      call symput("OS_R",compress(trim(OS_R))); 
      call symput("gene_G",compress(trim(gene_G))); 
      end;

      data sens_out;
      run;

      %do k2=1 %to &K;
         %CV(Trainin, &k2, &K);
         %Train(&GeneTotalNum, &eta);
         %Validate(&GeneTotalNum, &OS_R, &gene_G);

         data sens_out;
         set sens_out sens_set;
         run;
      %end;

      proc sort data=sens_out;
      by subjid;
      run;

      data sens_out;
      merge sens_out Outcome;
      by subjid;
      run;

      %Comparison(sens_out)

      data p_par_set;
      set p_par_set p_tmp;
      run;
   %end;

   data p_par_set;
   set p_par_set;
   if comp_pvalue=. then delete;
   run;

   proc sql;
   create table par_final as
   select * from p_par_set 
   having comp_pvalue=min(comp_pvalue);
   run;

   data par_final;
   set par_final;
   call symput("npar_min",par_num);
   run;

   data _null_;
   set Par;
   if _N_=&npar_min then do;
   call symput("eta",eta);
   call symput("OS_R",OS_R);
   call symput("gene_G",gene_G);
   end;  /*turning parameter selected*/

   data par_final;
   eta=&eta;
   OS_R=&OS_R;
   gene_G=&gene_G;
   run;
%mend TP;

/************************************Resubstitution Macro****************************************************/
/*%Resubstitution is for calculating the resubstitution estimator*/
/*to save computation time, turning parameter is selected by doing K-fold cross-validation on the first CV subset as that did in Freidlin et al. (2010)  */
/* Data: the full study dataset want to apply CVASD algorithm, format subect_id || treatment || outcome */

%macro Resubstitution (GeneTotalNum, K);
   %CV(Outcome, 1, &K);
   %TP (&GeneTotalNum, &K);

   data _null_;
   set par_final;
   call symput("final_eta",compress(trim(eta))); 
   call symput("final_R",compress(trim(OS_R))); 
   call symput("final_G",compress(trim(gene_G))); 
   run; 

   data sens_out;
   run;

   %do k2=1 %to &K;
      %CV(Outcome, &k2, &K);
      %Train(&GeneTotalNum, &final_eta);
      %Validate(&GeneTotalNum, &final_R, &final_G);

      data sens_out;
      set sens_out sens_set;
      run;
   %end;

   proc sort data=sens_out;
   by subjid;
   run;

   data sens_out;
   merge sens_out Outcome;
   by subjid;
   run;

   data sens_pt;
   set sens_out;
   if sens=1;
   keep subjid treatment response;
   run;

   proc freq data=sens_pt;
   table response*treatment/nocol nopercent;
   run;

   title "Selected Parameters";
   proc print data = par_final;
   run;
%mend Resubstitution;


/************************CVest Macro************************************/
/*%CVest is for calculating the CV estimator**************************/
/*the best set of turning parameters is selected from the entire study population********/

%Macro CVest (GeneTotalNum, K);
   data TrainSet;
   set Outcome;
   run;

   %TP(&GeneTotalNum, &K);

   data _null_;
   set par_final;
   call symput("final_eta",compress(trim(eta))); 
   call symput("final_R",compress(trim(OS_R))); 
   call symput("final_G",compress(trim(gene_G))); 
   run; 

   data sens_out;
   run;

   %do k2=1 %to &K;
      %CV(Outcome, &k2, &K);
      %Train(&GeneTotalNum, &final_eta);
      %Validate(&GeneTotalNum, &final_R, &final_G);

      data sens_out;
      set sens_out sens_set;
      run;
   %end;

   proc sort data=sens_out;
   by subjid;
   run;

   data sens_out;
   merge sens_out Outcome;
   by subjid;
   run;

   data sens_pt;
   set sens_out;
   if sens=1;
   keep subjid treatment response;
   run;

   proc freq data=sens_pt;
   table response*treatment/nocol nopercent;
   run;

   title "Selected Parameters";
   proc print data = par_final;
   run;
%mend CVest;

*************************;
*************************;
*************************;

libname perm "C:\Users\rizink\Desktop\B\Chapter12 Final\Final Chapter 11 Programs";

%Decision(perm.adsl, perm.adgene, perm.par, 0.04, seed = 12345);
%Resubstitution(10, 5);

%Decision(perm.adsl, perm.adgene, perm.par, 0.04, seed = 12345);
%CVest(10, 5);
