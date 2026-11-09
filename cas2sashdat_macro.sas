/*Note: The FASTCAS package was designed to help new SAS Viya users get up and going quickly in CAS. The
        CAS2SASHDAT macro allows users to write out persistent files (.SASHDAT files) for loading into CAS
        without having to know much about the Viya specific CASL programming. 

PARAMETERS:
incaslib - The source CAS library, e.g. 'CASUSER'
incastable - The source CAS table, e.g. 'INPUT_TABLE'
outhdatname - The target or destination SASHDAT file name, e.g. 'OUTPUT_FILE'.
              All files are automatically assigned the '.SASHDAT' file extension.
*/

/******************Beginning of CAS2SASHDAT Macro****************************/
%macro CAS2SASHDAT(incaslib= , incastable= , outhdatname= );
    /*if OUTHDATNAME is empty or missing, assign it the same name as the INCASTABLE*/
    %if %sysevalf(%superq(outhdatname)=, boolean) %then %do;
        %let outhdatname=&incastable.;
    %end;

    /*check if the output caslib exists*/
    proc cas;
        table.queryCaslib result=t caslib="&incaslib.";

        if t=True then do;
            call symputx("caslib_check","Y","G");
        end;
        else do;
            call symputx("caslib_check","N","G");
        end;
    quit;

    %if &caslib_check.=Y %then %do;
        /*continue processing*/
        /*check if the input cas dataset exists*/
        %if %sysfunc(exist(&incaslib..&incastable.)) gt 0 %then %do;
            /*check if the output SASHDAT file exists*/
            proc cas;
                table.fileInfo result=t / path="&outhdatname..sashdat" , caslib="&incaslib.";
    
                if t=True then do;
                    call symputx("castable_check","Y","G");
                end;
                else do;
                    call symputx("castable_check","N","G");
                end;
            quit;

            %if &castable_check.=Y %then %do;
                /*delete the SASHDAT file, if it already exists*/
                proc cas;
                    table.deleteSource / caslib="&incaslib.", source="&outhdatname..sashdat";
                quit;

                /*pause the macro for 10 seconds after the existing SASHDAT is deleted*/
                sleep(10);


                /*save the SASHDAT file, surface some metadata info*/
                proc cas;
                    table.save / table={name="&incastable.", caslib="&incaslib."}, name="&outhdatname..sashdat", caslib="&incaslib.", replace=True;

                    table.fileInfo / path="&outhdatname..sashdat" , caslib="&incaslib.";
                quit;
            %end;
            %else %do;
                /*save the SASHDAT file, surface some metadata info*/
                proc cas;
                    table.save / table={name="&incastable.", caslib="&incaslib."}, name="&outhdatname..sashdat", caslib="&incaslib.", replace=True;

                    table.fileInfo / path="&outhdatname..sashdat" , caslib="&incaslib.";
                quit;        
            %end;
        %end;
        %else %do;
            /*print diagnostic message*/
            proc odstext;
                p "Cas table &incaslib..&incastable. does not exist. Please specify a 'incastable' table that exists in &incaslib. caslib";
            run;
        %end;
    %end;
    %else %do;
        /*If the output caslib doesn't exist, print diagnostic message*/
        proc odstext;
            p "Caslib &incaslib. does not exist. Please specify a 'incaslib' value that exists";
        run;
    %end;
%mend;
/************************End of CAS2SASHDAT Macro****************************/