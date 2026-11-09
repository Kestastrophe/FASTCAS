/* This is the description file for the package.         */
/* The colon (:) is a field separator and is restricted */
/* in lines of the header part.                          */

/* **HEADER** */
Type: Package                                    :/*required, not null, constant value*/
Package: FASTCAS                                 :/*required, not null, up to 24 characters, naming restrictions like for a dataset name! */
Title: Package for interacting with CAS                  :/*required, not null*/
Version: 0.1                                     :/*required, not null*/
Author: Dave Kestner (dave.kestner@sas.com)        :/*required, not null*/
Maintainer: Dave Kestner (dave.kestner@sas.com) :/*required, not null*/
License: MIT                                     :/*required, not null, values: MIT, GPL2, BSD, etc.*/
Encoding: UTF8                                   :/*required, not null, values: UTF8, WLATIN1, LATIN2, etc. */

Required: "Base SAS Software", "Cloud Analytic Services"                   :/*optional, COMMA separated, QUOTED list, names of required SAS products, values must be like from proc setinit;run; output */

/* **DESCRIPTION** */
/* All the text below will be used in help */
DESCRIPTION START:

# This is the first draft of the FASTCAS package, which allows user to interact with CAS without having to know CASL

### Content ###################################################################

SAS2CAS(insasdataset= , outcaslib= , outcasdataset= , scope= );
CSV2CAS(incsv= , outcaslib= , outcasdataset= , scope= );
CAS2SASHDAT(incaslib= , incastable= , outhdatname= );

---
DESCRIPTION END: