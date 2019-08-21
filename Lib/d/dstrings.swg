/* -----------------------------------------------------------------------------
 * dstrings.swg
 *
 * Typemaps for wrapping pointers to/arrays of C chars as D strings.
 * ----------------------------------------------------------------------------- */

%define alaqilD_STRING_TYPEMAPS(DW_STRING_TYPE, DP_STRING_TYPE, FROM_STRINGZ, TO_STRINGZ)
%typemap(ctype) char *, char *&, char[ANY], char[]   "char *"
%typemap(imtype) char *, char *&, char[ANY], char[]   #DW_STRING_TYPE
%typemap(dtype) char *, char *&, char[ANY], char[]   #DP_STRING_TYPE


/*
 * char* typemaps.
 */

%typemap(in) char * %{ $1 = ($1_ltype)$input; %}
%typemap(out) char * %{ $result = alaqil_d_string_callback((const char *)$1); %}
%typemap(directorout, warning=alaqilWARN_TYPEMAP_DIRECTOROUT_PTR_MSG) char * %{ $result = ($1_ltype)$input; %}
%typemap(directorin) char * %{ $input = alaqil_d_string_callback((const char *)$1); %}
%typemap(ddirectorin) char * "FROM_STRINGZ($winput)"
%typemap(ddirectorout) char * "TO_STRINGZ($dcall)"


/*
 * char*& typemaps.
 */

%typemap(in) char *& ($*1_ltype temp = 0) %{
  temp = ($*1_ltype)$input;
  $1 = &temp;
%}
%typemap(out) char *& %{ if ($1) $result = alaqil_d_string_callback((const char *)*$1); %}


/*
 * char array typemaps.
 */

%typemap(in) char[ANY], char[] %{ $1 = ($1_ltype)$input; %}
%typemap(out) char[ANY], char[] %{ $result = alaqil_d_string_callback((const char *)$1); %}

%typemap(directorout) char[ANY], char[] %{ $result = ($1_ltype)$input; %}
%typemap(directorin) char[ANY], char[] %{ $input = alaqil_d_string_callback((const char *)$1); %}

%typemap(ddirectorin) char[ANY], char[] "$winput"
%typemap(ddirectorout) char[ANY], char[] "$dcall"


%typemap(din) char *, char *&, char[ANY], char[] "($dinput ? TO_STRINGZ($dinput) : null)"
%typemap(dout, excode=alaqilEXCODE) char *, char *&, char[ANY], char[] {
  DP_STRING_TYPE ret = FROM_STRINGZ ## ($imcall);$excode
  return ret;
}

%typecheck(alaqil_TYPECHECK_STRING)
    char *,
    char *&,
    char[ANY],
    char[]
  ""
%enddef


// We need to have the \0-terminated string conversion functions available in
// the D proxy modules.
#if (alaqil_D_VERSION == 1)
// Could be easily extended to support Phobos as well.
alaqilD_STRING_TYPEMAPS(char*, char[], tango.stdc.stringz.fromStringz, tango.stdc.stringz.toStringz)

%pragma(d) globalproxyimports = "static import tango.stdc.stringz;";
#else
alaqilD_STRING_TYPEMAPS(const(char)*, string, std.conv.to!string, std.string.toStringz)

%pragma(d) globalproxyimports = %{
static import std.conv;
static import std.string;
%}
#endif
#undef alaqilD_STRING_TYPEMAPS
