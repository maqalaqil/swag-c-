/* ------------------------------------------------------------
 * go.swg
 *
 * Go configuration module.
 * ------------------------------------------------------------ */

%include <gostring.swg>

/* Code insertion directives */
#define %go_import(...) %insert(go_imports) %{__VA_ARGS__%}

/* Basic types */

%typemap(gotype) bool,               const bool &               "bool"
%typemap(gotype) char,               const char &               "byte"
%typemap(gotype) signed char,        const signed char &        "int8"
%typemap(gotype) unsigned char,      const unsigned char &      "byte"
%typemap(gotype) short,              const short &              "int16"
%typemap(gotype) unsigned short,     const unsigned short &     "uint16"
%typemap(gotype) int,                const int &                "int"
%typemap(gotype) unsigned int,       const unsigned int &       "uint"
%typemap(gotype) long,               const long &               "int64"
%typemap(gotype) unsigned long,      const unsigned long &      "uint64"
%typemap(gotype) long long,          const long long &          "int64"
%typemap(gotype) unsigned long long, const unsigned long long & "uint64"
%typemap(gotype) float,              const float &              "float32"
%typemap(gotype) double,             const double &             "float64"

%typemap(in) bool,
	     char,
	     signed char,
	     unsigned char,
	     short,
	     unsigned short,
	     int,
	     unsigned int,
	     long,
	     unsigned long,
	     long long,
	     unsigned long long,
	     float,
	     double
%{ $1 = ($1_ltype)$input; %}

%typemap(in) const bool &,
	     const char &,
	     const signed char &,
	     const unsigned char &,
	     const short &,
	     const unsigned short &,
	     const int &,
	     const unsigned int &,
	     const long long &,
	     const unsigned long long &,
	     const float &,
	     const double &
%{ $1 = ($1_ltype)&$input; %}

%typemap(in) const long & ($*1_ltype temp),
	     const unsigned long & ($*1_ltype temp)
%{ temp = ($*1_ltype)$input;
   $1 = ($1_ltype)&temp; %}

%typemap(out) bool,
	      char,
	      signed char,
	      unsigned char,
	      short,
	      unsigned short,
	      int,
	      unsigned int,
	      long,
	      unsigned long,
	      long long,
	      unsigned long long,
	      float,
	      double
%{ $result = $1; %}

%typemap(goout) bool,
	      char,
	      signed char,
	      unsigned char,
	      short,
	      unsigned short,
	      int,
	      unsigned int,
	      long,
	      unsigned long,
	      long long,
	      unsigned long long,
	      float,
	      double
""

%typemap(out) const bool &,
	      const char &,
	      const signed char &,
	      const unsigned char &,
	      const short &,
	      const unsigned short &,
	      const int &,
	      const unsigned int &,
	      const long &,
	      const unsigned long &,
	      const long long &,
	      const unsigned long long &,
	      const float &,
	      const double &
%{ $result = ($*1_ltype)*$1; %}

%typemap(goout) const bool &,
	      const char &,
	      const signed char &,
	      const unsigned char &,
	      const short &,
	      const unsigned short &,
	      const int &,
	      const unsigned int &,
	      const long &,
	      const unsigned long &,
	      const long long &,
	      const unsigned long long &,
	      const float &,
	      const double &
""

%typemap(out) void ""

%typemap(goout) void ""

%typemap(directorin) bool,
		     char,
		     signed char,
		     unsigned char,
		     short,
		     unsigned short,
		     int,
		     unsigned int,
		     long,
		     unsigned long,
		     long long,
		     unsigned long long,
		     float,
		     double
%{ $input = ($1_ltype)$1; %}

%typemap(godirectorin) bool,
		     char,
		     signed char,
		     unsigned char,
		     short,
		     unsigned short,
		     int,
		     unsigned int,
		     long,
		     unsigned long,
		     long long,
		     unsigned long long,
		     float,
		     double
""

%typemap(directorin) const bool &,
		     const char &,
		     const signed char &,
		     const unsigned char &,
		     const short &,
		     const unsigned short &,
		     const int &,
		     const unsigned int &,
		     const long &,
		     const unsigned long &,
		     const long long &,
		     const unsigned long long &,
		     const float &,
		     const double &
%{ $input = ($*1_ltype)$1; %}

%typemap(godirectorin) const bool &,
		     const char &,
		     const signed char &,
		     const unsigned char &,
		     const short &,
		     const unsigned short &,
		     const int &,
		     const unsigned int &,
		     const long &,
		     const unsigned long &,
		     const long long &,
		     const unsigned long long &,
		     const float &,
		     const double &
""

%typemap(directorout) bool,
		      char,
		      signed char,
		      unsigned char,
		      short,
		      unsigned short,
		      int,
		      unsigned int,
		      long,
		      unsigned long,
		      long long,
		      unsigned long long,
		      float,
		      double
%{ $result = ($1_ltype)$input; %}

%typemap(directorout,warning=alaqilWARN_TYPEMAP_DIRECTOROUT_PTR_MSG) const bool &,
		      const char &,
		      const signed char &,
		      const unsigned char &,
		      const short &,
		      const unsigned short &,
		      const int &,
		      const unsigned int &,
		      const long &,
		      const unsigned long &,
		      const long long &,
		      const unsigned long long &,
		      const float &,
		      const double &
%{
  $result = new $*1_ltype($input);
  alaqil_acquire_pointer(&alaqil_mem, $result);
%}

/* The size_t type.  */

%typemap(gotype) size_t, const size_t & %{int64%}

%typemap(in) size_t
%{ $1 = (size_t)$input; %}

%typemap(in) const size_t &
%{ $1 = ($1_ltype)&$input; %}

%typemap(out) size_t
%{ $result = $1; %}

%typemap(goout) size_t ""

%typemap(out) const size_t &
%{ $result = ($*1_ltype)*$1; %}

%typemap(goout) const size_t & ""

%typemap(directorin) size_t
%{ $input = (size_t)$1; %}

%typemap(godirectorin) size_t ""

%typemap(directorin) const size_t &
%{ $input = ($*1_ltype)$1; %}

%typemap(godirectorin) const size_t & ""

%typemap(directorout) size_t
%{ $result = ($1_ltype)$input; %}

%typemap(directorout,warning=alaqilWARN_TYPEMAP_DIRECTOROUT_PTR_MSG) const size_t &
%{
  $result = new $*1_ltype($input);
  alaqil_acquire_pointer(&alaqil_mem, $result);
%}

/* Member pointers.  */

%typemap(gotype) alaqilTYPE (CLASS::*)
%{$gotypename%}

%typemap(in) alaqilTYPE (CLASS::*)
%{ $1 = *($&1_ltype)$input; %}

%typemap(out) alaqilTYPE (CLASS::*)
%{
  struct alaqil_out_type { intgo size; void* val; } *alaqil_out;
  alaqil_out = (struct alaqil_out_type*)malloc(sizeof(*alaqil_out));
  if (alaqil_out) {
    alaqil_out->size = sizeof($1_ltype);
    alaqil_out->val = malloc(alaqil_out->size);
    if (alaqil_out->val) {
      *($&1_ltype)(alaqil_out->val) = $1;
    }
  }
  $result = alaqil_out;
%}

%typemap(goout) alaqilTYPE (CLASS::*)
%{
  {
    type alaqil_out_type struct { size int; val uintptr }
    p := (*alaqil_out_type)(unsafe.Pointer($1))
    if p == nil || p.val == 0 {
      $result = nil
    } else {
      m := make([]byte, p.size)
      a := (*[1024]byte)(unsafe.Pointer(p.val))[:p.size]
      copy(m, a)
      alaqil_free(p.val)
      alaqil_free(uintptr(unsafe.Pointer(p)))
      $result = &m[0]
    }
  }
%}

%typemap(directorin) alaqilTYPE (CLASS::*)
%{ $input = *($&1_ltype)$1; %}

%typemap(godirectorin) alaqilTYPE (CLASS::*) ""

%typemap(directorout) alaqilTYPE (CLASS::*)
%{
  $result = new $1_ltype($input);
  alaqil_acquire_pointer(&alaqil_mem, $result);
%}

/* Pointers.  */

/* We can't translate pointers using a typemap, so that is handled in
   the C++ code.  */
%typemap(gotype) alaqilTYPE *
%{$gotypename%}

%typemap(in) alaqilTYPE *
%{ $1 = *($&1_ltype)&$input; %}

%typemap(out) alaqilTYPE *
%{ *($&1_ltype)&$result = ($1_ltype)$1; %}

%typemap(goout) alaqilTYPE * ""

%typemap(directorin) alaqilTYPE *
%{ *($&1_ltype)&$input = ($1_ltype)$1; %}

%typemap(godirectorin) alaqilTYPE * ""

%typemap(directorout) alaqilTYPE *
%{ $result = *($&1_ltype)&$input; %}

/* Pointer references.  */

%typemap(gotype) alaqilTYPE *const&
%{$gotypename%}

%typemap(in) alaqilTYPE *const& ($*1_ltype temp = 0)
%{
  temp = *($1_ltype)&$input;
  $1 = ($1_ltype)&temp;
%}

%typemap(out) alaqilTYPE *const&
%{ *($1_ltype)&$result = *$1; %}

%typemap(goout) alaqilTYPE *const& ""

/* References.  */

/* Converting a C++ reference to Go has to be handled in the C++
   code.  */
%typemap(gotype) alaqilTYPE &
%{$gotypename%}

%typemap(in) alaqilTYPE &
%{ $1 = *($&1_ltype)&$input; %}

%typemap(out) alaqilTYPE &
%{ *($&1_ltype)&$result = $1; %}

%typemap(goout) alaqilTYPE & ""

%typemap(directorin) alaqilTYPE &
%{ $input = ($1_ltype)&$1; %}

%typemap(godirectorin) alaqilTYPE & ""

%typemap(directorout) alaqilTYPE &
%{ *($&1_ltype)&$result = $input; %}

%typemap(directorout, warning=alaqilWARN_TYPEMAP_DIRECTOROUT_PTR_MSG) alaqilTYPE *const&
%{ static $*1_ltype alaqil_temp;
   alaqil_temp = *($1_ltype)&$input;
   $result = &alaqil_temp; %}

%typemap(gotype) alaqilTYPE &&
%{$gotypename%}

%typemap(in) alaqilTYPE &&
%{ $1 = *($&1_ltype)&$input; %}

%typemap(out) alaqilTYPE &&
%{ *($&1_ltype)&$result = $1; %}

%typemap(goout) alaqilTYPE && ""

%typemap(directorin) alaqilTYPE &&
%{ $input = ($1_ltype)&$1_name; %}

%typemap(godirectorin) alaqilTYPE && ""

%typemap(directorout) alaqilTYPE &&
%{ *($&1_ltype)&$result = $input; %}

/* C arrays turn into Go pointers.  If we know the length we can use a
   slice.  */

%typemap(gotype) alaqilTYPE []
%{$gotypename%}

%typemap(in) alaqilTYPE []
%{ $1 = *($&1_ltype)&$input; %}

%typemap(out) alaqilTYPE []
%{ *($&1_ltype)&$result = $1; %}

%typemap(goout) alaqilTYPE [] ""

%typemap(directorin) alaqilTYPE []
%{ $input = *($1_ltype)&$1; %}

%typemap(godirectorin) alaqilTYPE [] ""

%typemap(directorout) alaqilTYPE []
%{ *($&1_ltype)&$result = $input; %}

/* Strings.  */

%typemap(gotype)
	char *, char *&, char[ANY], char[] "string"

/* Needed to avoid confusion with the way the go module handles
   references.  */
%typemap(gotype) char&, unsigned char& "*byte"
%typemap(gotype) signed char& "*int8"

%typemap(in)
	char *, char[ANY], char[]
%{
  $1 = ($1_ltype)malloc($input.n + 1);
  memcpy($1, $input.p, $input.n);
  $1[$input.n] = '\0';
%}

%typemap(in) char *& (char *temp)
%{
  temp = (char *)malloc($input.n + 1);
  memcpy(temp, $input.p, $input.n);
  temp[$input.n] = '\0';
  $1 = ($1_ltype)&temp;
%}

%typemap(freearg)
	char *, char *&, char[ANY], char[]
%{ free($1); %}

%typemap(out,fragment="AllocateString")
	char *, char *&, char[ANY], char[]
%{ $result = alaqil_AllocateString((char*)$1, $1 ? strlen((char*)$1) : 0); %}

%typemap(goout,fragment="CopyString")
	char *, char *&, char[ANY], char[]
%{ $result = alaqilCopyString($1) %}

%typemap(directorin,fragment="AllocateString")
	char *, char *&, char[ANY], char[]
%{
  $input = alaqil_AllocateString((char*)$1, $1 ? strlen((char*)$1) : 0);
%}

%typemap(godirectorin,fragment="CopyString")
	char *, char *&, char[ANY], char[]
%{
  $result = alaqilCopyString($input)
%}

%typemap(godirectorout)
	char *, char *&, char[ANY], char[]
%{
  {
    p := alaqil_malloc(len($input) + 1)
    s := (*[1<<30]byte)(unsafe.Pointer(p))[:len($input) + 1]
    copy(s, $input)
    s[len($input)] = 0
    $result = *(*string)(unsafe.Pointer(&s))
  }
%}

%typemap(directorout, warning=alaqilWARN_TYPEMAP_DIRECTOROUT_PTR_MSG)
	char *, char *&, char[ANY], char[]
%{ $result = ($1_ltype)$input.p; %}

/* String & length */

%typemap(gotype) (char *STRING, size_t LENGTH) "string"

%typemap(in) (char *STRING, size_t LENGTH)
%{
  $1 = ($1_ltype)$input.p;
  $2 = ($2_ltype)$input.n;
%}

%typemap(out,fragment="AllocateString") (char *STRING, size_t LENGTH)
%{ $result = alaqil_AllocateString((char*)$1, (size_t)$2); %}

%typemap(goout,fragment="CopyString") (char *STRING, size_t LENGTH)
%{ $result = alaqilCopyString($1) %}

%typemap(directorin,fragment="AllocateString") (char *STRING, size_t LENGTH)
%{ $input = alaqil_AllocateString((char*)$1, $2); %}

%typemap(godirectorin,fragment="CopyString") (char *STRING, size_t LENGTH)
%{ $result = alaqilCopyString($input) %}

%typemap(directorout) (char *STRING, size_t LENGTH)
%{
  $1 = ($1_ltype)$input.p;
  $2 = ($2_ltype)$input.n;
%}

/* Enums.  We can't do the right thing for enums in typemap(gotype) so
   we deliberately don't define them.  The right thing would be to
   capitalize the name.  This is instead done in go.cxx.  */

%typemap(gotype) enum alaqilTYPE
%{$gotypename%}

%typemap(in) enum alaqilTYPE
%{ $1 = ($1_ltype)$input; %}

%typemap(out) enum alaqilTYPE
%{ $result = (intgo)$1; %}

%typemap(goout) enum alaqilTYPE ""

%typemap(directorin) enum alaqilTYPE
%{ $input = (intgo)$1; %}

%typemap(godirectorin) enum alaqilTYPE ""

%typemap(directorout) enum alaqilTYPE
%{ $result = ($1_ltype)$input; %}

%typemap(directorin) enum alaqilTYPE & (intgo e)
%{
  e = (intgo)$1;
  $input = ($1_ltype)&e;
%}

%typemap(godirectorin) enum alaqilTYPE & ""

%typemap(directorout) enum alaqilTYPE &
%{
  $*1_ltype f = ($*1_ltype)*$input;
  $result = ($1_ltype)&f;
%}

/* Arbitrary type.  This is a type passed by value in the C/C++ code.
   We convert it to a pointer for the Go code.  Note that all basic
   types are explicitly handled above.  */

%typemap(gotype) alaqilTYPE
%{$gotypename%}

%typemap(in) alaqilTYPE ($&1_type argp)
%{
  argp = ($&1_ltype)$input;
  if (argp == NULL) {
    _alaqil_gopanic("Attempt to dereference null $1_type");
  }
  $1 = ($1_ltype)*argp;
%}

%typemap(out) alaqilTYPE
#ifdef __cplusplus
%{ *($&1_ltype*)&$result = new $1_ltype($1); %}
#else
{
  $&1_ltype $1ptr = ($&1_ltype)malloc(sizeof($1_ltype));
  memmove($1ptr, &$1, sizeof($1_type));
  *($&1_ltype*)&$result = $1ptr;
}
#endif

%typemap(goout) alaqilTYPE ""

%typemap(directorin) alaqilTYPE
%{ $input = new $1_ltype((const $1_ltype &)$1); %}

%typemap(godirectorin) alaqilTYPE ""

%typemap(directorout) alaqilTYPE
%{ $result = *($&1_ltype)$input; %}

/* Exception handling */

%typemap(throws) char *
%{ _alaqil_gopanic($1); %}

%typemap(throws) alaqilTYPE, alaqilTYPE &, alaqilTYPE &&, alaqilTYPE *, alaqilTYPE [], alaqilTYPE [ANY]
%{
  (void)$1;
  _alaqil_gopanic("C++ $1_type exception thrown");
%}

/* Typecheck typemaps.  The purpose of these is merely to issue a
   warning for overloaded C++ functions that cannot be overloaded in
   Go as more than one C++ type maps to a single Go type.  */

%typecheck(alaqil_TYPECHECK_BOOL) /* Go bool */
    bool,
    const bool &
    ""

%typecheck(alaqil_TYPECHECK_CHAR) /* Go byte */
    char,
    const char &,
    unsigned char,
    const unsigned char &
    ""

%typecheck(alaqil_TYPECHECK_INT8) /* Go int8 */
    signed char,
    const signed char &
    ""

%typecheck(alaqil_TYPECHECK_INT16) /* Go int16 */
    short,
    const short &
    ""

%typecheck(alaqil_TYPECHECK_INT16) /* Go uint16 */
    unsigned short,
    const unsigned short &
    ""

%typecheck(alaqil_TYPECHECK_INT32) /* Go int */
    int,
    const int &
    ""

%typecheck(alaqil_TYPECHECK_INT32) /* Go uint */
    unsigned int,
    const unsigned int &
    ""

%typecheck(alaqil_TYPECHECK_INT64) /* Go int64 */
    long, 
    const long &, 
    long long,
    const long long &
    ""

%typecheck(alaqil_TYPECHECK_INT64) /* Go uint64 */
    unsigned long, 
    const unsigned long &, 
    unsigned long long,
    const unsigned long long &
    ""

%typecheck(alaqil_TYPECHECK_FLOAT) /* Go float32 */
    float,
    const float &
    ""

%typecheck(alaqil_TYPECHECK_DOUBLE) /* Go float64 */
    double,
    const double &
    ""

%typecheck(alaqil_TYPECHECK_STRING) /* Go string */
    char *,
    char *&,
    char[ANY],
    char [],
    signed char *,
    signed char *&,
    signed char[ANY],
    signed char [],
    unsigned char *,
    unsigned char *&,
    unsigned char[ANY],
    unsigned char []
    ""

%typecheck(alaqil_TYPECHECK_POINTER)
    alaqilTYPE,
    alaqilTYPE *,
    alaqilTYPE &,
    alaqilTYPE &&,
    alaqilTYPE *const&,
    alaqilTYPE [],
    alaqilTYPE (CLASS::*)
    ""

%apply alaqilTYPE * { alaqilTYPE *const }
%apply alaqilTYPE (CLASS::*) { alaqilTYPE (CLASS::*const) }
%apply alaqilTYPE & { alaqilTYPE (CLASS::*const&) }

/* Go keywords.  */
%include <gokw.swg>

%include <goruntime.swg>
