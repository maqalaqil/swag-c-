/* -----------------------------------------------------------------------------
 * enums.swg
 *
 * Include this file in order for C/C++ enums to be wrapped by proper Java enums.
 * Note that the JNI layer handles the enum as an int. The Java enum has extra
 * code generated to store the C++ int value. This is required for C++ enums that
 * specify a value for the enum item, as native Java enums do not support this.
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

%typemap(javaclassmodifiers) enum alaqilTYPE "public enum"
%typemap(javabase)           enum alaqilTYPE ""
%typemap(javacode)           enum alaqilTYPE ""
%typemap(javaimports)        enum alaqilTYPE ""
%typemap(javainterfaces)     enum alaqilTYPE ""

/*
 * alaqilNext static inner class used instead of a static int as static fields cannot be accessed from enum initialisers.
 * The alaqilToEnum method is used to find the Java enum from a C++ enum integer value. The default one here takes 
 * advantage of the fact that most enums do not have initial values specified, so the lookup is fast. If initial
 * values are specified then a lengthy linear search through all possible enums might occur. Specific typemaps could be
 * written to possibly optimise this lookup by taking advantage of characteristics peculiar to the targeted enum.
 */
%typemap(javabody) enum alaqilTYPE %{
  public final int alaqilValue() {
    return alaqilValue;
  }

  public static $javaclassname alaqilToEnum(int alaqilValue) {
    $javaclassname[] alaqilValues = $javaclassname.class.getEnumConstants();
    if (alaqilValue < alaqilValues.length && alaqilValue >= 0 && alaqilValues[alaqilValue].alaqilValue == alaqilValue)
      return alaqilValues[alaqilValue];
    for ($javaclassname alaqilEnum : alaqilValues)
      if (alaqilEnum.alaqilValue == alaqilValue)
        return alaqilEnum;
    throw new IllegalArgumentException("No enum " + $javaclassname.class + " with value " + alaqilValue);
  }

  @SuppressWarnings("unused")
  private $javaclassname() {
    this.alaqilValue = alaqilNext.next++;
  }

  @SuppressWarnings("unused")
  private $javaclassname(int alaqilValue) {
    this.alaqilValue = alaqilValue;
    alaqilNext.next = alaqilValue+1;
  }

  @SuppressWarnings("unused")
  private $javaclassname($javaclassname alaqilEnum) {
    this.alaqilValue = alaqilEnum.alaqilValue;
    alaqilNext.next = this.alaqilValue+1;
  }

  private final int alaqilValue;

  private static class alaqilNext {
    private static int next = 0;
  }
%}

%javaenum(proper);

