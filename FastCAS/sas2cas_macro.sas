/*Note: The FASTCAS package was designed to help new SAS Viya users get up and going quickly in CAS. The SAS2CAS macro
        hides some of the Viya specific CASL programming (e.g. PROC CAS and CASUTIL) in the background while making moving
        data from SAS datasets into CAS more easily digestible for users.

PARAMETERS:
insasdataset - The source sas dataset, e.g. 'SASHELP.HEART'
outcaslib - The target or destination CAS library, e.g. 'CASUSER'
outcastable - The target or destination CAS table, e.g. 'OUTPUT_TABLE'
scope (optional) - The scope of the destination CAS table, e.g. 'GLOBAL'. The program accepts any mixed-case spelling of 
        the words 'GLOBAL' and 'SESSION'. Null entry is interpreted as 'SESSION'
*/


/******************Beginning of SAS2CAS Macro****************************/
%macro SAS2CAS(insasdataset= , outcaslib= , outcastable= , scope= );
    /*check if the input SAS dataset exists */
    %if %sysfunc(exist(&insasdataset.)) = 0 %then %do;
        /*if the SAS dataset doesn't exist, print diagnostic message*/
        proc odstext;
            p "SAS dataset &insasdataset. does not exist. Please specify a 'insasdataset' value that exists";
        run;
    %end;
    %if %sysfunc(exist(&insasdataset.)) gt 0 %then %do;
        /*check if the output caslib exists*/
        proc cas;
            table.queryCaslib result=t caslib="&outcaslib.";

            if t=True then do;
                call symputx("caslib_check","Y","G");
            end;
            else do;
                call symputx("caslib_check","N","G");
            end;
        quit;

        %if &caslib_check.=Y %then %do;
             /*check if the output cas dataset exists*/
            %if %sysfunc(exist(&outcaslib..&outcastable.)) = 0 %then %do;
                /*Define scope of the output CAS dataset: Either "Session" or "Global"*/
               /* %if &scope. in (Global, global, GLOBAL) %then %do;*/
                  %if %kupcase(%sysfunc(strip(&scope.))) = %str(GLOBAL) %then %do;
                    /* write out global scope CAS dataset*/
                    data &outcaslib..&outcastable.(promote=yes);
                        set &insasdataset.;
                    run;
                %end;
                %else %do;
                    /*write out session scope CAS dataset*/
                    data &outcaslib..&outcastable.;
                        set &insasdataset.;
                    run;
                %end;
                /*end of define scope of the output CAS dataset*/
            %end;
            %if %sysfunc(exist(&outcaslib..&outcastable.)) gt 0 %then %do;
                 /*Define scope of the output CAS dataset:Either "Session" or "Global"*/
                /*%if &scope. in (Global, global, GLOBAL) %then %do;*/
                  %if %kupcase(%sysfunc(strip(&scope.))) = %str(GLOBAL) %then %do;
                    /*drop CAS table*/
                    proc casutil;
                        droptable casdata="&outcastable." incaslib="&outcaslib.";
                    run;
                    /*write out global scope CAS dataset*/
                      data &outcaslib..&outcastable.(promote=yes);
                        set &insasdataset.;
                      run;
                %end;
                %else %do;
                    /*drop CAS table*/
                    proc casutil;
                        droptable casdata="&outcastable." incaslib="&outcaslib.";
                    run;
                    /*write out session scope CAS dataset*/
                    data &outcaslib..&outcastable.;
                        set &insasdataset.;
                    run;
                %end;
                /*end of define scope of the output CAS dataset*/
            %end;
            /*end of check if the output cas dataset exists*/
        %end;
        %if &caslib_check.=N %then %do;
            /*If the output caslib doesn't exist, print diagnostic message*/
            proc odstext;
                p "Caslib &outcaslib. does not exist. Please specify a 'outcaslib' value that exists";
            run;
        %end;
        /*end of check if the output caslib exists*/
    %end;
    /*end of check if the input SAS dataset exists*/
%mend;
/************************End of SAS2CAS Macro****************************/
