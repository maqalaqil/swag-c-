/* ------------------------------------------------------------
 *  utility methods for char strings
 * ------------------------------------------------------------ */
%fragment("alaqil_AsCharPtrAndSize","header",fragment="alaqil_pchar_descriptor") {
alaqilINTERN int
alaqil_JSC_AsCharPtrAndSize(JSContextRef context, JSValueRef valRef, char** cptr, size_t* psize, int *alloc)
{
  if(JSValueIsString(context, valRef)) {
    JSStringRef js_str = JSValueToStringCopy(context, valRef, NULL);
    size_t len = JSStringGetMaximumUTF8CStringSize(js_str);
    char* cstr = (char*) %new_array(len, char);
    /* JSStringGetUTF8CString returns the length including 0-terminator */
    len = JSStringGetUTF8CString(js_str, cstr, len);

    if(alloc) *alloc = alaqil_NEWOBJ;
    if(psize) *psize = len;
    if(cptr) *cptr = cstr;

    return alaqil_OK;
  } else {
    if(JSValueIsObject(context, valRef)) {
      JSObjectRef obj = JSValueToObject(context, valRef, NULL);
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
alaqilINTERNINLINE JSValueRef
alaqil_JSC_FromCharPtrAndSize(JSContextRef context, const char* carray, size_t size)
{
  if (carray) {
    if (size > INT_MAX) {
      // TODO: handle extra long strings
      //alaqil_type_info* pchar_descriptor = alaqil_pchar_descriptor();
      //return pchar_descriptor ?
      //  alaqil_InternalNewPointerObj(%const_cast(carray,char *), pchar_descriptor, 0) : alaqil_Py_Void();
      return JSValueMakeUndefined(context);
    } else {
      JSStringRef jsstring;
      JSValueRef result;
      if(size < 2) {
        char c[2];
        int i;
        for(i=0;i<size;++i) {
          c[i] = carray[i];
        }
        c[size] = 0;
        jsstring = JSStringCreateWithUTF8CString(c);
      } else {
        jsstring = JSStringCreateWithUTF8CString(carray);
      }
      result = JSValueMakeString(context, jsstring);
      JSStringRelease(jsstring);
      return result;
    }
  } else {
    return JSValueMakeUndefined(context);
  }
}
}

%define %_typemap2_string(StringCode, CharCode,
			 Char, CharName,
			 alaqil_AsCharPtrAndSize,
			 alaqil_FromCharPtrAndSize,
			 alaqil_CharPtrLen,
       alaqil_CharBufLen,
			 alaqil_NewCopyCharArray,
			 alaqil_DeleteCharArray,
			 FragLimits, CHAR_MIN, CHAR_MAX)

%fragment("alaqil_From"#CharName"Ptr","header",fragment=#alaqil_FromCharPtrAndSize) {
alaqilINTERNINLINE alaqil_Object
alaqil_JSC_From##CharName##Ptr(JSContextRef context, const Char *cptr)
{
  return alaqil_JSC_FromCharPtrAndSize(context, cptr, (cptr ? alaqil_CharPtrLen(cptr) : 0));
}
}

%fragment("alaqil_From"#CharName"Array","header",fragment=#alaqil_FromCharPtrAndSize) {
alaqilINTERNINLINE alaqil_Object
alaqil_JSC_From##CharName##Array(JSContextRef context, const Char *cptr, size_t size)
{
  return alaqil_JSC_FromCharPtrAndSize(context, cptr, size);
}
}

%fragment("alaqil_As" #CharName "Ptr","header",fragment=#alaqil_AsCharPtrAndSize) {
%define_as(alaqil_As##CharName##Ptr(obj, val, alloc), alaqil_JSC_AsCharPtrAndSize(context, obj, val, NULL, alloc))
}

%fragment("alaqil_As" #CharName "Array","header",fragment=#alaqil_AsCharPtrAndSize) {
alaqilINTERN int
alaqil_JSC_As##CharName##Array(JSContextRef context, alaqil_Object obj, Char *val, size_t size)
{
  Char* cptr = 0; size_t csize = 0; int alloc = alaqil_OLDOBJ;
  int res = alaqil_JSC_AsCharPtrAndSize(context, obj, &cptr, &csize, &alloc);
  if (alaqil_IsOK(res)) {
    if ((csize == size + 1) && cptr && !(cptr[csize-1])) --csize;
    if (csize <= size) {
      if (val) {
        if (csize) memcpy(val, cptr, csize*sizeof(Char));
        if (csize < size) memset(val + csize, 0, (size - csize)*sizeof(Char));
      }
      if (alloc == alaqil_NEWOBJ) {
        alaqil_DeleteCharArray(cptr);
        res = alaqil_DelNewMask(res);
      }
      return res;
    }
    if (alloc == alaqil_NEWOBJ) alaqil_DeleteCharArray(cptr);
  }
  return alaqil_TypeError;
}

#define alaqil_As##CharName##Array(obj, val, size) alaqil_JSC_As##CharName##Array(context, obj, val, size)
}

/* Char */

%fragment(alaqil_From_frag(Char),"header",fragment=#alaqil_FromCharPtrAndSize) {
alaqilINTERNINLINE alaqil_Object
alaqil_From_dec(Char)(Char c)
{
  return alaqil_JSC_FromCharPtrAndSize(context, &c,1);
}
}

%fragment(alaqil_AsVal_frag(Char),"header",
          fragment="alaqil_As"#CharName"Array",
          fragment=FragLimits,
          fragment=alaqil_AsVal_frag(long)) {
alaqilINTERN int
alaqil_AsVal_dec(Char)(alaqil_Object obj, Char *val)
{
  int res = alaqil_As##CharName##Array(obj, val, 1);
  if (!alaqil_IsOK(res)) {
    long v;
    res = alaqil_AddCast(alaqil_AsVal(long)(obj, &v));
    if (alaqil_IsOK(res)) {
      if ((CHAR_MIN <= v) && (v <= CHAR_MAX)) {
        if (val) *val = %numeric_cast(v, Char);
      } else {
        res = alaqil_OverflowError;
      }
    }
  }
  return res;
}
}

%_typemap_string(StringCode,
                 Char,
                 alaqil_AsCharPtrAndSize,
                 alaqil_FromCharPtrAndSize,
                 alaqil_CharPtrLen,
                 alaqil_CharBufLen,
                 alaqil_As##CharName##Ptr,
                 alaqil_From##CharName##Ptr,
                 alaqil_As##CharName##Array,
                 alaqil_NewCopyCharArray,
                 alaqil_DeleteCharArray)

%enddef

%insert(runtime) %{
#define alaqil_AsCharPtrAndSize(val, cptr, psize, alloc)  alaqil_JSC_AsCharPtrAndSize(context, val, cptr, psize, alloc)
#define alaqil_FromCharPtrAndSize(cptr, size)  alaqil_JSC_FromCharPtrAndSize(context, cptr, size)
#define alaqil_FromCharPtr(cptr) alaqil_JSC_FromCharPtr(context, cptr)
%}
