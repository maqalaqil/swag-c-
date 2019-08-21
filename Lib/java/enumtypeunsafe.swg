/* -----------------------------------------------------------------------------
 * enumtypeunsafe.swg
 *
 * Include this file in order for C/C++ enums to be wrapped by integers values.
 * Each enum has an equivalent class named after the enum and the enum items are
 * wrapped by constant integers within this class. The enum items are not
 * typesafe as they are all integers.
 * ----------------------------------------------------------------------------- */

// const enum alaqilTYPE & typemaps
%typemap(jni) const enum alaqilTYPE & "jint"
%typemap(jtype) const enum alaqilTYPE & "int"
%typemap(jstype) const enum alaqilTYPE & "int"

%typemap(in) const enum alaqilTYPE & ($*1_ltype temp)
%{ temp = ($*1_ltype)$input; 
   $1 = &temp; %}
%typemap(out) const enum alaqilTYPE &  %{ $result = (jint)*$1; %}

%typemap(directorout,warning=alaqilWARN_TYPEMAP_THREAD_UNSAFE_MSG) const enum alaqilTYPE &
%{ static $*1_ltype temp = ($*1_ltype)$input; 
   $result = &temp; %}
%typemap(directorin, descriptor="I") const enum alaqilTYPE & "$input = (jint)$1;"
%typemap(javadirectorin) const enum alaqilTYPE & "$jniinput"
%typemap(javadirectorout) const enum alaqilTYPE & "$javacall"

%typecheck(alaqil_TYPECHECK_INT32) const enum alaqilTYPE & ""

%typemap(throws) const enum alaqilTYPE &
%{ (void)$1;
   alaqil_JavaThrowException(jenv, alaqil_JavaRuntimeException, "C++ $1_type exception thrown"); %}

%typemap(javain) const enum alaqilTYPE & "$javainput"
%typemap(javaout) const enum alaqilTYPE & {
    return $jnicall;
  }


// enum alaqilTYPE typemaps
%typemap(jni) enum alaqilTYPE "jint"
%typemap(jtype) enum alaqilTYPE "int"
%typemap(jstype) enum alaqilTYPE "int"

%typemap(in) enum alaqilTYPE  %{ $1 = ($1_ltype)$input; %}
%typemap(out) enum alaqilTYPE  %{ $result = (jint)$1; %}

%typemap(directorout) enum alaqilTYPE  %{ $result = ($1_ltype)$input; %}
%typemap(directorin, descriptor="I") enum alaqilTYPE "$input = (jint) $1;"
%typemap(javadirectorin) enum alaqilTYPE "$jniinput"
%typemap(javadirectorout) enum alaqilTYPE "$javacall"

%typecheck(alaqil_TYPECHECK_INT32) enum alaqilTYPE ""

%typemap(throws) enum alaqilTYPE
%{ (void)$1;
   alaqil_JavaThrowException(jenv, alaqil_JavaRuntimeException, "C++ $1_type exception thrown"); %}

%typemap(javain) enum alaqilTYPE "$javainput"
%typemap(javaout) enum alaqilTYPE {
    return $jnicall;
  }

// '$static' will be replaced with either 'static' or nothing depending on whether the enum is an inner Java class or not
%typemap(javaclassmodifiers) enum alaqilTYPE "public final $static class"
%typemap(javabase)           enum alaqilTYPE ""
%typemap(javacode)           enum alaqilTYPE ""
%typemap(javaimports)        enum alaqilTYPE ""
%typemap(javainterfaces)     enum alaqilTYPE ""
%typemap(javabody)           enum alaqilTYPE ""

%javaenum(typeunsafe);

