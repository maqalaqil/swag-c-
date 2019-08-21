%include <typemaps/wstring.swg>

#ifndef alaqil_STD_BASIC_STRING
#define alaqil_STD_WSTRING

%include <typemaps/std_strings.swg>

%{
#include <cwchar>
%}
%fragment("<string>");

namespace std
{
  %naturalvar wstring;
  class wstring;
}

%typemaps_std_string(std::wstring, wchar_t, alaqil_AsWCharPtrAndSize, alaqil_FromWCharPtrAndSize, %checkcode(STDUNISTRING));


#else

%include <std/std_wstring.i>

#endif
