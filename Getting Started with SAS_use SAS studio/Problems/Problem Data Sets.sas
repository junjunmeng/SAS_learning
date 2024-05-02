*Program for Problem Sets 1;
data Questionnaire;
   informat Gender 1. Q1-Q4 $1. Visit date9.;
   input Gender Q1-Q4 Visit Age;
   format Visit date9.;
datalines;
1 3 4 1 2 29May2015 16
1 5 5 4 3 01Sep2015 25
2 2 2 1 3 04Jul2014 45
2 3 3 3 4 07Feb2015 65
;
title "Listing of Data Set Questionnaire";
proc print data=Questionnaire noobs;
run;

/****************************************
*Program for Problem Sets 2;
data Interest;
   Money = 100;
   do while (put something here);
      Year + 1; *keep track of years;
      *compute new amount;
      output; *output an observation for each iteration
               of the loop;
   end;
run;
******************************************/

*Program for Problem Sets 3;
data Until;
   X = 5;
   Y = 10;
   do until (X eq 5);
      Y = 20;
   end;
run;

*Program for Problem Sets 4;
data Date_Test;
   input Month Day Year;
datalines;
10 21 1988
3 4 2015
1 1 1960
;

*Program for Problem Sets 5;
data Study;
   call streaminit(13579);
   do Subj = 1 to 10;
      Date = '01Jan2015'd + int(rand('uniform')*300);
      output;
   end;
   format Dates date9.;
run;

*Program for Problem Sets 6;
data FirstQtr;
   input Name $ Quantity Cost;
datalines;
Fred 100 3000
Jane 90 4000
April 120 5000
;
data SecondQtr;
   input Name $ Quantity Cost;
datalines;
Ron 200 9000
Jan 210 9500
Steve 177 5400
;

*Program for Problem Sets 7;
data First;
   input ID $ X Y Z;
datalines;
001 1 2 3
004 3 4 5
002 5 7 8
006 8 9 6
;
data Second;
   input ID $ Nane $;
datalines;
002 Jim
003 Fred
001 Susan
004 Jane
;

*Program for Problem Sets 8;
data Prices;
   informat Price dollar10.;
   input Item_Number $ Price;
datalines;
A123 $123
B76 4.56
X200 400
D88 39.75
;

*Program for Problem Sets 9;
data Questionnaire2;
   input Subj $ Q1-Q20;
datalines;
001 1 2 3 4 5 1 2 3 4 5 1 2 3 4 5 1 2 3 4 5
002 . . . . 3 2 3 1 2 3 4 3 2 3 4 3 5 4 4 4
003 1 2 1 2 1 2 12 3 2 3 . . . . . . 4 5 5 4
004 1 4 3 4 5 . 4 5 4 3 . . 1 1 1 1 1 1 1 1
;

*Program for Problem Sets 10;
data Char_Data;
   length Date $10 Weight Height $ 3;
   input Date Weight Height;
datalines;
10/21/1966 220 72
5/6/2000 110 63
;

*Program for Problem Sets 11;
data Oscar;
   length String $ 10 Name $ 20 Comment $ 25 Address $ 30
          Q1-Q5 $ 1;
   infile datalines dsd dlm=" ";
*Note: the DSD option is needed to strip the quotes from
 the variables that contain blanks;
   input String Name Comment Address Q1-Q5;
datalines;
AbC "jane E. MarPle" "Good Bad Bad Good" "25 River Road" y n N Y Y
12345 "Ron Cody" "Good Bad Ugly" "123 First Street" N n n n N
98x "Linda Y. d'amore" "No Comment" "1600 Penn Avenue" Y Y y y y
. "First Middle Last" . "21B Baker St." . . . Y N
;

*Program for Problem Sets 12;
Data How_Tall;
   input Ht $ @@;
*Note: the @@ at the end of the INPUT statement allows you
 to place several observations on one line of data;
datalines;
65inches 200cm 70In. 220Cm. 72INCHES
;

*Program for Problem Sets 13;
data Clinic;
   informat Date mmddyy10. Subj $3.;
   input Subj Date Heart_Rate Weight;
   format Date date9.;
datalines;
001 10/1/2015 68 150
003 6/25/2015 75 185
001 12/4/2015 66 148
001 11/5/2015 72 152
002 1/1/2014 75 120
003 4/25/2015 80 200
003 5/25/2015 78 190
003 8/20/2015 70 179
;

*Program for Problem Sets 14;
data Tricky;
   input x;
   if x gt 5 then Last_x = lag(x);
datalines;
6
7
2
10
11
;


*Program for Problem Sets 15;
data Prob1;
   length Char1-Char5 $ 8;
   input x1-x5 Char1-Char5;
   x1 = round(x1);
   x2 = round(x2);
   x3 = round(x3);
   x4 = round(x4);
   x5 = round(x5);
   Char1 = upcase(Char1);
   Char2 = upcase(Char2);
   Char3 = upcase(Char3);
   Char4 = upcase(Char4);
   Char5 = upcase(Char5);
datalines;
1.2 3 4.4 4.9 5 a b c d e
1.01 1.5 1.6 1.7 1.8 frank john mary jane susan
;
title "Listing of Data Set Prob1";
proc print data=Prob1 noobs;
run;

*Program for Problem Sets 16;
data Missing;
   input w x y z C1 $ C2 $ C3 $;
datalines;
999 1 999 3 Fred NA Jane
8 999 10 20 Michelle Mike John
11 9 8 7 NA na Peter
;

