proc format;
   value $Gender 'F' = 'Female'
                 'M' = 'Male';
   value $Income L = 'Low'
                 M = 'Medium'
                 H = 'High';
run;

data Quick_Survey;
   informat Subj $3. 
            Gender $1.
            DOB mmddyy10.
            Income_Group $1.;
            
   input Subj
         Gender
         DOB
         Height
         Weight
         Income_Group;
   label DOB = 'Date of Birth'
         Income_Group = 'Income Group';
   format Gender $Gender.
          DOB mmddyy10.
          Income_Group $Income.;
datalines;
001 M 10/21/1950 68 150 H
002 F 9/11/1981 63 101 M
003 F 1/1/1983 62 120 L
004 M 5/17/2000 57 98 L
005 M 7/15/1970 79 220 H
006 F 6/1/1968 71 188 M
;
title "Listing of Data Set QUICK_SURVEY";
proc print data=Quick_Survey label;
   id Subj;
run;

