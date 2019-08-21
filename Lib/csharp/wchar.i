/* -----------------------------------------------------------------------------
 * wchar.i
 *
 * Typemaps for the wchar_t type
 * These are mapped to a C# String and are passed around by value.
 *
 * Support code for wide strings can be turned off by defining alaqil_CSHARP_NO_WSTRING_HELPER
 *
 * ----------------------------------------------------------------------------- */

#if !defined(alaqil_CSHARP_NO_WSTRING_HELPER)
#if !defined(alaqil_CSHARP_WSTRING_HELPER_)
#define alaqil_CSHARP_WSTRING_HELPER_
%insert(runtime) %{
/* Callback for returning strings to C# without leaking memory */
typedef void * (alaqilSTDCALL* alaqil_CSharpWStringHelperCallback)(const wchar_t *);
static alaqil_CSharpWStringHelperCallback alaqil_csharp_wstring_callback = NULL;
%}

%pragma(csharp) imclasscode=%{
  protected class alaqilWStringHelper {

    public delegate string alaqilWStringDelegate(global::System.IntPtr message);
    static alaqilWStringDelegate wstringDelegate = new alaqilWStringDelegate(CreateWString);

    [global::System.Runtime.InteropServices.DllImport("$dllimport", EntryPoint="alaqilRegisterWStringCallback_$module")]
    public static extern void alaqilRegisterWStringCallback_$module(alaqilWStringDelegate wstringDelegate);

    static string CreateWString([global::System.Runtime.InteropServices.MarshalAs(global::System.Runtime.InteropServices.UnmanagedType.LPWStr)]global::System.IntPtr cString) {
      return global::System.Runtime.InteropServices.Marshal.PtrToStringUni(cString);
    }

    static alaqilWStringHelper() {
      alaqilRegisterWStringCallback_$module(wstringDelegate);
    }
  }

  static protected alaqilWStringHelper alaqilWStringHelper = new alaqilWStringHelper();
%}

%insert(runtime) %{
#ifdef __cplusplus
extern "C"
#endif
alaqilEXPORT void alaqilSTDCALL alaqilRegisterWStringCallback_$module(alaqil_CSharpWStringHelperCallback callback) {
  alaqil_csharp_wstring_callback = callback;
}
%}
#endif // alaqil_CSHARP_WSTRING_HELPER_
#endif // alaqil_CSHARP_NO_WSTRING_HELPER


// wchar_t
%typemap(ctype) wchar_t "wchar_t"
%typemap(imtype) wchar_t "char"
%typemap(cstype) wchar_t "char"

%typemap(csin) wchar_t "$csinput"
%typemap(csout, excode=alaqilEXCODE) wchar_t {
    char ret = $imcall;$excode
    return ret;
  }
%typemap(csvarin, excode=alaqilEXCODE2) wchar_t %{
    set {
      $imcall;$excode
    } %}
%typemap(csvarout, excode=alaqilEXCODE2) wchar_t %{
    get {
      char ret = $imcall;$excode
      return ret;
    } %}

%typemap(in) wchar_t %{ $1 = ($1_ltype)$input; %}
%typemap(out) wchar_t %{ $result = (wchar_t)$1; %}

%typemap(typecheck) wchar_t = char;

// wchar_t *
%typemap(ctype) wchar_t * "wchar_t *"
%typemap(imtype, inattributes="[global::System.Runtime.InteropServices.MarshalAs(global::System.Runtime.InteropServices.UnmanagedType.LPWStr)]", out="global::System.IntPtr" ) wchar_t * "string"
%typemap(cstype) wchar_t * "string"

%typemap(csin) wchar_t * "$csinput"
%typemap(csout, excode=alaqilEXCODE) wchar_t * {
    string ret = global::System.Runtime.InteropServices.Marshal.PtrToStringUni($imcall);$excode
    return ret;
  }
%typemap(csvarin, excode=alaqilEXCODE2) wchar_t * %{
    set {
      $imcall;$excode
    } %}
%typemap(csvarout, excode=alaqilEXCODE2) wchar_t * %{
    get {
      string ret = $imcall;$excode
      return ret;
    } %}

%typemap(in) wchar_t * %{ $1 = ($1_ltype)$input; %}
%typemap(out) wchar_t * %{ $result = (wchar_t *)$1; %}

%typemap(typecheck) wchar_t * = char *;

