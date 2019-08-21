/* File : example.i */
%module example

%{
#include "example.h"
%}

%apply alaqilTYPE *DISOWN {(Shape *s)};

/* Let's just grab the original header file here */
%include "example.h"

