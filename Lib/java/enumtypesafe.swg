/* -----------------------------------------------------------------------------
 * enumtypesafe.swg
 *
 * Include this file in order for C/C++ enums to be wrapped by the so called
 * typesafe enum pattern. Each enum has an equivalent Java class named after the
 * enum and each enum item is a static instance of this class.
 * ----------------------------------------------------------------------------- */

// const enum alaqilTYPE & typemaps
%typemap(jni) const enum alaqilTYPE & "jint"
%typemap(jtype) const enum alaqilTYPE & "int"
%typemap(jstype) const enum alaqilTYPE & "$*javaclassname"

%typemap(in) const enum alaqilTYPE & ($*1_ltype temp)
%{ temp = ($*1_ltype)$input; 
   $1 = &temp; %}
%typemap(out) const enum alaqilTYPE &  %{ $result = (jint)*$1; %}

%typemap(directorout,warning=alaqilWARN_TYPEMAP_THREAD_UNSAFE_MSG) const enum alaqilTYPE &
%{ static $*1_ltype temp = ($*1_ltype)$input; 
   $result = &temp; %}
%typemap(directorin, descriptor="L$packagepath/$*javaclassname;") const enum alaqilTYPE & "$input = (jint)$1;"
%typemap(javadirectorin) const enum alaqilTYPE & "$*javaclassname.alaqilToEnum($jniinput)"
%typemap(javadirectorout) const enum alaqilTYPE & "($javacall).alaqilValue()"

%typecheck(alaqil_TYPECHECK_POINTER) const enum alaqilTYPE & ""

%typemap(throws) const enum alaqilTYPE &
%{ (void)$1;
   alaqil_JavaThrowException(jenv, alaqil_JavaRuntimeException, "C++ $1_type exception thrown"); %}

%typemap(javain) const enum alaqilTYPE & "$javainput.alaqilValue()"
%typemap(javaout) const enum alaqilTYPE & {
    return $*javaclassname.alaqilToEnum($jnicall);
  }

// enum alaqilTYPE typemaps
%typemap(jni) enum alaqilTYPE "jint"
%typemap(jtype) enum alaqilTYPE "int"
%typemap(jstype) enum alaqilTYPE "$javaclassname"

%typemap(in) enum alaqilTYPE  %{ $1 = ($1_ltype)$input; %}
%typemap(out) enum alaqilTYPE  %{ $result = (jint)$1; %}

%typemap(directorout) enum alaqilTYPE  %{ $result = ($1_ltype)$input; %}
%typemap(directorin, descriptor="L$packagepath/$javaclassname;") enum alaqilTYPE "$input = (jint) $1;"
%typemap(javadirectorin) enum alaqilTYPE "$javaclassname.alaqilToEnum($jniinput)"
%typemap(javadirectorout) enum alaqilTYPE "($javacall).alaqilValue()"

%typecheck(alaqil_TYPECHECK_POINTER) enum alaqilTYPE ""

%typemap(throws) enum alaqilTYPE
%{ (void)$1;
   alaqil_JavaThrowException(jenv, alaqil_JavaRuntimeException, "C++ $1_type exception thrown"); %}

%typemap(javain) enum alaqilTYPE "$javainput.alaqilValue()"
%typemap(javaout) enum alaqilTYPE {
    return $javaclassname.alaqilToEnum($jnicall);
  }

// '$static' will be replaced with either 'static' or nothing depending on whether the enum is an inner Java class or not
%typemap(javaclassmodifiers) enum alaqilTYPE "public final $static class"
%typemap(javabase)           enum alaqilTYPE ""
%typemap(javacode)           enum alaqilTYPE ""
%typemap(javaimports)        enum alaqilTYPE ""
%typemap(javainterfaces)     enum alaqilTYPE ""

/*
 * The alaqilToEnum method is used to find the Java enum from a C++ enum integer value. The default one here takes 
 * advantage of the fact that most enums do not have initial values specified, so the lookup is fast. If initial
 * values are specified then a lengthy linear search through all possible enums might occur. Specific typemaps could be
 * written to possibly optimise this lookup by taking advantage of characteristics peculiar to the targeted enum.
 * The special variable, $enumvalues, is replaced with a comma separated list of all the enum values.
 */
%typemap(javabody) enum alaqilTYPE %{
  public final int alaqilValue() {
    return alaqilValue;
  }

  public String toString() {
    return alaqilName;
  }

  public static $javaclassname alaqilToEnum(int alaqilValue) {
    if (alaqilValue < alaqilValues.length && alaqilValue >= 0 && alaqilValues[alaqilValue].alaqilValue == alaqilValue)
      return alaqilValues[alaqilValue];
    for (int i = 0; i < alaqilValues.length; i++)
      if (alaqilValues[i].alaqilValue == alaqilValue)
        return alaqilValues[i];
    throw new IllegalArgumentException("No enum " + $javaclassname.class + " with value " + alaqilValue);
  }

  private $javaclassname(String alaqilName) {
    this.alaqilName = alaqilName;
    this.alaqilValue = alaqilNext++;
  }

  private $javaclassname(String alaqilName, int alaqilValue) {
    this.alaqilName = alaqilName;
    this.alaqilValue = alaqilValue;
    alaqilNext = alaqilValue+1;
  }

  private $javaclassname(String alaqilName, $javaclassname alaqilEnum) {
    this.alaqilName = alaqilName;
    this.alaqilValue = alaqilEnum.alaqilValue;
    alaqilNext = this.alaqilValue+1;
  }

  private static $javaclassname[] alaqilValues = { $enumvalues };
  private static int alaqilNext = 0;
  private final int alaqilValue;
  private final String alaqilName;
%}

%javaenum(typesafe);

