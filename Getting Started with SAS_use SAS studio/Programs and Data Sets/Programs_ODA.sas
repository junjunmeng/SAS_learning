*** This file contains all the programs used in this book.  You can copy them to
    a location such as ~/MyBookFiles and run them for yourself;

*Program 7-1: Program to Read Temperatures in Degrees Celsius and Convert them to Fahrenheit;
*Program C_to_F
 Program to read temperatures in degrees Celsius and convert
 them to degrees Fahrenheit;
 
Data Convert;
   infile "~/MyBookFiles/celsius.txt"; 
   input Temp_C;
   Temp_F = 1.8*Temp_C + 32;
run;

title "Temperature Conversion Chart";
proc print data=Convert;
   var Temp_C Temp_F;
run;

*Program 7-2: Reading Text Data from an Exernal File;
data Demo;
   infile '~/MyBookFiles/demographic.txt';
   input ID $ Gender $ Age Height Weight Party $;
run;

*Program 7-3: Computing frequencies on the Demo Data Set;
data Demo;
   infile "~/MyBookFiles/demographic.txt";
   input ID $ Gender $ Age Height Weight Party $;
run;

title "Computing Frequenciesfrom the DEMO Data Set";
proc freq data=Demo;
   tables Gender Party;
run;

*Program 8-1: Reading Data with Delimiters (Blanks);
/* This is another way to insert a coment */
data Blanks /* the data set name is Blanks */;
   infile "~/MyBookFiles/Blank_Delimiter.txt" missover;
   informat ID $11. First Last $15. Gender $1. State_Code $2.;
   input ID First Last Gender Age State_Code;
run;

title "Listing of Data Set Blanks";
proc print data=blanks;
run;

*Program 2: Reading CSV Files;
data commas;
   infile "~/MyBookFiles/Comma_Delimiter.txt" dsd missover;
   informat ID $11. First Last $15. Gender $1. State_Code $2.;
   input ID First Last Gender Age State_Code;
run;

title "Listing of Data Set Commas";
proc print data=Commas;
run;

*Program 8-3: Reading Tab Delimited Data;
data Tabs;
   infile "~/MyBookFiles/Tab_Delimiter.txt" dlm='09'x missover;
   informat ID $11. First Last $15. Gender $1. State_Code $2.;
   input ID First Last Gender Age State_Code;
run;

title "Listing of Data Set Tabs";
proc print data=Tabs;
run;

*Program 8-4: Reading Data in Fixed Columns Using Column Input;
data Health;
   infile '~/MyBookFiles/health.txt' pad;
   input Subj   $ 1-3
         Gender $ 4
         Age      5-6
         HR       7-8
         SBP      9-11
         DBP      12-14
         Chol     15-17;
run;

title "Listing of Data Set Health";
proc print data=Health;
   ID Subj;
run;

*Program 8-5: Reading Data in Fixed Columns Using Formatted Input;
data health;
   infile '~/MyBookFiles/health.txt' pad;
   input @1  Subj   $3.
         @4  Gender $1.
         @5  Age     2.
         @7  HR      2.
         @9  SBP     3.
         @12 DBP     3.
         @15 Chol    3.;
run;

title "Listing of Data Set Health";
proc print data=health;
   ID Subj;
run;

*Program 8-6: Demonstrating Formatted Input;
data Health;
   infile '~/MyBookFiles/health.txt' pad;
   input @1  Subj   $3.
         @4  Gender $1.
         @5  (Age HR) (2.)
         @9  (SBP DBP Chol) (3.);
run;

title "Listing of Data Set Health";
proc print data=health;
   ID Subj;
run;

*Program 9-1: Running PROC CONTENTS to Examine the Data Descriptor for Data Set DEMO;
*Program to display the data descriptor of data set DEMO;
data Demo;
   infile "~/MyBookFiles/demographic.txt/";
   input ID $ Gender $ Age Height Weight Party $;
run;
title "Data Descriptor for Data Set DEMO";
proc contents data=demo;
run;

*Program 9-2: Using a LIBNAME Statement;
libname Oscar "~/MyBookFiles";
data Oscar.Demo;
   infile "~/MyBookFiles/demographic.txt";
   input ID $ Gender $ Age Height Weight Party $;
run;

*Program 9-3: Reading the HeightWeight.txt File;
data HtWt;
   infile '~/MyBookFiles/HeightWeight.txt';
   input Height Weight;
run;

*Program 10-1: Creating the Taxes Data Set (and Demonstrating a DATALINES Statement);
data Taxes;
   informat SSN $11.
            Gender $1.
            Question_1 - Question_4 $1.;
    input SSN Gender Question_1 - Question_4
          Question_5;
datalines;
101-23-1928 M 1 3 C 4 23000
919-67-7800 F 9 2 D 2 17000
202-22-3848 M 0 5 A 5 57000
344-87-8737 M 1 1 B 2 34123
444-38-2837 F . 4 A 1 17233
763-01-0123 F 0 4 A 4 .
;

title "Listing of Data Set Taxes";
proc print data=Taxes;
   id SSN;
run;

*Program 10-2: Creating Your Own Formats;
proc format;
   value $Gender 'M'='Male' 
                 'F'='Female';
   value $Yesno '0'='No' 
                '1'='Yes' 
              other='Did not answer';
   value $Likert 1='Strongly Disagree'
                 2='Disagree'
                 3='No Opinion'
                 4='Agree'
                 5='Strongly Agree';
   value $Calls 'A'='None'
                'B'='1 or 2'
                'C'='3 - 5'
                'D'='More than 5';
   value Pay_group  low-10000 = 'Low'
                    10001-20000 = 'Medium'
                    20001-50000 = 'High'
                    50001-high = 'Very High';
run;

*Program 10-3: Computing Frequencies on the Taxes Data Set (without Formats);
title 'Frequencies for the Taxes Data Set';
proc freq data=Taxes;
   tables Gender Question_1 - Question_5 / nocum;
run;

*Program 10-4: Adding a Format Statement to PROC FREQ;
title 'Frequencies for the Taxes Data Set';
proc freq data=Taxes;
   format Gender $Gender. 
          Question_1 $Yesno.
          Question_2 Question_4 $Likert.
          Question_3 $Calls. 
          Question_5 Pay_group.;
   tables Gender Question_1 - Question_5 / nocum;
run;

*Program 10-5: Making a Permanent Formnat;
libname myfmts '~/MyBookFiles';
proc format library=myfmts;
   value $Gender 1='Male'
                 2='Female';
   value $Yesno  0='No'
                 1='Yes';
run;

*Program 10-6: Adding the FMTLIB Option;
libname myfmts '~/MyBookFiles';
proc format library=myfmts fmtlib;
   value $Gender 1='Male'
                 2='Female';
   value $Yesno  0='No'
                 1='Yes';
run;

*Program 10-7: Creating Variable Labels;
data Taxes;
   informat SSN $11.
            Gender $1.
            Question_1 - Question_4 $1.;
    input SSN Gender Question_1 - Question_5;
    label Question_1 = 'Do you pay taxes?'
          Question_2 = 'Are you satisfied with the service?'
          Question_3 � 'How many phone calls?'
          Question_4 = 'Was the person friendly?'
          Question_5 = 'How much did you pay?';
datalines;
101-23-1928 M 1 3 C 4 23000
919-67-7800 F 9 2 D 2 17000
202-22-3848 M 0 5 A 5 57000
344-87-8737 M 1 1 B 2 34123
444-38-2837 F . 4 A 1 17233
763-01-0123 F 0 4 A 4 .
;
title 'Frequencies for the Taxes Data Set';
proc freq data=Taxes;
   format Gender $Gender. 
          Question_1 $Yesno.
          Question_2 Question_4 $Likert.
          Question_3 $Calls. 
          Question_5 Pay_group.;
   tables Gender Question_1 - Question_5 / nocum;
run;

*Program 11-1;
data People;
   input @1  ID     $3. 
         @4  Gender $1.
         @5   Age    3.
         @8  Height  2.
         @10 Weight  3.;  
   if Age le 20 then Age_Group = 1;
   else if Age le 40 then Age_Group = 2;
   else if Age le 60 then Age_Group = 3;
   else if Age le 80 then Age_Group = 4;
   else if Age ge 80 then Age_Group = 5;

datalines;
001M 5465220
002F10161 98
003M 1770201
004M 2569166
005F   64187
006F 3567135
;
title "Listing of Data Set People";
proc print data=People;
   id ID;
run;

*Program 11-2: Corrected Version of Program 1;
data People;
   input @1  ID     $3. 
         @4  Gender $1.
         @5   Age    3.
         @8  Height  2.
         @10 Weight  3.;  
   if missing(Age) then Age_Group = .;
   else if Age le 20 then Age_Group = 1;
   else if Age le 40 then Age_Group = 2;
   else if Age le 60 then Age_Group = 3;
   else if Age le 80 then Age_Group = 4;
   else if Age ge 80 then Age_Group = 5;
datalines;
001M 5465220
002F10161 98
003M 1770201
004M 2569166
005F   64187
006F 3567135
;
title "Listing of Data Set People";
proc print data=People;
   id ID;
run;

*Program 11-3: Using Conditional Logic to Test for Out-of-Range Data Values;
data _null_;
   set People;
   if Weight lt 100 and not missing(Weight) or Weight gt 200 then
   put "Weight for ID " ID "is " Weight;
run;

*Program 11-4: A Common Error Using Multiple OR Operators;
data Mystery;
   input x;
   if x = 3 or 4 then Match = 'Yes';
   else Match = 'No';
datalines;
3
4
9
.
-5
;
title "Listing of Data Set Mystery";
proc print data=Mystery noobs;
run;

*Program 11-5: A Corrected Version of Program 4;
data Mystery;
   input x;
   if x = 3 or x = 4 then Match = 'Yes';
   else Match = 'No';
datalines;
3
4
9
.
-5
;
title "Listing of Data Set Mystery";
proc print data=Mystery noobs;
run;

*Program 12-1: Creating a Table of Celsius and Fahrenheit Temperatures;
data Convert_Temp;
   do Temp_C = 0 to 100;
      Temp_F = 1.8*Temp_C + 32;
      output;
   end;
run;

title "Listing of Data Set Convert_Temp";
proc print data=Convert_Temp noobs;
run;

*Program 12-2: Graphing a Cubic Equation;
data Cubic;
   do x = -5 to 5 by .01;
      y = 2*x**3 - x**2 + 3*x;
      output;
   end;
run;

title "Graph of Cubic Equation";
proc sgplot data=Cubic;
   series x=x y=y;
run;

*Program 12-3: Using a DO with Character Values;
data HR_Study;
   do Drug_Group = 'Placebo','Drug A','Drug B';
      input Heart_Rate @;
      output;
   end;
datalines;
80 70 60
82 77 63
76 74 70
78 80 67
;
title "Listing of Data Set HR_Study";
proc print data=HR_Study noobs;
run;

*Program 12-4: Demonstrating a DO WHILE Loop;
data Bank;
   Interest_Rate=.07;
   Amount = 1000;
   Goal = 2000;
   do while (Amount lt Goal);
      Year + 1;
      Amount = Amount + Interest_Rate*Amount;
      output;
   end;
   format Amount Goal dollar9.2;
run;

title "Listing of Data Set Bank";
proc print data=Bank noobs;
run;

*Program 12-5: Combining an Iterative DO Loop with a WHILE Condition;
data Bank;
   Interest_Rate=.07;
   Amount = 1000;
   Goal = 2000;
   do I = 1 to 20 while (Amount lt Goal);
      Year + 1;
      Amount = Amount + Interest_Rate*Amount;
      output;
   end;
   format Amount Goal dollar9.2;
   drop I;
run;

title "Listing of Data Set Bank";
proc print data=Bank noobs;
run;

*Program 12-6: Demonstrating a DO UNTIL Loop;
data Bank;
   Interest_Rate=.07;
   Amount = 1000;
   Goal = 2000;
   do until (Amount gt Goal);
      Year + 1;
      Amount = Amount + Interest_Rate*Amount;
      output;
   end;
   format Amount Goal dollar9.2;
run;

title "Listing of Data Set Bank";
proc print data=Bank noobs;
run;

*Program 12-7: Demonstrating that a DO UNTIL Loop Will Always Execute Once;
data At_Least_Once;
   x = 5;
   do until (x = 5);
      put "This line is inside the loop";
   end;
run;

*Program 12-8: Combining an Iterative DO Loop with an UNTIL Condition;
data Bank;
   Interest_Rate=.07;
   Amount = 1000;
   Goal = 2000;
   do I = 1 to 100 until (Amount gt Goal);
      Year + 1;
      Amount = Amount + Interest_Rate*Amount;
      output;
   end;
   format Amount Goal dollar9.2;
   drop I;
run;

title "Listing of Data Set Bank";
proc print data=Bank noobs;
run;

*Program 12-9: Demonstrating s LEAVE Statement;
data Bank;
   Interest_Rate=.07;
   Amount = 1000;
   Goal = 2000;
   do I = 1 to 20;
      Year + 1;
      Amount = Amount + Interest_Rate*Amount;
      output;
   if Amount gt Goal then leave;
   end;
   format Amount Goal dollar9.2;
   drop I;
run; 

title "Listing of Data Set Bank";
proc print data=Bank noobs;
run; 

*Program 12-10: Demonstrating a CONTINUE Statement;
data Bank;
   Interest_Rate=.07;
   Amount = 1000;
   Goal = 2000;
   do until (Amount gt Goal);
      Year + 1;
      Amount = Amount + Interest_Rate*Amount;     
      if Amount lt 1500 then continue;
      output;
  end;
   format Amount Goal dollar9.2;
run;

title "Listing of Data Set Bank";
proc print data=bank noobs;
run;

*Program 13-1: Reading Dates in a Variety of Date Formats;
data Read_Dates;
   infile '~/MyBookFiles/Date_Data.txt' pad;
   input @1  Date1 mmddyy10.
         @12 Date2 date9.
         @22 Date3 ddmmyy10.;
run;

title "Listing of Data Set Dates";
proc print data=Read_Dates noobs;
run;

*Program 13-2: Adding Formats to Display the Date Values;
data Read_Dates;
   infile '~/MyBookFiles/Date_Data.txt' pad;
   input @1  Date1 mmddyy10.
         @12 Date2 date9.
         @22 Date3 ddmmyy10.;
   format Date1 mmddyy10. Date2 Date3 date9.;
run;

title "Listing of Data Set Dates";
proc print data=Read_Dates noobs;
run;

*Program 13-3: Demonstrating a Date Constant;
data _null_;
title "Checking for Out of Range Dates";
   input @1 Date mmddyy10.;
   file print;
   if Date lt '01Jan2020'd and not missing(Date) or
      Date gt '31Dec2021'd then put "Date " Date "is out of range";
   format Date mmddyy10.;
datalines;
10/13/2020
5/1/2012
1/1/2015
6/5/2020
1/1/2000
;
*Program 13-4: Extracting the Day of the Week, Day of the Month, and Year from a SAS Date;
data Extract;
   informat Date mmddyy10.;
   input Date @@;
   Day_of_Week = weekday(Date);
   Day_of_Month = day(Date);
   Year = year(Date);
   format Date mmddyyd10.;
datalines;
1/5/2000 2/8/2000 4/23/2000 4/12/2000 8/21/2000 8/21/2000 8/22/2000
12/12/2000 12/15/2000 12/18/2000
2/22/2001 2/1/2001 4/18/2001 4/18/2001 4/18/2001 9/17/2001 12/25/2001
12/22/2001 3/3/2001 3/6/2001 3/7/2001
;
title "Listing of the First Eight Observations from Extract";
proc print data=Extract (obs=8);
run;

title "Frequencies for Day of the Week";
proc sgplot data=Extract;
   vbar Day_of_Week;
run;

*Program 13-5: Creating a Variable Representing Day of the Week Abbreviations;
proc format;
   value dow 1='Sun' 2='Mon' 3='Wed' 4='Thu' 
             5='Fri' 6='Sat' 7='Sun';
run;
data Extract;
   informat Date mmddyy10.;
   input Date @@;
   Day_of_Week = weekday(Date);
   Day_of_Month = day(Date);
   Year = year(Date);
   format Date mmddyyd10. Day_of_Week dow.;
datalines;
1/5/2000 2/8/2000 4/23/2000 4/12/2000 8/21/2000 8/21/2000 8/22/2000
12/12/2000 12/15/2000 12/18/2000
2/22/2001 2/1/2001 4/18/2001 4/18/2001 4/18/2001 9/17/2001 12/25/2001
12/22/2001 3/3/2001 3/6/2001 3/7/2001
;
title "Listing of the First Eight Observations from Extract";
proc print data=Extract (obs=8);
run;

title "Frequencies for Day of the Week";
proc sgplot data=Extract;
   vbar Day_of_Week;
run;

*Program 14-1: Using a WHERE Statement to Subset a SAS Data Set;
data Year1980;
   set sashelp.retail;
   where Year = 1980;
run;

title "Listing of Data Set Year1980";
proc print data=Year1980 noobs;
run;

*Program 14-2: Demonstrating a More Complicated Query;
data Complicated;
   set sashelp.retail;
   where Year in (1980, 1983, 1985) and Sales ge 250;
run;

title "Listing of Data Set Complicated";
proc print data=Complicated noobs;
run;

*Program 14-3: Rewriting Program 1 Using a WHERE= Data Set Option;
data Year1980;
   set sashelp.retail (where=(Year = 1980));
run;

*Program 14-4: Using a WHERE Data Set Option in a SAS Procedure;
proc print data=sashelp.Retail (where=(Year = 1980));
run;

*Program 14-5: Demonstrating the Subsetting IF Statement;
data Females;
   input @1  ID     $3. 
         @4  Gender $1.
         @5   Age    3.
         @8  Height  2.
         @10 Weight  3.;  
   if Gender = 'F';
datalines;
001M 5465220
002F10161 98
003M 1770201
004M 2569166
005F   64187
006F 3567135
;
title "Listing of Data Set Females";
proc print data=Females;
   id ID;
run;

*Program 14-6: Demonstrating a Trailing @;
data Females;
   input @4  Gender $1. @;
   if Gender = 'F' then 
      input @5   Age    3.
            @8  Height  2.
            @10 Weight  3.;  
   else delete;
datalines;
001M 5465220
002F10161 98
003M 1770201
004M 2569166
005F   64187
006F 3567135
;
*Program 14-7: Creating Several SAS Data Sets in One DATA step;
data Year1980 Year1981 Year1982;
   set sashelp.Retail;
   if Year = 1980 then output Year1980;
   else if Year = 1981 then output Year1981;
   else if Year = 1982 then output Year1982;
run;

/*** Note: Program 14-9 must be run before Program 14-8
     so the order was changed in this file ***/
     
*Program 14-9: Program to Create Data Sets ONE and TWO;
data One;
   informat ID $3. DOB mmddyy10. Gender $1.;
   input ID DOB Gender Height Weight;
   format DOB mmddyy10.;
datalines;
001 10/21/1950 M 68 160
002 11/11/1981 F 62 120
003 1/5/1983 M 72 220
;
data Two;
   informat ID $3. DOB mmddyy10. Gender $1.;
   input ID DOB Gender Height Weight;
   format DOB mmddyy10.;
datalines;
004 5/13/1978 M 70 190
005 8/23/1988 F 59 98
;

*Program 14-8: Using a SET Statement to Combine Two SAS Data Sets;
data Both;
   set One Two;
run;

/*** Programs 14-10 to 14-12 for demonstration purposes, not meant to be run 
*Program 14-10: Using a SET Statement to Solve the Problem;
Data Both;
   Set Big Small;
run;
*Program 14-11: Using PROC APPEND to Add Observations from One Data Set to another;
proc append base=Big Data=Small;
run;

*Program 14-12: Demonstrated How to Interleave Two or More Data Sets;
data combined;
   *Note: data sets One, Two, and Three are sorted by ID;
   set One Two Three;
   by ID;
run;
***/

*Program 14-13: Creating the Patients and Visits Data Sets;
data Patients;
   informat ID $4. Gender $1. DOB mmddyy10.;
   input ID Gender DOB;
   format DOB date9.;
datalines;
0001 M 10/10/1980
0023 F 1/2/1977
1243 M 6/17/2000
0002 M 8/23/1981
4535 F 2/25/1967
;
data Visits;
   informat ID $4. Visit_Date mmddyy10.;
   input ID Visit_Date Weight HR SBP DBP;
   format Visit_Date date9.;
datalines;
0023 2/10/2015 122 76 122 78
4535 10/21/2014 155 78 138 88
0001 11/11/2014 210 68 118 78
;
*Program 14-14: Merging Two SAS Data Sets;
proc sort data=Patients;
   by ID;
run;

proc sort data=Visits;
   by ID;
run;

data Merged;
   merge Patients Visits;
   by ID;
run;

title "Listing of Data Set Merged";
proc print data=Merged;
   id ID;
run;

*Program 14-15: Demonstrating the IN= Data Set Option;
*Note: both data set previously sorted by ID;
data Merged;
   merge Patients(in=In_Patients) Visits(In=In_Visits);
   by ID;
   put ID= In_Patients= In_Visits=;
run;

*Program 14-16: Using the IN= Data Set Options to Control the Merge Operation;
*Note: Both data sets already sorted by ID;
title "Listing of Data Set Only_Visit_Patients";
data Only_Visit_Patients;
   file print;
   merge Patients(in=In_Patients) Visits(in=In_visits);
   by ID;
   if In_Visits then output;
   if In_Visits and not In_Patients then
      put "Patient " ID "not found in the Patients data set.";
run;

title "Listing of Data Set Only_Visit_Patients";
proc print data=Only_Visit_Patients;
   id ID;
run;

*Program 14-17: Creating Another Data Set to Demonstrate a One-to-Many Merge;
data Many_Visits;
   informat ID $4. Visit_Date mmddyy10.;
   input ID Visit_Date HR SBP DBP;
   format Visit_Date date9.;
;
datalines;
0023 2/10/2015 122 76 122 78
0023 3/10/2015 120 74 120 76
4535 10/21/2014 155 78 138 88
0001 11/11/2014 210 68 118 78
0001 12/20/2014 210 68 120 82
0001 1/5/2015 212 70 210 80
;
*Program 14-18: Performing a One-to-Many Merge;
proc sort data=Patients;
   by ID;
run;

proc sort data=Many_Visits;
   by ID;
run;

data One_to_Many;
   merge Patients Many_Visits;
   by ID;
run;

title "Listing of data set One_To_Many";
proc print data=One_to_Many;
   id ID;
run;

*Program 14-19: Program to Create Data Set Visits_2;
data Visits_2;
   informat Pt $4. Visit_Date mmddyy10.;
   input Pt Visit_Date Weight HR SBP DBP;
   format Visit_Date date9.;
datalines;
0023 2/10/2015 122 76 122 78
4535 10/21/2014 155 78 138 88
0001 11/11/2014 210 68 118 78
;
*Program 14-20: Using a RENAME= Data Set Option to Rename the Variable Pt to ID;
proc sort data=Patients;
   by ID;
run;

proc sort data=Visits_2;
   by Pt;
run;

data Merged;
   merge Patients Visits_2(rename=(Pt = ID));
by ID;
run;

title "Listing of Data Set Merged";
proc print data=Merged;
   id ID;
run;

*Program 14-21: Program to Create Data Sets One_Char and Two_Num;
data One_Char;
   informat SS $11. Gender $1.;
   input SS Gender Age;
datalines;
123-45-6789 M 45
088-54-1950 F 23
321-43-7766 M 68
;
data Two_Num;
   informat Visit_Date mmddyy10. Fee_Paid $3.;
   input SS Visit_Date Fee_Paid;
   format Visit_Date mmddyy10.;
datalines;
123456789 10/14/2015 Yes
088541950 2/10/2015 No
321437766 3/23/2015 Yes
;

*Program 14-22: Merging Two Data Sets with One Character and One Numeric BY Variable;
data Two_Char;
   set Two_Num(rename=(SS = SS_Num));
   SS = put(SS_Num,SSN11.);
   drop SS_Num;
run;

proc sort data=One_Char;
   by SS;
run;

proc sort data=Two_Char;
   by SS;
run;

Data One_and_Two;
   merge One_Char Two_Char;
   by SS;
run;

title "Listing of Data Set One_and_Two";
proc print data=One_and_Two noobs;
run;

*Program 14-23: Program to Create the Master File;
data Price;
   input @1  Item_Number $5.
         @7  Description $10.
         @18 Price;
datalines;
12345 Hammer     11.98
22222 Saw        25.89
44010 Nails 10p  17.95
44008 Nails 8p   15.56
;
title "Listing of Data Set Price";
proc print data=Price;
   id Item_Number;
run;

*Program 14-24: Creating the Transaction Data Set;
data Transact;
   informat Item_Number $5.;
   input Item_Number Price;
datalines;
12345 12.98
44008 16.50
;
title "Listing of Data Set Transact";
proc print data=Transact;
   id Item_Number;
run;

*Program 14-25: Updating Your Master File Using a Transaction Data Set;
proc sort data=Price;
   by Item_Number;
run;

proc sort data=Transact;
   by Item_Number;
run;

data Price_10Oct2015;
   update Price Transact;
   by Item_Number;
run;

title "Listing of Data Set Price_10Oct2015";
proc print data= Price_10Oct2015;
   id Item_Number;
run;

*Program 15-1: Demonstrating the MISSING Function;
data Old_Miss;
   input ID $ Age;
   if missing(Age) then Age_group = .;
   else if Age le 50 then Age_group = 1;
   else Age_group = 2;
datalines;
001 15
002 . 
003 78
004 26
;
title "Listing of Data Set Old_Miss";
proc print data=Old_Miss noobs;
run;
*Program 15-2: Program Demonstrating Several Functions (N, NMISS, MAX, Largest, and Mean);
data Score;
   input ID $ Q1-Q10;
   if n(of Q1-Q5) ge 3 then Score1 = mean(of Q1-Q5);
   if nmiss(of Q6-Q10) le 2 then Score2 = mean(of Q6-Q10);
   Score3 = max(of Q1-Q10);
   Score4 = sum(largest(1,of Q1-Q10), 
                largest(2,of Q1-Q10),
                largest(3,of Q1-Q10));
datalines;
001 9 7 8 6 7 6 . . 9 2
002 . . . . 9 8 7 8 9 9
003 6 7 6 7 6 . . . 9 9
;
title "Listing of Data Set Score";
proc print data=Score noobs;
run;
*Program 15-3: Using CALL SORTN to Compute the Mean of the Eight Highest Scores;
data Test;
   input Stud_ID $ Score1-Score10;
   call sortn(of Score1-Score10);
   Mean_Top_8 = mean(of Score3-Score10);
datalines;
001 90 90 80 78 100 95 90 92 88 82
002 50 55 60 65 70 75 80 85 90 95
;
title "Listing of Data Set Test";
proc print data=Test;
   id Stud_ID;
   var Score1-Score10 Mean_Top_8;
run;
*Program 15-4: Demonstrating the LAG Function;
data Stocks;
   informat Date mmddyy10.;
   input Date Price;
   Up_Down = Price - lag(Price);
   format Date mmddyy10.;
datalines;
1/1/2015 100
1/2/2015 98
1/3/2015 96
1/4/2015 101
1/5/2015 101
1/6/2015 104
;
title "Listing of Data Set Stocks";
proc print data=Stocks noobs;
run;
*Program 15-5: Using the Family of LAGn functions to Compute a Moving Average;
data Moving;
   set Stocks;
   Yesterday = lag(Price);
   Two_Days_Ago = lag2(Price);
   Moving = mean(Price, Yesterday, Two_Days_Ago);
run;

title "Listing of Data Set Moving";
proc print data=Moving noobs;
run;

*Program 15-6: Demonstrating the Two Functions LENGTHN and LENGTHC;
data How_Long;
   length String $ 5 Miss $ 4;
   String = 'Abe';
   Miss = ' ';
   Length_String = lengthn(String);
   Store_String = lengthc(String);
   Display = ':' || String || ':';
   Length_Miss = lengthn(Miss);
   Store_Miss = lengthc(Miss);
run;

title "Listing of Data Set How_Long";
proc print data=How_Long noobs;
run;

*Program 15-7: Examples Using the PUT Function;
proc format;
   value Agegrp low-50='Young'
                51-high='Older'
                     . ='Missing'
                 other ='Error';
run;

data Put_Eg;
   informat Date mmddyy10.;
   input SS_Num Date Age;
   SS = put(SS_Num,ssn11.);
   Day = put(Date,downame3.);
   Age_Group = put(Age,agegrp.);
   format Date date9.;
datalines;
123456789 10/21/1950 42
890001233 11/12/2015 86
987654321 1/1/2015 15
;
title "Listing of Data Set Put_Eg";
proc print data=Put_Eg noobs;
run;

*Program 15-8: Demonstrating the Combination of CATS and COUNTC;
data Survey;
   input (Q1-Q5)($1.);
   Number_Y = countc(cats(of Q1-Q5),'Y','i');
datalines;
YyYnn
NNnnn
NYNyy
;
title "Listing of Data Set Survey";
proc print data=Survey noobs;
run;

*Program 15-9: Using the COMPRESS Function to Read Data that Includes Units;
data Weight;
   input Wt $ @@;
   Wt_Kg = input(compress(Wt,,'kd'),12.);
   if findc(Wt,'L','i') then Wt_Kg = Wt_Kg / 2.2;
datalines;
120lbs. 90Kg 80Kgs. 200Lb
;
title "Listing of Data Set Weight";
proc print data=Weight noobs;
run;

*Program 16-1: Creating the Clinic Data Set;
data Clinic;
   informat Date mmddyy10. PtNum $3.;
   input PtNum Date Height Weight Heart_Rate SBP DBP;
   format Date date9.;
datalines;
001 10/21/2015 68 190 68 120 80
001 11/25/2015 68 195 72 122 84
002 9/1/2015 72 220 76 140 94
003 5/6/2015 63 101 78 118 66
003 7/8/2015 63 106 76 122 70
003 9/1/2015 63 105 77 116 68
;
title "Listing of Data Set Clinic";
proc print data=Clinic;
   id PtNum;
run;

*Program 16-2: Creating First. and Last. Variables;
proc sort data=Clinic;
   by PtNum Date;
run;

data Clinic_New;
   set Clinic;
   by PtNum;
   file print;
   put  PtNum= Date= First.PtNum=  Last.PtNum=;
run;

*Program 16-3: Computing Visit to Visit Differences in Selected Variables;
proc sort data=Clinic;
   by PtNum Date;
run;

data Diff;
   set Clinic;
   by PtNum;
   if First.PtNum and Last.PtNum then delete;
   Diff_HR = dif(Heart_Rate);
   Diff_SBP = dif(SBP);
   Diff_DBP = dif(DBP);
   if not First.PtNum then output;
run;

title "Listing of Data Set Diff";
proc print data=Diff;
   id PtNum;
run;

*Program 16-4: Computing Differences Between the First and Last Visit;
proc sort data=Clinic;
   by PtNum Date;
run;

data First_Last;
   set Clinic;
   retain First_Heart_Rate First_SBP First_DBP;
   by PtNum;
   if First.PtNum and Last.PtNum then delete;
   if First.PtNum then do;
      First_Heart_Rate = Heart_Rate;
      First_SBP = SBP;
      First_DBP = DBP;
   end;
   if Last.PtNum then do;
      Diff_HR = Heart_Rate - First_Heart_Rate;
      Diff_SBP = First_SBP - SBP;
      Diff_DBP = First_DBP - DBP;
      output;
   end;
run;

title "Listing of Data Set First_Last";
proc print data=First_Last;
   id PtNum;
run;

*Program 16-5: Counting the Number of Visits for Each Patient;
proc sort data=Clinic;
   by PtNum;
run;

data Counts;
   set Clinic;
   by PtNum;
   if First.PtNum then N_Visits=0;
   N_Visits + 1;
   if Last.PtNum then output;
run;

title "Listing of Data Set Counts";
proc print data=Counts;
   id PtNum;
run;

*Program 17-1: Program to Convert 999 to a Missing Value (without using arrays);
data Health_Survey;
   input ID $ Age Height Weight Heart_Rate SBP DBP;
   if Age = 999 then Age = .;
   if Height = 999 then Height = .;
   if Weight = 999 then Weight = .;
   if Heart_Rate = 999 then Heart_Rate = .;
   if SBP = 999 then SBP = .;
   if DBP = 999 then DBP = .;
datalines;
001 23 68 190 68 120 999
002 56 72 220 76 140 88
003 37 999 999 80 132 78
004 82 60 110 80 999 999
;
title "Listing of Data Set Health_Survey";
proc print data=Health_Survey noobs;
run;

*Program 17-2: Rewriting Program 1 Using Arrays;
data Health_Survey;
   input ID $ Age Height Weight Heart_Rate SBP DBP;
   array miss[6] Age Height Weight Heart_Rate SBP DBP;
   do i = 1 to 6;
      if miss[i] = 999 then miss[i] = .;
   end;
   drop i;
datalines;
001 23 68 190 68 120 999
002 56 72 220 76 140 88
003 37 999 999 80 132 78
004 82 60 110 80 999 999
;
title "Listing of Data Set Health_Survey";
proc print data=Health_Survey noobs;
run;

*Program 17-3: Converting Character Variables to Uppercase;
data Uppity;
   informat Name $15. Q1-Q5 $1.;
   input Name Q1-Q5;
   array up[6] Name Q1-Q5;
   do i = 1 to 6;
      up[i] = upcase(up[i]);
   end;
   drop i;
datalines;
fred a B c D e
Sue a b c d D
;
title "Listing of Data Set Uppity";
proc print data=Uppity noobs;
run;

*Program 17-4: Converting 999 to a Missing Value for All Numeric Variables in a Data Set;
/**** Big is a theoretical data set 

data Big_New;
   set Big;
   array all_nums[*] _numeric_;
   do i = 1 to dim(all_nums);
      if all_nums[i] = 999 then all_nums[i] = .;
   end;
   drop i;
run;

*Program 17-5: Converting Every Character Variable in a Data Set to Uppercase;
data Big_New;
   Set Big;
   array all_chars[*] _character_;
   do i = 1 to dim{all_chars);
      all_chars[i] = upcase(all_chars[i];
   end;
   drop i;
run;

***/

*Program 17-6: Program to Create One Observation per Subject Data Set;
data Wide;
   input Subj $ Wt1-Wt5;
datalines;
001 120 122 124 123 128
002 200 190 188 180 173
003 115 114 113 110 90
;
title "Listing of Data Set Wide";
proc print data=Wide noobs;
run;

*Program 17-7: Converting a Data Set with One Observation 
per Subject into a Data Set with Multiple Observations per Subject;
data Thin;
   set Wide;
   array wt[5];
   do Time = 1 to 5;
      Weight = Wt[Time];
      output;
   end;
   drop Wt1-Wt5;
run;

title "Listing of data set Thin";
proc print data=Thin noobs;
run;

*Program 17-8: Converting a Data Set with Multiple Observations 
per Subject into a Data Set with One Observation per Subject;
proc sort data=Thin;
   by Subj;
run;

data Wide;
   set Thin;
   by Subj;
   array Wt[5];
   retain Wt1-Wt5;
   if first.Subj then call missing(of Wt1-Wt5);
   Wt[Time] = Weight;
   if last.Subj then output;
   keep Subj Wt1-Wt5;
run;

*Program 18-1: Demonstrating PROC PRINT without any Options or Statements;
title  "Listing of Data Set Shoes";
title2 "In the SASHELP Library";
title3 "-------------------------------------------------"; 
proc print data=sashelp.shoes;
run;

*Program 18-2: Adding ID and VAR Statements to the Procedure;
title  "Listing of Data Set Shoes";
title2 "In the SASHELP Library";
title3 "-------------------------------------------------";
proc print data=sashelp.shoes;
   id Region; 
   var Product Stores Sales Inventory;
run;

*Program 18-3: Using the OBS= Data Set Option to List the First Eight Observations;
title  "Listing of Data Set Shoes";
title2 "In the SASHELP Library";
title3 "-------------------------------------------------";
proc print data=sashelp.shoes(obs=8);
   id Region; 
   var Product Stores Sales Inventory;
run;

*Program 18-4: PROC PRINT with and without a LABEL Option;
data Dimensions;
   input Subj $ Ht Wt Waist;
   label Subj = 'Subject'
         Ht   = 'Height in Inches'
         Wt   = "Subject's Weight";
datalines;
001 68 180 35
002 75 220 40
003 60 101 28
;
title "PROC PRINT Without a LABEL Option";
proc print data=Dimensions;
   id Subj;
   Var Ht Wt Waist;
run;

title "PROC PRINT with LABEL Option";
proc print data=Dimensions label;
   id Subj;
   Var Ht Wt Waist;
run;

*Program 18-5: Listing the Health Data Set Broken Down by Gender;
data health;
   infile '~/MyBookFiles/health.txt' pad;
   input Subj   $ 1-3
         Gender $ 4
         Age      5-6
         HR       7-8
         SBP      9-11
         DBP      12-14
         Chol     15-17;
run;

proc sort data=Health;
   by Gender;
run;

title "Listing of Data Set Health - by Gender";
proc print data=health;
   ID Subj;
   by Gender;
run;

*Program 18-6: Adding a Count of the Number of Observations to the Listing;
title "Listing of Data Set Health - by Gender";
proc print data=health n = "Total Observations =";
   ID Subj;
run;

*Program 19-1: Creating the Blood_Pressure Data Set;
libname Trial "~/MyBookFiles";
data Trial.Blood_Pressure;
   call streaminit(37373);
   do Drug = 'Placebo','Drug A','Drug B';
      do i = 1 to 20;
         Subj + 1;
         if mod(Subj,2) then Gender = 'M';
         else Gender = 'F';
         SBP = rand('normal',130,10) +
               7*(Drug eq 'Placebo') - 6*(Drug eq 'Drug B');
         SBP = round(SBP,2);
         DBP = rand('normal',80,5) +
               3*(Drug eq 'Placebo') - 2*(Drug eq 'Drug B');
         DBP = round(DBP,2);
         Age = int(rand('normal',50,10) + .1*SBP);         
         if Subj in (5,15,25,55) then call missing(SBP, DBP);
         if Subj in (4,18) then call missing(Gender);
         output;
      end;
   end;
   drop i;
run;

title "Listing of Data Set Drug_Trial (first 10 observtions)";
proc print data=Trial.Blood_Pressure(obs=10);
   id Subj;
run;

*Program 19-2: Running PROC MEANS on the Blood_Pressure Data Set (using all the default options);
title "Running PROC MEANS with all the Defaults";
proc means data=Trial.Blood_Pressure;
run;

*Program 19-3: Adding Options to Control PROC MEANS Output;
title "Running PROC MEANS with Selected Options";
proc means data=Trial.Blood_Pressure n nmiss mean std cv stderr clm maxdec=3;
   var SBP DBP;
run;

*Program 19-4: Adding a BY Statement with PROC MEANS;
title "Statistics for Blood Pressure Study Broken Down by Gender";
proc sort data=Trial.Blood_Pressure out=Blood_Pressure;
   by Gender;
run;

proc means data=Blood_Pressure n nmiss mean std maxdec=2;
   by Gender;
   var SBP DBP;
run;

*Program 19-5: Using a CLASS Statement to see Statistics Broken Down by Region;
title "Using a CLASS Statement with PROC MEANS";
proc means data=Trial.Blood_Pressure n nmiss mean std maxdec=2;
   class Gender;
   var SBP DBP;
run;

*Program 19-6: Using Two CLASS Variables with PROC MEANS;
title "Using a CLASS Statement with Two CLASS Variables";
proc means data=Trial.Blood_Pressure n nmiss mean std maxdec=2;
   class Gender Drug;
   var SBP DBP;
run;

*Program 19-7: Adding the PRINTALLTYPES Option to PROC MEANS;
proc means data=Trial.Blood_Pressure n nmiss mean std maxdec=2
   printalltypes;
   class Gender Drug;
   var SBP DBP;
run;

*Program 19-8: Using PROC MEANS to Create a Data Set Containing the Grand Mean;
proc means data=Trial.Blood_Pressure noprint;
   var SBP DBP;
   output out=Grand_Mean mean=Grand_SBP Grand_DBP 
          n=Nonmiss_SBP Nonmiss_DBP;   
run;

*Program 19-9: Listing of Data Set Grand_Mean;
title "Listing of Data Set Grand_Mean";
proc print data=Grand_Mean noobs;
run;

*Program 19-10: Using AUTONAME to Name the Variables in the Output Data Set;
proc means data=Trial.Blood_Pressure noprint;
   var SBP DBP;
   output out=Grand_Mean mean= n= / autoname;   
run;

title "Listing of Data Set Grand_Mean";
title2 "Using the AUTONAME Output Option";
proc print data=Grand_Mean noobs;
run;

*Program 19-11: Creating a Summary Data Set with Two Class Variables;
proc means data=Trial.Blood_Pressure noprint;
   class Gender Drug;
   var SBP DBP;
   output out=Summary mean= n= std= / autoname;
run;

title "Listing of Data Set Summary";
proc print data=Summary noobs;
run;

*Program 19-12: Adding the NWAY Option to PROC MEANS;
proc means data=Trial.Blood_Pressure noprint nway;
   class Gender Drug;
   var SBP DBP;
   output out=Summary mean= n= std= / autoname;
run;

title "Listing of Data Set Sumarry";
title2 "NWAY Option Added";

proc print data=Summary noobs;
run;

*Program 19-13: Using a Formatted CLASS Variable;
proc format;
   value AgeGroup low-50  = '50 and Lower'
                   51-70   = '51 to 70'
                   71-high = '71 +';
run;

title "Using a Formatted CLASS Variable";
proc means data=Trial.Blood_Pressure n nmiss mean std maxdec=2;
   class Age;
   format Age AgeGroup.;
   var SBP DBP;
run;

*Program 19-14: Demonstrating PROC UNIVARIATE
title "Demonstrating PROC UNIVARIATE";
proc univariate data=Trial.Blood_Pressure;
   id Subj;
   var SBP;
   histogram;
   qqplot / normal (mu=est sigma=est);
run;

*Program 20-1: Program to Generate Test Data Set Risk;
proc format;
   value yesno 1 = '1-Yes'
               0 = '2-No';
run;
data Risk;
   call streaminit(12345678);
   length Age_Group $ 7;
   do Subj = 1 to 250;
      do Gender = 'F','M';
         Age = round(rand('uniform')*30 + 50);
         if Age lt 60 then Age_Group = '1:< 60';
         else if Age le 70 then Age_Group = '2:60-70';
         else Age_Group = '3:71+';
         if rand('uniform') lt .3 then BP_Status = 'High';
         else BP_Status = 'Low';
         Chol = rand('normal',200,30) + rand('uniform')*8*(Gender='M');
         Chol = round(Chol);
         if Chol gt 240 then Chol_Status = 'High';
         else Chol_Status = 'Low';
         Score = .1*Chol + age + 8*(Gender eq 'M') + 
         10*(BP_Status = 'High');
         Heart_Attack = (Score gt 100)*(rand('uniform') lt .6);
         output;
       end;
   end;
   keep Subj Gender Age Chol Chol_Status BP_Status Heart_Attack;
   format Heart_Attack yesno.;
run;

title "Listing of Data Set Risk (first 10 observations)";
proc print data=Risk(obs=10);
   id Subj;
run;

*Program 20-2: Using PROC FREW to Generate One-way Frequency Tables;
title "One-way Frequency Tables";
proc freq data=Risk;
   tables Gender Heart_Attack;
run;

*Program 20-3: Changing the Table Order and Removing the Cumulative Statistics;
title "One-way Frequency Tables";
proc freq data=Risk order=formatted;
   tables Gender Heart_Attack / nocum;
run;

*Program 20-4: Creating a Two-way Frequency Table;
title "Two-way Frequency Table of BP_Status by Heart_Attack";
proc freq data=Risk order=formatted;
   tables BP_Status * Heart_Attack;
run;

*Program 20-5: Adding a Request for a Chi-square Test;
title "Two-way Frequency Table of BP_Status by Heart_Attack";
proc freq data=Risk order=formatted;
   tables BP_Status * Heart_Attack / chisq;
run;

*Program 20-6: Creating a Three-way Table;
title "Three-way Table of Gender by BP_Status by Heart_Attack";
proc freq data=Risk order=formatted;
   tables Gender * BP_Status * Heart_Attack;
run;

*Program 20-7: Using Formats to Group a Numeric Variable;
proc format;
   value Agegroup low-19 = '<20'
                  20-39  = '20 to 39'
                  40-59  = '40 to 59'
                  60-79  = '60 to 79'
                  80-high= '80+'
                     .   = 'Missing';
run;

title "Using a Format to Group a Numeric Variable";
proc freq data=Risk;
   tables Age / nocum;
   format Age Agegroup.;
run;
