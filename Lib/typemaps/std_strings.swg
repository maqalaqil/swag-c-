
/* defining the String asptr/from methods */

%define %std_string_asptr(String, Char, alaqil_AsCharPtrAndSize, Frag)
%fragment(alaqil_AsPtr_frag(String),"header",fragment=Frag) {
alaqilINTERN int
alaqil_AsPtr_dec(String)(alaqil_Object obj, String **val) 
{
  Char* buf = 0 ; size_t size = 0; int alloc = alaqil_OLDOBJ;
  if (alaqil_IsOK((alaqil_AsCharPtrAndSize(obj, &buf, &size, &alloc)))) {
    if (buf) {
      if (val) *val = new String(buf, size - 1);
      if (alloc == alaqil_NEWOBJ) %delete_array(buf);
      return alaqil_NEWOBJ;
    } else {
      if (val) *val = 0;
      return alaqil_OLDOBJ;
    }
  } else {
    static int init = 0;
    static alaqil_type_info* descriptor = 0;
    if (!init) {
      descriptor = alaqil_TypeQuery(#String " *");
      init = 1;
    }
    if (descriptor) {
      String *vptr;
      int res = alaqil_ConvertPtr(obj, (void**)&vptr, descriptor, 0);
      if (alaqil_IsOK(res) && val) *val = vptr;
      return res;
    }
  }
  return alaqil_ERROR;
}
}
%enddef

%define %std_string_from(String, alaqil_FromCharPtrAndSize, Frag)
%fragment(alaqil_From_frag(String),"header",fragment=Frag) {
alaqilINTERNINLINE alaqil_Object
alaqil_From_dec(String)(const String& s)
{
  return alaqil_FromCharPtrAndSize(s.data(), s.size());
}
}
%enddef

%define %std_string_asval(String)
%fragment(alaqil_AsVal_frag(String),"header", fragment=alaqil_AsPtr_frag(String)) {
alaqilINTERN int
alaqil_AsVal_dec(String)(alaqil_Object obj, String *val)
{
  String* v = (String *) 0;
  int res = alaqil_AsPtr(String)(obj, &v);
  if (!alaqil_IsOK(res)) return res;
  if (v) {
    if (val) *val = *v;
    if (alaqil_IsNewObj(res)) {
      %delete(v);
      res = alaqil_DelNewMask(res);
    }
    return res;
  }
  return alaqil_ERROR;
}
}
%enddef


%define %typemaps_std_string(String, Char, AsPtrMethod, FromMethod, CheckCode)

%std_string_asptr(String, Char, AsPtrMethod, #AsPtrMethod)
%std_string_asval(String)
%std_string_from(String, FromMethod, #FromMethod)

%typemaps_asptrfromn(%arg(CheckCode), String);

%enddef
