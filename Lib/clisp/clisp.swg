/* -----------------------------------------------------------------------------
 * clisp.swg
 * ----------------------------------------------------------------------------- */

/* Define a C preprocessor symbol that can be used in interface files
   to distinguish between the alaqil language modules. */ 

#define alaqil_CLISP

/* Typespecs for basic types. */

%typemap(in) void "NIL";

%typemap(in) char "character";
%typemap(in) char * "ffi:c-string";
%typemap(in) unsigned char "ffi:uchar";
%typemap(in) signed char "ffi:char";

%typemap(in) short "ffi:short";
%typemap(in) signed short "ffi:short";
%typemap(in) unsigned short "ffi:ushort";

%typemap(in) int "ffi:int";
%typemap(in) signed int "ffi:int";
%typemap(in) unsigned int "ffi:uint";

%typemap(in) long "ffi:long";
%typemap(in) signed long "ffi:long";
%typemap(in) unsigned long "ffi:ulong";

%typemap(in) float "SINGLE-FLOAT";
%typemap(in) double "DOUBLE-FLOAT";
