/*Note: The FASTCAS package was designed to help new SAS Viya users get up and going quickly in CAS. The
        CSV2CAS macro allows users to load flat file data (.csv) into CAS without having to know much about
        the Viya specific CASL programming. 

PARAMETERS:
incsv - The source CSV file, e.g. '/mnt/viya-share/homes/dakest/SCO_DEMAND.csv'
outcaslib - The target or destination CAS library, e.g. 'CASUSER'
outcastable - The target or destination CAS table, e.g. 'OUTPUT_TABLE'
scope (optional) - The scope of the destination CAS table, e.g. 'GLOBAL'. The program accepts any mixed-case spelling of 
        the words 'GLOBAL' and 'SESSION'. Null entry is interpreted as 'SESSION'
*/

/******************Beginning of CSV2CAS Macro****************************/
%macro CSV2CAS(incsv= , outcaslib= , outcastable= , scope= );
    /*check if the input CSV file exists */
    %if %sysfunc(fileexist(&incsv.)) %then %do;
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
            /*If the caslib exists, keep processing*/
            /*check if the output cas dataset exists*/
            %if %sysfunc(exist(&outcaslib..&outcastable.)) gt 0 %then %do;
                /*Define scope of the output CAS dataset:Either "Session" or "Global"*/
                %if %kupcase(%sysfunc(strip(&scope.))) = %str(GLOBAL) %then %do;
                    proc casutil;
                        droptable casdata="&outcastable." incaslib="&outcaslib.";
                    run;
                    proc casutil;      
                        /*read in CSV file and replace any existing CAS table with the same 'outcaslib' and 'outcastable'*/                                
                        load file="&incsv." importoptions=(filetype="csv" getnames="true")
                        outcaslib="&outcaslib." casout="&outcastable." replace;

                        /*promote the CAS table created to Global scope*/
                        promote casdata="&outcastable." incaslib="&outcaslib." outcaslib="&outcaslib.";
                    quit;            
                %end;
                %else %do;
                    proc casutil;
                        droptable casdata="&outcastable." incaslib="&outcaslib.";
                    run;
                    proc casutil;      
                        /*read in CSV file and replace any existing CAS table with the same 'outcaslib' and 'outcastable'*/                                
                        load file="&incsv." importoptions=(filetype="csv" getnames="true")
                        outcaslib="&outcaslib." casout="&outcastable." replace;
                    quit;
                %end;
            %end;           
            %else %do;
                proc casutil;      
                    /*read in CSV file and replace any existing CAS table with the same 'outcaslib' and 'outcastable'*/                                
                    load file="&incsv." importoptions=(filetype="csv" getnames="true")
                    outcaslib="&outcaslib." casout="&outcastable.";
                quit;        
            %end;            
        %end;
        %if &caslib_check.=N %then %do;
            /*If the output caslib doesn't exist, print diagnostic message*/
            proc odstext;
                p "Caslib &outcaslib. does not exist. Please specify a 'outcaslib' value that exists";
            run;
        %end;
    %end;
    %else %do;
        /*if CSV file specified does not exist, print diagnostic message*/
        proc odstext;
            p "CSV file &incsv. does not exist. Please specify a 'incsv' file that exists";
        run;
    %end;
%mend;
/************************End of CSV2CAS Macro****************************/