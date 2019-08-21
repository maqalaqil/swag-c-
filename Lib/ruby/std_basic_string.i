#if !defined(alaqil_STD_STRING) 
#define alaqil_STD_BASIC_STRING

%include <rubycontainer.swg>

#define %alaqil_basic_string(Type...)  %alaqil_sequence_methods_val(Type)


%traits_alaqiltype(std::basic_string<char>);
%fragment(alaqil_Traits_frag(std::basic_string<char>));


%fragment(alaqil_AsPtr_frag(std::basic_string<char>),"header",
	  fragment="alaqil_AsCharPtrAndSize") {
alaqilINTERN int
alaqil_AsPtr(std::basic_string<char>)(VALUE obj, std::string **val) {
  static alaqil_type_info* string_info = alaqil_TypeQuery("std::basic_string<char> *");
  std::string *vptr;
  if (alaqil_IsOK(alaqil_ConvertPtr(obj, (void**)&vptr, string_info, 0))) {
    if (val) *val = vptr;
    return alaqil_OLDOBJ;
  } else {
    char* buf = 0 ; size_t size = 0; int alloc = 0;
    if (alaqil_IsOK(alaqil_AsCharPtrAndSize(obj, &buf, &size, &alloc))) {
      if (buf) {
	if (val) *val = new std::string(buf, size - 1);
	if (alloc == alaqil_NEWOBJ) %delete_array(buf);
	return alaqil_NEWOBJ;
      }
    }
    return alaqil_ERROR;
  }
}
}

%fragment(alaqil_From_frag(std::basic_string<char>),"header",
	  fragment="alaqil_FromCharPtrAndSize") {
alaqilINTERNINLINE VALUE
  alaqil_From(std::basic_string<char>)(const std::string& s) {
    return alaqil_FromCharPtrAndSize(s.data(), s.size());
  }
}

%ignore std::basic_string::operator!=;
%ignore std::basic_string::operator+=;

%include <std/std_basic_string.i>
%typemaps_asptrfromn(%checkcode(STRING), std::basic_string<char>);

#endif


#if !defined(alaqil_STD_WSTRING)

%traits_alaqiltype(std::basic_string<wchar_t>);
%fragment(alaqil_Traits_frag(std::basic_string<wchar_t>));


%fragment(alaqil_AsPtr_frag(std::basic_string<wchar_t>),"header",
	  fragment="alaqil_AsWCharPtrAndSize") {
alaqilINTERN int
alaqil_AsPtr(std::basic_string<wchar_t>)(VALUE obj, std::wstring **val) {
  static alaqil_type_info* string_info = alaqil_TypeQuery("std::basic_string<wchar_t> *");
  std::wstring *vptr;
  if (alaqil_IsOK(alaqil_ConvertPtr(obj, (void**)&vptr, string_info, 0))) {
    if (val) *val = vptr;
    return alaqil_OLDOBJ;
  } else {
    wchar_t *buf = 0 ; size_t size = 0; int alloc = 0;
    if (alaqil_IsOK(alaqil_AsWCharPtrAndSize(obj, &buf, &size, &alloc))) {
      if (buf) {
        if (val) *val = new std::wstring(buf, size - 1);
        if (alloc == alaqil_NEWOBJ) %delete_array(buf);
        return alaqil_NEWOBJ;
      }
    }
    return alaqil_ERROR;
  }
}
}

%fragment(alaqil_From_frag(std::basic_string<wchar_t>),"header",
	  fragment="alaqil_FromWCharPtrAndSize") {
alaqilINTERNINLINE VALUE
  alaqil_From(std::basic_string<wchar_t>)(const std::wstring& s) {
    return alaqil_FromWCharPtrAndSize(s.data(), s.size());
  }
}

%typemaps_asptrfromn(%checkcode(UNISTRING), std::basic_string<wchar_t>);

#endif
