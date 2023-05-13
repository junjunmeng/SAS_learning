*--------------------------------------------------------------------------*
| Programs and Data from Applied Statistics and the SAS Programming        |
| Language, 5th edition                                                    |
|                                                                          |
| The following file are available for downloading:                        |
|                                                                          |
| PROGRAMS.SAS - This file contains the programs used in this book         |
|                                                                          |
| HOMEWORK.DAT - Homework data and program files                           |
|                                                                          |
| HW_SOLUTIONS_ODD.SAS - Solutions to the odd-numbered homework problems   |                                                    |
|                                                                          |
| HW_SOLUTIONS_EVEN.SAS - Solutions to the even-numbered homework          |
|                         problems (available only to faculty)             |
*--------------------------------------------------------------------------*;
 
***Chapter 1;
DATA TEST;
   INPUT SUBJECT 1-2 GENDER $ 4 EXAM1 6-8 EXAM2 10-12
         HW_GRADE $ 14;
DATALINES; 
10 M  80  84 A
7  M  85  89 A
4  F  90  86 B
20 M  82  85 B
25 F  94  94 A
14 F  88  84 C
;
PROC MEANS DATA=TEST;
RUN;

PROC MEANS DATA=TEST;
   VAR EXAM1 EXAM2;
RUN;

PROC MEANS DATA=TEST N MEAN STD STDERR MAXDEC=1;
   VAR EXAM1 EXAM2;
RUN;

DATA EXAMPLE; 
   INPUT SUBJECT GENDER $ EXAM1 EXAM2 
         HW_GRADE $;
   FINAL = (EXAM1 + EXAM2) / 2;  
   IF FINAL GE 0 AND FINAL LT 65 THEN GRADE='F';  
   ELSE IF FINAL GE 65 AND FINAL LT 75 THEN GRADE='C'; 
   ELSE IF FINAL GE 75 AND FINAL LT 85 THEN GRADE='B';
   ELSE IF FINAL GE 85 THEN GRADE='A';
DATALINES; 
10   M   80   84   A
7   M   85   89   A
4   F   90   86   B
20   M   82   85   B
25   F   94   94   A
14   F   88   84   C
;
PROC SORT DATA=EXAMPLE; 
   BY SUBJECT; 
RUN; 
PROC PRINT DATA=EXAMPLE; 
   TITLE "Roster in Student Number Order";
   ID SUBJECT;
   VAR EXAM1 EXAM2 FINAL HW_GRADE GRADE;
RUN;
PROC MEANS DATA=EXAMPLE N MEAN STD STDERR MAXDEC=1;
   TITLE "Descriptive Statistics";
   VAR EXAM1 EXAM2 FINAL;
RUN;
PROC FREQ DATA=EXAMPLE;
   TABLES GENDER HW_GRADE GRADE;
RUN;

PROC SORT DATA=EXAMPLE;
   BY GENDER SUBJECT;
RUN;

PROC MEANS DATA=EXAMPLE N MEAN MAXDEC=1;
RUN;

PROC MEANS DATA=EXAMPLE N MEAN STD MAXDEC=1;
   TITLE "Descriptive Statistics on Exam Scores";
   VAR EXAM1 EXAM2;
RUN;

PROC FREQ DATA=EXAMPLE;
   TABLES GENDER HW_GRADE GRADE/ NOCUM;
RUN;

PROC FREQ DATA=EXAMPLE ORDER=FREQ;
   TABLES GENDER HW_GRADE GRADE/ NOCUM;
RUN;

***Chapter 2;
***Program to create the HTWT data set
   and to compute descriptive statistics;
DATA HTWT;
   INPUT SUBJECT  
         GENDER  $ 
         HEIGHT 
         WEIGHT;
DATALINES;
1 M 68.5 155
2 F 61.2 99
3 F 63.0 115
4 M 70.0 205
5 M 68.6 170
6 F 65.1 125
7 M 72.4 220
8 M   .  188
;
PROC MEANS DATA=HTWT;
   TITLE "Simple Descriptive Statistics";
RUN;

PROC MEANS DATA=HTWT N MEAN MAXDEC=3;
   TITLE "Simple Descriptive Statistics";
   VAR HEIGHT;
RUN;

PROC UNIVARIATE DATA=HTWT;
   TITLE "More Descriptive Statistics";
   VAR HEIGHT WEIGHT;
RUN;

PROC UNIVARIATE DATA=HTWT NORMAL PLOT;
   TITLE "More Descriptive Statistics";
   VAR HEIGHT WEIGHT;
RUN;

PROC UNIVARIATE DATA=HTWT NORMAL PLOT;
   TITLE "More Descriptive Statistics";
   VAR HEIGHT WEIGHT;
   ID SUBJECT;
RUN;

GOPTIONS RESET=ALL 
         FTEXT='Arial/bo'
         CBACK=WHITE
         COLORS=(BLACK)
         GUNIT=PCT
         HTEXT=2
         HPOS=15;

PROC UNIVARIATE DATA=HTWT;
   TITLE "More Descriptive Statistics";
   VAR HEIGHT WEIGHT;
   HISTOGRAM HEIGHT / MIDPOINTS=60 TO 75 BY 5  NORMAL;
   INSET MEAN='Mean' (5.2) 
         STD='Standard Deviation' (6.3)/ FONT='Arial' 
                                         POS=NW
                                         HEIGHT=3;
RUN;
QUIT;

PROC UNIVARIATE DATA=HTWT;
   TITLE "More Descriptive Statistics";
   VAR HEIGHT WEIGHT;
   QQPLOT HEIGHT;
RUN;
QUIT;

*Sort the data by GENDER;
PROC SORT DATA=HTWT;
   BY GENDER;
RUN;
*Run PROC MEANS for each value of GENDER;
PROC MEANS DATA=HTWT N MEAN STD MAXDEC=2;
   TITLE "The MEANS Procedure, Using a BY Statement";
   BY GENDER;  *This is the statement that gives the breakdown;
   VAR HEIGHT WEIGHT;
RUN;

PROC MEANS DATA=HTWT N MEAN STD MAXDEC=2;
   TITLE "The MEANS Procedure, Using a CLASS Statement";
   CLASS GENDER;  *You do NOT have to sort the data when
                   you use a CLASS statement;
   VAR HEIGHT WEIGHT;
RUN;

DATA HTWT;
   INPUT SUBJECT  
         GENDER  $ 
         HEIGHT 
         WEIGHT;
DATALINES;
1 M 68.5 155
2 F 61.2 99
3 F 63.0 115
4 M 70.0 205
5 M 68.6 170
6 F 65.1 125
7 M 72.4 220
8 F   .  188
;
PROC FREQ DATA=HTWT;
   TITLE "Using PROC FREQ to Compute Frequencies";
   TABLES GENDER;
RUN;

GOPTIONS RESET=ALL 
         FTEXT='Arial/bo'
         CBACK=WHITE
         CTEXT=BLACK
         HPOS=25
         GUNIT=PCT
         HTEXT=2;
PATTERN VALUE=X1 COLOR=BLACK;
PROC GCHART DATA=HTWT;
   TITLE "Bar Chart from PROC GCHART";
   VBAR GENDER;
RUN;

PROC GCHART DATA=HTWT;
   TITLE "Distribution of Heights";
   VBAR HEIGHT / MIDPOINTS = 60 TO 74 BY 2;
RUN;

DATA E_MART;
   INPUT YEAR
         DEPT $
         SALES;
DATALINES;
2001 TOYS 5000
2001 TOYS 4500
2001 TOYS 5500
2001 FOOD 4100
2001 FOOD 3300
2002 TOYS 6344
2002 TOYS 4567
2002 TOYS 4300
2002 FOOD 3700
2002 FOOD 3900
2003 TOYS 7000
2003 TOYS 7200
2003 TOYS 6000
2003 TOYS 7900
2003 FOOD 4000
2003 FOOD 5800
2003 FOOD 5600
;

PATTERN VALUE=EMPTY COLOR=BLACK;
AXIS1 LABEL=('Department');
PROC GCHART DATA=E_MART;
   TITLE "Simple Frequency Bar GCHART";
   VBAR DEPT / MAXIS=AXIS1;
RUN;

PROC GCHART DATA=E_MART;
   TITLE "Bar Chart on a Numerical Variable (SALES)";
   VBAR SALES;
RUN;

PATTERN VALUE=L2 COLOR=BLACK;
PROC GCHART DATA=E_MART;
   TITLE "Distribution of SALES by Department";
   VBAR SALES / GROUP=DEPT MIDPOINTS=4500 TO 5500 BY 1000;
   FORMAT SALES DOLLAR8.0;
RUN;

PROC GCHART DATA=E_MART;
   TITLE "Sum of SALES by YEAR";
   VBAR YEAR / SUMVAR=SALES TYPE=SUM DISCRETE;
   FORMAT SALES DOLLAR8.;
RUN;

PROC GCHART DATA=E_MART;
   TITLE "Mean Sales by YEAR";
   VBAR YEAR / SUMVAR=SALES TYPE=MEAN DISCRETE;
   FORMAT SALES DOLLAR8.;
RUN;

PATTERN1 COLOR=BLACK VALUE=X1;
PATTERN2 COLOR=BLACK VALUE=L2;

PROC GCHART DATA=E_MART;
   TITLE "Demonstrating the SUBGROUP Option";
   VBAR YEAR / SUBGROUP=DEPT 
               SUMVAR=SALES 
               TYPE=SUM 
               DISCRETE;
   FORMAT SALES DOLLAR8.;
RUN;
QUIT;

PROC GCHART DATA=E_MART;
   TITLE "SALES Broken Down by YEAR and DEPT";
   VBAR YEAR / GROUP=DEPT SUMVAR=SALES TYPE=SUM DISCRETE;
   FORMAT SALES DOLLAR8.;
RUN;

PROC PLOT DATA=HTWT;
   TITLE "Scatter Plot of WEIGHT by HEIGHT";
   PLOT WEIGHT*HEIGHT;
RUN;

PROC GPLOT DATA=HTWT;
   TITLE "Scatter Plot of WEIGHT by HEIGHT";
   TITLE2 "Using all the Defaults";
   PLOT WEIGHT*HEIGHT;
RUN;

PROC SORT DATA=HTWT;
   BY GENDER;
RUN;
PROC PLOT DATA=HTWT;
   TITLE "Separate Plots by GENDER";
   BY GENDER;
   PLOT WEIGHT*HEIGHT;
RUN;

PROC PLOT DATA=HTWT;
   TITLE "Using GENDER to Generate the Plotting Symbol";
   PLOT WEIGHT*HEIGHT=GENDER;
RUN;

SYMBOL1 V=CIRCLE COLOR=BLACK;
SYMBOL2 V=SQUARE COLOR=BLACK;
***Note: SYMBOL and SYMBOL1 are equivalent;
PROC GPLOT DATA=HTWT;
   TITLE "Using GENDER to Generate the Plotting Symbol";
   PLOT WEIGHT*HEIGHT=GENDER;
RUN;

***Chapter 3;
DATA QUEST;
   INPUT ID        $ 1-3 
         AGE         4-5 
         GENDER    $   6 
         RACE      $   7 
         MARITAL   $   8 
         EDUCATION $   9
            PRESIDENT    10 
         ARMS         11 
         CITIES       12;
DATALINES;
001091111232
002452222422
003351324442
004271111121
005682132333
006651243425
;
PROC MEANS DATA=QUEST MAXDEC=2 N MEAN STD CLM;
   TITLE "Questionnaire Analysis";
   VAR AGE;
RUN;

PROC FREQ DATA=QUEST;
      TITLE "Frequency Counts for Categorical Variables";
      TABLES GENDER RACE MARITAL EDUCATION
          PRESIDENT ARMS CITIES;
RUN;

DATA QUEST;
   INPUT ID        $ 1-3 
         AGE         4-5 
         GENDER    $   6 
         RACE      $   7 
         MARITAL   $   8 
         EDUCATION $   9
            PRESIDENT    10 
         ARMS         11 
         CITIES       12;
LABEL    MARITAL   = "Marital Status"
         EDUCATION = "Education Level"
         PRESIDENT = "President Doing a Good Job"
         ARMS      = "Arms Budget Increase"
         CITIES    = "Federal Aid to Cities";
DATALINES;
001091111232
002452222422
003351324442
004271111121
005682132333
006651243425
;
PROC MEANS DATA=QUEST MAXDEC=2 N MEAN STD CLM;
   TITLE "Questionnaire Analysis";
   VAR AGE;
RUN;

PROC FREQ DATA=QUEST;
      TITLE "Frequency Counts for Categorical Variables";
      TABLES GENDER RACE MARITAL EDUCATION
          PRESIDENT ARMS CITIES;
RUN;

PROC FORMAT;
   VALUE $SEXFMT '1' = 'Male' 
                 '2' = 'Female'
              OTHER  = 'Miscoded';
   VALUE $RACE   '1' = 'White' 
                 '2' = 'African Am.' 
                 '3' = 'Hispanic'
                 '4' = 'Other';
   VALUE $OSCAR   '1' = 'Single' 
                 '2' = 'Married'
                 '3' = 'Widowed'
                 '4' = 'Divorced';
   VALUE $EDUC    '1' = 'High Sch or Less'
                  '2' = 'Two Yr. College'
                  '3' = 'Four Yr. College'
                  '4' = 'Graduate Degree';
   VALUE LIKERT   1 = 'Str Disagree'
                  2 = 'Disagree'
                  3 = 'No opinion'
                  4 = 'Agree'
                  5 = 'Str Agree';
RUN;

DATA QUEST;
   INPUT ID        $ 1-3 
         AGE         4-5 
         GENDER    $   6 
         RACE      $   7 
         MARITAL   $   8 
         EDUCATION $   9
         PRESIDENT    10 
         ARMS         11 
         CITIES       12;
   LABEL    MARITAL   = "Marital Status"
            EDUCATION = "Education Level"
            PRESIDENT = "President Doing a Good Job"
            ARMS      = "Arms Budget Increase"
            CITIES    = "Federal Aid to Cities";
   FORMAT GENDER    $SEXFMT. 
          RACE      $RACE. 
          MARITAL   $OSCAR.
          EDUCATION $EDUC. 
          PRESIDENT ARMS CITIES LIKERT.;
DATALINES;
001091111232
002452222422
003351324442
004271111121
005682132333
006651243425
;
PROC MEANS DATA=QUEST MAXDEC=2 N MEAN STD CLM;
   TITLE "Questionnaire Analysis";
   VAR AGE;
RUN;

PROC FREQ DATA=QUEST;
      TITLE "Frequency Counts for Categorical Variables";
      TABLES GENDER RACE MARITAL EDUCATION
          PRESIDENT ARMS CITIES;
RUN;

DATA QUEST;
   INPUT ID        $ 1-3 
         AGE         4-5 
         GENDER    $   6 
         RACE      $   7 
         MARITAL   $   8 
         EDUCATION $   9
         PRESIDENT    10 
         ARMS         11 
         CITIES       12;
   IF AGE GE 0 AND AGE LE 20 THEN AGEGRP = 1;
      ELSE IF AGE GT 20 AND AGE LE 40 THEN AGEGRP = 2;
      ELSE IF AGE GT 40 AND AGE LE 60 THEN AGEGRP = 3;
      ELSE IF AGE GT 60 THEN AGEGRP= 4 ;
   LABEL    MARITAL   = "Marital Status"
            EDUCATION = "Education Level"
            PRESIDENT = "President Doing a Good Job"
            ARMS      = "Arms Budget Increase"
            CITIES    = "Federal Aid to Cities";
   FORMAT GENDER    $SEXFMT. 
          RACE      $RACE. 
          MARITAL   $OSCAR.
          EDUCATION $EDUC. 
          PRESIDENT ARMS CITIES LIKERT.;
DATALINES;
001091111232
002452222422
003351324442
004271111121
005682132333
006651243425
;
PROC FREQ DATA=QUEST;
   TABLES GENDER -- AGEGRP;
RUN;

PROC FORMAT;
VALUE AGROUP LOW-20   = '0-20'
             21-40    = '21-40'
             41-60    = '41-60'
             60-HIGH  = 'Greater than 60'
                    . = 'Did Not Answer'
                OTHER =  'Out of Range';
PROC FREQ DATA=QUEST;
   TITLE "Using a Format to Group a Numeric Variable";
   TABLES AGE;
   FORMAT AGE AGROUP.;
RUN;

DATA ELECT;
   INPUT GENDER $ CANDID $ ;
   ***Note: only sample data here;
DATALINES;
M DEWEY
F TRUMAN
M TRUMAN
M DEWEY
F TRUMAN
;
PROC FREQ DATA=ELECT;
   TABLES GENDER CANDID
          CANDID*GENDER;
RUN;

DATA CHISQ;
      INPUT GROUP $ OUTCOME $ COUNT;
DATALINES;
DRUG ALIVE 90
DRUG DEAD 10
PLACEBO ALIVE 80
PLACEBO DEAD 20
;
PROC FREQ DATA=CHISQ;
   TABLES GROUP*OUTCOME / CHISQ;
   WEIGHT COUNT;
RUN;

***Program to compute Chi-square for any number of 2 x 2 tables where the data lines consist of the cell frequencies. The order of the cell counts is upper left, upper right, lower left, and lower right. To use this program, substitute your cell frequencies for the sample data lines in this program.;
DATA CHISQ;
   N + 1;
   DO ROW = 1 TO 2;
      DO COL = 1 TO 2;
         INPUT COUNT @;
      OUTPUT;
      END;
   END;
DATALINES;
3 5 8 6
10 20 30 40
;
PROC FREQ DATA=CHISQ;
   BY N;
   TABLES ROW*COL / CHISQ;
   WEIGHT COUNT;
RUN;

/***********************************************************
Macro CHISQ
Purpose: To compute chi-square (and any other valid
         PROC FREQ TABLES options) from frequencies in a
         2 x 2 table.
Sample Calling Sequencies:
   ***Using the default options;
   %CHISQ(10,20,30,40)

   ***Omitting all options;
   %CHISQ(10,20,30,40,OPTIONS=)

   ***Removing percentages;
   %CHISQ(10,20,30,40,OPTIONS=NOCOL NOROW NOPERCENT)

   ***Reqauesting Odds Ratios and Relative Risk;
   %CHISQ(10,20,30,40,OPTIONS=CMH)

   ***Requesting Chi-square, OR, and RR;
   %CHISQ(10,20,30,40,OPTIONS=CHISQ CMH)
************************************************************/
%MACRO CHISQ(A,B,C,D,OPTIONS=CHISQ);
   DATA CHISQ;
      ARRAY CELLS[2,2] _TEMPORARY_ (&A &B &C &D);
      DO ROW = 1 TO 2;
         DO COL = 1 TO 2;
            COUNT = CELLS[ROW,COL];
            OUTPUT;
         END;
      END;
   RUN;
   PROC FREQ DATA=CHISQ;
      TABLES ROW*COL / &OPTIONS;
      WEIGHT COUNT;
   RUN;
%MEND CHISQ;

%CHISQ(10,20,30,40)
%CHISQ(10,20,30,40,OPTIONS=CHISQ CMH)

***Program Name: MCNEMAR.SAS in C:\APPLIED
Purpose: To perform Mc'Nemars Chi-square test for
paired samples;

PROC FORMAT;
   VALUE $OPINION 'P'='Positive'
                  'N'='Negative';
RUN;
DATA MCNEMAR;
   LENGTH BEFORE AFTER $ 1;
   INPUT SUBJECT BEFORE $ AFTER $;
   FORMAT BEFORE AFTER $OPINION.;
   *Note: only sample data;
DATALINES;
001 P P
002 P N
003 N N
100 N P
;
PROC FREQ DATA=MCNEMAR;
   TITLE "McNemar's Test for Paired Samples";
   TABLES BEFORE*AFTER / AGREE;
RUN;

DATA MCNEMAR;
   LENGTH AFTER BEFORE $ 1;
   INPUT AFTER $ BEFORE $ COUNT;
   FORMAT BEFORE AFTER $OPINION.;
DATALINES;
N N 32
N P 30
P N 15
P P 23
;
PROC FREQ DATA=MCNEMAR;
   TITLE "McNemar's Test for Paired Samples";
   TABLES BEFORE*AFTER / AGREE ;
   WEIGHT COUNT;
RUN;

DATA X_RAY;
   INPUT RADIOLOGIST_1 $ RADIOLOGIST_2 $ COUNT;
DATALINES;
No No 25
No Yes 3
Yes No 5
Yes Yes 50
;
PROC FREQ DATA=X_RAY;
   TITLE "Computing Coefficient Kappa for Two Observers";
   TABLES RADIOLOGIST_1 * RADIOLOGIST_2 / AGREE;
   WEIGHT COUNT;
RUN;

***Program to compute an Odds Ratio and the 95% CI;
DATA ODDS;
   INPUT OUTCOME $ EXPOSURE $ COUNT;
DATALINES;
CASE 1-YES 50
CASE 2-NO 100
CONTROL 1-YES 20
CONTROL 2-NO 130
;
PROC FREQ DATA=ODDS;
   TITLE "Program to Compute an Odds Ratio";
   TABLES EXPOSURE*OUTCOME / CHISQ CMH;
   WEIGHT COUNT;
RUN;

***Program to compute a Relative Risk and a 95% CI;
DATA RR;
   LENGTH GROUP $ 9;
   INPUT GROUP $ OUTCOME $ COUNT;
DATALINES;
HIGH-CHOL MI 20
HIGH-CHOL NO-MI 80
LOW-CHOL MI 15
LOW-CHOL NO-MI 135
;
PROC FREQ DATA=RR;
   TITLE "Program to Compute a Relative Risk";
   TABLES GROUP*OUTCOME / CMH;
   WEIGHT COUNT;
RUN;

***Chi-square Test for Trend;
DATA TREND;
      INPUT RESULT $ GROUP $ COUNT @@;
DATALINES;
FAIL A 10 FAIL B 15 FAIL C 14 FAIL D 25
PASS A 90 PASS B 85 PASS C 86 PASS D 75
;
PROC FREQ DATA=TREND;
      TITLE "Chi-square Test for Trend";
   TABLES RESULT*GROUP / CHISQ;
   WEIGHT COUNT;
RUN;

***Program to compute a Mantel-Haenszel Chi-square Test
   for Stratified Tables;
DATA ABILITY;
      INPUT GENDER $ RESULTS $ SLEEP $ COUNT;
DATALINES;
BOYS FAIL 1-LOW 20
BOYS FAIL 2-HIGH 15
BOYS PASS 1-LOW 100
BOYS PASS 2-HIGH 150
GIRLS FAIL 1-LOW 30
GIRLS FAIL 2-HIGH 25
GIRLS PASS 1-LOW 100
GIRLS PASS 2-HIGH 200
;
PROC FREQ DATA=ABILITY;
      TITLE "Mantel-Haenszel Chi-square Test";
      TABLES GENDER*SLEEP*RESULTS/ALL;
   WEIGHT COUNT;
RUN;

***With a few lines of made up data;
DATA DIAG1;
   INPUT ID 1-3 DX1 20-22 DX2 23-25 DX3 26-28;
DATALINES;
1234567890123456789012345678
001                007008009
002                008      
003                001009   
004                009001003
;

DATA DIAG2;
   SET DIAG1;
   DX = DX1;
   IF DX NE . THEN OUTPUT;
   DX = DX2;
   IF DX NE . THEN OUTPUT;
   DX = DX3;
   IF DX NE . THEN OUTPUT;
   KEEP ID DX;
RUN;

DATA DIAG2;
   SET DIAG1;
   ARRAY D[*] DX1-DX3;
   DO I = 1 TO 3;
      DX = D[I];
      IF D[I] NE . THEN OUTPUT;
   END;
   KEEP ID DX;
RUN;

***Chapter 4;

DATA HOSPITAL;
   INPUT @1   ID            $3.
         @4   DOB     MMDDYY10.
         @14  ADMIT   MMDDYY10.
         @24  DISCHRG MMDDYY10.
         @34  DX             1.
         @35  FEE            5.;
   LENGTH_STAY = DISCHRG-ADMIT + 1;
   AGE = ADMIT - DOB;
DATALINES;
00110/21/194612/12/200412/14/20048 8000
00205/01/198007/08/200408/08/2004412000
00301/01/196001/01/200401/04/20043 9000
00406/23/199811/11/200412/25/2004715123
;

***Note: This is a very poor way to structure your data set. This is
   for instructional purposes only;
DATA HOSP_PATIENTS;
   INPUT #1 
      @1  ID           $3.
      @4  DATE1   MMDDYY8. 
      @12 HR1           3.
      @15 SBP1          3.
      @18 DBP1          3.
      @21 DX1           3.
      @24 DOCFEE1       4.
      @28 LABFEE1       4.
         #2
      @4  DATE2   MMDDYY8. 
      @12 HR2           3.
      @15 SBP2          3.
      @18 DBP2          3.
      @21 DX2           3.
      @24 DOCFEE2       4.
      @28 LABFEE2       4.
         #3
      @4  DATE3   MMDDYY8. 
      @12 HR3           3.
      @15 SBP3          3.
      @18 DBP3          3.
      @21 DX3           3.
      @24 DOCFEE3       4.
      @28 LABFEE3       4.
         #4
      @4  DATE4   MMDDYY8. 
      @12 HR4           3.
      @15 SBP4          3.
      @18 DBP4          3.
      @21 DX4           3.
      @24 DOCFEE4       4.
      @28 LABFEE4       4.;
   FORMAT DATE1-DATE4 MMDDYY10.;
DATALINES;
0071021198307012008001400400150
0071201198307213009002000500200
007
007
0090903198306611007013700300000
009
009
009
0050705198307414008201300900000
0050115198208018009601402001500
0050618198207017008401400800400
0050703198306414008401400800200
;

DATA PATIENTS;
   INPUT @1  ID          $3.
         @4  DATE   MMDDYY8. 
         @12 HR           3.
         @15 SBP          3.
         @18 DBP          3.
         @21 DX           3.
         @24 DOCFEE       4.
         @28 LABFEE       4.;
   FORMAT DATE MMDDYY10.;
DATALINES;
0071021198307012008001400400150
0071201198307213009002000500200
0090903198306611007013700300000
0050705198307414008201300900000
0050115198208018009601402001500
0050618198207017008401400800400
0050703198306414008401400800200
;

DATA PATIENTS;
   INPUT @1  ID          $3.
         @4  DATE   MMDDYY8. 
         @12 HR           3.
         @15 SBP          3.
         @18 DBP          3.
         @21 DX           3.
         @24 DOCFEE       4.
         @28 LABFEE       4.;
   FORMAT DATE MMDDYY10.;
DATALINES;
0071021198307012008001400400150
0071201198307213009002000500200
0090903198306611007013700300000
0050705198307414008201300900000
0050115198208018009601402001500
0050618198207017008401400800400
0050703198306414008401400800200
;
PROC MEANS DATA=PATIENTS NOPRINT NWAY;
   CLASS ID;
   VAR HR -- DBP DOCFEE LABFEE;
   OUTPUT OUT=STATS MEAN=M_HR M_SBP M_DBP M_DOCFEE M_LABFEE;
RUN;

PROC SORT DATA=PATIENTS;
   BY ID DATE;
RUN;
DATA RECENT; 
   SET PATIENTS;
   BY ID;
   IF LAST.ID;
RUN;

DATA LOOKING_BACK;
   INPUT DAY OZONE;
   OZONE_LAG24 = LAG(OZONE);
   OZONE_LAG48 = LAG2(OZONE);
DATALINES;
1 8
2 10
3 12
3 7
;
PROC PRINT DATA=LOOKING_BACK;
   TITLE "Demonstrating the LAG Function";
RUN;

DATA LAGGARD;
   INPUT X;
   IF X GT 5 THEN LAG_X = LAG(X);
DATALINES;
7
9
1
8
;
PROC PRINT DATA=LAGGARD;
   TITLE "Demonstrating a Feature of the LAG Function";
RUN;

*Assume data set PATIENTS is already sorted by ID and DATE;
DATA DIFFERENCE;
   SET PATIENTS;
   BY ID;
   DIFF_HR = HR - LAG(HR);
   DIFF_SBP = SBP - LAG(SBP);
   DIFF_DBP = DBP - LAG(DBP);
   IF NOT FIRST.ID THEN OUTPUT;
RUN;

DATA FIRST_LAST;
   SET PATIENTS;
   BY ID;
   ***Data set PATIENTS is sorted by ID and DATE;
   RETAIN FIRST_HR FIRST_SBP FIRST_DBP;
   ***Omit patients with only one visit;
   IF FIRST.ID AND LAST.ID THEN DELETE;
   ***If it is the first visit assign values to the
      retained variables;
   IF FIRST.ID THEN DO;
      FIRST_HR = HR;
      FIRST_SBP = SBP;
      FIRST_DBP = DBP;
   END;
   IF LAST.ID THEN DO;
      D_HR = HR - FIRST_HR;
      D_SBP = SBP - FIRST_SBP;
      D_DBP = DBP - FIRST_DBP;
      OUTPUT;
   END;
RUN;

DATA FIRST_LAST;
   SET PATIENTS;
   BY ID;
   ***Data set PATIENTS is sorted by ID and DATE;
   ***Omit patients with only one visit;
   IF FIRST.ID AND LAST.ID THEN DELETE; 
   ***If it is the first or last visit execute the LAG
      function;
   IF FIRST.ID OR LAST.ID THEN DO;
      D_HR = HR - LAG(HR);
      D_SBP = SBP - LAG(SBP);
      D_DBP = DBP - LAG(SBP);
   END;
   IF LAST.ID THEN OUTPUT;
RUN;

PROC FREQ DATA=PATIENTS ORDER=FREQ;
   TITLE "Diagnoses in Decreasing Frequency Order";
   TABLES DX;
RUN;

PROC SORT DATA=PATIENTS;
   BY ID DX;
RUN;
DATA DIAG;
   SET PATIENTS;
   BY ID DX;
   IF FIRST.DX;
RUN;
PROC FREQ DATA=DIAG ORDER=FREQ;
   TABLES DX;
RUN;

DATA SCHOOL;
   LENGTH GENDER $ 1 TEACHER $ 5;
   INPUT SUBJECT 
         GENDER  $ 
         TEACHER $ 
         T_AGE 
         PRETEST 
         POSTTEST;
   GAIN = POSTTEST - PRETEST;
DATALINES;
1 M JONES 35 67 81
2 F JONES 35 98 86
3 M JONES 35 52 92
4 M BLACK 42 41 74
5 F BLACK 42 46 76
6 M SMITH 68 38 80
7 M SMITH 68 49 71
8 F SMITH 68 38 63
9 M HAYES 23 71 72
10 F HAYES 23 46 92
11 M HAYES 23 70 90
12 F WONG 47 49 64
13 M WONG 47 50 63
;
PROC MEANS DATA=SCHOOL N MEAN STD MAXDEC=2;
   TITLE "Means Scores for Each Teacher";
   CLASS TEACHER;
   VAR PRETEST POSTTEST GAIN;
RUN;

PROC MEANS DATA=SCHOOL NOPRINT NWAY;
   CLASS TEACHER;
   VAR PRETEST POSTTEST GAIN;
   OUTPUT OUT=TEACHSUM
          MEAN=M_PRE M_POST M_GAIN;
RUN;
*To get a list of what was produced and therefore what
is contained in the data set TEACHSUM, add the following:;
PROC PRINT DATA=TEACHSUM;
   TITLE "Listing of Data Set TEACHSUM";
RUN;
*Hey! This is a good example of why comments
are useful. ;

PROC MEANS DATA=SCHOOL NOPRINT NWAY;
   CLASS TEACHER;
   ID T_AGE;
   VAR PRETEST POSTTEST GAIN;
   OUTPUT OUT=TEACHSUM
          MEAN=M_PRE M_POST M_GAIN;
RUN;

DATA DEMOG;
   LENGTH GENDER $ 1 REGION $ 5;
   INPUT SUBJ GENDER $ REGION $ HEIGHT WEIGHT;
DATALINES;
01 M North 70 200
02 M North 72 220
03 M South 68 155
04 M South 74 210
05 F North 68 130
06 F North 63 110
07 F South 65 140
08 F South 64 108
09 F South  . 220
10 F South 67 130
;

PROC MEANS DATA=DEMOG N MEAN STD MAXDEC=2;
   TITLE "Output from PROC MEANS";
   CLASS GENDER REGION;
   VAR HEIGHT WEIGHT;
RUN;

PROC MEANS DATA=DEMOG NOPRINT;
   CLASS GENDER REGION;
   VAR HEIGHT WEIGHT;
   OUTPUT OUT=SUMMARY
          MEAN=M_HEIGHT M_WEIGHT;  
RUN;
***Add a PROC PRINT to list the observations in SUMMARY;
PROC PRINT DATA=SUMMARY;
   TITLE "Listing of Data Set SUMMARY";
RUN;

PROC MEANS DATA=DEMOG NOPRINT CHARTYPE;
   CLASS GENDER REGION;
   VAR HEIGHT WEIGHT;
   OUTPUT OUT=SUMMARY
          MEAN=M_HEIGHT M_WEIGHT;
RUN;

DATA GRAND REGION GENDER GENDER_REGION;
   SET SUMMARY;
   IF _TYPE_ = '00' THEN OUTPUT GRAND;
   ELSE IF _TYPE_ = '01' THEN OUTPUT REGION;
   ELSE IF _TYPE_ = '10' THEN OUTPUT GENDER;
   ELSE IF _TYPE_ = '11' THEN OUTPUT GENDER_REGION;
RUN;

PROC MEANS DATA=DEMOG NOPRINT NWAY;
   CLASS GENDER REGION;
   VAR HEIGHT WEIGHT;
   OUTPUT OUT=SUMMARY
          MEAN=M_HEIGHT M_WEIGHT;
RUN;
PROC PRINT DATA=SUMMARY;
   TITLE "Listing of Data Set SUMMARY with NWAY Option";
RUN;

PROC MEANS DATA=DEMOG NOPRINT NWAY;
   CLASS GENDER REGION;
   VAR HEIGHT WEIGHT;
   OUTPUT OUT  = SUMMARY
          N    = N_HEIGHT N_WEIGHT
          MEAN = M_HEIGHT M_WEIGHT;
RUN;
PROC PRINT DATA=SUMMARY;
   TITLE1 "Listing of Data Set SUMMARY with NWAY Option";
   TITLE2 "with Requests for N= and MEAN=";
RUN;

PROC MEANS DATA=DEMOG NOPRINT NWAY;
   CLASS GENDER REGION;
   VAR HEIGHT WEIGHT;
   OUTPUT OUT   = SUMMARY(DROP=_TYPE_)
          N     = N_HEIGHT N_WEIGHT
          MEAN  = M_HEIGHT M_WEIGHT;
RUN;

PROC MEANS DATA=DEMOG NOPRINT NWAY;
   CLASS GENDER REGION;
   VAR HEIGHT WEIGHT;
   OUTPUT OUT = SUMMARY(DROP=_TYPE_)
          MEAN =;
RUN;

PROC MEANS DATA=DEMOG NOPRINT NWAY;
   CLASS GENDER REGION;
   VAR HEIGHT WEIGHT;
   OUTPUT OUT = SUMMARY
          MEAN = MEAN_HEIGHT MEAN_WEIGHT
          N = M_HEIGHT N_WEIGHT
          MEDIAN = MEDIAN_HEIGHT MEDIAN_WEIGHT
          MIN = MIN_HEIGHT MIN_WEIGHT
          MAX = MAX_HEIGHT MAX_WEIGHT;
RUN;

PROC MEANS DATA=DEMOG NOPRINT NWAY;
   CLASS GENDER REGION;
   VAR HEIGHT WEIGHT;
   OUTPUT OUT = SUMMARY(DROP=_TYPE_ RENAME=(_FREQ_ = NUMBER))
          MEAN =
          N =
          MEDIAN =
          MIN =
          MAX = / AUTONAME;
RUN;

***Chapter 5;

DATA CORR_EG;
   INPUT GENDER $ HEIGHT WEIGHT AGE;
   HEIGHT2 = HEIGHT**2;
   ***Note: Above line added to nonlinear example later;
DATALINES;
M 68 155 23
F 61 99 20
F 63 115 21
M 70 205 45
M 69 170 .
F 65 125 30
M 72 220 48
;
PROC CORR DATA=CORR_EG;
   TITLE "Example of a Correlation Matrix";
   VAR HEIGHT WEIGHT AGE;
RUN;

PROC CORR DATA=CORR_EG PEARSON SPEARMAN NOSIMPLE;
   TITLE "Example of a Correlation Matrix";
   VAR HEIGHT WEIGHT AGE;
RUN;

PROC CORR DATA=CORR_EG NOSIMPLE;
   TITLE "Example of a Partial Correlation";
   VAR HEIGHT WEIGHT;
   PARTIAL AGE;
RUN;

PROC REG DATA=CORR_EG;
   TITLE "Regression Line for Height-Weight Data";
   MODEL WEIGHT = HEIGHT;
RUN;

PROC GPLOT DATA=CORR_EG;
   PLOT WEIGHT*HEIGHT;
RUN;

***You can abbreviate VALUE as V= and COLOR as C=;
PROC GPLOT DATA=CORR_EG;
   PLOT WEIGHT*HEIGHT;
RUN;

SYMBOL1 VALUE=DOT COLOR=BLACK;
PROC REG DATA=CORR_EG;
   TITLE "Regression and Residual Plots";
   MODEL WEIGHT = HEIGHT;
   PLOT WEIGHT * HEIGHT
        RESIDUAL. * HEIGHT;
RUN;
QUIT;

GOPTIONS CSYMBOL=BLACK;
SYMBOL1 VALUE=DOT;
SYMBOL2 VALUE=NONE I=RLCLM95;
SYMBOL3 VALUE=NONE I=RLCLI95 LINE=3;
PROC GPLOT DATA=CORR_EG;
   TITLE "Regression Lines and 95% CI's";
   PLOT WEIGHT * HEIGHT = 1
        WEIGHT * HEIGHT = 2
        WEIGHT * HEIGHT = 3 / OVERLAY;
RUN;
QUIT;

SYMBOL VALUE=DOT COLOR=BLACK;
PROC REG DATA=CORR_EG;
   MODEL WEIGHT = HEIGHT HEIGHT2;
   PLOT R. * HEIGHT;
   ***Note: R. is short for RESIDUAL.;
RUN;

DATA HEART;
   INPUT DOSE HR @@;
   ***The double @ at the end of the INPUT statement allows you to
      read several observations from one data line.  It is an 
      instruction not to move the pointer to a new line when you
      reach the bottom of the DATA step (default action);
DATALINES;
2 60 2 58 4 63 4 62 8 67 8 65 16 70 16 70 32 74 32 73
;
SYMBOL VALUE=DOT COLOR=BLACK I=SM;

***I = SM produces a smooth line through the data points. You can 
   follow SM by a number from 0 to 99 to control how much the line 
   should try to touch each data point (low values such as SM1 produce 
   lots of wiggle high values such as SM80, give smoother lines). 
   Also, you can add an "S" to the end of this option if your x-values 
   are not sorted (example: I=SM80S);

PROC GPLOT DATA=HEART;
   PLOT HR*DOSE;
RUN;
PROC REG DATA=HEART;
   MODEL HR = DOSE;
RUN;

DATA HEART;
   INPUT DOSE HR @@;
   LDOSE = LOG(DOSE);
   LABEL LDOSE = "Log of Dose";
DATALINES;
2 60 2 58 4 63 4 62 8 67 8 65 16 70 16 70 32 74 32 73
;

PROC REG DATA=HEART;
   TITLE "Investigating the Dose/HR Relationship";
   MODEL HR = LDOSE;
RUN; 

SYMBOL VALUE=DOT;
PROC GPLOT DATA=HEART;
   PLOT HR*LDOSE;
RUN;

***Chapter 6;

DATA RESPONSE;
   INPUT GROUP $ TIME;
DATALINES;
C 80
C 93
C 83
C 89
C 98
T 100
T 103
T 104
T 99
T 102
;
PROC TTEST DATA=RESPONSE;
   TITLE "T-test Example";
   CLASS GROUP;
   VAR TIME;
RUN;

DATA ASSIGN;
   DO SUBJ = 1 TO 50;
      IF RANUNI(123) LE .5 THEN GROUP = 'A';
      ELSE GROUP = 'B';
      OUTPUT;
   END;
RUN;
OPTIONS PS=16 LS=72;
PROC REPORT DATA=ASSIGN PANELS=99 NOWD;
   TITLE "Simple Random Assignment";
   COLUMNS SUBJ GROUP;
   DEFINE SUBJ / WIDTH=4;
   DEFINE GROUP / WIDTH=5;
RUN;

PROC FORMAT;
    VALUE GRPFMT 0='CONTROL' 1='TREATMENT';
RUN;
DATA RANDOM;
   DO SUBJ = 1 TO 20;
      GROUP=RANUNI(0);
      OUTPUT;
   END;
RUN;
PROC RANK DATA=RANDOM GROUPS=2 OUT=SPLIT;
   VAR GROUP;
RUN;
PROC PRINT DATA=SPLIT NOOBS;
   TITLE "Subject Group Assignments";
   VAR SUBJ GROUP;
   FORMAT GROUP GRPFMT.;
RUN;

DATA TUMOR;
   INPUT GROUP $ MASS @@;
DATALINES;
A 3.1 A 2.2 A 1.7 A 2.7 A 2.5
B 0.0 B 0.0 B 1.0 B 2.3
;
PROC NPAR1WAY DATA=TUMOR WILCOXON;
   TITLE "Nonparametric Test to Compare Tumor Masses";
   CLASS GROUP;
   VAR MASS;
   EXACT WILCOXON;
RUN;

DATA PAIRED;
   INPUT CTIME TTIME;
DATALINES;
90 95
87 92
100 104
80 89
95 101
90 105
;
PROC TTEST DATA=PAIRED;
   TITLE "Demonstrating a Paired T-test";
   PAIRED CTIME * TTIME;
RUN;

***Chapter 7;

DATA READING;
   INPUT GROUP $ WORDS @@;
DATALINES;
X 700   X 850   X 820   X 640   X 920
Y 480   Y 460   Y 500   Y 570   Y 580
Z 500   Z 550   Z 480   Z 600   Z 610
;
PROC ANOVA DATA=READING;
   TITLE "Analysis of Reading Data";
   CLASS GROUP;
   MODEL WORDS = GROUP;
   MEANS GROUP;
RUN;

PROC GLM DATA=READING;
   TITLE "Analysis of Reading Data - Planned Comparions";
   CLASS GROUP;
   MODEL WORDS = GROUP;   
   CONTRAST 'X VS. Y AND Z' GROUP   -2 1 1;
   CONTRAST 'METHOD Y VS Z' GROUP   0 1 -1;
RUN;

DATA TWOWAY;
   INPUT GROUP $ GENDER $ WORDS @@;
DATALINES;
X M 700  X M 850  X M 820  X M 640  X M 920
Y M 480  Y M 460  Y M 500  Y M 570  Y M 580
Z M 920  Z M 550  Z M 480  Z M 600  Z M 610
X F 900  X F 880  X F 899  X F 780  X F 899
Y F 590  Y F 540  Y F 560  Y F 570  Y F 555
Z F 520  Z F 660  Z F 525  Z F 610  Z F 645
;
PROC ANOVA DATA=TWOWAY;
   TITLE "Analysis of Reading Data";
   CLASS GROUP GENDER;
   MODEL WORDS = GROUP | GENDER;
   MEANS GROUP | GENDER / SNK;
RUN;

DATA RITALIN;
   DO GROUP = 'NORMAL','HYPER ';
      DO DRUG = 'PLACEBO','RITALIN';
         DO SUBJ = 1 TO 4;
            INPUT ACTIVITY @;
            OUTPUT;
         END;
      END;
   END;
DATALINES;
50 45 55 52 67 60 58 65 70 72 68 75 51 57 48 55
;
PROC ANOVA DATA=RITALIN;
   TITLE "Activity Study";
   CLASS GROUP DRUG;
   MODEL ACTIVITY=GROUP | DRUG;
   MEANS GROUP | DRUG;
RUN;

PROC MEANS DATA=RITALIN NWAY NOPRINT;
   CLASS GROUP DRUG;
   VAR ACTIVITY;
   OUTPUT OUT=MEANS MEAN=M_HR;
RUN;

SYMBOL1 V=SQUARE COLOR=BLACK I=JOIN;
SYMBOL2 V=CIRCLE COLOR=BLACK I=JOIN;
PROC GPLOT DATA=MEANS;
   TITLE "Interaction Plot";
   PLOT M_HR * DRUG = GROUP;
RUN;

PROC SORT DATA=RITALIN;
   BY GROUP;
RUN;
PROC TTEST DATA=RITALIN;
   TITLE "Drug Comparisons for Each Group Separately";
   BY GROUP;
   CLASS DRUG;
   VAR ACTIVITY;
RUN;

DATA RITALIN;
   DO GROUP = 'NORMAL','HYPER ';
      DO DRUG = 'PLACEBO','RITALIN';
         DO SUBJ = 1 TO 4;
            INPUT ACTIVITY @;
            CONDITION = TRIM(GROUP) || '-' || DRUG;
            OUTPUT;
         END;
      END;
   END;
DATALINES;
50 45 55 52 67 60 58 65 70 72 68 75 51 57 48 55
;
PROC ANOVA DATA=RITALIN;
   TITLE "One-way ANOVA Ritalin Study";
   CLASS CONDITION;
   MODEL ACTIVITY = CONDITION;
   MEANS CONDITION / SNK;
RUN;

PROC GLM DATA=RITALIN;
   TITLE "Demonstrating the CONTRAST Statement of GLM";
   CLASS GROUP DRUG;
   MODEL ACTIVITY = GROUP | DRUG / SS3;
   CONTRAST 'Hyperactive only' DRUG 1 -1 
                               GROUP*DRUG 1 -1 0 0;
   CONTRAST 'Normals only'   DRUG 1 -1
                             GROUP*DRUG 0 0 1 -1;
RUN;

PROC GLM DATA=RITALIN;
   TITLE "One-way ANOVA Ritalin Study";
   CLASS CONDITION;
   MODEL ACTIVITY = CONDITION;
   CONTRAST 'Hyperactive only'  CONDITION   1  -1   0   0;
   CONTRAST 'Normals only'      CONDITION   0   0   1  -1;
RUN;

DATA PUDDING;
   LENGTH FLAVOR $ 9;
   INPUT FLAVOR $ SWEET RATING @@;
DATALINES;
VANILLA 1 9  VANILLA 2 8  VANILLA 3 6
VANILLA 1 7  VANILLA 2 7  VANILLA 3 5
VANILLA 1 8  VANILLA 2 8  VANILLA 3 7
VANILLA 1 7
CHOCOLATE 1 9  CHOCOLATE 2 8  CHOCOLATE 3 4
CHOCOLATE 1 9  CHOCOLATE 2 7  CHOCOLATE 3 5
CHOCOLATE 1 7  CHOCOLATE 2 6  CHOCOLATE 3 6
CHOCOLATE 1 7  CHOCOLATE 2 8  CHOCOLATE 3 4
CHOCOLATE 1 8                 CHOCOLATE 3 4
;
PROC GLM DATA=PUDDING;
   TITLE  "Pudding Taste Evaluation";
   TITLE3 "Two-way ANOVA - Unbalanced Design";
   TITLE4 "---------------------------------";
   CLASS SWEET FLAVOR;
   MODEL RATING = SWEET | FLAVOR / SS3;
   LSMEANS SWEET | FLAVOR / PDIFF ADJUST=TUKEY;
RUN;

DATA COVAR;
   LENGTH GROUP $ 1;
   INPUT GROUP MATH IQ @@;
DATALINES;
A  260  105   A  325  115   A  300  122   A  400  125   A  390  138
B  325  126   B  440  135   B  425  142   B  500  140   B  600  160
;
PROC CORR DATA=COVAR NOSIMPLE;
   TITLE "Covariate Example";
   VAR MATH IQ;
RUN;
PROC TTEST DATA=COVAR;
   CLASS GROUP;
   VAR IQ MATH;
RUN;

PROC GLM DATA=COVAR;
   CLASS GROUP;
   MODEL MATH = IQ GROUP IQ*GROUP / SS3;
RUN;

PROC GLM DATA=COVAR;
   CLASS GROUP;
   MODEL MATH = IQ GROUP / SS3;
   LSMEANS GROUP;
RUN;

***Chapter 8;

DATA PAIN;
   INPUT SUBJ @; 
   DO DRUG = 1 to 4; 
      INPUT PAIN @; 
      OUTPUT;    
   END; 
DATALINES;
1   5   9   6  11
2   7  12   8   9
3  11  12  10  14
4   3   8   5   8
;

DATA PAIN;
   SUBJ + 1; 
   DO DRUG = 1 TO 4;
      INPUT PAIN @;
      OUTPUT;
   END;
DATALINES;
 5   9   6  11
 7  12   8   9
11  12  10  14
 3   8   5   8
;

PROC ANOVA DATA=PAIN;
   TITLE "One-way Repeated Measures ANOVA";
   CLASS SUBJ DRUG;
   MODEL PAIN = SUBJ DRUG;
   MEANS DRUG / SNK;
RUN;

DATA REPEAT1;
   INPUT SUBJ PAIN1-PAIN4;
DATALINES;
1   5   9   6  11
2   7  12   8   9
3  11  12  10  14
4   3   8   5   8
;
PROC ANOVA DATA=REPEAT1;
   TITLE "One-way ANOVA Using the REPEATED Statement";
   MODEL PAIN1-PAIN4 = / NOUNI;
   REPEATED DRUG 4 (1 2 3 4);
RUN;

PROC ANOVA DATA=REPEAT1;
   TITLE "One-way ANOVA Using the Repeated Statement";
   MODEL PAIN1-PAIN4 = / NOUNI;
   REPEATED DRUG 4 CONTRAST(1)/ NOM SUMMARY;
   REPEATED DRUG 4 CONTRAST(2)/ NOM SUMMARY;
   REPEATED DRUG 4 CONTRAST(3)/ NOM SUMMARY;
RUN;

PROC MIXED DATA=PAIN;
   TITLE "One Factor Experiment - Mixed Model";
   CLASS SUBJ DRUG;
   MODEL PAIN = DRUG;
   RANDOM SUBJ;
RUN;
QUIT;

DATA PREPOST;
   INPUT SUBJ GROUP $ PRETEST POSTEST;
   DIFF = POSTEST-PRETEST;
DATALINES;
1   C   80   83
2   C   85   86
3   C   83   88
4   T   82   94
5   T   87   93
6   T   84   98
;
PROC TTEST DATA=PREPOST;
   TITLE "T-test on Difference Scores";
   CLASS GROUP;
   VAR DIFF;
RUN;

PROC ANOVA DATA=PREPOST;
   TITLE1 "Two-way ANOVA with a Repeated Measure on One Factor";
   CLASS GROUP;
   MODEL PRETEST POSTEST = GROUP / NOUNI;
   REPEATED TIME 2 (0 1);
   MEANS GROUP;
RUN;

DATA TWOWAY;
   SET PREPOST;
   LENGTH TIME $ 4;
   TIME = 'PRE';
   SCORE = PRETEST;
   OUTPUT;
   TIME = 'POST';
   SCORE = POSTEST;
   OUTPUT;
   KEEP SUBJ GROUP TIME SCORE;
RUN;

PROC ANOVA DATA=TWOWAY;
   TITLE "Two-way ANOVA with TIME as a Repeated Measure";
   CLASS SUBJ GROUP TIME;
   MODEL SCORE = GROUP SUBJ(GROUP) TIME
                 GROUP*TIME TIME*SUBJ(GROUP);
   MEANS GROUP|TIME;
   TEST H=GROUP            E=SUBJ(GROUP);
   TEST H=TIME GROUP*TIME     E=TIME*SUBJ(GROUP);
RUN;

PROC MEANS DATA=TWOWAY NOPRINT NWAY;
   CLASS GROUP TIME;
   VAR SCORE;
   OUTPUT OUT=INTER
          MEAN=;
RUN;
OPTIONS LINESIZE=68 PAGESIZE=24;
SYMBOL1 VALUE=CIRCLE COLOR=BLACK INTERPOL=JOIN;
SYMBOL2 VALUE=SQUARE COLOR=BLACK INTERPOL=JOIN;

PROC GPLOT DATA=INTER;
   TITLE "Interaction Plot";
   PLOT SCORE*TIME=GROUP;
RUN;

PROC MIXED DATA=TWOWAY;
   TITLE "Mixed Model for Two-way Design";
   CLASS GROUP TIME SUBJ;
   MODEL SCORE = GROUP TIME GROUP*TIME /SOLUTION;
   RANDOM SUBJ(GROUP);
   LSMEANS GROUP TIME;
RUN;
QUIT;

DATA SLEEP;
   INPUT SUBJ TREAT $ TIME $ REACT;
DATALINES;
1   CONT   AM   65
1   DRUG   AM   70
1   CONT   PM   55
1   DRUG   PM   60
2   CONT   AM   72
2   DRUG   AM   78
2   CONT   PM   64
2   DRUG   PM   68
3   CONT   AM   90
3   DRUG   AM   97
3   CONT   PM   80
3   DRUG   PM   85
;

PROC ANOVA DATA=SLEEP;
   TITLE "Two-way ANOVA with a Repeated Measure on Both Factors";
   CLASS SUBJ TREAT TIME;
   MODEL REACT = SUBJ|TREAT|TIME;
   MEANS TREAT|TIME;
   TEST H=TREAT       E=SUBJ*TREAT;
   TEST H=TIME        E=SUBJ*TIME;
   TEST H=TREAT*TIME  E=SUBJ*TREAT*TIME;
RUN;

DATA REPEAT2;
   INPUT REACT1-REACT4;
DATALINES;
65   70   55   60
72   78   64   68
90   97   80   85
;
PROC ANOVA DATA=REPEAT2;
   MODEL REACT1-REACT4 = / NOUNI;
   REPEATED TIME 2 , TREAT 2 / NOM;
RUN;

DATA COFFEE;
   INPUT SUBJ BRAND $ GENDER $ SCORE_B SCORE_D;
DATALINES;
1   A   M   7   8
2   A   M   6   7
3   A   M   6   8
4   A   F   5   7
5   A   F   4   7
6   A   F   4   6
7   B   M   4   6
8   B   M   3   5
9   B   M   3   5
10  B   F   3   4
11  B   F   4   4
12  B   F   2   3
13  C   M   8   9
14  C   M   6   9
15  C   M   5   8
16  C   F   6   9
17  C   F   6   9
18  C   F   7   8
;
PROC ANOVA DATA=COFFEE;
   TITLE "Coffee Study";
   CLASS BRAND GENDER;
   MODEL SCORE_B SCORE_D = BRAND|GENDER / NOUNI;
   REPEATED MEAL;
   MEANS BRAND|GENDER;
RUN;

DATA COFFEE2;
   SET COFFEE;
   MEAL = 'BREAKFAST';
   SCORE = SCORE_B;
   OUTPUT;
   MEAL='DINNER';
   SCORE = SCORE_D;
   OUTPUT;
RUN;
PROC ANOVA DATA=COFFEE2;
   CLASS SUBJ BRAND GENDER MEAL;
   MODEL SCORE = BRAND GENDER BRAND*GENDER SUBJ(BRAND GENDER)
                 MEAL BRAND*MEAL GENDER*MEAL BRAND*GENDER*MEAL
                 MEAL*SUBJ(BRAND GENDER);
   MEANS BRAND|GENDER / SNK E=SUBJ(BRAND GENDER);
   MEANS MEAL BRAND*MEAL GENDER*MEAL BRAND*GENDER*MEAL;
*---------------------------------------------------------*
| The following TEST statements are needed to obtain the  |
| correct F and p-values:                                 |
*---------------------------------------------------------*;
   TEST H=BRAND GENDER BRAND*GENDER
        E=SUBJ(BRAND GENDER);
   TEST H=MEAL BRAND*MEAL GENDER*MEAL BRAND*GENDER*MEAL
        E=MEAL*SUBJ(BRAND GENDER);
RUN;

DATA READ_1;
   INPUT SUBJ SES $ READ1-READ6;
   LABEL READ1 = 'SPRING YR 1'
         READ2 = 'FALL YR 1'
         READ3 = 'SPRING YR 2'
         READ4 = 'FALL YR 2'
         READ5 = 'SPRING YR 3'
         READ6 = 'FALL YR 3';
DATALINES;
1 HIGH 61 50 60 55 59 62
2 HIGH 64 55 62 57 63 63
3 HIGH 59 49 58 52 60 58
4 HIGH 63 59 65 64 67 70
5 HIGH 62 51 61 56 60 63
6 LOW 57 42 56 46 54 50
7 LOW 61 47 58 48 59 55
8 LOW 55 40 55 46 57 52
9 LOW 59 44 61 50 63 60
10 LOW 58 44 56 49 55 49
;
PROC ANOVA DATA=READ_1;
   TITLE "Reading Comprehension Analysis";
   CLASS SES;
   MODEL READ1-READ6 = SES / NOUNI;
   REPEATED YEAR 3, SEASON 2;
   MEANS SES;
RUN;

*--------------------------------------------------------------*
| Alternative Program for reading in the data for the reading  |
| experiment with all the data for one subject on one line.    |
*--------------------------------------------------------------*;
DATA READ_3;
   DO SES = 'HIGH','LOW';
      SUBJ = 0; 
      DO N = 1 TO 5; 
         SUBJ + 1; 
         DO YEAR = 1 TO 3;
            DO SEASON = 'SPRING','FALL'; 
               INPUT SCORE @; 
               OUTPUT; 
            END;
         END;
      END;
   END;
DROP N; 
DATALINES;
61   50   60   55   59   62
64   55   62   57   63   63
59   49   58   52   60   58
63   59   65   64   67   70
62   51   61   56   60   63
57   42   56   46   54   50
61   47   58   48   59   55
55   40   55   46   57   52
59   44   61   50   63   60
58   44   56   49   55   49
;

PROC ANOVA DATA=READ_3;
   TITLE "Reading Comprehension Analysis";
   CLASS SUBJ SES YEAR SEASON;
   MODEL SCORE = SES SUBJ(SES)
                 YEAR SES*YEAR YEAR*SUBJ(SES)
                 SEASON SES*SEASON SEASON*SUBJ(SES)
                 YEAR*SEASON SES*YEAR*SEASON YEAR*SEASON*SUBJ(SES);
   MEANS YEAR / SNK E=YEAR*SUBJ(SES);
   MEANS SES SEASON SES*YEAR SES*SEASON YEAR*SEASON
         SES*YEAR*SEASON;
   TEST H=SES                 E=SUBJ(SES);
   TEST H=YEAR SES*YEAR       E=YEAR*SUBJ(SES);
   TEST H=SEASON SES*SEASON   E=SEASON*SUBJ(SES);
   TEST H=YEAR*SEASON SES*YEAR*SEASON
        E=YEAR*SEASON*SUBJ(SES);
RUN;

***Chapter 9;

DATA WEIGHT_LOSS;
   INPUT ID DOSAGE EXERCISE LOSS;
DATALINES;
1  100  0 -4
2  100  0  0
3  100  5 -7
4  100  5 -6
5  100 10 -2
6  100 10 -14
7  200  0 -5
8  200  0 -2
9  200  5 -5
10  200  5 -8
11  200 10 -9
12  200 10 -9
13  300  0 1
14  300  0 0
15  300  5 -3
16  300  5 -3
17  300 10 -8
18  300 10 -12
19  400  0 -5
20  400  0 -4
21  400  5 -4
22  400  5 -6
23  400 10 -9
24  400 10 -7
;
PROC REG DATA=WEIGHT_LOSS;
   TITLE "Weight Loss Experiment - Regression Example";
   MODEL LOSS=DOSAGE EXERCISE / P R;
RUN;
QUIT;

DATA NONEXP;
   INPUT ID ACH6 ACH5 APT ATT INCOME;
DATALINES;
1  7.5   6.6   104   60   67
2  6.9   6.0   116   58   29
3  7.2   6.0   130   63   36
4  6.8   5.9   110   74   84
5  6.7   6.1   114   55   33
6  6.6   6.3   108   52   21
7  7.1   5.2   103   48   19
8  6.5   4.4    92   42   30
9  7.2   4.9   136   57   32
10 6.2   5.1   105   49   23
11 6.5   4.6    98   54   57
12 5.8   4.3    91   56   29
13 6.7   4.8   100   49   30
14 5.5   4.2    98   43   36
15 5.3   4.3   101   52   31
16 4.7   4.4    84   41   33
17 4.9   3.9    96   50   20
18 4.8   4.1    99   52   34
19 4.7   3.8   106   47   30
20 4.6   3.6    89   58   27
;
PROC REG DATA=NONEXP;
   TITLE "Nonexperimental Design Example";
MODEL ACH6 = ACH5 APT ATT INCOME /
   SELECTION = FORWARD;
MODEL ACH6 = ACH5 APT ATT INCOME /
   SELECTION = MAXR;
RUN;
QUIT;

PROC REG DATA=NONEXP; 
   MODEL ACH6 =   INCOME ATT APT ACH5 / SELECTION=RSQUARE CP;
   MODEL ACH5 =   INCOME ATT APT / SELECTION=RSQUARE CP
RUN;
QUIT;

PROC CORR DATA=NONEXP NOSIMPLE;
   TITLE "Correlations from NONEXP Data Set";
   VAR APT ATT ACH5 ACH6 INCOME;
RUN; 

PROC REG DATA=NONEXP;
   TITLE "Adding the Variance Inflation Factor to the Regression";
   MODEL ACH6 = ACH5 APT ATT INCOME / VIF;
RUN;
QUIT;

*--------------------------------------------------*
| Program Name: LOGISTIC.SAS in C:\APPLIED         |
| Purpose: To demonstrate logistic regression      |
| Date: April 13, 2004                             |
*--------------------------------------------------*;
PROC FORMAT;
   VALUE AGEGROUP   0 = '20 to 65 (inclusive)'
                    1 = '<20 or >65';
   VALUE VISION  0 = 'No Problem'
                 1 = 'Some Problem';
   VALUE YES_NO  0 = 'No'
                 1 = 'Yes';
RUN;
DATA LOGISTIC;
***Copy the file ACCIDENT.DTA to a folder of your choice
   and modify the following INFILE statement appropriately;
   INFILE 'C:\BOOKS\APPLIED_5th\ACCIDENT.DTA' MISSOVER;
   INPUT ACCIDENT AGE VISION DRIVE_ED GENDER : $1.;
   IF NOT MISSING(AGE) THEN DO;
      IF AGE GE 20 AND AGE LE 65 THEN AGEGROUP = 0;
      ELSE AGEGROUP = 1;
      IF AGE LT 20 THEN YOUNG = 1;
      ELSE YOUNG = 0;
      IF AGE GT 65 THEN OLD = 1;
      ELSE OLD = 0;
   END;
   LABEL 
      ACCIDENT = 'Accident in Last Year?'
      AGE      = 'Age of Driver'
      VISION   = 'Vision Problem?'
      DRIVE_ED = 'Driver Education?';
   FORMAT   ACCIDENT DRIVE_ED YOUNG OLD YES_NO.
            AGEGROUP AGEGROUP.
            VISION VISION.;
RUN;

PROC LOGISTIC DATA=LOGISTIC DESCENDING;
   TITLE "Predicting Accidents Using Logistic Regression";
   MODEL  ACCIDENT = AGE VISION DRIVE_ED /
      SELECTION = FORWARD
      CTABLE PPROB =(0 to 1 by .1)
      LACKFIT
      RISKLIMITS;
RUN;
QUIT;

OPTIONS PS=24;
PATTERN COLOR=BLACK VALUE=EMPTY;
PROC GCHART DATA=LOGISTIC;
      TITLE "Distribution of Ages by Accident Status";
      VBAR AGE / MIDPOINTS=10 TO 90 BY 10
   GROUP=ACCIDENT;
RUN;

PROC LOGISTIC DATA=LOGISTIC DESCENDING;
      TITLE "Predicting Accidents Using Logistic Regression";
      MODEL ACCIDENT = AGEGROUP VISION DRIVE_ED /
         SELECTION=FORWARD
         CTABLE PPROB =(0 to 1 by .1)
         LACKFIT
         RISKLIMITS
         OUTROC=ROC;
RUN;
QUIT;
OPTIONS LS=64 PS=32;
SYMBOL VALUE=DOT COLOR=BLACK INTERPOL=SMS60 WIDTH=2;
PROC GPLOT DATA=ROC;
   TITLE "ROC Curve";
   PLOT _SENSIT_ * _1MSPEC_ ;
   LABEL _SENSIT_ = 'Sensitivity'
           _1MSPEC_ = '1 - Specificity';
RUN;

PROC LOGISTIC DATA=LOGISTIC DESCENDING;
      TITLE "Predicting Accidents Using Logistic Regression";
      TITLE "Using Two Dummy Variables (YOUNG and OLD) for AGE";
   MODEL ACCIDENT =  YOUNG OLD VISION DRIVE_ED /
         SELECTION=FORWARD
            CTABLE PPROB=(0 to 1 by .1)
         LACKFIT
         RISKLIMITS
         OUTROC=ROC;
RUN;
QUIT;

PROC LOGISTIC DATA=LOGISTIC DESCENDING;
   TITLE "Predicting Accidents Using Logistic Regression";
   ***Note: Values of GENDER are not the original
      values used to create the output in the text;
   CLASS GENDER (PARAM=REF REF='F');
   MODEL  ACCIDENT = GENDER VISION DRIVE_ED;
RUN;
QUIT;

***Chapter 10;

*---------------------------------------------------------------*
| Program Name: FACTOR.SAS in C:\APPLIED                        |
| Purpose: To perform a factor analysis on psychological Data   |
*---------------------------------------------------------------*;
PROC FORMAT;
   VALUE LIKERT
    1 = 'V. Strong Dis.'
    2 = 'Strongly Dis.'
    3 = 'Disagree'
    4 = 'No Opinion'
    5 = 'Agree'
    6 = 'Strongly Agree'
    7 = 'V. Strong Agree';
RUN;
DATA FACTOR;
***Copy the file FACTOR.DTA to a folder of your choice
   and modify the following INFILE statement appropriately;
   INFILE 'C:\BOOKS\APPLIED_5th\FACTOR.DTA' PAD;
   INPUT @1  SUBJ $2. 
         @3 (QUES1-QUES6) (1.);
   LABEL QUES1 = 'Feel Blue'
         QUES2 = 'People Stare at Me'
         QUES3 = 'People Follow Me'
         QUES4 = 'Basically Happy'
         QUES5 = 'People Want to Hurt Me'
         QUES6 = 'Enjoy Going to Parties';
   FORMAT QUES1-QUES6 LIKERT.;
RUN;

PROC FACTOR DATA=FACTOR PREPLOT PLOT ROTATE=VARIMAX
            NFACTORS=2 OUT=FACT SCREE;
   TITLE "Example of Factor Analysis";
   VAR QUES1-QUES6;
RUN;

PROC FACTOR DATA=FACTOR ROTATE=PROMAX NFACTORS=2;
      TITLE "Example of Factor Analysis - Oblique Rotation";
   VAR QUES1-QUES6;
RUN;

PROC FACTOR DATA=FACTOR PREPLOT PLOT ROTATE=VARIMAX
            NFACTORS=2 OUT=FACT SCREE;
      TITLE "Example of Factor Analysis";
   VAR QUES1-QUES6;
      PRIORS SMC; ***This is the new line;
RUN;

DATA FACTOR;
***Copy the file FACTOR.DTA to a folder of your choice
   and modify the following INFILE statement appropriately;
   INFILE 'C:\BOOKS\APPLIED_5th\FACTOR.DTA' PAD;
   INPUT @1  SUBJ $2. 
         @3 (QUES1-QUES6) (1.);
   ***Reverse the scores for questions 4 and 6;
   QUES4 = 8 - QUES4;
   QUES6 = 8 - QUES6;
   LABEL QUES1 = 'Feel Blue'
         QUES2 = 'People Stare at Me'
         QUES3 = 'People Follow Me'
         QUES4 = 'Basically Happy'
         QUES5 = 'People Want to Hurt Me'
         QUES6 = 'Enjoy Going to Parties';
   FORMAT QUES1-QUES6 LIKERT.;
RUN;

***Chapter 11;

*-------------------------------------------------------------*
| Program Name: SCORE1.SAS in C:\APPLIED                      |
| Purpose: To score a five item multiple choice exam.         |
| Data: The first line is the answer key, remaining lines     |
| contain the student responses                               |
| Date: April 23, 2004                                        |
*-------------------------------------------------------------*;
DATA SCORE;
   ARRAY ANS[5] $ 1 ANS1-ANS5; ***Student answers;
   ARRAY KEY[5] $ 1 KEY1-KEY5; ***Answer key;
   ARRAY S[5] 3 S1-S5; ***Score array 1=right,0=wrong;
   RETAIN KEY1-KEY5;
   ***Read the answer key;
   IF _N_ = 1 THEN INPUT (KEY1-KEY5)($1.);
   ***Read student responses;
   INPUT   @1  ID 1-9
           @11 (ANS1-ANS5)($1.);
   ***Score the test;
   DO I=1 TO 5;
       S[I] = (KEY[I] EQ ANS[I]); 
   END;
   ***Compute Raw and Percenta]e scores;
   RAW=SUM (OF S1-S5);
   PERCENT=100*RAW / 5;
   KEEP ID RAW PERCENT;
   LABEL ID      = 'Social Security Number'
         RAW     = 'Raw Score'
         PERCENT = 'Percent Score';
DATALINES;
ABCDE
123456789 ABCDE
035469871 BBBBB
111222333 ABCBE
212121212 CCCDE
867564733 ABCDA
876543211 DADDE
987876765 ABEEE
;
PROC SORT DATA=SCORE;
   BY ID;
RUN;
PROC PRINT DATA=SCORE LABEL;
   TITLE "Listing of SCORE data set";
   ID ID;
   VAR RAW PERCENT;
   FORMAT ID SSN11.;
RUN;

*--------------------------------------------------------------*
| Program Name: SCORE2.SAS in C:\APPLIED                       |
| Purpose: To score a multiple-choice exam with an arbitrary   |
| number of items                                              |
| Data: The first line is the answer key, remaining lines      |
| contain the student responses                                |
| Data in file C:\APPLIED\TEST.DTA                             |
| Date: July 23, 1996                                          |
*--------------------------------------------------------------*;
%LET NUMBER=5; ***The number of items on the test;

DATA SCORE;
***Copy the file TEST.DTA to a folder of your choice
   and modify the following INFILE statement appropriately;
   INFILE 'C:\BOOKS\APPLIED_5th\TEST.DTA' PAD;
   ARRAY ANS[&NUMBER] $ 1 ANS1-ANS&NUMBER; ***Student answers;
   ARRAY KEY[&NUMBER] $ 1 KEY1-KEY&NUMBER; ***Answer key;
   ARRAY S[&NUMBER] 3 S1-S&NUMBER; ***Score array 1=right,0=wrong;
   RETAIN KEY1-KEY&NUMBER;
   IF _N_ = 1 THEN INPUT @1 (KEY1-KEY&NUMBER)($1.);
   INPUT @1  ID 1-9
         @11 (ANS1-ANS&NUMBER)($1.);
   DO I=1 TO &NUMBER;
      S[I] = (KEY[I] EQ ANS[I]);
   END;
   RAW=SUM (OF S1-S&NUMBER);
   PERCENT=100*RAW / &NUMBER;
   KEEP ANS1-ANS&NUMBER ID RAW PERCENT;
   LABEL ID      = 'Social Security Number'
         RAW     = 'Raw Score'
         PERCENT = 'Percent Score';
RUN;
PROC SORT DATA=SCORE;
   BY ID;
RUN;
PROC PRINT DATA=SCORE LABEL;
   TITLE "Listing of SCORE data set";
   ID ID;
   VAR RAW PERCENT;
   FORMAT ID SSN11.;
RUN;
PROC MEANS DATA=SCORE MAXDEC=2 N MEAN STD RANGE MIN MAX;
   TITLE "Class Statistics";
   VAR RAW PERCENT;
RUN;
PATTERN COLOR=BLACK VALUE=EMPTY;
PROC GCHART DATA=SCORE;
   TITLE "Histogram of Student Scores";
   VBAR PERCENT / MIDPOINTS=0 TO 100 BY 5;
RUN;
PROC FREQ DATA=SCORE;
   TITLE "Frequency Distribution of Student Answers";
   TABLES ANS1-ANS&NUMBER / NOCUM;
RUN;

*--------------------------------------------------------------*
| Program Name: SCORE3.SAS in C:\APPLIED                       |
| Purpose: To score a multiple-choice exam with an arbitrary   |
| number of items and compute item statistics                  |
| Data: The first line is the answer key, remaining lines      |
| contain the student responses. Data is located in            |
| file C:\APPLIED\TEST.DTA                                     |
| Date: April 24, 2004                                         |
*--------------------------------------------------------------*;
OPTIONS LS=64 PS=59 NOCENTER;
PROC FORMAT;
   PICTURE PCT LOW-<0=' ' 0-HIGH='00000%';
RUN;

%LET NUMBER=5; ***The number of items on the test;

DATA SCORE;
***Copy the file TEST.DTA to a folder of your choice
   and modify the following INFILE statement appropriately;
   INFILE 'C:\BOOKS\APPLIED_5th\TEST.DTA' PAD;
   ARRAY ANS[&NUMBER] $ 2 ANS1-ANS&NUMBER; ***Student answers;
   ARRAY KEY[&NUMBER] $ 1 KEY1-KEY&NUMBER; ***Answer key;
   ARRAY S[&NUMBER] 3 S1-S&NUMBER; ***Score array 1=right,0=wrong;
   RETAIN KEY1-KEY&NUMBER;
   IF _N_=1 THEN INPUT @1 (KEY1-KEY&NUMBER)($1.);
   INPUT @1  ID 1-9
         @11 (ANS1-ANS&NUMBER)($1.);
   DO I=1 TO &NUMBER;
      IF KEY[I] EQ ANS[I] THEN DO;
      S[I] = 1;
      SUBSTR(ANS[I],2,1)='*';
      ***Place an asterisk next to correct answer;
      END;
      ELSE S[I] = 0;
   END;
   RAW=SUM (OF S1-S&NUMBER);
   PERCENT=100*RAW / &NUMBER;
   KEEP ANS1-ANS&NUMBER ID RAW PERCENT;
   LABEL ID      = 'Social Security Number'
         RAW     = 'Raw Score'
         PERCENT = 'Percent Score';
RUN;

DATA TEMP;
   SET SCORE;
   ARRAY ANS[*] $ 2 ANS1-ANS&NUMBER;
   DO QUESTION=1 TO &NUMBER;
      CHOICE=ANS[QUESTION];
      OUTPUT;
   END;
   KEEP QUESTION CHOICE PERCENT;
RUN;

PROC TABULATE DATA=TEMP;
   TITLE "Item Analysis Using PROC TABULATE";
   CLASS QUESTION CHOICE;
   VAR PERCENT;
   TABLE QUESTION*CHOICE,
   PERCENT=' '*(PCTN<CHOICE>*F=PCT. MEAN*F=PCT.
   STD*F=10.2)  / RTS=20 MISSTEXT=' ';
   KEYLABEL ALL  = 'Total' 
            MEAN = 'Mean Score' PCTN='FREQ'
            STD  = 'Standard Deviation';
RUN;

*-------------------------------------------------------------*
| Program Name: SCORE4.SAS in C:\APPLIED                      |
| Purpose: To score a multiple-choice exam with an arbitrary  |
| number of items                                             |
| Data: The first line is the answer key, remaining lines     |
| contain the student responses                               |
| Data in file C:\APPLIED\TEST.DTA                            |
| Date: April 25, 2004                                        |
*-------------------------------------------------------------*;
%LET NUMBER=5; ***The number of items on the test;

DATA SCORE;
***Copy the file TEST.DTA to a folder of your choice
   and modify the following INFILE statement appropriately;
   INFILE 'C:\BOOKS\APPLIED_5th\TEST.DTA' PAD;
   ARRAY ANS [&NUMBER] $ 1 ANS1-ANS&NUMBER; ***Student answers;
   ARRAY KEY [&NUMBER] $ 1 KEY1-KEY&NUMBER; ***Answer key;
   ARRAY S [&NUMBER] S1-S&NUMBER; ***Score array 1=right,0=wrong;
   RETAIN KEY1-KEY&NUMBER;
   IF _N_ = 1 THEN INPUT (KEY1-KEY&NUMBER)($1.);
   INPUT @1  ID 1-9
         @11 (ANS1-ANS&NUMBER)($1.);
   DO I=1 TO &NUMBER;
      S[I] = (KEY [I] EQ ANS [I]);
   END;
   RAW=SUM (OF S1-S&NUMBER);
   PERCENT=100*RAW / &NUMBER;
   KEEP ANS1-ANS&NUMBER S1-S&NUMBER KEY1-Key&NUMBER
   ID RAW PERCENT;
   ***Note: ANS1-ANSn, S1-Sn, KEY1-KEYn   are needed later on;
   LABEL ID      = 'Social Security Number'
         RAW     = 'Raw Score'
         PERCENT = 'Percent Score';
RUN;

*---------------------------------------------------------*
| You may want to include the procedures in Section C     |
| which print student rosters, histograms, and class      |
| statistics.                                             |
*---------------------------------------------------------*;
***Section to prepare data sets for PROC TABULATE;
***Write correlation coefficients to a data set;
PROC CORR DATA=SCORE NOSIMPLE NOPRINT
          OUTP=CORROUT(WHERE=(_TYPE_='CORR'));
   VAR S1-S&NUMBER;
   WITH RAW;
RUN;
***Reshape the data set;
DATA CORR;
   SET CORROUT;
   ARRAY S{*} 3 S1-S&NUMBER;
   DO I=1 TO &NUMBER;
      CORR = S[I];
      OUTPUT;
   END;
   KEEP I CORR;
RUN;
***Compute quartiles;
PROC RANK DATA=SCORE GROUPS=4 OUT=QUART(DROP=PERCENT ID);
   RANKS QUARTILE;
   VAR RAW;
RUN;
***Create ITEM variable and reshape again;
DATA TAB;
   SET QUART;
   LENGTH ITEM $ 5 QUARTILE CORRECT I 3 CHOICE $ 1;
   ARRAY S{*} S1-S&NUMBER;
   ARRAY ANS{*} $ 1 ANS1-ANS&NUMBER;
   ARRAY KEY{*} $ 1 KEY1-KEY&NUMBER;
   QUARTILE = QUARTILE+1;
   DO I=1 TO &NUMBER;
      ITEM=RIGHT(PUT(I,3.)) || " " || KEY[I];
      CORRECT=S[I];
      CHOICE=ANS[I];
      OUTPUT;
   END;
   KEEP I ITEM QUARTILE CORRECT CHOICE;
RUN;
PROC SORT DATA=TAB;
   BY I;
RUN;
***Combine correlations and quartile information;
DATA BOTH;
   MERGE CORR TAB;
   BY I;
RUN;
***Print out a pretty table;
OPTIONS LS=72;
PROC TABULATE FORMAT=7.2 DATA=BOTH ORDER=INTERNAL NOSEPS;
   TITLE "Item Statistics";
   LABEL QUARTILE = 'Quartile'
         CHOICE   = 'Choices';
   CLASS ITEM QUARTILE CHOICE;
   VAR CORRECT CORR;
   TABLE ITEM='# Key'*F=6.,
   CHOICE*(PCTN<CHOICE>)*F=3. CORRECT=' '*MEAN='Diff.'*F=PERCENT5.2
   CORR=' '*MEAN='Corr.'*F=5.2
   CORRECT=' '*QUARTILE*MEAN='Prop. Correct'*F=PERCENT7.2/
      RTS=8;
   KEYLABEL PCTN='%' ;
RUN;

PROC CORR DATA=SCORE NOSIMPLE ALPHA;
   TITLE "Coefficient Alpha from Data Set SCORE";
   VAR S1-S5;
RUN;

DATA KAPPA;
   INPUT SUBJECT RATER_1 $ RATER_2 $ @@;
DATALINES;
1 N N 2 X X 3 X X 4 X N 5 N X
6 N N 7 N N 8 X N 9 X X 10 N N
;
PROC FREQ DATA=KAPPA;
   TITLE "Coefficient Kappa Calculation";
   TABLE RATER_1 * RATER_2 / NOCUM NOPERCENT KAPPA;
RUN;

***Chapter 12;

DATA QUEST;
   INPUT ID GENDER $ AGE HEIGHT WEIGHT;
DATALINES;
1   M   23   68   155
2   F        61   102
3      M   55   70   202
;

DATA INFORM;
   INFORMAT DOB VISIT MMDDYY10.;
   INPUT ID DOB VISIT DX;
DATALINES;
1 10/21/1946 6/5/1989 256.20
2 9/15/1944 4/23/1989 232.0
;

DATA FORM;
   INPUT ID DOB : MMDDYY10. VISIT : MMDDYY10. DX;
DATALINES;
1 10/21/1946 6/5/1989 256.20
2 9/15/1944 4/23/1989 232.0
;

*Example with an INFORMAT statement;
DATA LONGNAME;
   INFORMAT LAST $20.;
   INPUT ID LAST SCORE;
DATALINES;
1 STEVENSON 89
2 CODY 100
3 SMITH 55
4 GETTLEFINGER 92
;

*Example with INPUT informats;
DATA LONGNAME;
   INPUT ID LAST : $20. SCORE;
DATALINES;
1 STEVENSON 89
2 CODY 100
3 SMITH 55
4 GETTLEFINGER 92
;

DATA FIRSTLST;
   INPUT ID NAME & $30. SCORE1 SCORE2;
DATALINES;
1 RON CODY  97 98
2 JEFF SMITH  57 58
;

DATA COL;
   INPUT ID       1-3 
         GENDER $ 4 
         HEIGHT   5-6 
         WEIGHT   7-11;
DATALINES;
001M68155.5
2  F61 99.0
 3 M  233.5
;

DATA COLUMN;
INPUT #1 ID      1-3 
         AGE     5-6 
         HEIGHT 10-11 
         WEIGHT 15-17
      #2 SBP     5-7 
         DBP     8-10;
DATALINES;
001   56   72   202
   140080
002   45   70   170
   130070
;

DATA XYDATA;
   INPUT X Y @@;
DATALINES;
1 2 7 9 3 4 10 12
15 18 23 67
;

***Traditional INPUT Method;
DATA EX1A;
   INPUT GROUP $ X @@;
DATALINES;
C 20 C 25 C 23 C 27 C 30
T 40 T 42 T 35
;
PROC TTEST DATA=EX1A;
   CLASS GROUP;
   VAR X;
RUN;

DATA EX1B;               
   GROUP='C';            
   DO I=1 TO 5;          
      INPUT X @;         
      OUTPUT;            
   END;                  
   GROUP='T';            
   DO I=1 TO 3;          
      INPUT X @;         
      OUTPUT;            
   END;                  
   DROP I;               
DATALINES;               
20 25 23 27 30           
40 42 35                 
;                        
PROC TTEST DATA=EX1B;    
   CLASS GROUP;          
   VAR X;                
RUN;

DATA EX1C;               
   DO GROUP = 'C','T';            
      DO I=1 TO 5*(GROUP EQ 'C') + 3*(GROUP EQ 'T');          
         INPUT X @;         
         OUTPUT;            
      END;                  
   END;                  
   DROP I;               
DATALINES;               
20 25 23 27 30           
40 42 35                 
;                        
PROC TTEST DATA=EX1B;    
   CLASS GROUP;          
   VAR X;                
RUN;

DATA EX1D;
   DO GROUP='C','T';
      INPUT N;
      DO I=1 TO N;
         INPUT X @;
         OUTPUT;
      END;
   END;
   DROP N I;
DATALINES;
5
20 25 23 27 30
3
40 42 35
;
PROC TTEST DATA=EX1C;
   CLASS GROUP;
   VAR X;
RUN;

***Reading the Data with Tags;
DATA EX1E;
   RETAIN GROUP;
   INPUT DUMMY $ @@;
   IF DUMMY='C' OR DUMMY='T' THEN GROUP=DUMMY;
   ELSE DO;
      X = INPUT(DUMMY,5.0);
      OUTPUT;
   END;
   DROP DUMMY;
DATALINES;
C 20 25 23 27 30
T 40 42 35
;
PROC TTEST DATA=EX1D;
   CLASS GROUP;
   VAR X;
RUN;

***First Method of Reading ANOVA Data with Tags;
DATA EX2A;
   DO GENDER='M','F';
      DO GROUP='A','B','C';
         INPUT DUMMY $ @;
         DO WHILE (DUMMY NE '#');
            SCORE=INPUT(DUMMY,6.0);
            OUTPUT;
            INPUT DUMMY $ @;
         END;
      END;
   END;
   DROP DUMMY;
DATALINES;
20 30 40 20 50 # 70 80 90
# 90 90 80 90 # 25 30 45 30
65 72 # 70 90 90 80 85 # 20 20 30 #
;

***More Elegant Method for Unbalanced ANOVA Design;
DATA EX2B;
   RETAIN GROUP GENDER;
   LENGTH GROUP GENDER $ 1;
   INPUT DUMMY $ @@;
   IF VERIFY (DUMMY,'ABCMF ') = 0 THEN DO;
      GROUP = SUBSTR (DUMMY,1,1);
      GENDER = SUBSTR (DUMMY,2,1);
      DELETE;
   END;
   ELSE SCORE = INPUT (DUMMY,6.);
   DROP DUMMY;
DATALINES;
AM   20   30   40   20   50
BM   70   80   90
CM   90   80   80   90
AF   25   30   45   30   65   72
BF   70   90   90   80   85
CF   20   20   30
;

***Chapter 13;

DATA EX1;
   INPUT GROUP $ X Y Z;
DATALINES;
CONTROL 12 17 19
TREAT 23 25 29
CONTROL 19 18 16
TREAT 22 22 29
;

DATA TEST;
   INPUT AUTHOR $10. TITLE $40.;
DATALINES4;
SMITH  The Use of the ; in Writing
FIELD  Commentary on Smith's Book
;;;;

*------------------------------------------------*
| Personal Computer or UNIX Example              |
| Reading ASCII data from an External Data File  |
*------------------------------------------------*;
DATA EX2A;
   INFILE 'B:MYDATA';
   ***This INFILE statement tells the program that
      our INPUT data is located in the file MYDATA
      on a diskette in the B drive;
   INPUT GROUP $ X Y Z;
RUN;
PROC MEANS DATA=EX2A N MEAN STD STDERR MAXDEC=2 ;
   VAR X Y Z;
RUN;

***File MYDATA (located on the diskette in drive B) looks like this:
(Copy the four lines below to a file of your choice)
CONTROL 12 17 19
TREAT 23 25 29
CONTROL 19 18 16
TREAT 22 22 29
;

***You will have to make up two files to test this program;
DATA EX2E;
   IF TESTEND NE 1 THEN INFILE 'B:OSCAR' END=TESTEND;
   ELSE INFILE 'C:\DATA\BIGBIRD.TXT';
   INPUT GROUP $ X Y Z;
RUN;
PROC MEANS DATA=EX2E N MEAN STD STDERR MAXDEC=2;
   VAR X Y Z;
RUN;

***Program to count missing values;
TITLE;
DATA _NULL_;
***Copy the file CLINIC.DAT to a folder of your choice
   and modify the following INFILE statement appropriately;
   INFILE 'C:\BOOKS\APPLIED_5th\CLINIC.DAT' PAD END=LAST;
   INPUT @1  ID     $3.
         @4  GENDER $1.
         @5  DOB MMDDYY10.
         @15 HR      3.
         @18 SBP     3.
         @21 DBP     3.;
   IF MISSING(GENDER) THEN N_GENDER + 1;
   IF MISSING(DOB)    THEN N_DOB + 1;
   IF MISSING(HR)     THEN N_HR + 1;
   IF MISSING(SBP)    THEN N_SBP + 1;
   IF MISSING(DBP)    THEN N_DBP + 1;

   FILE PRINT;
   IF LAST THEN 
      PUT "Summary Report of Missing Values" /
          40*'-' /
          "Number of Missing values for GENDER: " N_GENDER /
          "Number of Missing Values for DOB: " N_DOB /
          "Number of Missing Values for HR: " N_HR /
          "Number of Missing Values for SBP: " N_SBP /
          "Number of Missing Values for DBP: " N_DBP;
RUN;

***File B:MYDATA, now with short records
CONTROL 1 2 3
TREAT 4 5
CONTROL 6 7 8
TREAT 8 9 10
;

DATA EX2F;
   INFILE 'B:MYDATA' MISSOVER;
   INPUT GROUP $ X Y Z;
RUN;
PROC MEANS DATA=EX2F N MEAN STD STDERR MAXDEC=2 ;
   VAR X Y Z;
RUN;

***File MYDATA.TXT is
A123456
B56
A556677
;

DATA EX2G;
   INFILE 'C:\DATA\MYDATA.TXT' PAD;
   INPUT GROUP $ 1
         X     2-3
         Y     4-5
         Z     6-7;
RUN;
PROC MEANS DATA=EX2G N MEAN STD STDERR MAXDEC=2 ;
   VAR X Y Z;
RUN;

DATA EX2H;
   INFILE DATALINES MISSOVER;
   INPUT X Y Z;
DATALINES;
1 2 3
4 5
6 7 8
;

DATA ALL_THREE;
***Copy the files FILE001.DAT, FILE002.DAT and FILE003.DAT to a folder of your choice
   and modify the following INFILE statement appropriately;
   INFILE 'C:\BOOKS\APPLIED_5TH\FILE*.DAT' MISSOVER DLM=',';
   INPUT X Y Z;
RUN;

DATA READ_MANY;
***Copy the files AAA.DAT, BBB.DAT, and CCC.DAT to a folder of your choice
   and modify the following FILENAME statement appropriately;
   FILENAME MIKE ('C:\BOOKS\APPLIED_5th\AAA.DAT' 'C:\BOOKS\APPLIED_5th\BBB.DAT'
                  'C:\BOOKS\APPLIED_5th\CCC.DAT');
   INFILE MIKE MISSOVER;
   INPUT X Y Z;
RUN;

DATA EX3A;
   ***This program reads a raw data file, creates a new
      variable, and writes the new data set to another file;
   INFILE 'C:MYDATA';   ***Input file;
   FILE 'A:NEWDATA'; ***Output file;
   INPUT GROUP $ X Y Z;
   TOTAL = SUM (OF X Y Z);
   PUT GROUP $ 1-10 @12 (X Y Z TOTAL) (5.);
RUN;

OPTIONS MISSING=" ";
DATA COMMA_DELIMITED;
   INPUT NAME $ X Y Z;
DATALINES;
CODY 1 2 3
SMITH 4 5 6
MISS . 8 9
;
ODS LISTING CLOSE;  ***Turn of listing;
ODS CSV FILE='C:\MYFOLDER\COMMA_ODS.CSV';
PROC PRINT DATA=COMMA_DELIMITED NOOBS;
   TITLE;
RUN;
ODS CSV CLOSE;
ODS LISTING;  ***Turn listing back on;

*------------------------------------------------------------*
| This program reads data following the datalines statement  |
| and creates a permanent SAS data set in a subdirectory     |
| called C:\SASDATA                                          |
*------------------------------------------------------------*;
LIBNAME FELIX 'C:\SASDATA';

DATA FELIX.EX4A;
   INPUT GROUP $ X Y Z;
DATALINES;
CONTROL 12 17 19
TREAT 23 25 29
CONTROL 19 18 16
TREAT 22 22 29
;

***Change the folder for your system;
LIBNAME FELIX 'C:\SASDATA';
OPTIONS FMTSEARCH=(FELIX);
***We will place the permanent SAS data sets and the
   formats in C:\SASDATA;
PROC FORMAT LIBRARY=FELIX;
   VALUE $XGROUP 'TREAT'   = 'TREATMENT GRP'
                 'CONTROL' = 'CONTROL GRP';
RUN;

DATA FELIX.EX4A;
   INPUT GROUP $ X Y Z;
   FORMAT GROUP $XGROUP.;
DATALINES;
CONTROL 12 17 19
TREAT 23 25 29
CONTROL 19 18 16
TREAT 22 22 29
;

LIBNAME C 'C:\SASDATA';
OPTIONS FMTSEARCH=(C) ;
***Tell the program to look in C:\SASDATA for user
   defined formats;
PROC PRINT DATA=C.EX4A;
RUN;

***Chapter 14;

***Programs to create data sets MASTER and TEST;
DATA MASTER;
   INPUT SS NAME : $9.;
DATALINES;
123456789   CODY
987654321   SMITH
111223333   GREGORY
222334444   HAMER
777665555   CHAMBLISS
;
DATA TEST;
   INPUT SS SCORE;
DATALINES;
123456789   100
987654321   67
222334444   92
;

PROC SORT DATA=MASTER;
   BY SS;
RUN;
PROC SORT DATA=TEST;
   BY SS;
RUN;

DATA BOTH;
   MERGE MASTER TEST;
   BY SS;
   FORMAT SS SSN11.;
RUN;

DATA BOTH;
   MERGE MASTER TEST (IN=FRODO);
   BY SS;
   IF FRODO;
   FORMAT SS SSN11.;
RUN;

DATA BOTH;
   MERGE MASTER(IN=BILBO) 
         TEST  (IN=FRODO);
   BY SS;
   IF BILBO AND FRODO;
   FORMAT SS SSN11.;
RUN;

DATA WORKER;
   INPUT ID YEAR  WBC;
DATALINES;
1  1940  6000
2  1940  8000
3  1940  9000
1  1941  6500
2  1941  8500
3  1941  8900
;
DATA EXP;
   INPUT YEAR EXPOSURE;
DATALINES;
1940  200
1941  150
1942  100
1943  80
;
PROC SORT DATA=WORKER;
   BY YEAR;
RUN;
PROC SORT DATA=EXP;
   BY YEAR;
RUN;
DATA COMBINE;
   MERGE WORKER (IN=INWORK) EXP;
   BY YEAR;
   IF INWORK;
RUN;

DATA EXP;
   INPUT YEAR WORK $ EXPOSURE;
DATALINES;
1940  MIXER 190
1940  SPREADER 200
1941  MIXER 140
1941  SPREADER 150
1942  MIXER 90
1942  SPREADER 100
1943  MIXER 70
1943  SPREADER 80
;
DATA WORKER;
   INPUT ID YEAR WORK $ WBC;
DATALINES;
1  1940  MIXER 6000
2  1940  SPREADER 8000
3  1940  MIXER 9000
1  1941  MIXER 6500
2  1941  MIXER 8500
3  1941  SPREADER 8900
;
PROC SORT DATA=WORKER;
   BY YEAR WORK;
RUN;
PROC SORT DATA=EXP;
   BY YEAR WORK;
RUN;
DATA COMBINE;
   MERGE WORKER (IN=INWORK) EXP;
   BY YEAR WORK;
   IF INWORK;
RUN;

DATA MASTER;
   INPUT PART_NO PRICE;
DATALINES;
1  19
4  23
6  22
7  45
;
DATA UPDATE_DATA;
   INPUT PART_NO PRICE;
DATALINES;
4  24
5  37
7  .
;
PROC SORT DATA=MASTER;
   BY PART_NO;
RUN;
PROC SORT DATA=UPDATE_DATA;
   BY PART_NO;
RUN;
DATA NEWMASTR;
   UPDATE MASTER UPDATE_DATA;
   BY PART_NO;
RUN;

***Chapter 15;

*--------------------------------------------------------------*
   | Example 1: Converting 999 to missing without using an array  |
*--------------------------------------------------------------*;
DATA MISSING;
   SET OLD;
   IF A = 999 THEN A = .;
   IF B = 999 THEN B = .;
   IF C = 999 THEN C = .;
   IF D = 999 THEN D = .;
   IF E = 999 THEN E = .;
RUN;

*--------------------------------------------------------------*
| Example 1: Converting 999 to missing using an array          |
*--------------------------------------------------------------*;
DATA MISSING;
   SET OLD;
   ARRAY X[5] A B C D E;
   DO I=1 TO 5;
      IF X[I] = 999 THEN X[I] = .;
   END;
   DROP I;
RUN;

*---------------------------------------------------------------*
| Example 2: Converting 999 to missing for all numeric vars     |
*---------------------------------------------------------------*;
DATA ALLNUMS;
   SET ALL;
   ARRAY PRESTON[*] _NUMERIC_ ;
   DO I = 1 TO DIM(PRESTON);
      IF PRESTON[I] = 999 THEN PRESTON[I] = .;
   END;
   DROP I;
RUN;

*----------------------------------------------------------------*
| Example 3: Converting 'N/A' to Missing for character vars      |
*----------------------------------------------------------------*;
DATA NOTAPPLY;
   SET OLD;
   IF S1 = 'N/A' THEN S1 = ' ';
   IF S2 = 'N/A' THEN S2 = ' ';
   IF S3 = 'N/A' THEN S3 = ' ';
   IF X = 'N/A' THEN X = ' ';
   IF Y = 'N/A' THEN Y = ' ';
   IF Z = 'N/A' THEN Z = ' ';
RUN;

*----------------------------------------------------------------*
| Example 3: Converting 'N/A' to Missing for character vars      |
*----------------------------------------------------------------*;
DATA NOTAPPLY;
   SET OLD;
   ARRAY RUSSELL[*] $ S1-S3 X Y Z;
   DO J = 1 TO DIM(RUSSELL);
      IF RUSSELL[J] = 'N/A' THEN RUSSELL[J] = ' ';
   END;
   DROP J;
RUN;

*--------------------------------------------------------*
| Example 4: Metric conversion without using arrays      |
*--------------------------------------------------------*;
DATA CONVERT;
   INPUT HT1-HT3 WT1-WT5;
   HTCM1 = 2.54 * HT1;
   HTCM2 = 2.54 * HT2;
   HTCM3 = 2.54 * HT3;
   WTKG1 = WT1 / 2.2;
   WTKG2 = WT2 / 2.2;
   WTKG3 = WT3 / 2.2;
   WTKG4 = WT4 / 2.2;
   WTKG5 = WT5 / 2.2;
DATALINES;
68 66 72 100 120 130 140 150
75 64 63 90 80 100 110 122
;

*--------------------------------------------------------*
| Example 4: Metric conversion without using arrays      |
*--------------------------------------------------------*;
DATA CONVERT;
   INPUT HT1-HT3 WT1-WT5;
   ARRAY HT[3];
   ARRAY HTCM[3];
   ARRAY WT[5];
   ARRAY WTKG[5];
   *** Yes, we know the variable names are missing, read on;
   DO I=1 TO 5;
      IF I LE 3 THEN HTCM[I] = 2.54 * HT[I];
      WTKG[I] = WT[I] / 2.2;
   END;
DATALINES;
68 66 72 100 120 130 140 150
75 64 63 90 80 100 110 122
;

*---------------------------------------------------------------*
| Example 5: Using a temporary array to determine the number    |
|     of tests passed                                           |
*---------------------------------------------------------------*;
DATA PASSING;
   ARRAY PASS[5] _TEMPORARY_ (65 70 65 80 75);
   ARRAY SCORE[5];
   INPUT ID $ SCORE[*];
   PASS_NUM = 0;
   DO I=1 TO 5;
      IF SCORE[I] GE PASS[I] THEN PASS_NUM + 1;
   END;
   DROP I;
DATALINES;
001 64 69 68 82 74
002 80 80 80 60 80
;
PROC PRINT DATA=PASSING;
   TITLE "Passing Data Set";
   ID ID;
   VAR PASS_NUM SCORE1-SCORE5;
RUN;

*------------------------------------------------------*
| Example 6: Using a temporary array to score a test   |
*------------------------------------------------------*;
DATA SCORE;
   ARRAY KEY[10] $ 1 _TEMPORARY_;
   ARRAY ANS[10] $ 1;
   ARRAY SCORE[10] _TEMPORARY_;
   IF _N_ = 1 THEN
      DO I=1 TO 10;
         INPUT KEY[I] @;
      END;
   INPUT ID $ @5 (ANS1-ANS10) ($1.);
   RAWSCORE = 0;
   DO I=1 TO 10;
      SCORE[I] = (ANS[I] EQ KEY[I]);
      RAWSCORE + SCORE[I];
   END;
   PERCENT = 100*RAWSCORE/10;
   DROP I;
DATALINES;
A B C D E E D C B A
001 ABCDEABCDE
002 AAAAABBBBB
;
PROC PRINT DATA=SCORE;
   TITLE "SCORE Data Set";
   ID ID;
   VAR RAWSCORE PERCENT;
RUN;

*-----------------------------------------------------*
| Example 8: Coverting plain text to morse code       |
*-----------------------------------------------------*;
DATA _NULL_;
   FILE PRINT;
   ARRAY M[65:90] $ 4 _TEMPORARY_
      ('.-' '-…' '-.-.' '-..' '.' 
       '..-.' '--.' '….' '..' '.---'
       '-.-' '.-..' '--' '-.' '---'
       '.--.' '--.-' '.-.' '…' '-'
       '..-' '…-' '.--' '-..-' '-.--'
       '--..');
   INPUT LETTER $1. @@;
   LETTER = UPCASE(LETTER);
   IF LETTER EQ ' ' THEN DO;
      PUT ' ' @;
      RETURN;
   END;
   MORSE = M[RANK(LETTER)];
   PUT MORSE @;
DATALINES;
This is a test
;

*--------------------------------------------------------*
| Example 9: demonstrating the older implicit array      |
*--------------------------------------------------------*;
DATA OLDARRAY;
   ARRAY MOZART(I) A B C D E;
   INPUT A B C D E;
   DO I=1 TO 5;
      IF MOZART = 999 THEN MOZART = .;
   END;
   DROP I;
DATALINES;
10 20 30 999 50
1 999 3 4 5
;

*--------------------------------------------------------*
| Example 10: Demonstrating the Older Implicit ARRAY     |
*--------------------------------------------------------*;
DATA OLDARRAY;
   ARRAY MOZART A B C D E;
   INPUT A B C D E;
   DO OVER MOZART;
      IF MOZART = 999 THEN MOZART = .;
   END;
DATALINES;
10 20 30 999 50
1 999 3 4 5
;

***Chapter 16;

DATA DIAGNOSE;
   INPUT ID DX1 DX2 DX3;
DATALINES;
ID DX1   DX2   DX3
01 3  4  .
02 1  2  3
03 4  5  .
04 7  .  .
;
*-----------------------------------------------------------*
  Example 1A: Creating multiple observations from a single   
  observation without using an array                         
*-----------------------------------------------------------*;
DATA NEW_DX;
   SET DIAGNOSE;
   DX = DX1;
   IF DX NE . THEN OUTPUT;
   DX = DX2;
   IF DX NE . THEN OUTPUT;
   DX = DX3;
   IF DX NE . THEN OUTPUT;
   KEEP ID DX;
RUN;

*-----------------------------------------------------------*
  Example 1B: Creating multiple observations from a single   
  observation using an array                                 
*-----------------------------------------------------------*;
DATA NEW_DX;
   SET DIAGNOSE;
   ARRAY DXARRAY[3] DX1 - DX3;
   DO I = 1 TO 3;
      DX = DXARRAY[I];
      IF DX NE . THEN OUTPUT;
   END;
   KEEP ID DX;
RUN;

PROC FREQ DATA=NEW_DX;
   TABLES DX / NOCUM;
RUN;

DATA ONEPER;
   INPUT ID S1 S2 S3;
DATALINES;
01 3  4  5
02 7  8  9
03 6  5  4
;

*-----------------------------------------------------------*
  Example 2: Creating multiple observations from a single    
  observation using an array                                 
*-----------------------------------------------------------*;
DATA MANYPER;
   SET ONEPER;
   ARRAY S[3];
   DO TIME = 1 TO 3;
      SCORE = S[TIME];
      OUTPUT;
   END;
   KEEP ID TIME SCORE;
RUN;

DATA WT_ONE;
   INPUT ID WT1 - WT6;
DATALINES;
01 155   158   162   149   148   147
02 110   112   114   107   108   109
;
*------------------------------------------------------------*
  Example 3: Using a multi-dimensional array to restructure   
  a data set                                                  
*------------------------------------------------------------*;
DATA WT_MANY;
   SET WT_ONE;
   ARRAY WTS[2,3] WT1-WT6;
   DO COND = 1 TO 2;
      DO TIME = 1 TO 3;
         WEIGHT = WTS[COND,TIME];
         OUTPUT;
      END;
   END;
   DROP WT1-WT6;
RUN;

*------------------------------------------------------------*
  Example 4A: Creating a data set with one observation per    
  subject from a data set with multiple observations per      
  subject. (Caution: This program will not work if there      
  are any missing time values.)                               
*------------------------------------------------------------*;
PROC SORT DATA=MANYPER;
   BY ID TIME;
RUN;
DATA ONEPER;
   ARRAY S[3] S1-S3;
   RETAIN S1-S3;
   SET MANYPER;
   BY ID;
   S[TIME] = SCORE;
   IF LAST.ID THEN OUTPUT;
   KEEP ID S1-S3;
RUN;

DATA MANYPER2;
   INPUT ID TIME SCORE;
DATALINES;
01 1  3
01 2  4
01 3  5
02 1  7
02 3  9
03 1  6
03 2  5
03 3  4
;
*------------------------------------------------------------*
  Example 4B: Creating a data set with one observation per    
  subject from a data set with multiple observations per      
  subject (corrected version)                                 
*------------------------------------------------------------*;
PROC SORT DATA=MANYPER2;
   BY ID TIME;
RUN;
DATA ONEPER;
   ARRAY S[3] S1-S3;
   RETAIN S1-S3;
   SET MANYPER2;
   BY ID;
   IF FIRST.ID THEN DO I = 1 TO 3;
      S[I] = .;
   END;
   S[TIME] = SCORE;
   IF LAST.ID THEN OUTPUT;
   KEEP ID S1-S3;
RUN;

*-----------------------------------------------------------*
  Example 5: Creating a data set with one observation per    
    subject from a data set with multiple observations per    
    subject using a Multi-dimensional array    
*-----------------------------------------------------------*;
PROC SORT DATA=WT_MANY;
   BY ID COND TIME;
RUN;
DATA WT_ONE;
   ARRAY WT[2,3] WT1-WT6;
   RETAIN WT1-WT6;
   SET WT_MANY;
   BY ID;
   IF FIRST.ID THEN
      DO I = 1 TO 2;
         DO J = 1 TO 3;
            WT[I,J] = .;
         END;
      END;
   WT[COND,TIME] = WEIGHT;
   IF LAST.ID THEN OUTPUT;
   KEEP ID WT1-WT6;
RUN;
PROC PRINT DATA=WT_ONE;
   TITLE 'WT_ONE Again';
RUN;

***Chapter 17;

DATA EASYWAY;
   INPUT (X1-X100)(2.);
   IF N(OF X1-X100) GE 75 THEN
   AVE=MEAN(OF X1-X100);
DATALINES;
(I'll let you supply your own lines of data)
;

DATA SHUFFLE;
   INPUT NAME : $20.;
   X=RANUNI (0);
DATALINES;
CODY
SMITH
MARTIN
LAVERY
THAYER
;
PROC SORT DATA=SHUFFLE;
   BY X;
RUN;
PROC PRINT DATA=SHUFFLE;
   TITLE "Names in Random Order";
   VAR NAME;
RUN;

DATA DATES;
   INPUT ID 1-3 MONTH 4-5 DAY 10-11 YEAR 79-80;
   DATE = MDY (MONTH,DAY,YEAR);
   DROP MONTH DAY YEAR;
   FORMAT DATE MMDDYY8.;
DATALINES;
00110    21                                                                   05
002 5     7                                                                   78
;

PROC FORMAT;
   VALUE DAYWK 1='SUN' 2='MON' 3='TUE' 4='WED' 5='THU'
               6='FRI' 7='SAT';
   VALUE MONTH 1='JAN' 2='FEB' 3='MAR' 4='APR' 5='MAY' 6='JUN'
               7='JUL' 8='AUG' 9='SEP' 10='OCT' 11='NOV' 12='DEC';
RUN;
DATA HOSP;
   ***You can make up more data if you wish;
   INPUT @1 ADMIT MMDDYY6. ;
   DAY=WEEKDAY(ADMIT);
   MONTH=MONTH(ADMIT);
   FORMAT ADMIT MMDDYY8. DAY DAYWK. MONTH MONTH.;
DATALINES;
102105
122599
102205
102105
;
PROC GCHART DATA=HOSP;
   VBAR DAY / DISCRETE;
   VBAR MONTH / DISCRETE;
RUN;

PROC FORMAT;
   VALUE AGEGRP LOW-20='1' 21-40='2' 41-60='3' 61-HIGH='4';
RUN;
DATA PUTEG;
   INPUT AGE @@;
   AGE4 = PUT(AGE,AGEGRP.);
DATALINES;
5 10 15 20 25 30 66 68 99
;

DATA FREEFORM;
   INPUT TEST $ @@;
   RETAIN GROUP;
   IF TEST='A' OR TEST='B' THEN DO;
      GROUP = TEST;
      DELETE;
   END;
   ELSE SCORE = INPUT (TEST, 5.);
   DROP TEST;
DATALINES;
A 45 55 B 87 A 44 23 B 88 99
;
PROC PRINT DATA=FREEFORM NOOBS;
   TITLE 'Listing of Data Set FREEFORM';
RUN;

DATA ORIG;
   INPUT SUBJ  TIME  X;
DATALINES;
1  1  4
1  2  6
2  1  7
2  2  2
;
DATA LAGEG;
   SET ORIG;
   ***Note: Data Set ORIG is Sorted by SUBJ and TIME;
   DIFF = X-LAG(X);
   IF TIME = 2 THEN OUTPUT;
RUN;

***Chapter 18;

DATA EXAMPLE1;
   INPUT GROUP $ @10 STRING $3.;
   LEFT = 'X '; *X AND 4 BLANKS;
   RIGHT = ' X'; *4 BLANKS AND X;
   C1 = SUBSTR(GROUP,1,2) ;
   C2 = REPEAT(GROUP,1);
   LGROUP = LENGTH(GROUP) ;
   LSTRING = LENGTH(STRING) ;
   LLEFT = LENGTH(LEFT);
   LRIGHT = LENGTH(RIGHT);
   LC1 = LENGTH(C1);
   LC2 = LENGTH(C2);
DATALINES;
ABCDEFGH 123
XXX 4
Y 5
;
PROC CONTENTS DATA=EXAMPLE1 POSITION;
   TITLE "Output from PROC CONTENTS";
RUN;
PROC PRINT DATA=EXAMPLE1 NOOBS;
   TITLE "Listing of Example 1";
RUN;

DATA EXAMPLE2;
   INPUT #1 @1 NAME $20.
         #2 @1 ADDRESS $30.
         #3 @1  CITY $15.
            @20 STATE $2.
            @25 ZIP $5.;
   NAME = COMPBL(NAME);
   ADDRESS = COMPBL(ADDRESS);
   CITY = COMPBL(CITY);
DATALINES;
RON CODY
89 LAZY BROOK ROAD
FLEMINGTON NJ 08822
BILL BROWN
28 CATHY STREET
NORTH CITY NY 11518
;
PROC PRINT DATA=EXAMPLE2;
   TITLE "Example 2";
   ID NAME;
   VAR ADDRESS CITY STATE ZIP;
RUN;

DATA EXAMPLE3;
   INPUT PHONE $ 1-15;
   PHONE1 = COMPRESS(PHONE);
   PHONE2 = COMPRESS(PHONE,'(-) ');
DATALINES;
(908)235-4490
(201) 555-77 99
;
PROC PRINT DATA=EXAMPLE3;
   TITLE "Listing of Example 3";
RUN;

DATA EXAMPLE4;
  INPUT ID     $ 1-4 
        ANSWER $ 5-9;
   P = VERIFY(ANSWER,'ABCDE');
   OK = (P EQ 0);
DATALINES;
001 ACBED
002 ABXDE
003 12CCE
004 ABC E
;
PROC PRINT DATA=EXAMPLE4 NOOBS;
TITLE "Listing of Example 4";
RUN;

DATA EXAMPLE5;
   INPUT STRING $3.;
DATALINES;
ABC
EBX
aBC
VBD
;

DATA _NULL_;
   SET EXAMPLE5;
   FILE PRINT;
   CHECK = 'ABCDE';
   IF VERIFY(STRING,CHECK) NE 0 THEN
      PUT 'Error in Record ' _N_ STRING=;
RUN;

DATA EXAMPLE6;
   INPUT ID $ 1-9;
   LENGTH STATE $ 2;
   STATE = SUBSTR(ID,1,2);
   NUM = INPUT(SUBSTR(ID,7,3),3.);
DATALINES;
NYXXXX123
NJ1234567
;
PROC PRINT DATA=EXAMPLE6 NOOBS;
   TITLE "LISTING OF EXAMPLE 6";
RUN;

DATA EXAMPLE7;
   INPUT SBP DBP @@;
   LENGTH SBP_CHK DBP_CHK $ 4;
   SBP_CHK = PUT(SBP,3.);
   DBP_CHK = PUT(DBP,3.);
   IF SBP GT 160 THEN SUBSTR(SBP_CHK,4,1) = '*';
   IF DBP GT 90 THEN SUBSTR(DBP_CHK,4,1) = '*';
DATALINES;
120 80 180 92 200 110
;
PROC PRINT DATA=EXAMPLE7 NOOBS;
   TITLE "Listing of Example 7";
RUN;

DATA EXAMPLE8;
   INPUT SBP DBP @@;
   LENGTH SBP_CHK DBP_CHK $ 4;
   SBP_CHK = PUT(SBP,3.);
   DBP_CHK = PUT(DBP,3.);
   IF SBP GT 160 THEN SBP_CHK = SUBSTR(SBP_CHK,1,3) || '*';
   IF DBP GT 90 THEN DBP_CHK = TRIM(DBP_CHK) || '*';
DATALINES;
120 80 180 92 200 110
;
PROC PRINT DATA=EXAMPLE8 NOOBS;
   TITLE "Listing of Example 8";
RUN;

DATA EXAMPLE9;
   INPUT STRING $ 1-5;
DATALINES;
12345
8 642
;
DATA UNPACK;
   SET EXAMPLE9;
   ARRAY X[5];
   DO J = 1 TO 5;
      X[J] = INPUT(SUBSTR(STRING,J,1),1.);
   END;
   DROP J;
RUN;
PROC PRINT DATA=UNPACK NOOBS;
   TITLE "Listing of UNPACK";
RUN;

DATA EX_10;
   INPUT LONG_STR $ 1-80;
   ARRAY PIECES[5] $ 10 PIECE1-PIECE5;
   DO I = 1 TO 5;
      PIECES[I] = SCAN(LONG_STR,I,',;.! ');
   END;
   DROP LONG_STR I;
DATALINES4;
THIS LINE,CONTAINS!FIVE.WORDS
ABCDEFGHIJKL XXX;YYY
;;;;
PROC PRINT DATA=EX_10 NOOBS;
   TITLE "Listing of Example 10";
RUN;

DATA EX_11;
   INPUT STRING $ 1-10;
   FIRST = INDEX(STRING,'XYZ');
   FIRST_C = INDEXC(STRING,'X','Y','Z');
DATALINES;
ABCXYZ1234
1234567890
ABCX1Y2Z39
ABCZZZXYZ3
;
PROC PRINT DATA=EX_11 NOOBS;
   TITLE "Listing of Example 11";
RUN;

DATA EX_12;
   LENGTH A B C D E $ 1;
   INPUT A B C D E X Y;
DATALINES;
M f P p D 1 2
m f m F M 3 4
;
DATA UPPER;
   SET EX_12;
   ARRAY ALL_C[*] _CHARACTER_;
   DO I = 1 TO DIM(ALL_C);
      ALL_C[I] = UPCASE(ALL_C[I]);
   END;
   DROP I;
RUN;
PROC PRINT DATA=UPPER NOOBS;
   TITLE "Listing of UPPER";
RUN;

DATA EX_13;
   INPUT QUES : $1. @@;
   QUES = TRANSLATE(QUES,'ABCDE','12345');
DATALINES;
1 4 3 2 5
5 3 4 2 1
;
PROC PRINT DATA=EX_13 NOOBS;
   TITLE "LISTING OF EXAMPLE 13";
RUN;

DATA EX_14;
   LENGTH CHAR $ 1;
   INPUT CHAR @@;
   X = INPUT(TRANSLATE(UPCASE(CHAR),'01','NY'),1.);
DATALINES;
N Y n y A B 0 1
;
PROC PRINT DATA=EX_14 NOOBS;
   TITLE "Listing of Example 14";
RUN;

DATA CONVERT;
   INPUT @1 ADDRESS $20. ;
   ***Convert Street, Avenue, and Boulevard to
      their abbreviations;
   ADDRESS = TRANWRD (ADDRESS,'Street','St.');
   ADDRESS = TRANWRD (ADDRESS,'Avenue','Ave.');
   ADDRESS = TRANWRD (ADDRESS,'Road','Rd.');
DATALINES;
89 Lazy Brook Road
123 River Rd.
12 Main Street
;
PROC PRINT DATA=CONVERT;
   TITLE "Listing of Data Set CONVERT";
RUN;

DATA ONE;
   LENGTH FIRST LAST $ 15;
   INPUT FIRST LAST;
DATALINES;
Ron Cody
Elizabeth Cantor
Ralph Fitzpatrick
;
DATA CONVERT;
   SET ONE;
   LENGTH NAME $ 32;
   NAME = TRIM(LAST) || ', ' || FIRST;
RUN;
PROC PRINT DATA=CONVERT NOOBS;
   TITLE "Listing of Data Set CONVERT";
RUN;

DATA EX_16;
   LENGTH NAME1-NAME3 $ 10;
   INPUT NAME1-NAME3;
   S1 = SOUNDEX(NAME1);
   S2 = SOUNDEX(NAME2);
   S3 = SOUNDEX(NAME3);
DATALINES;
cody Kody cadi
cline klein clana
smith smythE adams
;
PROC PRINT DATA=EX_16 NOOBS;
   TITLE "Listing of Example 16";
RUN;

DATA SPELLING_DISTANCE;
   INFORMAT WORD_ONE WORD_TWO $15.;
   INPUT WORD_ONE WORD_TWO;
   DISTANCE = SPEDIS(WORD_ONE,WORD_TWO);
DATALINES;
Exact Exact
Mistake Mistaken
abcde acbde
abcde uvwxyz
123-45-6789 123-54-6789
;
PROC PRINT DATA=SPELLING_DISTANCE NOOBS;
   TITLE "Listing of Data Set SPELLING_DISTANCE";
RUN;

***Chapter 19;

DATA TEST;
   INPUT HR SBP DBP;
DATALINES;
80 160 100
70 150 90
60 140 80
;
PROC MEANS NOPRINT DATA=TEST;
   VAR HR SBP DBP;
   OUTPUT OUT=MOUT(DROP=_TYPE_ _FREQ_)
          MEAN=M_HR M_SBP M_DBP;
RUN;
DATA NEW;
   SET TEST;
   IF _N_ = 1 THEN SET MOUT;
   HRPER = 100*HR/M_HR;
   SBPPER = 100*SBP/M_SBP;
   DBPPER = 100*DBP/M_DBP;
   DROP M_HR M_SBP M_DBP;
RUN;
PROC PRINT DATA=NEW NOOBS;
   TITLE "Listing of Data Set NEW";
RUN;

DATA TEST;
   INPUT GROUP $ HR SBP DBP @@;
DATALINES;
A 80 160 100 A 70 150 90 A 60 140 80
B 90 200 180 B 80 180 140 B 70 140 80
;
PROC SORT DATA=TEST;
   BY GROUP;
RUN;
PROC MEANS DATA=TEST NOPRINT NWAY;
   CLASS GROUP;
   VAR HR SBP DBP;
   OUTPUT OUT=MOUT(DROP=_TYPE_ _FREQ_)
          MEAN=M_HR M_SBP M_DBP;
RUN;
DATA NEW;
   MERGE TEST MOUT;
   BY GROUP;
   HRPER = 100*HR/M_HR;
   SBPPER = 100*SBP/M_SBP;
   DBPPER = 100*DBP/M_DBP;
   DROP M_HR M_SBP M_DBP;
RUN;
PROC PRINT DATA=NEW NOOBS;
   TITLE "Listing of Data Set NEW";
RUN;

DATA ORIG;
   INPUT SUBJ TIME DBP SBP;
DATALINES;

1 1 70 120
1 2 80 130
1 3 84 136
2 1 82 132
2 2 84 138
2 3 92 144
;
SYMBOL1 VALUE=NONE I=STD1MT COLOR=BLACK LINE=1 WIDTH=2;
PROC GPLOT DATA=ORIG;
   TITLE "Plot of Means with Error Bars";
   FOOTNOTE JUSTIFY=LEFT HEIGHT=1 
      "Bars represent plus and minus one standard error";
   PLOT (SBP DBP)*(TIME);
RUN;
QUIT;

%LET LIST=ONE TWO THREE;

DATA TEST;
   INPUT &LIST FOUR;
DATALINES;
1 2 3 4
4 5 6 6
;
PROC FREQ DATA=TEST;
   TABLES &LIST;
RUN;

DATA ICD;
   INPUT ID YEAR ICD;
DATALINES;
001 1950 450
002 1950 440
003 1951 460
004 1950 450
005 1951 300
;
PROC FREQ DATA=ICD;
   TABLES YEAR*ICD / OUT=ICDFREQ(DROP=PERCENT) NOPRINT;
   ***Data set ICDFREQ contains the counts
   for each CODE in each YEAR;
   TABLES YEAR / OUT=TOTAL(DROP=PERCENT) NOPRINT;
   ***Data set TOTAL contains the total number
   of obs for each YEAR;
RUN;
DATA RELATIVE;
   MERGE ICDFREQ TOTAL(RENAME=(COUNT=TOT_CNT));
   ***We need to rename COUNT in one of the two data sets
   so that we can have both values in data set RELATIVE;
   BY YEAR;
   RELATIVE = 100*COUNT/TOT_CNT;
RUN;
PROC PRINT DATA=RELATIVE;
   TITLE "Relative Frequencies of ICD Codes by Year";
RUN;

PROC FORMAT;
   VALUE SYMPTOM 1='ALCOHOL' 
                 2='INK' 
                 3='SULPHUR' 
                 4='IRON' 
                 5='TIN'
                 6='COPPER' 
                 7='DDT' 
                 8='CARBON' 
                 9='SO2' 
                10='NO2';
RUN;
DATA SENSI;
   INPUT ID 1-4 (CHEM1-CHEM10)(1.);
   ARRAY CHEM[*]   CHEM1-CHEM10;
   DO I=1 TO 10;
      IF CHEM[I] = 1 THEN DO;
         SYMPTOM = I;
         OUTPUT;
      END;
   END;
   KEEP ID SYMPTOM;
   FORMAT SYMPTOM SYMPTOM.;
DATALINES;
00011010101010
00021000010000
00031100000000
00041001001111
00051000010010
;
PROC FREQ DATA=SENSI ORDER=FREQ;
   TABLES SYMPTOM / NOCUM;
RUN;

***Program to compute a moving average;
DATA MOVING;
   INPUT COST @@;
   DAY+1;
   COST1=LAG(COST);
   COST2=LAG2(COST);
   IF _N_ GE 3 THEN DO;
      MOV_AVE=MEAN(COST, COST1, COST2);
      OUTPUT;
   END;
   DROP COST1 COST2;
DATALINES;
1 2 3 4 . 6 8 12 8
;
PROC PRINT DATA=MOVING NOOBS;
   TITLE 'Listing of Data Set MOVING';
RUN;

DATA NEVER;
   INPUT X @@;
   IF X GT 3 THEN X_LAG = LAG(X);
DATALINES;
5 7 2 1 4
;

DATA SORT;
   INPUT L1-L5;
   ARRAY S[5];
   DO I = 1 TO 5;
      S[I] = ORDINAL(I,OF L1-L5);
   END;
   DROP I;
DATALINES;
5 2 9 1 3 
6 . 22 7 0
;
PROC PRINT DATA=SORT NOOBS;
   TITLE "Listing of Data Set SORT";
RUN;

***Copy of the SCORE DATA set from Chapter 11, except the 
   variables S1 to S5 are added to the KEEP list. Variables
   S1-S5 which are the scored responses for each of   
   the 5 items on a test. S=1 for a correct answer, S=0 for an    
   incorrect response;
DATA SCORE;
   ARRAY ANS[5] $ 1 ANS1-ANS5; ***Student answers;
   ARRAY KEY[5] $ 1 KEY1-KEY5; ***Answer key;
   ARRAY S[5] 3 S1-S5; ***Score array 1=right,0=wrong;
   RETAIN KEY1-KEY5;
   ***Read the answer key;
   IF _N_=1 THEN INPUT (KEY1-KEY5)($1.);
   ***Read student responses;
   INPUT   @1  ID 1-9 
           @11 (ANS1-ANS5)($1.);
   ***Score the test;
   DO I=1 TO 5;
       S[I] = (KEY[I] EQ ANS[I]);
   END;
   ***Compute Raw and Percentile scores;
   RAW=SUM (OF S1-S5); 
   PERCENT=100*RAW / 5;
   KEEP ID RAW PERCENT S1-S5;
   LABEL ID      = 'Social Security Number'
         RAW     = 'Raw Score'
         PERCENT = 'Percent Score';
DATALINES;
ABCDE
123456789 ABCDE
035469871 BBBBB
111222333 ABCBE
212121212 CCCDE
867564733 ABCDA
876543211 DADDE
987876765 ABEEE
;
PROC MEANS NOPRINT DATA=SCORE;
   VAR S1-S5 RAW;
   OUTPUT OUT=VAROUT 
          VAR=VS1-VS5 VRAW;
RUN;
DATA _NULL_; 
   FILE PRINT;
   SET VAROUT;
   SUMVAR = SUM(OF VS1-VS5);
   KR20 = (5/4)*(1-SUMVAR/VRAW);
   PUT KR20=;
RUN;

%MACRO KR20(DSN,   /* Data set holding the scored test */
            N,     /* Number of items on the test      */
            RAW,   /* Name of the raw score variable   */
            ARRAY  /* Name of the array holding scored
                      responses                        */
            );
   PROC MEANS NOPRINT DATA=&DSN;
      VAR &ARRAY.1-&ARRAY&N &RAW;
      OUTPUT OUT=VAROUT 
             VAR=VS1-VS&N VRAW;
   RUN;
   DATA _NULL_;
      FILE PRINT;
      SET VAROUT;
      SUMVAR = SUM(OF VS1-VS5);
      KR20 = (&N/%EVAL(&N - 1))*(1-SUMVAR/VRAW);
      PUT KR20=;
   RUN; 
%MEND KR20;

