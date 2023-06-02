** Run the Pinnacle 21 Community in batch mode;
** set the appropriate system options;
options symbolgen xsync noxwait ; 

** specify the path and the file for running the validator in command-line mode;
%let p21path=c:\software\pinnacle21-community;
%let validatorjar=components\lib\validator-cli-2.1.0.jar;

** specify the location of the data sets to be validated. ;
%let sourcepath=g:\2nd-edition\define2\sdtm;

** specify the file to be validated;
** to validate all files in a directory use the * wildcard;
%let files=*.xpt;

** specify the config file path;
%let config=&p21path\components\config\sdtm 3.2.xml;

** specify the name and location of the codelist file;
%let codelists=&p21path\components\config\data\CDISC\SDTM\2014-09-26\SDTM Terminology.odm.xml;

** specify the output report path;
%let reportpath=&sourcepath;

** specify the name of the validation report;
** append the file name with the date and time; 
%let reportfile=sdtm-validation-report-&sysdate.T%sysfunc(tranwrd(&systime,:,-)).xls;

** run the report;
x java -jar "&p21path\&validatorjar" -type=SDTM -source="&sourcepath\&files " -config="&config" -config:define="&sourcepath\define.xml" -config:codelists=”&codelists” -report="&reportpath\&reportfile" -report:overwrite="yes" ;