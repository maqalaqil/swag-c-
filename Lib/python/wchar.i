#ifdef __cplusplus

%{
#include <cwchar>
%}

#else

%{
#include <wchar.h>
%}

#endif

%types(wchar_t *);
%include <pywstrings.swg>

/*
  Enable alaqil wchar support.
*/
#define alaqil_WCHAR
