%include <shared_ptr.i>

// Set SHARED_PTR_DISOWN to $disown if required, for example
// #define SHARED_PTR_DISOWN $disown
#if !defined(SHARED_PTR_DISOWN)
#define SHARED_PTR_DISOWN 0
#endif

%fragment("alaqil_null_deleter_python", "header", fragment="alaqil_null_deleter") {
%#define alaqil_NO_NULL_DELETER_alaqil_BUILTIN_INIT
}

// Language specific macro implementing all the customisations for handling the smart pointer
%define alaqil_SHARED_PTR_TYPEMAPS(CONST, TYPE...)

// %naturalvar is as documented for member variables
%naturalvar TYPE;
%naturalvar alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE >;

// destructor wrapper customisation
%feature("unref") TYPE
//"if (debug_shared) { cout << \"deleting use_count: \" << (*smartarg1).use_count() << \" [\" << (boost::get_deleter<alaqil_null_deleter>(*smartarg1) ? std::string(\"CANNOT BE DETERMINED SAFELY\") : ( (*smartarg1).get() ? (*smartarg1)->getValue() : std::string(\"NULL PTR\") )) << \"]\" << endl << flush; }\n"
                               "(void)arg1; delete smartarg1;"

// Typemap customisations...

// plain value
%typemap(in) CONST TYPE (void *argp, int res = 0) {
  int newmem = 0;
  res = alaqil_ConvertPtrAndOwn($input, &argp, $descriptor(alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< TYPE > *), %convertptr_flags, &newmem);
  if (!alaqil_IsOK(res)) {
    %argument_fail(res, "$type", $symname, $argnum);
  }
  if (!argp) {
    %argument_nullref("$type", $symname, $argnum);
  } else {
    $1 = *(%reinterpret_cast(argp, alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > *)->get());
    if (newmem & alaqil_CAST_NEW_MEMORY) delete %reinterpret_cast(argp, alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > *);
  }
}
%typemap(out) CONST TYPE {
  alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > *smartresult = new alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE >(new $1_ltype(($1_ltype &)$1));
  %set_output(alaqil_NewPointerObj(%as_voidptr(smartresult), $descriptor(alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< TYPE > *), alaqil_POINTER_OWN));
}

%typemap(varin) CONST TYPE {
  void *argp = 0;
  int newmem = 0;
  int res = alaqil_ConvertPtrAndOwn($input, &argp, $descriptor(alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< TYPE > *), %convertptr_flags, &newmem);
  if (!alaqil_IsOK(res)) {
    %variable_fail(res, "$type", "$name");
  }
  if (!argp) {
    %variable_nullref("$type", "$name");
  } else {
    $1 = *(%reinterpret_cast(argp, alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > *)->get());
    if (newmem & alaqil_CAST_NEW_MEMORY) delete %reinterpret_cast(argp, alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > *);
  }
}
%typemap(varout) CONST TYPE {
  alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > *smartresult = new alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE >(new $1_ltype(($1_ltype &)$1));
  %set_varoutput(alaqil_NewPointerObj(%as_voidptr(smartresult), $descriptor(alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< TYPE > *), alaqil_POINTER_OWN));
}

%typemap(directorin,noblock=1) CONST TYPE (alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > *smartarg = 0) %{
  smartarg = new alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE >(new $1_ltype(($1_ltype &)$1));
  $input = alaqil_NewPointerObj(%as_voidptr(smartarg), $descriptor(alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< TYPE > *), alaqil_POINTER_OWN | %newpointer_flags);
%}
%typemap(directorout,noblock=1) CONST TYPE (void *alaqil_argp, int alaqil_res = 0) {
  int newmem = 0;
  alaqil_res = alaqil_ConvertPtrAndOwn($input, &alaqil_argp, $descriptor(alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< TYPE > *), %convertptr_flags, &newmem);
  if (!alaqil_IsOK(alaqil_res)) {
    %dirout_fail(alaqil_res, "$type");
  }
  if (!alaqil_argp) {
    %dirout_nullref("$type");
  } else {
    $result = *(%reinterpret_cast(alaqil_argp, alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > *)->get());
    if (newmem & alaqil_CAST_NEW_MEMORY) delete %reinterpret_cast(alaqil_argp, alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > *);
  }
}

// plain pointer
// Note: $disown not implemented by default as it will lead to a memory leak of the shared_ptr instance
%typemap(in) CONST TYPE * (void  *argp = 0, int res = 0, alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > tempshared, alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > *smartarg = 0) {
  int newmem = 0;
  res = alaqil_ConvertPtrAndOwn($input, &argp, $descriptor(alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< TYPE > *), SHARED_PTR_DISOWN | %convertptr_flags, &newmem);
  if (!alaqil_IsOK(res)) {
    %argument_fail(res, "$type", $symname, $argnum);
  }
  if (newmem & alaqil_CAST_NEW_MEMORY) {
    tempshared = *%reinterpret_cast(argp, alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > *);
    delete %reinterpret_cast(argp, alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > *);
    $1 = %const_cast(tempshared.get(), $1_ltype);
  } else {
    smartarg = %reinterpret_cast(argp, alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > *);
    $1 = %const_cast((smartarg ? smartarg->get() : 0), $1_ltype);
  }
}

%typemap(out, fragment="alaqil_null_deleter_python") CONST TYPE * {
  alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > *smartresult = $1 ? new alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE >($1 alaqil_NO_NULL_DELETER_$owner) : 0;
  %set_output(alaqil_NewPointerObj(%as_voidptr(smartresult), $descriptor(alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< TYPE > *), $owner | alaqil_POINTER_OWN));
}

%typemap(varin) CONST TYPE * {
  void *argp = 0;
  int newmem = 0;
  int res = alaqil_ConvertPtrAndOwn($input, &argp, $descriptor(alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< TYPE > *), %convertptr_flags, &newmem);
  if (!alaqil_IsOK(res)) {
    %variable_fail(res, "$type", "$name");
  }
  alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > tempshared;
  alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > *smartarg = 0;
  if (newmem & alaqil_CAST_NEW_MEMORY) {
    tempshared = *%reinterpret_cast(argp, alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > *);
    delete %reinterpret_cast(argp, alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > *);
    $1 = %const_cast(tempshared.get(), $1_ltype);
  } else {
    smartarg = %reinterpret_cast(argp, alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > *);
    $1 = %const_cast((smartarg ? smartarg->get() : 0), $1_ltype);
  }
}
%typemap(varout, fragment="alaqil_null_deleter_python") CONST TYPE * {
  alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > *smartresult = $1 ? new alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE >($1 alaqil_NO_NULL_DELETER_0) : 0;
  %set_varoutput(alaqil_NewPointerObj(%as_voidptr(smartresult), $descriptor(alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< TYPE > *), alaqil_POINTER_OWN));
}

%typemap(directorin,noblock=1, fragment="alaqil_null_deleter_python") CONST TYPE * (alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > *smartarg = 0) %{
  smartarg = $1 ? new alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE >($1 alaqil_NO_NULL_DELETER_0) : 0;
  $input = alaqil_NewPointerObj(%as_voidptr(smartarg), $descriptor(alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< TYPE > *), alaqil_POINTER_OWN | %newpointer_flags);
%}
%typemap(directorout,noblock=1) CONST TYPE * %{
#error "directorout typemap for plain pointer not implemented"
%}

// plain reference
%typemap(in) CONST TYPE & (void  *argp = 0, int res = 0, alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > tempshared) {
  int newmem = 0;
  res = alaqil_ConvertPtrAndOwn($input, &argp, $descriptor(alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< TYPE > *), %convertptr_flags, &newmem);
  if (!alaqil_IsOK(res)) {
    %argument_fail(res, "$type", $symname, $argnum);
  }
  if (!argp) { %argument_nullref("$type", $symname, $argnum); }
  if (newmem & alaqil_CAST_NEW_MEMORY) {
    tempshared = *%reinterpret_cast(argp, alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > *);
    delete %reinterpret_cast(argp, alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > *);
    $1 = %const_cast(tempshared.get(), $1_ltype);
  } else {
    $1 = %const_cast(%reinterpret_cast(argp, alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > *)->get(), $1_ltype);
  }
}
%typemap(out, fragment="alaqil_null_deleter_python") CONST TYPE & {
  alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > *smartresult = new alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE >($1 alaqil_NO_NULL_DELETER_$owner);
  %set_output(alaqil_NewPointerObj(%as_voidptr(smartresult), $descriptor(alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< TYPE > *), alaqil_POINTER_OWN));
}

%typemap(varin) CONST TYPE & {
  void *argp = 0;
  int newmem = 0;
  int res = alaqil_ConvertPtrAndOwn($input, &argp, $descriptor(alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< TYPE > *), %convertptr_flags, &newmem);
  if (!alaqil_IsOK(res)) {
    %variable_fail(res, "$type", "$name");
  }
  alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > tempshared;
  if (!argp) {
    %variable_nullref("$type", "$name");
  }
  if (newmem & alaqil_CAST_NEW_MEMORY) {
    tempshared = *%reinterpret_cast(argp, alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > *);
    delete %reinterpret_cast(argp, alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > *);
    $1 = *%const_cast(tempshared.get(), $1_ltype);
  } else {
    $1 = *%const_cast(%reinterpret_cast(argp, alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > *)->get(), $1_ltype);
  }
}
%typemap(varout, fragment="alaqil_null_deleter_python") CONST TYPE & {
  alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > *smartresult = new alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE >(&$1 alaqil_NO_NULL_DELETER_0);
  %set_varoutput(alaqil_NewPointerObj(%as_voidptr(smartresult), $descriptor(alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< TYPE > *), alaqil_POINTER_OWN));
}

%typemap(directorin,noblock=1, fragment="alaqil_null_deleter_python") CONST TYPE & (alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > *smartarg = 0) %{
  smartarg = new alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE >(&$1 alaqil_NO_NULL_DELETER_0);
  $input = alaqil_NewPointerObj(%as_voidptr(smartarg), $descriptor(alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< TYPE > *), alaqil_POINTER_OWN | %newpointer_flags);
%}
%typemap(directorout,noblock=1) CONST TYPE & %{
#error "directorout typemap for plain reference not implemented"
%}

// plain pointer by reference
// Note: $disown not implemented by default as it will lead to a memory leak of the shared_ptr instance
%typemap(in) TYPE *CONST& (void  *argp = 0, int res = 0, $*1_ltype temp = 0, alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > tempshared) {
  int newmem = 0;
  res = alaqil_ConvertPtrAndOwn($input, &argp, $descriptor(alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< TYPE > *), SHARED_PTR_DISOWN | %convertptr_flags, &newmem);
  if (!alaqil_IsOK(res)) {
    %argument_fail(res, "$type", $symname, $argnum);
  }
  if (newmem & alaqil_CAST_NEW_MEMORY) {
    tempshared = *%reinterpret_cast(argp, alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > *);
    delete %reinterpret_cast(argp, alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > *);
    temp = %const_cast(tempshared.get(), $*1_ltype);
  } else {
    temp = %const_cast(%reinterpret_cast(argp, alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > *)->get(), $*1_ltype);
  }
  $1 = &temp;
}
%typemap(out, fragment="alaqil_null_deleter_python") TYPE *CONST& {
  alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > *smartresult = *$1 ? new alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE >(*$1 alaqil_NO_NULL_DELETER_$owner) : 0;
  %set_output(alaqil_NewPointerObj(%as_voidptr(smartresult), $descriptor(alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< TYPE > *), alaqil_POINTER_OWN));
}

%typemap(varin) TYPE *CONST& %{
#error "varin typemap not implemented"
%}
%typemap(varout) TYPE *CONST& %{
#error "varout typemap not implemented"
%}

%typemap(directorin,noblock=1, fragment="alaqil_null_deleter_python") TYPE *CONST& (alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > *smartarg = 0) %{
   smartarg = $1 ? new alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE >($1 alaqil_NO_NULL_DELETER_0) : 0;
  $input = alaqil_NewPointerObj(%as_voidptr(smartarg), $descriptor(alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< TYPE > *), alaqil_POINTER_OWN | %newpointer_flags);
%}
%typemap(directorout,noblock=1) TYPE *CONST& %{
#error "directorout typemap for plain pointer by reference not implemented"
%}

// shared_ptr by value
%typemap(in) alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > (void *argp, int res = 0) {
  int newmem = 0;
  res = alaqil_ConvertPtrAndOwn($input, &argp, $descriptor(alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< TYPE > *), %convertptr_flags, &newmem);
  if (!alaqil_IsOK(res)) {
    %argument_fail(res, "$type", $symname, $argnum);
  }
  if (argp) $1 = *(%reinterpret_cast(argp, $&ltype));
  if (newmem & alaqil_CAST_NEW_MEMORY) delete %reinterpret_cast(argp, $&ltype);
}
%typemap(out) alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > {
  alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > *smartresult = $1 ? new alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE >($1) : 0;
  %set_output(alaqil_NewPointerObj(%as_voidptr(smartresult), $descriptor(alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< TYPE > *), alaqil_POINTER_OWN));
}

%typemap(varin) alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > {
  int newmem = 0;
  void *argp = 0;
  int res = alaqil_ConvertPtrAndOwn($input, &argp, $descriptor(alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< TYPE > *), %convertptr_flags, &newmem);
  if (!alaqil_IsOK(res)) {
    %variable_fail(res, "$type", "$name");
  }
  $1 = argp ? *(%reinterpret_cast(argp, $&ltype)) : alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< TYPE >();
  if (newmem & alaqil_CAST_NEW_MEMORY) delete %reinterpret_cast(argp, $&ltype);
}
%typemap(varout) alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > {
  alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > *smartresult = $1 ? new alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE >($1) : 0;
  %set_varoutput(alaqil_NewPointerObj(%as_voidptr(smartresult), $descriptor(alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< TYPE > *), alaqil_POINTER_OWN));
}

%typemap(directorin,noblock=1) alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > (alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > *smartarg = 0) %{
  smartarg = $1 ? new alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE >($1) : 0;
  $input = alaqil_NewPointerObj(%as_voidptr(smartarg), $descriptor(alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< TYPE > *), alaqil_POINTER_OWN | %newpointer_flags);
%}
%typemap(directorout,noblock=1) alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > (void *alaqil_argp, int alaqil_res = 0) {
  int newmem = 0;
  alaqil_res = alaqil_ConvertPtrAndOwn($input, &alaqil_argp, $descriptor(alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< TYPE > *), %convertptr_flags, &newmem);
  if (!alaqil_IsOK(alaqil_res)) {
    %dirout_fail(alaqil_res, "$type");
  }
  if (alaqil_argp) {
    $result = *(%reinterpret_cast(alaqil_argp, $&ltype));
    if (newmem & alaqil_CAST_NEW_MEMORY) delete %reinterpret_cast(alaqil_argp, $&ltype);
  }
}

// shared_ptr by reference
%typemap(in) alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > & (void *argp, int res = 0, $*1_ltype tempshared) {
  int newmem = 0;
  res = alaqil_ConvertPtrAndOwn($input, &argp, $descriptor(alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< TYPE > *), %convertptr_flags, &newmem);
  if (!alaqil_IsOK(res)) {
    %argument_fail(res, "$type", $symname, $argnum);
  }
  if (newmem & alaqil_CAST_NEW_MEMORY) {
    if (argp) tempshared = *%reinterpret_cast(argp, $ltype);
    delete %reinterpret_cast(argp, $ltype);
    $1 = &tempshared;
  } else {
    $1 = (argp) ? %reinterpret_cast(argp, $ltype) : &tempshared;
  }
}
%typemap(out) alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > & {
  alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > *smartresult = *$1 ? new alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE >(*$1) : 0;
  %set_output(alaqil_NewPointerObj(%as_voidptr(smartresult), $descriptor(alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< TYPE > *), alaqil_POINTER_OWN));
}

%typemap(varin) alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > & %{
#error "varin typemap not implemented"
%}
%typemap(varout) alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > & %{
#error "varout typemap not implemented"
%}

%typemap(directorin,noblock=1) alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > & (alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > *smartarg = 0) %{
  smartarg = $1 ? new alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE >($1) : 0;
  $input = alaqil_NewPointerObj(%as_voidptr(smartarg), $descriptor(alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< TYPE > *), alaqil_POINTER_OWN | %newpointer_flags);
%}
%typemap(directorout,noblock=1) alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > & %{
#error "directorout typemap for shared_ptr ref not implemented"
%}

// shared_ptr by pointer
%typemap(in) alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > * (void *argp, int res = 0, $*1_ltype tempshared) {
  int newmem = 0;
  res = alaqil_ConvertPtrAndOwn($input, &argp, $descriptor(alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< TYPE > *), %convertptr_flags, &newmem);
  if (!alaqil_IsOK(res)) {
    %argument_fail(res, "$type", $symname, $argnum);
  }
  if (newmem & alaqil_CAST_NEW_MEMORY) {
    if (argp) tempshared = *%reinterpret_cast(argp, $ltype);
    delete %reinterpret_cast(argp, $ltype);
    $1 = &tempshared;
  } else {
    $1 = (argp) ? %reinterpret_cast(argp, $ltype) : &tempshared;
  }
}
%typemap(out) alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > * {
  alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > *smartresult = ($1 && *$1) ? new alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE >(*$1) : 0;
  %set_output(alaqil_NewPointerObj(%as_voidptr(smartresult), $descriptor(alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< TYPE > *), alaqil_POINTER_OWN));
  if ($owner) delete $1;
}

%typemap(varin) alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > * %{
#error "varin typemap not implemented"
%}
%typemap(varout) alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > * %{
#error "varout typemap not implemented"
%}

%typemap(directorin,noblock=1) alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > * (alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > *smartarg = 0) %{
  smartarg = ($1 && *$1) ? new alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE >(*$1) : 0;
  $input = alaqil_NewPointerObj(%as_voidptr(smartarg), $descriptor(alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< TYPE > *), alaqil_POINTER_OWN | %newpointer_flags);
%}
%typemap(directorout,noblock=1) alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > * %{
#error "directorout typemap for pointer to shared_ptr not implemented"
%}

// shared_ptr by pointer reference
%typemap(in) alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > *& (void *argp, int res = 0, alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > tempshared, $*1_ltype temp = 0) {
  int newmem = 0;
  res = alaqil_ConvertPtrAndOwn($input, &argp, $descriptor(alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< TYPE > *), %convertptr_flags, &newmem);
  if (!alaqil_IsOK(res)) {
    %argument_fail(res, "$type", $symname, $argnum);
  }
  if (argp) tempshared = *%reinterpret_cast(argp, $*ltype);
  if (newmem & alaqil_CAST_NEW_MEMORY) delete %reinterpret_cast(argp, $*ltype);
  temp = &tempshared;
  $1 = &temp;
}
%typemap(out) alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > *& {
  alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > *smartresult = (*$1 && **$1) ? new alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE >(**$1) : 0;
  %set_output(alaqil_NewPointerObj(%as_voidptr(smartresult), $descriptor(alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< TYPE > *), alaqil_POINTER_OWN));
}

%typemap(varin) alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > *& %{
#error "varin typemap not implemented"
%}
%typemap(varout) alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > *& %{
#error "varout typemap not implemented"
%}

%typemap(directorin,noblock=1) alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > *& (alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > *smartarg = 0) %{
  smartarg = ($1 && *$1) ? new alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE >(*$1) : 0;
  $input = alaqil_NewPointerObj(%as_voidptr(smartarg), $descriptor(alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< TYPE > *), alaqil_POINTER_OWN | %newpointer_flags);
%}
%typemap(directorout,noblock=1) alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > *& %{
#error "directorout typemap for pointer ref to shared_ptr not implemented"
%}

// Typecheck typemaps
// Note: alaqil_ConvertPtr with void ** parameter set to 0 instead of using alaqil_ConvertPtrAndOwn, so that the casting
// function is not called thereby avoiding a possible smart pointer copy constructor call when casting up the inheritance chain.
%typemap(typecheck, precedence=alaqil_TYPECHECK_POINTER, equivalent="TYPE *", noblock=1)
                      TYPE CONST,
                      TYPE CONST &,
                      TYPE CONST *,
                      TYPE *CONST&,
                      alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE >,
                      alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > &,
                      alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > *,
                      alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > *& {
  int res = alaqil_ConvertPtr($input, 0, $descriptor(alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< TYPE > *), 0);
  $1 = alaqil_CheckState(res);
}


// various missing typemaps - If ever used (unlikely) ensure compilation error rather than runtime bug
%typemap(in) CONST TYPE[], CONST TYPE[ANY], CONST TYPE (CLASS::*) %{
#error "typemaps for $1_type not available"
%}
%typemap(out) CONST TYPE[], CONST TYPE[ANY], CONST TYPE (CLASS::*) %{
#error "typemaps for $1_type not available"
%}

%typemap(doctype) alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE >,
                  alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > &,
                  alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > *,
                  alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > *&
  %{TYPE%}


%template() alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE >;


%enddef
