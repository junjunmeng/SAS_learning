**** defines common librefs and SAS options.;

%let sasroot=%sysfunc(sysget(SASROOT));
%let sysin = %sysfunc(getoption(sysin));
%let path=%substr(&sysin,1,%index(%upcase(&sysin),\CHAPTER07\)-1);
%put sasroot=&sasroot path=&path;

options ls=256 nocenter extendobscounter=NO
        sasautos=("&sasroot/core/sasmacro", "../macros")
        ;
%include "..\macros\xpt_macros.sas";
libname sdtm    "&path/chapter03";
libname adam    "&path/chapter07";


proc format;
        value _0n1y 0 = 'N'
                    1 = 'Y'
        ;                    
        value avisitn 1 = '3'
                      2 = '6'
        ;                      
        value popfl 0 - high = 'Y'
                    other = 'N'
        ;                    
        value $trt01pn  'Analgezia HCL 30 mg' = '1'
                        'Placebo'             = '0'
        ;
        value agegr1n 0 - 54 = "1"
                      55-high= "2"
        ;                      
        value agegr1_ 1 = "<55 YEARS"
                      2 = ">=55 YEARS"
        ;                      
        value $aereln  'NOT RELATED'        = '0'
                       'POSSIBLY RELATED'   = '1'
                       'PROBABLY RELATED'   = '2'
        ;
        value $aesevn  'MILD'               = '1'
                       'MODERATE'           = '2'
                       'SEVERE'             = '3'
        ;                                              
        value relgr1n 0 = 'Not related'
                      1 = 'Related'
        ;                       
        value evntdesc 0 = 'PAIN RELIEF'
                       1 = 'PAIN WORSENING PRIOR TO RELIEF'
                       2 = 'PAIN ADVERSE EVENT PRIOR TO RELIEF'
                       3 = 'COMPLETED STUDY PRIOR TO RELIEF'
        ;                    
run;

