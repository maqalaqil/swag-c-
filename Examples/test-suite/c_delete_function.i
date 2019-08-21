%module c_delete_function

/* check C++ delete keyword is okay in C wrappers */

%warnfilter(alaqilWARN_PARSE_KEYWORD) delete;

#if !defined(alaqilOCTAVE) && !defined(alaqil_JAVASCRIPT_V8) /* Octave and Javascript/v8 compiles wrappers as C++ */

%inline %{
double delete(double d) { return d; }
%}

#endif
