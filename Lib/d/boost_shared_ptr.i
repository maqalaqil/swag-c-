%include <shared_ptr.i>

// Language specific macro implementing all the customisations for handling the smart pointer
%define alaqil_SHARED_PTR_TYPEMAPS(CONST, TYPE...)

// %naturalvar is as documented for member variables
%naturalvar TYPE;
%naturalvar alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE >;

// destructor mods
%feature("unref") TYPE
//"if (debug_shared) { cout << \"deleting use_count: \" << (*smartarg1).use_count() << \" [\" << (boost::get_deleter<alaqil_null_deleter>(*smartarg1) ? std::string(\"CANNOT BE DETERMINED SAFELY\") : ((*smartarg1).get() ? (*smartarg1)->getValue() : std::string(\"NULL PTR\"))) << \"]\" << endl << flush; }\n"
                               "(void)arg1; delete smartarg1;"

// Typemap customisations...

// plain value
%typemap(in, canthrow=1) CONST TYPE ($&1_type argp = 0) %{
  argp = ((alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > *)$input) ? ((alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > *)$input)->get() : 0;
  if (!argp) {
    alaqil_DSetPendingException(alaqil_DIllegalArgumentException, "Attempt to dereference null $1_type");
    return $null;
  }
  $1 = *argp; %}
%typemap(out) CONST TYPE
%{ $result = new alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE >(new $1_ltype(($1_ltype &)$1)); %}

%typemap(directorin) CONST TYPE
%{ $input = new alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > (new $1_ltype((const $1_ltype &)$1)); %}

%typemap(directorout) CONST TYPE
%{ if (!$input) {
    alaqil_DSetPendingException(alaqil_DIllegalArgumentException, "Attempt to dereference null $1_type");
    return $null;
  }
  alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > *smartarg = (alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > *)$input;
  $result = *smartarg->get();
%}

// plain pointer
%typemap(in, canthrow=1) CONST TYPE * (alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > *smartarg = 0) %{
  smartarg = (alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > *)$input;
  $1 = (TYPE *)(smartarg ? smartarg->get() : 0); %}
%typemap(out, fragment="alaqil_null_deleter") CONST TYPE * %{
  $result = $1 ? new alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE >($1 alaqil_NO_NULL_DELETER_$owner) : 0;
%}

%typemap(directorin) CONST TYPE *
%{ $input = $1 ? new alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE >($1 alaqil_NO_NULL_DELETER_0) : 0; %}

%typemap(directorout) CONST TYPE * %{
#error "typemaps for $1_type not available"
%}

// plain reference
%typemap(in, canthrow=1) CONST TYPE & %{
  $1 = ($1_ltype)(((alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > *)$input) ? ((alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > *)$input)->get() : 0);
  if (!$1) {
    alaqil_DSetPendingException(alaqil_DIllegalArgumentException, "$1_type reference is null");
    return $null;
  } %}
%typemap(out, fragment="alaqil_null_deleter") CONST TYPE &
%{ $result = new alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE >($1 alaqil_NO_NULL_DELETER_$owner); %}

%typemap(directorin) CONST TYPE &
%{ $input = new alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > (&$1 alaqil_NO_NULL_DELETER_0); %}

%typemap(directorout) CONST TYPE & %{
#error "typemaps for $1_type not available"
%}

// plain pointer by reference
%typemap(in) TYPE *CONST& ($*1_ltype temp = 0)
%{ temp = (TYPE *)(((alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > *)$input) ? ((alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > *)$input)->get() : 0);
   $1 = &temp; %}
%typemap(out, fragment="alaqil_null_deleter") TYPE *CONST&
%{ $result = new alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE >(*$1 alaqil_NO_NULL_DELETER_$owner); %}

%typemap(directorin) TYPE *CONST&
%{ $input = $1 ? new alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE >($1 alaqil_NO_NULL_DELETER_0) : 0; %}

%typemap(directorout) TYPE *CONST& %{
#error "typemaps for $1_type not available"
%}

// shared_ptr by value
%typemap(in) alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE >
%{ if ($input) $1 = *($&1_ltype)$input; %}
%typemap(out) alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE >
%{ $result = $1 ? new $1_ltype($1) : 0; %}

%typemap(directorin) alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE >
%{ $input = $1 ? new alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE >($1) : 0; %}

%typemap(directorout) alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE >
%{ if ($input) {
    alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > *smartarg = (alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > *)$input;
    $result = *smartarg;
  }
%}

// shared_ptr by reference
%typemap(in, canthrow=1) alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > & ($*1_ltype tempnull)
%{ $1 = $input ? ($1_ltype)$input : &tempnull; %}
%typemap(out) alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > &
%{ $result = *$1 ? new $*1_ltype(*$1) : 0; %}

%typemap(directorin) alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > &
%{ $input = $1 ? new alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE >($1) : 0; %}

%typemap(directorout) alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > & %{
#error "typemaps for $1_type not available"
%}

// shared_ptr by pointer
%typemap(in) alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > * ($*1_ltype tempnull)
%{ $1 = $input ? ($1_ltype)$input : &tempnull; %}
%typemap(out, fragment="alaqil_null_deleter") alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > *
%{ $result = ($1 && *$1) ? new $*1_ltype(*($1_ltype)$1) : 0;
   if ($owner) delete $1; %}

%typemap(directorin) alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > *
%{ $input = ($1 && *$1) ? new alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE >(*$1) : 0; %}

%typemap(directorout) alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > * %{
#error "typemaps for $1_type not available"
%}

// shared_ptr by pointer reference
%typemap(in) alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > *& (alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > tempnull, $*1_ltype temp = 0)
%{ temp = $input ? *($1_ltype)&$input : &tempnull;
   $1 = &temp; %}
%typemap(out) alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > *&
%{ *($1_ltype)&$result = (*$1 && **$1) ? new alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE >(**$1) : 0; %}

%typemap(directorin) alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > *&
%{ $input = ($1 && *$1) ? new alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE >(*$1) : 0; %}

%typemap(directorout) alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > *& %{
#error "typemaps for $1_type not available"
%}

// various missing typemaps - If ever used (unlikely) ensure compilation error rather than runtime bug
%typemap(in) CONST TYPE[], CONST TYPE[ANY], CONST TYPE (CLASS::*) %{
#error "typemaps for $1_type not available"
%}
%typemap(out) CONST TYPE[], CONST TYPE[ANY], CONST TYPE (CLASS::*) %{
#error "typemaps for $1_type not available"
%}


%typemap (ctype)  alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE >,
                  alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > &,
                  alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > *,
                  alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > *& "void *"
%typemap (imtype) alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE >,
                  alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > &,
                  alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > *,
                  alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > *& "void*"
%typemap (dtype) alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE >,
                  alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > &,
                  alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > *,
                  alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > *& "$typemap(dtype, TYPE)"

%typemap(din) alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE >,
              alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > &,
              alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > *,
              alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > *& "$typemap(dtype, TYPE).alaqilGetCPtr($dinput)"

%typemap(ddirectorout) alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > "$typemap(dtype, TYPE).alaqilGetCPtr($dcall)"

%typemap(ddirectorin) CONST TYPE,
                      CONST TYPE *,
                      CONST TYPE &,
                      TYPE *CONST& "($winput is null) ? null : new $typemap(dtype, TYPE)($winput, true)"

%typemap(ddirectorin) alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE >,
                      alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > &,
                      alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > *,
                      alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > *& "($winput is null) ? null : new $typemap(dtype, TYPE)($winput, true)"


%typemap(dout, excode=alaqilEXCODE) alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > {
  void* cPtr = $imcall;
  auto ret = (cPtr is null) ? null : new $typemap(dtype, TYPE)(cPtr, true);$excode
  return ret;
}
%typemap(dout, excode=alaqilEXCODE) alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > & {
  void* cPtr = $imcall;
  auto ret = (cPtr is null) ? null : new $typemap(dtype, TYPE)(cPtr, true);$excode
  return ret;
}
%typemap(dout, excode=alaqilEXCODE) alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > * {
  void* cPtr = $imcall;
  auto ret = (cPtr is null) ? null : new $typemap(dtype, TYPE)(cPtr, true);$excode
  return ret;
}
%typemap(dout, excode=alaqilEXCODE) alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > *& {
  void* cPtr = $imcall;
  auto ret = (cPtr is null) ? null : new $typemap(dtype, TYPE)(cPtr, true);$excode
  return ret;
}


%typemap(dout, excode=alaqilEXCODE) CONST TYPE {
  auto ret = new $typemap(dtype, TYPE)($imcall, true);$excode
  return ret;
}
%typemap(dout, excode=alaqilEXCODE) CONST TYPE & {
  auto ret = new $typemap(dtype, TYPE)($imcall, true);$excode
  return ret;
}
%typemap(dout, excode=alaqilEXCODE) CONST TYPE * {
  void* cPtr = $imcall;
  auto ret = (cPtr is null) ? null : new $typemap(dtype, TYPE)(cPtr, true);$excode
  return ret;
}
%typemap(dout, excode=alaqilEXCODE) TYPE *CONST& {
  void* cPtr = $imcall;
  auto ret = (cPtr is null) ? null : new $typemap(dtype, TYPE)(cPtr, true);$excode
  return ret;
}

// Proxy classes (base classes, ie, not derived classes)
%typemap(dbody) alaqilTYPE %{
private void* alaqilCPtr;
private bool alaqilCMemOwn;

public this(void* cObject, bool ownCObject) {
  alaqilCPtr = cObject;
  alaqilCMemOwn = ownCObject;
}

public static void* alaqilGetCPtr(typeof(this) obj) {
  return (obj is null) ? null : obj.alaqilCPtr;
}
%}

// Derived proxy classes
%typemap(dbody_derived) alaqilTYPE %{
private void* alaqilCPtr;
private bool alaqilCMemOwn;

public this(void* cObject, bool ownCObject) {
  super($imdmodule.$dclazznameSmartPtrUpcast(cObject), ownCObject);
  alaqilCPtr = cObject;
  alaqilCMemOwn = ownCObject;
}

public static void* alaqilGetCPtr(typeof(this) obj) {
  return (obj is null) ? null : obj.alaqilCPtr;
}
%}

%typemap(ddispose, methodname="dispose", methodmodifiers="public") TYPE {
  synchronized(this) {
    if (alaqilCPtr !is null) {
      if (alaqilCMemOwn) {
        alaqilCMemOwn = false;
        $imcall;
      }
      alaqilCPtr = null;
    }
  }
}

%typemap(ddispose_derived, methodname="dispose", methodmodifiers="public") TYPE {
  synchronized(this) {
    if (alaqilCPtr !is null) {
      if (alaqilCMemOwn) {
        alaqilCMemOwn = false;
        $imcall;
      }
      alaqilCPtr = null;
      super.dispose();
    }
  }
}

// Typecheck typemaps
%typemap(typecheck, precedence=alaqil_TYPECHECK_POINTER, equivalent="TYPE *")
  TYPE CONST,
  TYPE CONST &,
  TYPE CONST *,
  TYPE *CONST&,
  alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE >,
  alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > &,
  alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > *,
  alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > *&
  ""

%template() alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE >;
%enddef
