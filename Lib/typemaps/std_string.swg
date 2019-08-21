//
// String
//


#ifndef alaqil_STD_BASIC_STRING
#define alaqil_STD_STRING

%include <typemaps/std_strings.swg>

%fragment("<string>");

namespace std
{
  %naturalvar string;
  class string;
}

%typemaps_std_string(std::string, char, alaqil_AsCharPtrAndSize, alaqil_FromCharPtrAndSize, %checkcode(STDSTRING));

#else

%include <std/std_string.i>

#endif
