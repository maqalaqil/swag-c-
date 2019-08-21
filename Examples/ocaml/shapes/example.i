/* File : example.i */
%module(directors="1") example
#ifndef alaqilSEXP
%{
	#include "example.h"
%}
#endif

%feature("director");
%include "example.h"
