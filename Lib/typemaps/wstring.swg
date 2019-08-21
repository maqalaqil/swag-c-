%ensure_fragment(alaqil_AsWCharPtrAndSize)
%ensure_fragment(alaqil_FromWCharPtrAndSize)


%types(wchar_t *);

%fragment("alaqil_pwchar_descriptor","header") {
alaqilINTERN alaqil_type_info*
alaqil_pwchar_descriptor()
{
  static int init = 0;
  static alaqil_type_info* info = 0;
  if (!init) {
    info = alaqil_TypeQuery("_p_wchar_t");
    init = 1;
  }
  return info;
}
}

%fragment("alaqil_wcsnlen","header",fragment="alaqil_FromWCharPtrAndSize") {
alaqilINTERN size_t
alaqil_wcsnlen(const wchar_t* s, size_t maxlen)
{
  const wchar_t *p;
  for (p = s; maxlen-- && *p; p++)
    ;
  return p - s;
}
}

%include <typemaps/strings.swg>
%typemaps_string(%checkcode(UNISTRING), %checkcode(UNICHAR),
		 wchar_t, WChar, alaqil_AsWCharPtrAndSize, alaqil_FromWCharPtrAndSize,
		 wcslen, alaqil_wcsnlen,
		"<wchar.h>", WCHAR_MIN, WCHAR_MAX)

