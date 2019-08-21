/* ----------------------------------------------------------------------------
 *  Errors and exceptions
 *
 * ---------------------------------------------------------------------------*/

#define alaqil_Error(code, msg)     alaqil_JSC_exception(context, exception, code, msg)
#define alaqil_exception(code, msg) do { alaqil_JSC_exception(context, exception, code, msg); alaqil_fail; } while (0)
#define alaqil_fail                 goto fail

alaqilRUNTIME void alaqil_Javascript_Raise(JSContextRef context, JSValueRef *exception, const char* type) {
  JSStringRef message = JSStringCreateWithUTF8CString(type);
  JSValueRef error_arguments[1]; 
  JSObjectRef exception_object;
  JSValueRef exception_value;
  exception_value = JSValueMakeString(context, message);
  /* Converting the result to an object will let JavascriptCore add 
     "sourceURL" (file) and "line" (number) and "message" to the exception,
     instead of just returning a raw string. This is extremely important for debugging your errors.
     Using JSObjectMakeError is better than JSValueToObject because the latter only populates
     "sourceURL" and "line", but not "message" or any others I don't know about.
   */
  error_arguments[0] = exception_value;
  exception_object = JSObjectMakeError(context, 1, error_arguments, NULL);

  /* Return the exception_object */
  *exception = exception_object;

  JSStringRelease(message);
}

alaqilRUNTIME void alaqil_JSC_exception(JSContextRef context, JSValueRef *exception, int code, const char* msg) {
  alaqil_Javascript_Raise(context, exception, msg);
}

/* ----------------------------------------------------------------------------
 *  The parent class of all Proxies
 *
 * ---------------------------------------------------------------------------*/

typedef struct {
  bool alaqilCMemOwn;
  void *alaqilCObject;
  alaqil_type_info *info;
} alaqilPrivData;

alaqilRUNTIME JSValueRef _wrap_alaqilObject_disown(JSContextRef context, JSObjectRef function, JSObjectRef thisObject, size_t argc, const JSValueRef argv[], JSValueRef* exception)
{
  JSValueRef jsresult;

  JSObjectRef obj = JSValueToObject(context, thisObject, NULL);
  alaqilPrivData *cdata = (alaqilPrivData *) JSObjectGetPrivate(obj);

  cdata->alaqilCMemOwn = false;

  jsresult = JSValueMakeUndefined(context);
  return jsresult;
}

alaqilRUNTIME JSValueRef _wrap_alaqilObject_getCPtr(JSContextRef context, JSObjectRef function, JSObjectRef thisObject, size_t argc, const JSValueRef argv[], JSValueRef* exception)
{
  JSValueRef jsresult;
  long result;

  JSObjectRef obj = JSValueToObject(context, thisObject, NULL);
  alaqilPrivData *cdata = (alaqilPrivData*) JSObjectGetPrivate(obj);

  result = (long) cdata->alaqilCObject;
  jsresult = JSValueMakeNumber(context, result);

  return jsresult;
}

alaqilRUNTIME JSValueRef _wrap_alaqilObject_equals(JSContextRef context, JSObjectRef function, JSObjectRef thisObject, size_t argc, const JSValueRef argv[], JSValueRef* exception)
{
  JSValueRef jsresult;
  bool result;

  JSObjectRef obj = JSValueToObject(context, thisObject, NULL);
  alaqilPrivData *cdata = (alaqilPrivData*) JSObjectGetPrivate(obj);

  JSObjectRef obj2 = JSValueToObject(context, argv[0], NULL);
  alaqilPrivData *cdata2 = (alaqilPrivData*) JSObjectGetPrivate(obj2);

  result = (cdata->alaqilCObject == cdata2->alaqilCObject);
  jsresult = JSValueMakeBoolean(context, result);

  return jsresult;
}

alaqilRUNTIME JSStaticValue _alaqilObject_values[] = {
  {
    0, 0, 0, 0
  }
};

alaqilRUNTIME JSStaticFunction _alaqilObject_functions[] = {
  {
    "disown",_wrap_alaqilObject_disown, kJSPropertyAttributeNone
  },
  {
    "equals",_wrap_alaqilObject_equals, kJSPropertyAttributeNone
  },
  {
    "getCPtr",_wrap_alaqilObject_getCPtr, kJSPropertyAttributeNone
  },
  {
    0, 0, 0
  }
};

alaqilRUNTIME JSClassDefinition _alaqilObject_objectDefinition;

alaqilRUNTIME JSClassRef _alaqilObject_classRef;


alaqilRUNTIME int alaqil_JSC_ConvertInstancePtr(JSContextRef context, JSObjectRef objRef, void** ptr, alaqil_type_info *info, int flags) {
  alaqilPrivData *cdata;

  cdata = (alaqilPrivData *) JSObjectGetPrivate(objRef);
  if(cdata == NULL) {
    return alaqil_ERROR;
  }
  if(cdata->info != info) {
    bool type_valid = false;
    alaqil_cast_info *t = info->cast;
    while(t != NULL) {
      if(t->type == cdata->info) {
        type_valid = true;
        break;
      }
      t = t->next;
    }
    if(!type_valid) {
      return alaqil_TypeError;
    }
  }

  *ptr = cdata->alaqilCObject;

  if(flags & alaqil_POINTER_DISOWN) {
    cdata->alaqilCMemOwn = false;
  }

  return alaqil_OK;
}

alaqilRUNTIME int alaqil_JSC_ConvertPtr(JSContextRef context, JSValueRef valRef, void** ptr, alaqil_type_info *info, int flags) {
  JSObjectRef objRef;

  /* special case: JavaScript null => C NULL pointer */
  if(JSValueIsNull(context, valRef)) {
    *ptr=0;
    return (flags & alaqil_POINTER_NO_NULL) ? alaqil_NullReferenceError : alaqil_OK;
  }

  if(!JSValueIsObject(context, valRef)) {
    return alaqil_TypeError;
  }

  objRef = JSValueToObject(context, valRef, NULL);
  if(objRef == NULL) {
    return alaqil_ERROR;
  }

  return alaqil_JSC_ConvertInstancePtr(context, objRef, ptr, info, flags);
}

alaqilRUNTIME JSObjectRef alaqil_JSC_NewPointerObj(JSContextRef context, void *ptr, alaqil_type_info *info, int flags) {
  JSClassRef classRef;
  JSObjectRef result;
  alaqilPrivData *cdata;

  if (ptr == NULL) {
    // HACK: it is not possible to use JSValueToObject (causing seg-fault)
    // This static cast turned out to be a workaround
    // In future, we should change the interface of this method
    // to return JSValueRef instead of JSObjectRef.
    return (JSObjectRef) JSValueMakeNull(context);
  }

  if(info->clientdata == NULL) {
    classRef = _alaqilObject_classRef;
  } else {
    classRef = (JSClassRef) info->clientdata;
  }

  result = JSObjectMake(context, classRef, NULL);

  cdata = (alaqilPrivData*) malloc(sizeof(alaqilPrivData));
  cdata->alaqilCObject = ptr;
  cdata->alaqilCMemOwn = (flags & alaqil_POINTER_OWN) ? 1 : 0;
  cdata->info = info;

  JSObjectSetPrivate(result, cdata);

  return result;
}

#define alaqil_ConvertPtr(obj, ptr, info, flags)    alaqil_JSC_ConvertPtr(context, obj, ptr, info, flags)
#define alaqil_NewPointerObj(ptr, info, flags)      alaqil_JSC_NewPointerObj(context, ptr, info, flags)

#define alaqil_ConvertInstance(obj, pptr, type, flags)    alaqil_JSC_ConvertInstancePtr(context, obj, pptr, type, flags)
#define alaqil_NewInstanceObj(thisvalue, type, flags)     alaqil_JSC_NewPointerObj(context, thisvalue, type, flags)

#define alaqil_ConvertFunctionPtr(obj, pptr, type)        alaqil_JSC_ConvertPtr(context, obj, pptr, type, 0)
#define alaqil_NewFunctionPtrObj(ptr, type)               alaqil_JSC_NewPointerObj(context, ptr, type, 0)

/* ----------------------------------------------------------------------------
 *  A class for packed data
 *
 * ---------------------------------------------------------------------------*/

typedef struct {
  void *data;
  size_t size;
  alaqil_type_info *type;
} alaqilPackedData;

alaqilRUNTIME JSStaticValue _alaqilPackedData_values[] = {
  {
    0, 0, 0, 0
  }
};
alaqilRUNTIME JSStaticFunction _alaqilPackedData_functions[] = {
  {
    0, 0, 0
  }
};
alaqilRUNTIME JSClassDefinition _alaqilPackedData_objectDefinition;
alaqilRUNTIME JSClassRef _alaqilPackedData_classRef;

alaqilRUNTIMEINLINE
int alaqilJSCPacked_Check(JSContextRef context, JSValueRef valRef) {
  return JSValueIsObjectOfClass(context, valRef, _alaqilPackedData_classRef);
}

alaqilRUNTIME
alaqil_type_info* alaqilJSCPacked_UnpackData(JSContextRef context, JSValueRef valRef, void *ptr, size_t size) {
  if (alaqilJSCPacked_Check(context, valRef)) {
    JSObjectRef objRef = JSValueToObject(context, valRef, NULL);
    alaqilPackedData *sobj = (alaqilPackedData *) JSObjectGetPrivate(objRef);
    if (sobj->size != size) return 0;
    memcpy(ptr, sobj->data, size);
    return sobj->type;
  } else {
    return 0;
  }
}

alaqilRUNTIME
int alaqil_JSC_ConvertPacked(JSContextRef context, JSValueRef valRef, void *ptr, size_t sz, alaqil_type_info *ty) {
  alaqil_type_info *to = alaqilJSCPacked_UnpackData(context, valRef, ptr, sz);
  if (!to) return alaqil_ERROR;
  if (ty) {
    if (to != ty) {
      /* check type cast? */
      alaqil_cast_info *tc = alaqil_TypeCheck(to->name,ty);
      if (!tc) return alaqil_ERROR;
    }
  }
  return alaqil_OK;
}

alaqilRUNTIME
JSValueRef alaqil_JSC_NewPackedObj(JSContextRef context, void *data, size_t size, alaqil_type_info *type) {

  JSClassRef classRef = _alaqilObject_classRef;
  JSObjectRef result = JSObjectMake(context, classRef, NULL);

  alaqilPackedData* cdata = (alaqilPackedData*) malloc(sizeof(alaqilPackedData));
  cdata->data = data;
  cdata->size = size;
  cdata->type = type;

  JSObjectSetPrivate(result, cdata);

  return result;
}

/*  alaqilPackedData wrappers  */
alaqilRUNTIME
void _wrap_alaqilPackedData_delete(JSObjectRef obj)
{
  alaqilPackedData* cdata = (alaqilPackedData*) JSObjectGetPrivate(obj);
  if (cdata) {
    free(cdata->data);
  }
}

/* for C++ member pointers, ie, member methods */

#define alaqil_ConvertMember(obj, ptr, sz, ty)            alaqil_JSC_ConvertPacked(context, obj, ptr, sz, ty)
#define alaqil_NewMemberObj(ptr, sz, type)                alaqil_JSC_NewPackedObj(context, ptr, sz, type)


/* ---------------------------------------------------------------------------
 * Support for IN/OUTPUT typemaps (see Lib/typemaps/inoutlist.swg)
 *
 * ---------------------------------------------------------------------------*/
alaqilRUNTIME
unsigned int alaqilJSC_ArrayLength(JSContextRef context, JSObjectRef arr) {
  static JSStringRef LENGTH = 0;
  JSValueRef exception = NULL;
  JSValueRef js_length;
  double length;

  if (LENGTH == 0) {
    LENGTH = JSStringCreateWithUTF8CString("length");
  }

  js_length = JSObjectGetProperty(context, arr, LENGTH, &exception);
  if (exception == 0 && JSValueIsNumber(context, js_length)) {
    length = JSValueToNumber(context, js_length, 0);
    return (unsigned int) length;
  } else {
    return 0;
  }
}

alaqilRUNTIME
JSValueRef alaqilJSC_AppendOutput(JSContextRef context, JSValueRef value, JSValueRef obj) {
  JSObjectRef arr;
  unsigned int length;

  if (JSValueIsUndefined(context, value)) {
    arr = JSObjectMakeArray(context, 0, 0, 0);
  } else {
    arr = JSValueToObject(context, value, 0);
  }

  length = alaqilJSC_ArrayLength(context, arr);
  JSObjectSetPropertyAtIndex(context, arr, length, obj, 0);
  return arr;
}
