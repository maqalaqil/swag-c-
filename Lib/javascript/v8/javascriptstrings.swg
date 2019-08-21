
/* ------------------------------------------------------------
 *  utility methods for char strings 
 * ------------------------------------------------------------ */
%fragment("alaqil_AsCharPtrAndSize", "header", fragment="alaqil_pchar_descriptor") {
alaqilINTERN int
alaqil_AsCharPtrAndSize(v8::Handle<v8::Value> valRef, char** cptr, size_t* psize, int *alloc)
{
  if(valRef->IsString()) {
    v8::Handle<v8::String> js_str = alaqilV8_TO_STRING(valRef);

    size_t len = alaqilV8_UTF8_LENGTH(js_str) + 1;
    char* cstr = new char[len];
    alaqilV8_WRITE_UTF8(js_str, cstr, len);
    
    if(alloc) *alloc = alaqil_NEWOBJ;
    if(psize) *psize = len;
    if(cptr) *cptr = cstr;
    
    return alaqil_OK;
  } else {
    if(valRef->IsObject()) {
      v8::Handle<v8::Object> obj = alaqilV8_TO_OBJECT(valRef);
      // try if the object is a wrapped char[]
      alaqil_type_info* pchar_descriptor = alaqil_pchar_descriptor();
      if (pchar_descriptor) {
        void* vptr = 0;
        if (alaqil_ConvertPtr(obj, &vptr, pchar_descriptor, 0) == alaqil_OK) {
          if (cptr) *cptr = (char *) vptr;
          if (psize) *psize = vptr ? (strlen((char *)vptr) + 1) : 0;
          if (alloc) *alloc = alaqil_OLDOBJ;
          return alaqil_OK;
        }
      }
      return alaqil_TypeError;
    } else {
      return alaqil_TypeError;
    }
  }
}
}

%fragment("alaqil_FromCharPtrAndSize","header",fragment="alaqil_pchar_descriptor") {
alaqilINTERNINLINE v8::Handle<v8::Value>
alaqil_FromCharPtrAndSize(const char* carray, size_t size)
{
  if (carray) {
    if (size > INT_MAX) {
      // TODO: handle extra long strings
      return alaqilV8_UNDEFINED();
    } else {
      v8::Handle<v8::String> js_str = alaqilV8_STRING_NEW2(carray, size);
      return js_str;
    }
  } else {
    return alaqilV8_UNDEFINED();
  }
}
}
