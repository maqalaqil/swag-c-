/* ---------------------------------------------------------------------------
 * These typedefs and defines are used to deal with v8 API changes
 *
 * ---------------------------------------------------------------------------*/

// First v8 version that uses "SetWeak" and not "MakeWeak"

#define alaqilV8_SETWEAK_VERSION 0x032224

#if (V8_MAJOR_VERSION-0) < 4 && (alaqil_V8_VERSION < 0x031803)
#define alaqilV8_STRING_NEW2(cstr, len) v8::String::New(cstr, len)
#else
#define alaqilV8_STRING_NEW2(cstr, len) v8::String::NewFromUtf8(v8::Isolate::GetCurrent(), cstr, v8::String::kNormalString, len)
#endif

#if (V8_MAJOR_VERSION-0) < 4 && (alaqil_V8_VERSION < 0x031903)
typedef v8::Handle<v8::Value> alaqilV8ReturnValue;
typedef v8::Arguments alaqilV8Arguments;
typedef v8::AccessorInfo alaqilV8PropertyCallbackInfo;
#define alaqilV8_RETURN(val) return scope.Close(val)
#define alaqilV8_RETURN_INFO(val, info) return scope.Close(val)
#else
typedef void alaqilV8ReturnValue;
typedef v8::FunctionCallbackInfo<v8::Value> alaqilV8Arguments;
typedef v8::PropertyCallbackInfo<v8::Value> alaqilV8PropertyCallbackInfo;
#define alaqilV8_RETURN(val) args.GetReturnValue().Set(val); return
#define alaqilV8_RETURN_INFO(val, info) info.GetReturnValue().Set(val); return
#endif

#if (V8_MAJOR_VERSION-0) < 4 && (alaqil_V8_VERSION < 0x032117)
#define alaqilV8_HANDLESCOPE() v8::HandleScope scope
#define alaqilV8_HANDLESCOPE_ESC() v8::HandleScope scope
#define alaqilV8_ESCAPE(val) return scope.Close(val)
#elif (V8_MAJOR_VERSION-0) < 4 && (alaqil_V8_VERSION < 0x032224)
#define alaqilV8_HANDLESCOPE() v8::HandleScope scope(v8::Isolate::GetCurrent());
#define alaqilV8_HANDLESCOPE_ESC() v8::HandleScope scope(v8::Isolate::GetCurrent());
#define alaqilV8_ESCAPE(val) return scope.Close(val)
#else
#define alaqilV8_HANDLESCOPE() v8::HandleScope scope(v8::Isolate::GetCurrent());
#define alaqilV8_HANDLESCOPE_ESC() v8::EscapableHandleScope scope(v8::Isolate::GetCurrent());
#define alaqilV8_ESCAPE(val) return scope.Escape(val)
#endif

#if (V8_MAJOR_VERSION-0) < 4 && (alaqil_V8_VERSION < 0x032224)
#define alaqilV8_ADJUST_MEMORY(size) v8::V8::AdjustAmountOfExternalAllocatedMemory(size)
#define alaqilV8_CURRENT_CONTEXT() v8::Context::GetCurrent()
#define alaqilV8_THROW_EXCEPTION(err) v8::ThrowException(err)
#define alaqilV8_STRING_NEW(str) v8::String::New(str)
#define alaqilV8_SYMBOL_NEW(sym) v8::String::NewSymbol(sym)
#else
#define alaqilV8_ADJUST_MEMORY(size) v8::Isolate::GetCurrent()->AdjustAmountOfExternalAllocatedMemory(size)
#define alaqilV8_CURRENT_CONTEXT() v8::Isolate::GetCurrent()->GetCurrentContext()
#define alaqilV8_THROW_EXCEPTION(err) v8::Isolate::GetCurrent()->ThrowException(err)
#define alaqilV8_STRING_NEW(str) v8::String::NewFromUtf8(v8::Isolate::GetCurrent(), str)
#define alaqilV8_SYMBOL_NEW(sym) v8::String::NewFromUtf8(v8::Isolate::GetCurrent(), sym)
#endif

#if (V8_MAJOR_VERSION-0) < 4 && (alaqil_V8_VERSION < 0x032318)
#define alaqilV8_ARRAY_NEW() v8::Array::New()
#define alaqilV8_BOOLEAN_NEW(bool) v8::Boolean::New(bool)
#define alaqilV8_EXTERNAL_NEW(val) v8::External::New(val)
#define alaqilV8_FUNCTEMPLATE_NEW(func) v8::FunctionTemplate::New(func)
#define alaqilV8_FUNCTEMPLATE_NEW_VOID() v8::FunctionTemplate::New()
#define alaqilV8_INT32_NEW(num) v8::Int32::New(num)
#define alaqilV8_INTEGER_NEW(num) v8::Integer::New(num)
#define alaqilV8_INTEGER_NEW_UNS(num) v8::Integer::NewFromUnsigned(num)
#define alaqilV8_NUMBER_NEW(num) v8::Number::New(num)
#define alaqilV8_OBJECT_NEW() v8::Object::New()
#define alaqilV8_UNDEFINED() v8::Undefined()
#define alaqilV8_NULL() v8::Null()
#else
#define alaqilV8_ARRAY_NEW() v8::Array::New(v8::Isolate::GetCurrent())
#define alaqilV8_BOOLEAN_NEW(bool) v8::Boolean::New(v8::Isolate::GetCurrent(), bool)
#define alaqilV8_EXTERNAL_NEW(val) v8::External::New(v8::Isolate::GetCurrent(), val)
#define alaqilV8_FUNCTEMPLATE_NEW(func) v8::FunctionTemplate::New(v8::Isolate::GetCurrent(), func)
#define alaqilV8_FUNCTEMPLATE_NEW_VOID() v8::FunctionTemplate::New(v8::Isolate::GetCurrent())
#define alaqilV8_INT32_NEW(num) v8::Int32::New(v8::Isolate::GetCurrent(), num)
#define alaqilV8_INTEGER_NEW(num) v8::Integer::New(v8::Isolate::GetCurrent(), num)
#define alaqilV8_INTEGER_NEW_UNS(num) v8::Integer::NewFromUnsigned(v8::Isolate::GetCurrent(), num)
#define alaqilV8_NUMBER_NEW(num) v8::Number::New(v8::Isolate::GetCurrent(), num)
#define alaqilV8_OBJECT_NEW() v8::Object::New(v8::Isolate::GetCurrent())
#define alaqilV8_UNDEFINED() v8::Undefined(v8::Isolate::GetCurrent())
#define alaqilV8_NULL() v8::Null(v8::Isolate::GetCurrent())
#endif

#if (V8_MAJOR_VERSION-0) < 4 && (alaqil_V8_VERSION < 0x031710)
#define alaqilV8_SET_CLASS_TEMPL(class_templ, class) class_templ = v8::Persistent<v8::FunctionTemplate>::New(class);
#elif (V8_MAJOR_VERSION-0) < 4 && (alaqil_V8_VERSION < 0x031900)
#define alaqilV8_SET_CLASS_TEMPL(class_templ, class) class_templ = v8::Persistent<v8::FunctionTemplate>::New(v8::Isolate::GetCurrent(), class);
#else
#define alaqilV8_SET_CLASS_TEMPL(class_templ, class) class_templ.Reset(v8::Isolate::GetCurrent(), class);
#endif

#ifdef NODE_VERSION
#if NODE_VERSION_AT_LEAST(10, 12, 0)
#define alaqil_NODE_AT_LEAST_1012
#endif
#endif

//Necessary to check Node.js version because V8 API changes are backported in Node.js
#if (defined(NODE_VERSION) && !defined(alaqil_NODE_AT_LEAST_1012)) || \
    (!defined(NODE_VERSION) && (V8_MAJOR_VERSION-0) < 7)
#define alaqilV8_TO_OBJECT(handle) (handle)->ToObject()
#define alaqilV8_TO_STRING(handle) (handle)->ToString()
#define alaqilV8_NUMBER_VALUE(handle) (handle)->NumberValue()
#define alaqilV8_INTEGER_VALUE(handle) (handle)->IntegerValue()
#define alaqilV8_BOOLEAN_VALUE(handle) (handle)->BooleanValue()
#define alaqilV8_WRITE_UTF8(handle, buffer, len) (handle)->WriteUtf8(buffer, len)
#define alaqilV8_UTF8_LENGTH(handle) (handle)->Utf8Length()
#else
#define alaqilV8_TO_OBJECT(handle) (handle)->ToObject(alaqilV8_CURRENT_CONTEXT()).ToLocalChecked()
#define alaqilV8_TO_STRING(handle) (handle)->ToString(alaqilV8_CURRENT_CONTEXT()).ToLocalChecked()
#define alaqilV8_NUMBER_VALUE(handle) (handle)->NumberValue(alaqilV8_CURRENT_CONTEXT()).ToChecked()
#define alaqilV8_INTEGER_VALUE(handle) (handle)->IntegerValue(alaqilV8_CURRENT_CONTEXT()).ToChecked()
#define alaqilV8_BOOLEAN_VALUE(handle) (handle)->BooleanValue(alaqilV8_CURRENT_CONTEXT()).ToChecked()
#define alaqilV8_WRITE_UTF8(handle, buffer, len) (handle)->WriteUtf8(v8::Isolate::GetCurrent(), buffer, len)
#define alaqilV8_UTF8_LENGTH(handle) (handle)->Utf8Length(v8::Isolate::GetCurrent())
#endif

/* ---------------------------------------------------------------------------
 * Error handling
 *
 * ---------------------------------------------------------------------------*/

#define alaqil_Error(code, msg)     alaqilV8_ErrorHandler.error(code, msg)
#define alaqil_exception(code, msg) do { alaqilV8_ErrorHandler.error(code, msg); alaqil_fail; } while (0)
#define alaqil_fail                 goto fail
#define alaqilV8_OVERLOAD false

alaqilINTERN void alaqil_V8_Raise(const char *msg) {
  alaqilV8_THROW_EXCEPTION(v8::Exception::Error(alaqilV8_STRING_NEW(msg)));
}

/*
  Note: There are two contexts for handling errors.
  A static V8ErrorHandler is used in not overloaded methods.
  For overloaded methods the throwing type checking mechanism is used
  during dispatching. As V8 exceptions can not be reset properly
  the trick is to use a dynamic ErrorHandler with same local name as the global
  one.

  - See definition of alaqil_Error above.
  - See code templates 'JS_function_dispatcher', 'JS_functionwrapper_overload',
    and 'JS_function_dispatch_case' in javascriptcode.swg

*/
class V8ErrorHandler {
public:
  virtual ~V8ErrorHandler() {}
  virtual void error(int code, const char *msg) {
    alaqil_V8_Raise(msg);
  }
};
// this is used in usually
alaqilRUNTIME V8ErrorHandler alaqilV8_ErrorHandler;

// instances of this are used in overloaded functions
class OverloadErrorHandler: public V8ErrorHandler {
public:
  virtual void error(int code, const char *msg) {
    err = v8::Exception::Error(alaqilV8_STRING_NEW(msg));
    if(code != alaqil_TypeError) {
        alaqilV8_THROW_EXCEPTION(err);
    }
  }
  v8::Handle<v8::Value> err;
};

/* ---------------------------------------------------------------------------
 * Basic Proxy object
 *
 * ---------------------------------------------------------------------------*/

// Note: to trigger the v8 gc more often one can tell v8 about the memory consumption
// TODO: we could add a v8 specific parameter to control this value
#define alaqilV8_AVG_OBJ_SIZE 1000

class alaqilV8_Proxy {
public:
  alaqilV8_Proxy(): alaqilCMemOwn(false), alaqilCObject(0), info(0) {
    alaqilV8_ADJUST_MEMORY(alaqilV8_AVG_OBJ_SIZE);
  };

  ~alaqilV8_Proxy() {
#if (V8_MAJOR_VERSION-0) < 4 && (alaqil_V8_VERSION < 0x031710)
    handle.ClearWeak();
    handle.Dispose();
#elif (V8_MAJOR_VERSION-0) < 4 && (alaqil_V8_VERSION < 0x032100)
    handle.ClearWeak(v8::Isolate::GetCurrent());
    handle.Dispose(v8::Isolate::GetCurrent());
#elif (V8_MAJOR_VERSION-0) < 4 && (alaqil_V8_VERSION < alaqilV8_SETWEAK_VERSION)
    handle.ClearWeak();
    handle.Dispose();
#else    
    handle.ClearWeak();
    handle.Reset();
#endif

#if (V8_MAJOR_VERSION-0) < 4 && (alaqil_V8_VERSION < alaqilV8_SETWEAK_VERSION)
    handle.Clear();
#endif

    alaqilV8_ADJUST_MEMORY(-alaqilV8_AVG_OBJ_SIZE);
  }

  bool alaqilCMemOwn;
  void *alaqilCObject;
  alaqil_type_info *info;
  v8::Persistent<v8::Object> handle;
};

class alaqilV8_ClientData {
public:
  v8::Persistent<v8::FunctionTemplate> class_templ;

#if (V8_MAJOR_VERSION-0) < 4 && (alaqil_V8_VERSION < 0x031710)
  void (*dtor) (v8::Persistent< v8::Value> object, void *parameter);
#elif (V8_MAJOR_VERSION-0) < 4 && (alaqil_V8_VERSION < 0x031900)
  void (*dtor) (v8::Isolate *isolate, v8::Persistent< v8::Value> object, void *parameter);
#elif (V8_MAJOR_VERSION-0) < 4 && (alaqil_V8_VERSION < alaqilV8_SETWEAK_VERSION)
  void (*dtor) (v8::Isolate *isolate, v8::Persistent< v8::Object > *object, alaqilV8_Proxy *proxy);
#elif (V8_MAJOR_VERSION-0) < 5
  void (*dtor) (const v8::WeakCallbackData<v8::Object, alaqilV8_Proxy> &data);
#else
  void (*dtor) (const v8::WeakCallbackInfo<alaqilV8_Proxy> &data);
#endif
};

alaqilRUNTIME v8::Persistent<v8::FunctionTemplate> alaqilV8_alaqilTYPE_Proxy_class_templ;

alaqilRUNTIME int alaqil_V8_ConvertInstancePtr(v8::Handle<v8::Object> objRef, void **ptr, alaqil_type_info *info, int flags) {
  alaqilV8_HANDLESCOPE();

  if(objRef->InternalFieldCount() < 1) return alaqil_ERROR;

#if (V8_MAJOR_VERSION-0) < 4 && (alaqil_V8_VERSION < 0x031511)
  v8::Handle<v8::Value> cdataRef = objRef->GetInternalField(0);
  alaqilV8_Proxy *cdata = static_cast<alaqilV8_Proxy *>(v8::External::Unwrap(cdataRef));
#else
  alaqilV8_Proxy *cdata = static_cast<alaqilV8_Proxy *>(objRef->GetAlignedPointerFromInternalField(0));
#endif

  if(cdata == NULL) {
    return alaqil_ERROR;
  }
  if(cdata->info != info) {
    alaqil_cast_info *tc = alaqil_TypeCheckStruct(cdata->info, info);
    if (!tc && cdata->info->name) {
      tc = alaqil_TypeCheck(cdata->info->name, info);
    }
    bool type_valid = tc != 0;
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


#if (V8_MAJOR_VERSION-0) < 4 && (alaqil_V8_VERSION < 0x031710)
alaqilRUNTIME void alaqilV8_Proxy_DefaultDtor(v8::Persistent< v8::Value > object, void *parameter) {
  alaqilV8_Proxy *proxy = static_cast<alaqilV8_Proxy *>(parameter);
#elif (V8_MAJOR_VERSION-0) < 4 && (alaqil_V8_VERSION < 0x031900)
alaqilRUNTIME void alaqilV8_Proxy_DefaultDtor(v8::Isolate *, v8::Persistent< v8::Value > object, void *parameter) {
  alaqilV8_Proxy *proxy = static_cast<alaqilV8_Proxy *>(parameter);
#elif (V8_MAJOR_VERSION-0) < 4 && (alaqil_V8_VERSION < alaqilV8_SETWEAK_VERSION)
alaqilRUNTIME void alaqilV8_Proxy_DefaultDtor(v8::Isolate *, v8::Persistent< v8::Object > *object, alaqilV8_Proxy *proxy) {
#elif (V8_MAJOR_VERSION-0) < 5
alaqilRUNTIME void alaqilV8_Proxy_DefaultDtor(const v8::WeakCallbackData<v8::Object, alaqilV8_Proxy> &data) {
  alaqilV8_Proxy *proxy = data.GetParameter();
#else
alaqilRUNTIME void alaqilV8_Proxy_DefaultDtor(const v8::WeakCallbackInfo<alaqilV8_Proxy> &data) {
  alaqilV8_Proxy *proxy = data.GetParameter();
#endif

  delete proxy;
}

alaqilRUNTIME int alaqil_V8_GetInstancePtr(v8::Handle<v8::Value> valRef, void **ptr) {
  if(!valRef->IsObject()) {
    return alaqil_TypeError;
  }
  v8::Handle<v8::Object> objRef = alaqilV8_TO_OBJECT(valRef);

  if(objRef->InternalFieldCount() < 1) return alaqil_ERROR;

#if (V8_MAJOR_VERSION-0) < 4 && (alaqil_V8_VERSION < 0x031511)
  v8::Handle<v8::Value> cdataRef = objRef->GetInternalField(0);
  alaqilV8_Proxy *cdata = static_cast<alaqilV8_Proxy *>(v8::External::Unwrap(cdataRef));
#else
  alaqilV8_Proxy *cdata = static_cast<alaqilV8_Proxy *>(objRef->GetAlignedPointerFromInternalField(0));
#endif

  if(cdata == NULL) {
    return alaqil_ERROR;
  }

  *ptr = cdata->alaqilCObject;

  return alaqil_OK;
}

alaqilRUNTIME void alaqilV8_SetPrivateData(v8::Handle<v8::Object> obj, void *ptr, alaqil_type_info *info, int flags) {
  alaqilV8_Proxy *cdata = new alaqilV8_Proxy();
  cdata->alaqilCObject = ptr;
  cdata->alaqilCMemOwn = (flags & alaqil_POINTER_OWN) ? 1 : 0;
  cdata->info = info;

#if (V8_MAJOR_VERSION-0) < 4 && (alaqil_V8_VERSION < 0x031511)
  obj->SetPointerInInternalField(0, cdata);
#else
  obj->SetAlignedPointerInInternalField(0, cdata);
#endif

#if (V8_MAJOR_VERSION-0) < 4 && (alaqil_V8_VERSION < 0x031710)
  cdata->handle = v8::Persistent<v8::Object>::New(obj);
#elif (V8_MAJOR_VERSION-0) < 4 && (alaqil_V8_VERSION < 0x031900)
  cdata->handle = v8::Persistent<v8::Object>::New(v8::Isolate::GetCurrent(), obj);
#else
  cdata->handle.Reset(v8::Isolate::GetCurrent(), obj);
#endif

#if (V8_MAJOR_VERSION-0) < 4 && (alaqil_V8_VERSION < 0x031710)
  // clientdata must be set for owned data as we need to register the dtor
  if(cdata->alaqilCMemOwn && (alaqilV8_ClientData*)info->clientdata) {
    cdata->handle.MakeWeak(cdata, ((alaqilV8_ClientData*)info->clientdata)->dtor);
  } else {
    cdata->handle.MakeWeak(cdata, alaqilV8_Proxy_DefaultDtor);
  }
#elif (V8_MAJOR_VERSION-0) < 4 && (alaqil_V8_VERSION < 0x031918)
  if(cdata->alaqilCMemOwn && (alaqilV8_ClientData*)info->clientdata) {
    cdata->handle.MakeWeak(v8::Isolate::GetCurrent(), cdata, ((alaqilV8_ClientData*)info->clientdata)->dtor);
  } else {
    cdata->handle.MakeWeak(v8::Isolate::GetCurrent(), cdata, alaqilV8_Proxy_DefaultDtor);
  }
#elif (V8_MAJOR_VERSION-0) < 4 && (alaqil_V8_VERSION < alaqilV8_SETWEAK_VERSION)
  if(cdata->alaqilCMemOwn && (alaqilV8_ClientData*)info->clientdata) {
    cdata->handle.MakeWeak(cdata, ((alaqilV8_ClientData*)info->clientdata)->dtor);
  } else {
    cdata->handle.MakeWeak(cdata, alaqilV8_Proxy_DefaultDtor);
  }
#elif (V8_MAJOR_VERSION-0) < 5
  if(cdata->alaqilCMemOwn && (alaqilV8_ClientData*)info->clientdata) {
    cdata->handle.SetWeak(cdata, ((alaqilV8_ClientData*)info->clientdata)->dtor);
  } else {
    cdata->handle.SetWeak(cdata, alaqilV8_Proxy_DefaultDtor);
  }
#else
  if(cdata->alaqilCMemOwn && (alaqilV8_ClientData*)info->clientdata) {
    cdata->handle.SetWeak(cdata, ((alaqilV8_ClientData*)info->clientdata)->dtor, v8::WeakCallbackType::kParameter);
  } else {
    cdata->handle.SetWeak(cdata, alaqilV8_Proxy_DefaultDtor, v8::WeakCallbackType::kParameter);
  }
#endif

#if (V8_MAJOR_VERSION-0) < 4 && (alaqil_V8_VERSION < 0x031710)
  cdata->handle.MarkIndependent();
#elif (V8_MAJOR_VERSION-0) < 4 && (alaqil_V8_VERSION < 0x032100)
  cdata->handle.MarkIndependent(v8::Isolate::GetCurrent());
#else
  cdata->handle.MarkIndependent();
#endif

}

alaqilRUNTIME int alaqil_V8_ConvertPtr(v8::Handle<v8::Value> valRef, void **ptr, alaqil_type_info *info, int flags) {
  alaqilV8_HANDLESCOPE();
  
  /* special case: JavaScript null => C NULL pointer */
  if(valRef->IsNull()) {
    *ptr=0;
    return (flags & alaqil_POINTER_NO_NULL) ? alaqil_NullReferenceError : alaqil_OK;
  }
  if(!valRef->IsObject()) {
    return alaqil_TypeError;
  }
  v8::Handle<v8::Object> objRef = alaqilV8_TO_OBJECT(valRef);
  return alaqil_V8_ConvertInstancePtr(objRef, ptr, info, flags);
}

alaqilRUNTIME v8::Handle<v8::Value> alaqil_V8_NewPointerObj(void *ptr, alaqil_type_info *info, int flags) {
  alaqilV8_HANDLESCOPE_ESC();
  
  v8::Handle<v8::FunctionTemplate> class_templ;

  if (ptr == NULL) {
#if (V8_MAJOR_VERSION-0) < 4 && (alaqil_V8_VERSION < 0x031903)
    alaqilV8_ESCAPE(alaqilV8_NULL());
#else    
    v8::Local<v8::Primitive> result = alaqilV8_NULL();
    alaqilV8_ESCAPE(result);
#endif
  }

#if (V8_MAJOR_VERSION-0) < 4 && (alaqil_V8_VERSION < 0x031903)
  if(info->clientdata != 0) {
    class_templ = ((alaqilV8_ClientData*) info->clientdata)->class_templ;
  } else {
    class_templ = alaqilV8_alaqilTYPE_Proxy_class_templ;
  }
#else
  v8::Isolate *isolate = v8::Isolate::GetCurrent();

  if(info->clientdata != 0) {
    class_templ = v8::Local<v8::FunctionTemplate>::New(isolate, ((alaqilV8_ClientData*) info->clientdata)->class_templ);
  } else {
    class_templ = v8::Local<v8::FunctionTemplate>::New(isolate, alaqilV8_alaqilTYPE_Proxy_class_templ);
  }
#endif

//  v8::Handle<v8::Object> result = class_templ->InstanceTemplate()->NewInstance();
  v8::Local<v8::Object> result = class_templ->InstanceTemplate()->NewInstance();
  alaqilV8_SetPrivateData(result, ptr, info, flags);

  alaqilV8_ESCAPE(result);
}

#define alaqil_ConvertPtr(obj, ptr, info, flags)    alaqil_V8_ConvertPtr(obj, ptr, info, flags)
#define alaqil_NewPointerObj(ptr, info, flags)      alaqil_V8_NewPointerObj(ptr, info, flags)

#define alaqil_ConvertInstance(obj, pptr, type, flags)    alaqil_V8_ConvertInstancePtr(obj, pptr, type, flags)
#define alaqil_NewInstanceObj(thisvalue, type, flags)     alaqil_V8_NewPointerObj(thisvalue, type, flags)

#define alaqil_ConvertFunctionPtr(obj, pptr, type)        alaqil_V8_ConvertPtr(obj, pptr, type, 0)
#define alaqil_NewFunctionPtrObj(ptr, type)               alaqil_V8_NewPointerObj(ptr, type, 0)

#define alaqil_GetInstancePtr(obj, ptr)    alaqil_V8_GetInstancePtr(obj, ptr)

alaqilRUNTIME alaqilV8ReturnValue _alaqilV8_wrap_equals(const alaqilV8Arguments &args) {
  alaqilV8_HANDLESCOPE();
  
  v8::Handle<v8::Value> jsresult;
  void *arg1 = (void *) 0 ;
  void *arg2 = (void *) 0 ;
  bool result;
  int res1;
  int res2;

  if(args.Length() != 1) alaqil_exception_fail(alaqil_ERROR, "Illegal number of arguments for equals.");

  res1 = alaqil_GetInstancePtr(args.Holder(), &arg1);
  if (!alaqil_IsOK(res1)) {
    alaqil_exception_fail(alaqil_ERROR, "Could not get pointer from 'this' object for equals.");
  }
  res2 = alaqil_GetInstancePtr(args[0], &arg2);
  if (!alaqil_IsOK(res2)) {
    alaqil_exception_fail(alaqil_ArgError(res2), "in method '" "equals" "', argument " "1"" of type '" "void *""'");
  }

  result = (bool)(arg1 == arg2);
  jsresult =  alaqilV8_BOOLEAN_NEW(result);

  alaqilV8_RETURN(jsresult);
  goto fail;
fail:
  alaqilV8_RETURN(alaqilV8_UNDEFINED());
}

alaqilRUNTIME alaqilV8ReturnValue _wrap_getCPtr(const alaqilV8Arguments &args) {
  alaqilV8_HANDLESCOPE();
  
  v8::Handle<v8::Value> jsresult;
  void *arg1 = (void *) 0 ;
  long result;
  int res1;

  res1 = alaqil_GetInstancePtr(args.Holder(), &arg1);
  if (!alaqil_IsOK(res1)) {
    alaqil_exception_fail(alaqil_ArgError(res1), "in method '" "getCPtr" "', argument " "1"" of type '" "void *""'");
  }

  result = (long)arg1;
  jsresult = alaqilV8_NUMBER_NEW(result);

  alaqilV8_RETURN(jsresult);
  goto fail;
fail:
  alaqilV8_RETURN(alaqilV8_UNDEFINED());
}

/* ---------------------------------------------------------------------------
 * PackedData object
 *
 * ---------------------------------------------------------------------------*/

class alaqilV8PackedData {
public:
  alaqilV8PackedData(void *data, size_t size, alaqil_type_info *type): data(data), size(size), type(type) {};

  ~alaqilV8PackedData() {
  };

  void *data;
  size_t size;
  alaqil_type_info *type;

  v8::Persistent<v8::Object> handle;
};

alaqilRUNTIMEINLINE
int alaqilV8Packed_Check(v8::Handle<v8::Value> valRef) {
  alaqilV8_HANDLESCOPE();
  
  v8::Handle<v8::Object> objRef = alaqilV8_TO_OBJECT(valRef);
  if(objRef->InternalFieldCount() < 1) return false;
#if (V8_MAJOR_VERSION-0) < 5
  v8::Handle<v8::Value> flag = objRef->GetHiddenValue(alaqilV8_STRING_NEW("__alaqil__packed_data__"));
#else
  v8::Local<v8::Private> privateKey = v8::Private::ForApi(v8::Isolate::GetCurrent(), alaqilV8_STRING_NEW("__alaqil__packed_data__"));
  v8::Local<v8::Value> flag;
  if (!objRef->GetPrivate(alaqilV8_CURRENT_CONTEXT(), privateKey).ToLocal(&flag))
    return false;
#endif
  return (flag->IsBoolean() && alaqilV8_BOOLEAN_VALUE(flag));
}

alaqilRUNTIME
alaqil_type_info *alaqilV8Packed_UnpackData(v8::Handle<v8::Value> valRef, void *ptr, size_t size) {
  if (alaqilV8Packed_Check(valRef)) {
    alaqilV8_HANDLESCOPE();
    
    alaqilV8PackedData *sobj;

    v8::Handle<v8::Object> objRef = alaqilV8_TO_OBJECT(valRef);

#if (V8_MAJOR_VERSION-0) < 4 && (alaqil_V8_VERSION < 0x031511)
    v8::Handle<v8::Value> cdataRef = objRef->GetInternalField(0);
    sobj = static_cast<alaqilV8PackedData*>(v8::External::Unwrap(cdataRef));
#else
    sobj = static_cast<alaqilV8PackedData*>(objRef->GetAlignedPointerFromInternalField(0));
#endif
    if (sobj == NULL || sobj->size != size) return 0;
    memcpy(ptr, sobj->data, size);
    return sobj->type;
  } else {
    return 0;
  }
}

alaqilRUNTIME
int alaqilV8_ConvertPacked(v8::Handle<v8::Value> valRef, void *ptr, size_t sz, alaqil_type_info *ty) {
  alaqil_type_info *to = alaqilV8Packed_UnpackData(valRef, ptr, sz);
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

#if (V8_MAJOR_VERSION-0) < 4 && (alaqil_V8_VERSION < 0x031710)
alaqilRUNTIME void _wrap_alaqilV8PackedData_delete(v8::Persistent< v8::Value > object, void *parameter) {
  alaqilV8PackedData *cdata = static_cast<alaqilV8PackedData *>(parameter);
#elif (V8_MAJOR_VERSION-0) < 4 && (alaqil_V8_VERSION < 0x031900)
alaqilRUNTIME void _wrap_alaqilV8PackedData_delete(v8::Isolate *isolate, v8::Persistent<v8::Value> object, void *parameter) {
  alaqilV8PackedData *cdata = static_cast<alaqilV8PackedData *>(parameter);
#elif (V8_MAJOR_VERSION-0) < 4 && (alaqil_V8_VERSION < alaqilV8_SETWEAK_VERSION)
alaqilRUNTIME void _wrap_alaqilV8PackedData_delete(v8::Isolate *isolate, v8::Persistent<v8::Object> *object, alaqilV8PackedData *cdata) {
#elif (V8_MAJOR_VERSION-0) < 5
alaqilRUNTIME void _wrap_alaqilV8PackedData_delete(const v8::WeakCallbackData<v8::Object, alaqilV8PackedData> &data) {
  v8::Local<v8::Object> object = data.GetValue();
  alaqilV8PackedData *cdata = data.GetParameter();
#else
alaqilRUNTIME void _wrap_alaqilV8PackedData_delete(const v8::WeakCallbackInfo<alaqilV8PackedData> &data) {
  alaqilV8PackedData *cdata = data.GetParameter();
#endif

  delete cdata;

#if (V8_MAJOR_VERSION-0) < 4 && (alaqil_V8_VERSION < 0x031710)
  object.Clear();
  object.Dispose();
#elif (V8_MAJOR_VERSION-0) < 4 && (alaqil_V8_VERSION < 0x031900)
  object.Clear();
  object.Dispose(isolate);
#elif (V8_MAJOR_VERSION-0) < 4 && (alaqil_V8_VERSION < 0x032100)
  object->Dispose(isolate);
#elif (V8_MAJOR_VERSION-0) < 4 && (alaqil_V8_VERSION < alaqilV8_SETWEAK_VERSION)
  object->Dispose();
#elif (V8_MAJOR_VERSION-0) < 5
  object.Clear();
#endif
}

alaqilRUNTIME
v8::Handle<v8::Value> alaqilV8_NewPackedObj(void *data, size_t size, alaqil_type_info *type) {
  alaqilV8_HANDLESCOPE_ESC();

  alaqilV8PackedData *cdata = new alaqilV8PackedData(data, size, type);
//  v8::Handle<v8::Object> obj = alaqilV8_OBJECT_NEW();
  v8::Local<v8::Object> obj = alaqilV8_OBJECT_NEW();

#if (V8_MAJOR_VERSION-0) < 5
  obj->SetHiddenValue(alaqilV8_STRING_NEW("__alaqil__packed_data__"), alaqilV8_BOOLEAN_NEW(true));
#else
  v8::Local<v8::Private> privateKey = v8::Private::ForApi(v8::Isolate::GetCurrent(), alaqilV8_STRING_NEW("__alaqil__packed_data__"));
  obj->SetPrivate(alaqilV8_CURRENT_CONTEXT(), privateKey, alaqilV8_BOOLEAN_NEW(true));
#endif

#if (V8_MAJOR_VERSION-0) < 4 && (alaqil_V8_VERSION < 0x031511)
  obj->SetPointerInInternalField(0, cdata);
#else
  obj->SetAlignedPointerInInternalField(0, cdata);
#endif

#if (V8_MAJOR_VERSION-0) < 4 && (alaqil_V8_VERSION < 0x031710)
  cdata->handle = v8::Persistent<v8::Object>::New(obj);
#elif (V8_MAJOR_VERSION-0) < 4 && (alaqil_V8_VERSION < 0x031900)
  cdata->handle = v8::Persistent<v8::Object>::New(v8::Isolate::GetCurrent(), obj);
#else
  cdata->handle.Reset(v8::Isolate::GetCurrent(), obj);
#endif


#if (V8_MAJOR_VERSION-0) < 4 && (alaqil_V8_VERSION < 0x031710)
  cdata->handle.MakeWeak(cdata, _wrap_alaqilV8PackedData_delete);
#elif (V8_MAJOR_VERSION-0) < 4 && (alaqil_V8_VERSION < 0x031918)
  cdata->handle.MakeWeak(v8::Isolate::GetCurrent(), cdata, _wrap_alaqilV8PackedData_delete);
#elif (V8_MAJOR_VERSION-0) < 4 && (alaqil_V8_VERSION < alaqilV8_SETWEAK_VERSION)
  cdata->handle.MakeWeak(cdata, _wrap_alaqilV8PackedData_delete);
#elif (V8_MAJOR_VERSION-0) < 5
  cdata->handle.SetWeak(cdata, _wrap_alaqilV8PackedData_delete);
//  v8::V8::SetWeak(&cdata->handle, cdata, _wrap_alaqilV8PackedData_delete);
#else
  cdata->handle.SetWeak(cdata, _wrap_alaqilV8PackedData_delete, v8::WeakCallbackType::kParameter);
#endif

#if (V8_MAJOR_VERSION-0) < 4 && (alaqil_V8_VERSION < 0x031710)
  cdata->handle.MarkIndependent();
#elif (V8_MAJOR_VERSION-0) < 4 && (alaqil_V8_VERSION < 0x032100)
  cdata->handle.MarkIndependent(v8::Isolate::GetCurrent());
#else
  cdata->handle.MarkIndependent();
#endif

  alaqilV8_ESCAPE(obj);
}

#define alaqil_ConvertMember(obj, ptr, sz, ty)            alaqilV8_ConvertPacked(obj, ptr, sz, ty)
#define alaqil_NewMemberObj(ptr, sz, type)                alaqilV8_NewPackedObj(ptr, sz, type)


/* ---------------------------------------------------------------------------
 * Support for IN/OUTPUT typemaps (see Lib/typemaps/inoutlist.swg)
 *
 * ---------------------------------------------------------------------------*/

alaqilRUNTIME

#if (V8_MAJOR_VERSION-0) < 4 && (alaqil_V8_VERSION < 0x031903)
v8::Handle<v8::Value> alaqilV8_AppendOutput(v8::Handle<v8::Value> result, v8::Handle<v8::Value> obj) {
#else
v8::Handle<v8::Value> alaqilV8_AppendOutput(v8::Local<v8::Value> result, v8::Handle<v8::Value> obj) {
#endif
  alaqilV8_HANDLESCOPE_ESC();
  
  if (result->IsUndefined()) {
    result = alaqilV8_ARRAY_NEW();
  }
#if (V8_MAJOR_VERSION-0) < 4 && (alaqil_V8_VERSION < 0x031903)
  v8::Handle<v8::Array> arr = v8::Handle<v8::Array>::Cast(result);
#else  
  v8::Local<v8::Array> arr = v8::Local<v8::Array>::Cast(result);
#endif
  arr->Set(arr->Length(), obj);

  alaqilV8_ESCAPE(arr);
}
