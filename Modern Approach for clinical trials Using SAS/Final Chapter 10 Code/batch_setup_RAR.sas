/*  Description::   Run all the tables and plots for RAR
   Program::      batch_setup_RAR.sas
    Author::         Gaurav Sharma
    Date::        2/23/15
    Description:: This program runs all the programs for Optimal Response-Adaptive Randomization Designs
*/

proc template;
  define style intextdefault;
  parent=styles.printer;
  style color_list from color_list /
      'bgH'=white;
  style fonts from fonts/
      'TitleFont'       = ("Arial" ,10pt, Bold)
      'TitleFont2'      = ("Arial" ,10pt, Bold)
      'HeadingFont'     = ("Arial",9pt, Bold)
      'StrongFont'      = ("Arial",9pt, Bold)
      'docFont'         = ("Arial",8pt)
        'footerFont'       = ("Arial",9pt)
         'EmphasisFont'      = ("Arial")
      'FixedStrongFont'   = ("Arial")
      'BatchFixedFont'    = ("Arial")
      'FixedFont'         = ("Arial")
      'FixedEmphasisFont' = ("Arial");
  style systemtitle from systemtitle /
        protectspecialchars = off;
  style systemfooter from systemfooter /
        protectspecialchars = off
        font=fonts("footerFont");
  style Header from HeadersAndFooters /
        protectspecialchars = off;
  style Data from Cell /
        protectspecialchars = off;
  style output from container /
      cellpadding = 7
      cellspacing = 0
      borderwidth = 10
      rules = GROUPS
      frame = BOX;
  end;
run;

%let rtfstyle=intextdefault;
%let dir = C:\Users\rizink\Desktop\B\Chapter11 Final\Final Chapter 10 Programs\RARChapter_SAS\;

%include "&dir.ch10.2.sas" / source2;
%include "&dir.ch10.3.5.sas" / source2;
%include "&dir.ch10.4.2.sas" / source2;
%include "&dir.ch10.5.sas" / source2;
%include "&dir.ch10.4.1.sas" / source2;
%include "&dir.ch10.7.1.sas" / source2;
%include "&dir.ch10.7.2.sas" / source2;