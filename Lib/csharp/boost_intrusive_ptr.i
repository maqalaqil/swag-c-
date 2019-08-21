// Users can provide their own alaqil_INTRUSIVE_PTR_TYPEMAPS or alaqil_INTRUSIVE_PTR_TYPEMAPS_NO_WRAP macros before including this file to change the
// visibility of the constructor and getCPtr method if desired to public if using multiple modules.
#ifndef alaqil_INTRUSIVE_PTR_TYPEMAPS
#define alaqil_INTRUSIVE_PTR_TYPEMAPS(CONST, TYPE...) alaqil_INTRUSIVE_PTR_TYPEMAPS_IMPLEMENTATION(internal, internal, CONST, TYPE)
#endif
#ifndef alaqil_INTRUSIVE_PTR_TYPEMAPS_NO_WRAP
#define alaqil_INTRUSIVE_PTR_TYPEMAPS_NO_WRAP(CONST, TYPE...) alaqil_INTRUSIVE_PTR_TYPEMAPS_NO_WRAP_IMPLEMENTATION(internal, internal, CONST, TYPE)
#endif

%include <intrusive_ptr.i>

// Language specific macro implementing all the customisations for handling the smart pointer
%define alaqil_INTRUSIVE_PTR_TYPEMAPS_IMPLEMENTATION(PTRCTOR_VISIBILITY, CPTR_VISIBILITY, CONST, TYPE...)

// %naturalvar is as documented for member variables
%naturalvar TYPE;
%naturalvar alaqil_INTRUSIVE_PTR_QNAMESPACE::intrusive_ptr< CONST TYPE >;

// destructor wrapper customisation
%feature("unref") TYPE "(void)arg1; delete smartarg1;"

// Typemap customisations...

%typemap(in, canthrow=1) CONST TYPE ($&1_type argp = 0) %{
  // plain value
  argp = (*(alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > **)&$input) ? (*(alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > **)&$input)->get() : 0;
  if (!argp) {
    alaqil_CSharpSetPendingExceptionArgument(alaqil_CSharpArgumentNullException, "Attempt to dereference null $1_type", 0);
    return $null;
  }
  $1 = *argp;
%}
%typemap(out, fragment="alaqil_intrusive_deleter") CONST TYPE %{
  //plain value(out)
  $1_ltype* resultp = new $1_ltype(($1_ltype &)$1);
  intrusive_ptr_add_ref(resultp);
  *(alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > **)&$result = new alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE >(resultp, alaqil_intrusive_deleter< CONST TYPE >());
%}

%typemap(in, canthrow=1) CONST TYPE * (alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > *smartarg = 0) %{
  // plain pointer
  smartarg = *(alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > **)&$input;
  $1 = (TYPE *)(smartarg ? smartarg->get() : 0);
%}
%typemap(out, fragment="alaqil_intrusive_deleter,alaqil_null_deleter") CONST TYPE * %{
  //plain pointer(out)
  #if ($owner)
  if ($1) {
    intrusive_ptr_add_ref($1);
    *(alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > **)&$result = new alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE >($1, alaqil_intrusive_deleter< CONST TYPE >());
  } else {
    *(alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > **)&$result = 0;
  }
  #else
    *(alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > **)&$result = $1 ? new alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE >($1 alaqil_NO_NULL_DELETER_0) : 0;
  #endif
%}

%typemap(in, canthrow=1) CONST TYPE & %{
  // plain reference
  $1 = ($1_ltype)((*(alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > **)&$input) ? (*(alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > **)&$input)->get() : 0);
  if(!$1) {
    alaqil_CSharpSetPendingExceptionArgument(alaqil_CSharpArgumentNullException, "$1_type reference is null", 0);
    return $null;
  }
%}
%typemap(out, fragment="alaqil_intrusive_deleter,alaqil_null_deleter") CONST TYPE & %{
  //plain reference(out)
  #if ($owner)
  if ($1) {
    intrusive_ptr_add_ref($1);
    *(alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > **)&$result = new alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE >($1, alaqil_intrusive_deleter< CONST TYPE >());
  } else {
    *(alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > **)&$result = 0;
  }
  #else
    *(alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > **)&$result = $1 ? new alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE >($1 alaqil_NO_NULL_DELETER_0) : 0;
  #endif
%}

%typemap(in) TYPE *CONST& ($*1_ltype temp = 0) %{
  // plain pointer by reference
  temp = ($*1_ltype)((*(alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > **)&$input) ? (*(alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > **)&$input)->get() : 0);
  $1 = &temp;
%}
%typemap(out, fragment="alaqil_intrusive_deleter,alaqil_null_deleter") TYPE *CONST& %{
  // plain pointer by reference(out)
  #if ($owner)
  if (*$1) {
    intrusive_ptr_add_ref(*$1);
    *(alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > **)&$result = new alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE >(*$1, alaqil_intrusive_deleter< CONST TYPE >());
  } else {
    *(alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > **)&$result = 0;
  }
  #else
    *(alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > **)&$result = new alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE >(*$1 alaqil_NO_NULL_DELETER_0);
  #endif
%}

%typemap(in) alaqil_INTRUSIVE_PTR_QNAMESPACE::intrusive_ptr< CONST TYPE > (alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > * smartarg) %{
  // intrusive_ptr by value
  smartarg = *(alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE >**)&$input;
  if (smartarg) {
    $1 = alaqil_INTRUSIVE_PTR_QNAMESPACE::intrusive_ptr< CONST TYPE >(smartarg->get(), true);
  }
%}
%typemap(out, fragment="alaqil_intrusive_deleter") alaqil_INTRUSIVE_PTR_QNAMESPACE::intrusive_ptr< CONST TYPE > %{
  if ($1) {
    intrusive_ptr_add_ref($1.get());
    *(alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > **)&$result = new alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE >($1.get(), alaqil_intrusive_deleter< CONST TYPE >());
  } else {
    *(alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > **)&$result = 0;
  }
%}

%typemap(in) alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > alaqilSharedPtrUpcast ($&1_type smartarg) %{
  // shared_ptr by value
  smartarg = *($&1_ltype*)&$input;
  if (smartarg) $1 = *smartarg;
%}
%typemap(out) alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > ANY_TYPE_alaqilSharedPtrUpcast %{
  *($&1_ltype*)&$result = $1 ? new $1_ltype($1) : 0;
%}

%typemap(in) alaqil_INTRUSIVE_PTR_QNAMESPACE::intrusive_ptr< CONST TYPE > & ($*1_ltype tempnull, $*1_ltype temp, alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > * smartarg) %{
  // intrusive_ptr by reference
  if ( $input ) {
    smartarg = *(alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE >**)&$input;
    temp = alaqil_INTRUSIVE_PTR_QNAMESPACE::intrusive_ptr< CONST TYPE >(smartarg->get(), true);
    $1 = &temp;
  } else {
    $1 = &tempnull;
  }
%}
%typemap(memberin) alaqil_INTRUSIVE_PTR_QNAMESPACE::intrusive_ptr< CONST TYPE > & %{
  delete &($1);
  if ($self) {
    alaqil_INTRUSIVE_PTR_QNAMESPACE::intrusive_ptr< CONST TYPE > * temp = new alaqil_INTRUSIVE_PTR_QNAMESPACE::intrusive_ptr< CONST TYPE >(*$input);
    $1 = *temp;
  }
%}
%typemap(out, fragment="alaqil_intrusive_deleter") alaqil_INTRUSIVE_PTR_QNAMESPACE::intrusive_ptr< CONST TYPE > & %{
  if (*$1) {
    intrusive_ptr_add_ref($1->get());
    *(alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > **)&$result = new alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE >($1->get(), alaqil_intrusive_deleter< CONST TYPE >());
  } else {
    *(alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > **)&$result = 0;
  }
%}

%typemap(in) alaqil_INTRUSIVE_PTR_QNAMESPACE::intrusive_ptr< CONST TYPE > * ($*1_ltype tempnull, $*1_ltype temp, alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > * smartarg) %{
  // intrusive_ptr by pointer
  if ( $input ) {
    smartarg = *(alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE >**)&$input;
    temp = alaqil_INTRUSIVE_PTR_QNAMESPACE::intrusive_ptr< CONST TYPE >(smartarg->get(), true);
    $1 = &temp;
  } else {
    $1 = &tempnull;
  }
%}
%typemap(memberin) alaqil_INTRUSIVE_PTR_QNAMESPACE::intrusive_ptr< CONST TYPE > * %{
  delete $1;
  if ($self) $1 = new alaqil_INTRUSIVE_PTR_QNAMESPACE::intrusive_ptr< CONST TYPE >(*$input);
%}
%typemap(out, fragment="alaqil_intrusive_deleter") alaqil_INTRUSIVE_PTR_QNAMESPACE::intrusive_ptr< CONST TYPE > * %{
  if ($1 && *$1) {
    intrusive_ptr_add_ref($1->get());
    *(alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > **)&$result = new alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE >($1->get(), alaqil_intrusive_deleter< CONST TYPE >());
  } else {
    *(alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > **)&$result = 0;
  }
  if ($owner) delete $1;
%}

%typemap(in) alaqil_INTRUSIVE_PTR_QNAMESPACE::intrusive_ptr< CONST TYPE > *& (alaqil_INTRUSIVE_PTR_QNAMESPACE::intrusive_ptr< CONST TYPE > temp, $*1_ltype tempp = 0, alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > * smartarg) %{
  // intrusive_ptr by pointer reference
  smartarg = *(alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE >**)&$input;
  if ($input) {
    temp = alaqil_INTRUSIVE_PTR_QNAMESPACE::intrusive_ptr< CONST TYPE >(smartarg->get(), true);
  }
  tempp = &temp;
  $1 = &tempp;
%}
%typemap(memberin) alaqil_INTRUSIVE_PTR_QNAMESPACE::intrusive_ptr< CONST TYPE > *& %{
  if ($self) $1 = *$input;
%}
%typemap(out, fragment="alaqil_intrusive_deleter") alaqil_INTRUSIVE_PTR_QNAMESPACE::intrusive_ptr< CONST TYPE > *& %{
  if (*$1 && **$1) {
    intrusive_ptr_add_ref((*$1)->get());
    *(alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > **)&$result = new alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE >((*$1)->get(), alaqil_intrusive_deleter< CONST TYPE >());
  } else {
    *(alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > **)&$result = 0;
  }
%}

// various missing typemaps - If ever used (unlikely) ensure compilation error rather than runtime bug
%typemap(in) CONST TYPE[], CONST TYPE[ANY], CONST TYPE (CLASS::*) %{
#error "typemaps for $1_type not available"
%}
%typemap(out) CONST TYPE[], CONST TYPE[ANY], CONST TYPE (CLASS::*) %{
#error "typemaps for $1_type not available"
%}


%typemap (ctype)    alaqil_INTRUSIVE_PTR_QNAMESPACE::intrusive_ptr< CONST TYPE >,
                  alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE >,
                  alaqil_INTRUSIVE_PTR_QNAMESPACE::intrusive_ptr< CONST TYPE > &,
                  alaqil_INTRUSIVE_PTR_QNAMESPACE::intrusive_ptr< CONST TYPE > *,
                  alaqil_INTRUSIVE_PTR_QNAMESPACE::intrusive_ptr< CONST TYPE > *& "void *"
%typemap (imtype, out="global::System.IntPtr")  alaqil_INTRUSIVE_PTR_QNAMESPACE::intrusive_ptr< CONST TYPE >,
                  alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE >,
                  alaqil_INTRUSIVE_PTR_QNAMESPACE::intrusive_ptr< CONST TYPE > &,
                  alaqil_INTRUSIVE_PTR_QNAMESPACE::intrusive_ptr< CONST TYPE > *,
                  alaqil_INTRUSIVE_PTR_QNAMESPACE::intrusive_ptr< CONST TYPE > *& "global::System.Runtime.InteropServices.HandleRef"
%typemap (cstype) alaqil_INTRUSIVE_PTR_QNAMESPACE::intrusive_ptr< CONST TYPE >,
                  alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE >,
                  alaqil_INTRUSIVE_PTR_QNAMESPACE::intrusive_ptr< CONST TYPE > &,
                  alaqil_INTRUSIVE_PTR_QNAMESPACE::intrusive_ptr< CONST TYPE > *,
                  alaqil_INTRUSIVE_PTR_QNAMESPACE::intrusive_ptr< CONST TYPE > *& "$typemap(cstype, TYPE)"
%typemap(csin) alaqil_INTRUSIVE_PTR_QNAMESPACE::intrusive_ptr< CONST TYPE >,
                 alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE >,
                 alaqil_INTRUSIVE_PTR_QNAMESPACE::intrusive_ptr< CONST TYPE > &,
                 alaqil_INTRUSIVE_PTR_QNAMESPACE::intrusive_ptr< CONST TYPE > *,
                 alaqil_INTRUSIVE_PTR_QNAMESPACE::intrusive_ptr< CONST TYPE > *& "$typemap(cstype, TYPE).getCPtr($csinput)"

%typemap(csout, excode=alaqilEXCODE) alaqil_INTRUSIVE_PTR_QNAMESPACE::intrusive_ptr< CONST TYPE > {
    global::System.IntPtr cPtr = $imcall;
    $typemap(cstype, TYPE) ret = (cPtr == global::System.IntPtr.Zero) ? null : new $typemap(cstype, TYPE)(cPtr, true);$excode
    return ret;
  }
%typemap(csout, excode=alaqilEXCODE) alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > {
    global::System.IntPtr cPtr = $imcall;
    $typemap(cstype, TYPE) ret = (cPtr == global::System.IntPtr.Zero) ? null : new $typemap(cstype, TYPE)(cPtr, true);$excode
    return ret;
  }
%typemap(csout, excode=alaqilEXCODE) alaqil_INTRUSIVE_PTR_QNAMESPACE::intrusive_ptr< CONST TYPE > & {
    global::System.IntPtr cPtr = $imcall;
    $typemap(cstype, TYPE) ret = (cPtr == global::System.IntPtr.Zero) ? null : new $typemap(cstype, TYPE)(cPtr, true);$excode
    return ret;
  }
%typemap(csout, excode=alaqilEXCODE) alaqil_INTRUSIVE_PTR_QNAMESPACE::intrusive_ptr< CONST TYPE > * {
    global::System.IntPtr cPtr = $imcall;
    $typemap(cstype, TYPE) ret = (cPtr == global::System.IntPtr.Zero) ? null : new $typemap(cstype, TYPE)(cPtr, true);$excode
    return ret;
  }
%typemap(csout, excode=alaqilEXCODE) alaqil_INTRUSIVE_PTR_QNAMESPACE::intrusive_ptr< CONST TYPE > *& {
    global::System.IntPtr cPtr = $imcall;
    $typemap(cstype, TYPE) ret = (cPtr == global::System.IntPtr.Zero) ? null : new $typemap(cstype, TYPE)(cPtr, true);$excode
    return ret;
  }
%typemap(csvarout, excode=alaqilEXCODE2) alaqil_INTRUSIVE_PTR_QNAMESPACE::intrusive_ptr< CONST TYPE > %{
    get {
      $typemap(cstype, TYPE) ret = new $typemap(cstype, TYPE)($imcall, true);$excode
      return ret;
    } %}
%typemap(csvarout, excode=alaqilEXCODE2) alaqil_INTRUSIVE_PTR_QNAMESPACE::intrusive_ptr< CONST TYPE >& %{
    get {
      $typemap(cstype, TYPE) ret = new $typemap(cstype, TYPE)($imcall, true);$excode
      return ret;
    } %}
%typemap(csvarout, excode=alaqilEXCODE2) alaqil_INTRUSIVE_PTR_QNAMESPACE::intrusive_ptr< CONST TYPE >* %{
    get {
      $typemap(cstype, TYPE) ret = new $typemap(cstype, TYPE)($imcall, true);$excode
      return ret;
    } %}


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

// Base proxy classes
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

// CONST version needed ???? also for C#
%typemap(imtype, nopgcpp="1") alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< TYPE > alaqilSharedPtrUpcast "global::System.Runtime.InteropServices.HandleRef"
%typemap(imtype, nopgcpp="1") alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > alaqilSharedPtrUpcast "global::System.Runtime.InteropServices.HandleRef"


%template() alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE >;
%template() alaqil_INTRUSIVE_PTR_QNAMESPACE::intrusive_ptr< CONST TYPE >;
%enddef


/////////////////////////////////////////////////////////////////////


%include <shared_ptr.i>

%define alaqil_INTRUSIVE_PTR_TYPEMAPS_NO_WRAP_IMPLEMENTATION(PTRCTOR_VISIBILITY, CPTR_VISIBILITY, CONST, TYPE...)

%naturalvar TYPE;
%naturalvar alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE >;

// destructor mods
%feature("unref") TYPE "(void)arg1; delete smartarg1;"


// plain value
%typemap(in, canthrow=1) CONST TYPE ($&1_type argp = 0) %{
  argp = (*(alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > **)&$input) ? (*(alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > **)&$input)->get() : 0;
  if (!argp) {
    alaqil_CSharpSetPendingExceptionArgument(alaqil_CSharpArgumentNullException, "Attempt to dereference null $1_type", 0);
    return $null;
  }
  $1 = *argp; %}
%typemap(out) CONST TYPE
%{ *(alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > **)&$result = new alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE >(new $1_ltype(($1_ltype &)$1)); %}

// plain pointer
%typemap(in) CONST TYPE * (alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > *smartarg = 0) %{
  smartarg = *(alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > **)&$input;
  $1 = (TYPE *)(smartarg ? smartarg->get() : 0); %}
%typemap(out, fragment="alaqil_null_deleter") CONST TYPE * %{
  *(alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > **)&$result = $1 ? new alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE >($1 alaqil_NO_NULL_DELETER_$owner) : 0;
%}

// plain reference
%typemap(in, canthrow=1) CONST TYPE & %{
  $1 = ($1_ltype)((*(alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > **)&$input) ? (*(alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > **)&$input)->get() : 0);
  if (!$1) {
    alaqil_CSharpSetPendingExceptionArgument(alaqil_CSharpArgumentNullException, "$1_type reference is null", 0);
    return $null;
  } %}
%typemap(out, fragment="alaqil_null_deleter") CONST TYPE &
%{ *(alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > **)&$result = new alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE >($1 alaqil_NO_NULL_DELETER_$owner); %}

// plain pointer by reference
%typemap(in) TYPE *CONST& ($*1_ltype temp = 0)
%{ temp = ($*1_ltype)((*(alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > **)&$input) ? (*(alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > **)&$input)->get() : 0);
   $1 = &temp; %}
%typemap(out, fragment="alaqil_null_deleter") TYPE *CONST&
%{ *(alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > **)&$result = new alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE >(*$1 alaqil_NO_NULL_DELETER_$owner); %}

%typemap(in) alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > alaqilSharedPtrUpcast ($&1_type smartarg) %{
  // shared_ptr by value
  smartarg = *($&1_ltype*)&$input;
  if (smartarg) $1 = *smartarg;
%}
%typemap(out) alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > ANY_TYPE_alaqilSharedPtrUpcast %{
  *($&1_ltype*)&$result = $1 ? new $1_ltype($1) : 0;
%}

// various missing typemaps - If ever used (unlikely) ensure compilation error rather than runtime bug
%typemap(in) CONST TYPE[], CONST TYPE[ANY], CONST TYPE (CLASS::*) %{
#error "typemaps for $1_type not available"
%}
%typemap(out) CONST TYPE[], CONST TYPE[ANY], CONST TYPE (CLASS::*) %{
#error "typemaps for $1_type not available"
%}


%typemap (ctype)    alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > "void *"
%typemap (imtype)  alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > "void *"
%typemap (cstype) alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > "$typemap(cstype, TYPE)"
%typemap (csin) alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > "$typemap(cstype, TYPE).getCPtr($csinput)"
%typemap(csout, excode=alaqilEXCODE) alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > {
    global::System.IntPtr cPtr = $imcall;
    return (cPtr == global::System.IntPtr.Zero) ? null : new $typemap(cstype, TYPE)(cPtr, true);
  }

%typemap(csout, excode=alaqilEXCODE) CONST TYPE {
    return new $typemap(cstype, TYPE)($imcall, true);
  }
%typemap(csout, excode=alaqilEXCODE) CONST TYPE & {
    return new $typemap(cstype, TYPE)($imcall, true);
  }
%typemap(csout, excode=alaqilEXCODE) CONST TYPE * {
    global::System.IntPtr cPtr = $imcall;
    return (cPtr == global::System.IntPtr.Zero) ? null : new $typemap(cstype, TYPE)(cPtr, true);
  }
%typemap(csout, excode=alaqilEXCODE) TYPE *CONST& {
    global::System.IntPtr cPtr = $imcall;
    return (cPtr == global::System.IntPtr.Zero) ? null : new $typemap(cstype, TYPE)(cPtr, true);
  }

// Base proxy classes
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


// CONST version needed ???? also for C#
%typemap(imtype, nopgcpp="1") alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< TYPE > alaqilSharedPtrUpcast "global::System.Runtime.InteropServices.HandleRef"
%typemap(imtype, nopgcpp="1") alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > alaqilSharedPtrUpcast "global::System.Runtime.InteropServices.HandleRef"

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
