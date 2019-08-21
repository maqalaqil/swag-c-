/* -----------------------------------------------------------------------------
 * arrays_javascript.i
 *
 * These typemaps give more natural support for arrays. The typemaps are not efficient
 * as there is a lot of copying of the array values whenever the array is passed to C/C++
 * from JavaScript and vice versa. The JavaScript array is expected to be the same size as the C array.
 * An exception is thrown if they are not.
 *
 * Example usage:
 * Wrapping:
 *
 *   %include <arrays_javascript.i>
 *   %inline %{
 *       extern int FiddleSticks[3];
 *   %}
 *
 * Use from JavaScript like this:
 *
 *   var fs = [10, 11, 12];
 *   example.FiddleSticks = fs;
 *   fs = example.FiddleSticks;
 * ----------------------------------------------------------------------------- */

%fragment("alaqil_JSCGetIntProperty",    "header", fragment=alaqil_AsVal_frag(int)) {}
%fragment("alaqil_JSCGetNumberProperty", "header", fragment=alaqil_AsVal_frag(double)) {}

%typemap(in, fragment="alaqil_JSCGetIntProperty") int[], int[ANY]
    (int length = 0, JSObjectRef array, JSValueRef jsvalue, int i = 0, int res = 0, $*1_ltype temp) {
  if (JSValueIsObject(context, $input))
  {
    // Convert into Array
    array = JSValueToObject(context, $input, NULL);

    length = $1_dim0;

    $1  = ($*1_ltype *)malloc(sizeof($*1_ltype) * length);

    // Get each element from array
    for (i = 0; i < length; i++)
    {
      jsvalue = JSObjectGetPropertyAtIndex(context, array, i, NULL);

      // Get primitive value from JSObject
      res = alaqil_AsVal(int)(jsvalue, &temp);
      if (!alaqil_IsOK(res))
      {
        alaqil_exception_fail(alaqil_ERROR, "Failed to convert $input to double");
      }
      arg$argnum[i] = temp;
    }

  }
  else
  {
    alaqil_exception_fail(alaqil_ERROR, "$input is not JSObjectRef");
  }
}

%typemap(freearg) int[], int[ANY] {
    free($1);
}

%typemap(out, fragment=alaqil_From_frag(int)) int[], int[ANY] (int length = 0, int i = 0)
{
  length = $1_dim0;
  JSValueRef values[length];

  for (i = 0; i < length; i++)
  {
    values[i] = alaqil_From(int)($1[i]);
  }

  $result = JSObjectMakeArray(context, length, values, NULL);
}

%typemap(in, fragment="alaqil_JSCGetNumberProperty") double[], double[ANY]
    (int length = 0, JSObjectRef array, JSValueRef jsvalue, int i = 0, int res = 0, $*1_ltype temp) {
  if (JSValueIsObject(context, $input))
  {
    // Convert into Array
    array = JSValueToObject(context, $input, NULL);

    length = $1_dim0;

    $1  = ($*1_ltype *)malloc(sizeof($*1_ltype) * length);

    // Get each element from array
    for (i = 0; i < length; i++)
    {
      jsvalue = JSObjectGetPropertyAtIndex(context, array, i, NULL);

      // Get primitive value from JSObject
      res = alaqil_AsVal(double)(jsvalue, &temp);
      if (!alaqil_IsOK(res))
      {
        alaqil_exception_fail(alaqil_ERROR, "Failed to convert $input to double");
      }
      arg$argnum[i] = temp;
    }

  }
  else
  {
    alaqil_exception_fail(alaqil_ERROR, "$input is not JSObjectRef");
  }
}

%typemap(freearg) double[], double[ANY] {
    free($1);
}

%typemap(out, fragment=alaqil_From_frag(double)) double[], double[ANY] (int length = 0, int i = 0)
{
  length = $1_dim0;
  JSValueRef values[length];

  for (i = 0; i < length; i++)
  {
    values[i] = alaqil_From(double)($1[i]);
  }

  $result = JSObjectMakeArray(context, length, values, NULL);
}
