%ensure_fragment(alaqil_AsCharPtrAndSize)
%ensure_fragment(alaqil_FromCharPtrAndSize)

%types(char *);

%fragment("alaqil_pchar_descriptor","header") {
alaqilINTERN alaqil_type_info*
alaqil_pchar_descriptor(void)
{
  static int init = 0;
  static alaqil_type_info* info = 0;
  if (!init) {
    info = alaqil_TypeQuery("_p_char");
    init = 1;
  }
  return info;
}
}

%fragment("alaqil_strnlen","header",fragment="alaqil_FromCharPtrAndSize") {
alaqilINTERN size_t
alaqil_strnlen(const char* s, size_t maxlen)
{
  const char *p;
  for (p = s; maxlen-- && *p; p++)
    ;
  return p - s;
}
}

%include <typemaps/strings.swg>
%typemaps_string(%checkcode(STRING), %checkcode(CHAR),
		 char, Char, alaqil_AsCharPtrAndSize, alaqil_FromCharPtrAndSize,
		 strlen, alaqil_strnlen,
		"<limits.h>", CHAR_MIN, CHAR_MAX)
