/* 
   adding backward compatibility macros
*/

#define alaqil_arg(x...)     %arg(x)
#define alaqil_Mangle(x...)  %mangle(x)

#define alaqil_As_frag(Type...)      %fragment_name(As, Type)
#define alaqil_As_name(Type...)      %symbol_name(As, Type) 
#define alaqil_As(Type...)     	   alaqil_As_name(Type) alaqil_AS_CALL_ARGS 

#define alaqil_Check_frag(Type...)   %fragment_name(Check, Type)
#define alaqil_Check_name(Type...)   %symbol_name(Check, Type) 
#define alaqil_Check(Type...)        alaqil_Check_name(Type) alaqil_AS_CALL_ARGS 

%define %ascheck_methods(Code, Type...)
%fragment(alaqil_As_frag(Type),"header", fragment=alaqil_AsVal_frag(Type)) {
alaqilINTERNINLINE Type
alaqil_As(Type)(PyObject* obj)
{
  Type v;
  int res = alaqil_AsVal(Type)(obj, &v);
  if (!alaqil_IsOK(res)) {
    /*
      this is needed to make valgrind/purify happier. 
     */
    memset((void*)&v, 0, sizeof(Type));
    alaqil_Error(res, "");
  }
  return v;
}
}

%fragment(alaqil_Check_frag(Type),"header",fragment=alaqil_AsVal_frag(Type)) {
alaqilINTERNINLINE int
alaqil_Check(Type)(PyObject* obj)
{
  int res = alaqil_AsVal(Type)(obj, (Type*)0);
  return alaqil_IsOK(res);
}
}
%enddef

%apply_checkctypes(%ascheck_methods)

