/* -----------------------------------------------------------------------------
 * enumsimple.swg
 *
 * This file provides backwards compatible enum wrapping. alaqil versions 1.3.21
 * and earlier wrapped global enums with constant integers in the module class
 * or Constants interface. Enums declared within a C++ class were wrapped by
 * constant integers in the Java proxy class.
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

%typemap(javaclassmodifiers) enum alaqilTYPE ""
%typemap(javabase)           enum alaqilTYPE ""
%typemap(javacode)           enum alaqilTYPE ""
%typemap(javaimports)        enum alaqilTYPE ""
%typemap(javainterfaces)     enum alaqilTYPE ""
%typemap(javabody)           enum alaqilTYPE ""

%javaenum(simple);

