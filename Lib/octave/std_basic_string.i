#if !defined(alaqil_STD_STRING) 
#define alaqil_STD_BASIC_STRING
#define alaqil_STD_MODERN_STL

%include <octcontainer.swg>

#define %alaqil_basic_string(Type...)  %alaqil_sequence_methods_val(Type)


%fragment(alaqil_AsPtr_frag(std::basic_string<char>),"header",
	  fragment="alaqil_AsCharPtrAndSize") {
alaqilINTERN int
alaqil_AsPtr(std::basic_string<char>)(octave_value obj, std::string **val) {
  if (obj.is_string()) {
    if (val)
      *val = new std::string(obj.string_value());
    return alaqil_NEWOBJ;
  }
  return alaqil_ERROR;
}
}

%fragment(alaqil_From_frag(std::basic_string<char>),"header",
	  fragment="alaqil_FromCharPtrAndSize") {
alaqilINTERNINLINE octave_value
  alaqil_From(std::basic_string<char>)(const std::string& s) {
    return alaqil_FromCharPtrAndSize(s.data(), s.size());
  }
}

%ignore std::basic_string::operator +=;

%include <std/std_basic_string.i>
%typemaps_asptrfromn(%checkcode(STRING), std::basic_string<char>);

#endif


#if !defined(alaqil_STD_WSTRING)

%fragment(alaqil_AsPtr_frag(std::basic_string<wchar_t>),"header",
	  fragment="alaqil_AsWCharPtrAndSize") {
alaqilINTERN int
alaqil_AsPtr(std::basic_string<wchar_t>)(octave_value obj, std::wstring **val) {
  if (obj.is_string()) {
    if (val)
      *val = new std::wstring(obj.string_value());
    return alaqil_NEWOBJ;
  }
  return alaqil_ERROR;
}
}

%fragment(alaqil_From_frag(std::basic_string<wchar_t>),"header",
	  fragment="alaqil_FromWCharPtrAndSize") {
alaqilINTERNINLINE PyObject*
  alaqil_From(std::basic_string<wchar_t>)(const std::wstring& s) {
    return alaqil_FromWCharPtrAndSize(s.data(), s.size());
  }
}

%typemaps_asptrfromn(%checkcode(UNISTRING), std::basic_string<wchar_t>);

#endif
