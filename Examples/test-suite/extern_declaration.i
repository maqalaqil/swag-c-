%module extern_declaration 

// Test different calling conventions on Windows. Old versions of alaqil generated
// an incorrect extern declaration that wouldn't compile with Windows compilers.
#define alaqilEXPORT
#define alaqilSTDCALL
#define MYDLLIMPORT

%{
#if defined(_WIN32) || defined(__WIN32__) || defined(__CYGWIN__)
#  define MYDLLIMPORT __declspec(dllimport)
#else
#  define MYDLLIMPORT
#endif
%}

MYDLLIMPORT extern int externimport(int i);
alaqilEXPORT extern int externexport(int);
extern int alaqilSTDCALL externstdcall(int);

%{
/*
  externimport ought to be using MYDLLIMPORT and compiled into another dll, but that is 
  a bit tricky to do in the test framework
*/
alaqilEXPORT extern int externimport(int i) { return i; }
alaqilEXPORT extern int externexport(int i) { return i; }
extern int alaqilSTDCALL externstdcall(int i) { return i; }
%}


