// Users can provide their own alaqil_SHARED_PTR_TYPEMAPS macro before including this file to change the
// visibility of the constructor and getCPtr method if desired to public if using multiple modules.
#ifndef alaqil_SHARED_PTR_TYPEMAPS
#define alaqil_SHARED_PTR_TYPEMAPS(CONST, TYPE...) alaqil_SHARED_PTR_TYPEMAPS_IMPLEMENTATION(internal, internal, CONST, TYPE)
#endif

%include <shared_ptr.i>

// Language specific macro implementing all the customisations for handling the smart pointer
%define alaqil_SHARED_PTR_TYPEMAPS_IMPLEMENTATION(PTRCTOR_VISIBILITY, CPTR_VISIBILITY, CONST, TYPE...)

// %naturalvar is as documented for member variables
%naturalvar TYPE;
%naturalvar alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE >;

// destructor mods
%feature("unref") TYPE
//"if (debug_shared) { cout << \"deleting use_count: \" << (*smartarg1).use_count() << \" [\" << (boost::get_deleter<alaqil_null_deleter>(*smartarg1) ? std::string(\"CANNOT BE DETERMINED SAFELY\") : ( (*smartarg1).get() ? (*smartarg1)->getValue() : std::string(\"NULL PTR\") )) << \"]\" << endl << flush; }\n"
                               "(void)arg1; delete smartarg1;"

// Typemap customisations...

// plain value
%typemap(in, canthrow=1) CONST TYPE ($&1_type argp = 0) %{
  argp = ((alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > *)$input) ? ((alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > *)$input)->get() : 0;
  if (!argp) {
    alaqil_CSharpSetPendingExceptionArgument(alaqil_CSharpArgumentNullException, "Attempt to dereference null $1_type", 0);
    return $null;
  }
  $1 = *argp; %}
%typemap(out) CONST TYPE
%{ $result = new alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE >(new $1_ltype(($1_ltype &)$1)); %}

%typemap(directorin) CONST TYPE
%{ $input = new alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > (new $1_ltype((const $1_ltype &)$1)); %}

%typemap(directorout) CONST TYPE
%{ if (!$input) {
    alaqil_CSharpSetPendingExceptionArgument(alaqil_CSharpArgumentNullException, "Attempt to dereference null $1_type", 0);
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
    alaqil_CSharpSetPendingExceptionArgument(alaqil_CSharpArgumentNullException, "$1_type reference is null", 0);
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
%typemap (imtype, out="global::System.IntPtr") alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE >,
                                alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > &,
                                alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > *,
                                alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > *& "global::System.Runtime.InteropServices.HandleRef"
%typemap (cstype) alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE >,
                  alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > &,
                  alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > *,
                  alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > *& "$typemap(cstype, TYPE)"

%typemap(csin) alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE >,
               alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > &,
               alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > *,
               alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > *& "$typemap(cstype, TYPE).getCPtr($csinput)"

%typemap(csout, excode=alaqilEXCODE) alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > {
    global::System.IntPtr cPtr = $imcall;
    $typemap(cstype, TYPE) ret = (cPtr == global::System.IntPtr.Zero) ? null : new $typemap(cstype, TYPE)(cPtr, true);$excode
    return ret;
  }
%typemap(csout, excode=alaqilEXCODE) alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > & {
    global::System.IntPtr cPtr = $imcall;
    $typemap(cstype, TYPE) ret = (cPtr == global::System.IntPtr.Zero) ? null : new $typemap(cstype, TYPE)(cPtr, true);$excode
    return ret;
  }
%typemap(csout, excode=alaqilEXCODE) alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > * {
    global::System.IntPtr cPtr = $imcall;
    $typemap(cstype, TYPE) ret = (cPtr == global::System.IntPtr.Zero) ? null : new $typemap(cstype, TYPE)(cPtr, true);$excode
    return ret;
  }
%typemap(csout, excode=alaqilEXCODE) alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > *& {
    global::System.IntPtr cPtr = $imcall;
    $typemap(cstype, TYPE) ret = (cPtr == global::System.IntPtr.Zero) ? null : new $typemap(cstype, TYPE)(cPtr, true);$excode
    return ret;
  }


%typemap(csout, excode=alaqilEXCODE) CONST TYPE {
    $typemap(cstype, TYPE) ret = new $typemap(cstype, TYPE)($imcall, true);$excode
    return ret;
  }
%typemap(csout, excode=alaqilEXCODE) CONST TYPE & {
    $typemap(cstype, TYPE) ret = new $typemap(cstype, TYPE)($imcall, true);$excode
    return ret;
  }
%typemap(csout, excode=alaqilEXCODE) CONST TYPE * {
    global::System.IntPtr cPtr = $imcall;
    $typemap(cstype, TYPE) ret = (cPtr == global::System.IntPtr.Zero) ? null : new $typemap(cstype, TYPE)(cPtr, true);$excode
    return ret;
  }
%typemap(csout, excode=alaqilEXCODE) TYPE *CONST& {
    global::System.IntPtr cPtr = $imcall;
    $typemap(cstype, TYPE) ret = (cPtr == global::System.IntPtr.Zero) ? null : new $typemap(cstype, TYPE)(cPtr, true);$excode
    return ret;
  }

%typemap(csvarout, excode=alaqilEXCODE2) CONST TYPE & %{
    get {
      $csclassname ret = new $csclassname($imcall, true);$excode
      return ret;
    } %}
%typemap(csvarout, excode=alaqilEXCODE2) CONST TYPE * %{
    get {
      global::System.IntPtr cPtr = $imcall;
      $csclassname ret = (cPtr == global::System.IntPtr.Zero) ? null : new $csclassname(cPtr, true);$excode
      return ret;
    } %}

%typemap(csvarout, excode=alaqilEXCODE2) alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > & %{
    get {
      global::System.IntPtr cPtr = $imcall;
      $typemap(cstype, TYPE) ret = (cPtr == global::System.IntPtr.Zero) ? null : new $typemap(cstype, TYPE)(cPtr, true);$excode
      return ret;
    } %}
%typemap(csvarout, excode=alaqilEXCODE2) alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > * %{
    get {
      global::System.IntPtr cPtr = $imcall;
      $typemap(cstype, TYPE) ret = (cPtr == global::System.IntPtr.Zero) ? null : new $typemap(cstype, TYPE)(cPtr, true);$excode
      return ret;
    } %}

%typemap(csdirectorout) alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > "$typemap(cstype, TYPE).getCPtr($cscall).Handle"

%typemap(csdirectorin) CONST TYPE,
                       CONST TYPE *,
                       CONST TYPE &,
                       TYPE *CONST& "($iminput == global::System.IntPtr.Zero) ? null : new $typemap(cstype, TYPE)($iminput, true)"

%typemap(csdirectorin) alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE >,
                       alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > &,
                       alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > *,
                       alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > *& "($iminput == global::System.IntPtr.Zero) ? null : new $typemap(cstype, TYPE)($iminput, true)"


// Proxy classes (base classes, ie, not derived classes)
%typemap(csbody) TYPE %{
  private global::System.Runtime.InteropServices.HandleRef alaqilCPtr;
  private bool alaqilCMemOwnBase;

  PTRCTOR_VISIBILITY $csclassname(global::System.IntPtr cPtr, bool cMemoryOwn) {
    alaqilCMemOwnBase = cMemoryOwn;
    alaqilCPtr = new global::System.Runtime.InteropServices.HandleRef(this, cPtr);
  }

  CPTR_VISIBILITY static global::System.Runtime.InteropServices.HandleRef getCPtr($csclassname obj) {
    return (obj == null) ? new global::System.Runtime.InteropServices.HandleRef(null, global::System.IntPtr.Zero) : obj.alaqilCPtr;
  }
%}

// Derived proxy classes
%typemap(csbody_derived) TYPE %{
  private global::System.Runtime.InteropServices.HandleRef alaqilCPtr;
  private bool alaqilCMemOwnDerived;

  PTRCTOR_VISIBILITY $csclassname(global::System.IntPtr cPtr, bool cMemoryOwn) : base($imclassname.$csclazznamealaqilSmartPtrUpcast(cPtr), true) {
    alaqilCMemOwnDerived = cMemoryOwn;
    alaqilCPtr = new global::System.Runtime.InteropServices.HandleRef(this, cPtr);
  }

  CPTR_VISIBILITY static global::System.Runtime.InteropServices.HandleRef getCPtr($csclassname obj) {
    return (obj == null) ? new global::System.Runtime.InteropServices.HandleRef(null, global::System.IntPtr.Zero) : obj.alaqilCPtr;
  }
%}

%typemap(csdestruct, methodname="Dispose", methodmodifiers="public") TYPE {
    lock(this) {
      if (alaqilCPtr.Handle != global::System.IntPtr.Zero) {
        if (alaqilCMemOwnBase) {
          alaqilCMemOwnBase = false;
          $imcall;
        }
        alaqilCPtr = new global::System.Runtime.InteropServices.HandleRef(null, global::System.IntPtr.Zero);
      }
      global::System.GC.SuppressFinalize(this);
    }
  }

%typemap(csdestruct_derived, methodname="Dispose", methodmodifiers="public") TYPE {
    lock(this) {
      if (alaqilCPtr.Handle != global::System.IntPtr.Zero) {
        if (alaqilCMemOwnDerived) {
          alaqilCMemOwnDerived = false;
          $imcall;
        }
        alaqilCPtr = new global::System.Runtime.InteropServices.HandleRef(null, global::System.IntPtr.Zero);
      }
      global::System.GC.SuppressFinalize(this);
      base.Dispose();
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
