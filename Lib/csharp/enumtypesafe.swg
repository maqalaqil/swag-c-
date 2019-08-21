/* -----------------------------------------------------------------------------
 * enumtypesafe.swg
 *
 * Include this file in order for C/C++ enums to be wrapped by the so called
 * typesafe enum pattern. Each enum has an equivalent C# class named after the
 * enum and each enum item is a static instance of this class.
 * ----------------------------------------------------------------------------- */

// const enum alaqilTYPE & typemaps
%typemap(ctype) const enum alaqilTYPE & "int"
%typemap(imtype) const enum alaqilTYPE & "int"
%typemap(cstype) const enum alaqilTYPE & "$*csclassname"

%typemap(in) const enum alaqilTYPE & ($*1_ltype temp)
%{ temp = ($*1_ltype)$input; 
   $1 = &temp; %}
%typemap(out) const enum alaqilTYPE & %{ $result = (int)*$1; %}

%typemap(directorout,warning=alaqilWARN_TYPEMAP_THREAD_UNSAFE_MSG) const enum alaqilTYPE &
%{ static $*1_ltype temp = ($*1_ltype)$input; 
   $result = &temp; %}
%typemap(directorin) const enum alaqilTYPE & "$input = (int)$1;"
%typemap(csdirectorin) const enum alaqilTYPE & "$*csclassname.alaqilToEnum($iminput)"
%typemap(csdirectorout) const enum alaqilTYPE & "$cscall.alaqilValue"

%typecheck(alaqil_TYPECHECK_POINTER) const enum alaqilTYPE & ""

%typemap(throws, canthrow=1) const enum alaqilTYPE &
%{ (void)$1;
   alaqil_CSharpSetPendingException(alaqil_CSharpApplicationException, "C++ $1_type exception thrown");
   return $null; %}

%typemap(csin) const enum alaqilTYPE & "$csinput.alaqilValue"
%typemap(csout, excode=alaqilEXCODE) const enum alaqilTYPE & {
    $*csclassname ret = $*csclassname.alaqilToEnum($imcall);$excode
    return ret;
  }

%typemap(csvarout, excode=alaqilEXCODE2) const enum alaqilTYPE & %{
    get {
      $*csclassname ret = $*csclassname.alaqilToEnum($imcall);$excode
      return ret;
    } %}


// enum alaqilTYPE typemaps
%typemap(ctype) enum alaqilTYPE "int"
%typemap(imtype) enum alaqilTYPE "int"
%typemap(cstype) enum alaqilTYPE "$csclassname"

%typemap(in) enum alaqilTYPE %{ $1 = ($1_ltype)$input; %}
%typemap(out) enum alaqilTYPE %{ $result = (int)$1; %}

%typemap(directorout) enum alaqilTYPE  %{ $result = ($1_ltype)$input; %}
%typemap(directorin) enum alaqilTYPE "$input = (int)$1;"
%typemap(csdirectorin) enum alaqilTYPE "$csclassname.alaqilToEnum($iminput)"
%typemap(csdirectorout) enum alaqilTYPE "$cscall.alaqilValue"

%typecheck(alaqil_TYPECHECK_POINTER) enum alaqilTYPE ""

%typemap(throws, canthrow=1) enum alaqilTYPE
%{ (void)$1;
   alaqil_CSharpSetPendingException(alaqil_CSharpApplicationException, "C++ $1_type exception thrown");
   return $null; %}

%typemap(csin) enum alaqilTYPE "$csinput.alaqilValue"
%typemap(csout, excode=alaqilEXCODE) enum alaqilTYPE {
    $csclassname ret = $csclassname.alaqilToEnum($imcall);$excode
    return ret;
  }

%typemap(csvarout, excode=alaqilEXCODE2) enum alaqilTYPE %{
    get {
      $csclassname ret = $csclassname.alaqilToEnum($imcall);$excode
      return ret;
    } %}

%typemap(csbase)           enum alaqilTYPE ""
%typemap(csclassmodifiers) enum alaqilTYPE "public sealed class"
%typemap(cscode)           enum alaqilTYPE ""
%typemap(csimports)        enum alaqilTYPE ""
%typemap(csinterfaces)     enum alaqilTYPE ""

/*
 * The alaqilToEnum method is used to find the C# enum from a C++ enum integer value. The default one here takes 
 * advantage of the fact that most enums do not have initial values specified, so the lookup is fast. If initial
 * values are specified then a lengthy linear search through all possible enums might occur. Specific typemaps could be
 * written to possibly optimise this lookup by taking advantage of characteristics peculiar to the targeted enum.
 * The special variable, $enumvalues, is replaced with a comma separated list of all the enum values.
 */
%typemap(csbody) enum alaqilTYPE %{
  public readonly int alaqilValue;

  public static $csclassname alaqilToEnum(int alaqilValue) {
    if (alaqilValue < alaqilValues.Length && alaqilValue >= 0 && alaqilValues[alaqilValue].alaqilValue == alaqilValue)
      return alaqilValues[alaqilValue];
    for (int i = 0; i < alaqilValues.Length; i++)
      if (alaqilValues[i].alaqilValue == alaqilValue)
        return alaqilValues[i];
    throw new global::System.ArgumentOutOfRangeException("No enum $csclassname with value " + alaqilValue);
  }

  public override string ToString() {
    return alaqilName;
  }

  private $csclassname(string alaqilName) {
    this.alaqilName = alaqilName;
    this.alaqilValue = alaqilNext++;
  }

  private $csclassname(string alaqilName, int alaqilValue) {
    this.alaqilName = alaqilName;
    this.alaqilValue = alaqilValue;
    alaqilNext = alaqilValue+1;
  }

  private $csclassname(string alaqilName, $csclassname alaqilEnum) {
    this.alaqilName = alaqilName;
    this.alaqilValue = alaqilEnum.alaqilValue;
    alaqilNext = this.alaqilValue+1;
  }

  private static $csclassname[] alaqilValues = { $enumvalues };
  private static int alaqilNext = 0;
  private readonly string alaqilName;
%}

%csenum(typesafe);

