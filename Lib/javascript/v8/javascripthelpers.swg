%insert(runtime) %{

// Note: since 3.19 there are new CallBack types, since 03.21.9 the old ones have been removed
#if (V8_MAJOR_VERSION-0) < 4 && (alaqil_V8_VERSION < 0x031903)
typedef v8::InvocationCallback  alaqilV8FunctionCallback;
typedef v8::AccessorGetter      alaqilV8AccessorGetterCallback;
typedef v8::AccessorSetter      alaqilV8AccessorSetterCallback;
typedef v8::AccessorInfo        alaqilV8PropertyCallbackInfoVoid;
#elif (V8_MAJOR_VERSION-0) < 5
typedef v8::FunctionCallback            alaqilV8FunctionCallback;
typedef v8::AccessorGetterCallback      alaqilV8AccessorGetterCallback;
typedef v8::AccessorSetterCallback      alaqilV8AccessorSetterCallback;
typedef v8::PropertyCallbackInfo<void>  alaqilV8PropertyCallbackInfoVoid;
#else
typedef v8::FunctionCallback            alaqilV8FunctionCallback;
typedef v8::AccessorNameGetterCallback  alaqilV8AccessorGetterCallback;
typedef v8::AccessorNameSetterCallback  alaqilV8AccessorSetterCallback;
typedef v8::PropertyCallbackInfo<void>  alaqilV8PropertyCallbackInfoVoid;
#endif

/**
 * Creates a class template for a class with specified initialization function.
 */
alaqilRUNTIME v8::Handle<v8::FunctionTemplate> alaqilV8_CreateClassTemplate(const char* symbol) {
    alaqilV8_HANDLESCOPE_ESC();
    
    v8::Local<v8::FunctionTemplate> class_templ = alaqilV8_FUNCTEMPLATE_NEW_VOID();
    class_templ->SetClassName(alaqilV8_SYMBOL_NEW(symbol));

    v8::Handle<v8::ObjectTemplate> inst_templ = class_templ->InstanceTemplate();
    inst_templ->SetInternalFieldCount(1);

    v8::Handle<v8::ObjectTemplate> equals_templ = class_templ->PrototypeTemplate();
    equals_templ->Set(alaqilV8_SYMBOL_NEW("equals"), alaqilV8_FUNCTEMPLATE_NEW(_alaqilV8_wrap_equals));

    v8::Handle<v8::ObjectTemplate> cptr_templ = class_templ->PrototypeTemplate();
    cptr_templ->Set(alaqilV8_SYMBOL_NEW("getCPtr"), alaqilV8_FUNCTEMPLATE_NEW(_wrap_getCPtr));

    alaqilV8_ESCAPE(class_templ);
}

/**
 * Registers a class method with given name for a given class template.
 */
alaqilRUNTIME void alaqilV8_AddMemberFunction(v8::Handle<v8::FunctionTemplate> class_templ, const char* symbol,
  alaqilV8FunctionCallback _func) {
    v8::Handle<v8::ObjectTemplate> proto_templ = class_templ->PrototypeTemplate();
    proto_templ->Set(alaqilV8_SYMBOL_NEW(symbol), alaqilV8_FUNCTEMPLATE_NEW(_func));
}

/**
 * Registers a class property with given name for a given class template.
 */
alaqilRUNTIME void alaqilV8_AddMemberVariable(v8::Handle<v8::FunctionTemplate> class_templ, const char* symbol,
  alaqilV8AccessorGetterCallback getter, alaqilV8AccessorSetterCallback setter) {
  v8::Handle<v8::ObjectTemplate> proto_templ = class_templ->InstanceTemplate();
  proto_templ->SetAccessor(alaqilV8_SYMBOL_NEW(symbol), getter, setter);
}

/**
 * Registers a class method with given name for a given object.
 */
alaqilRUNTIME void alaqilV8_AddStaticFunction(v8::Handle<v8::Object> obj, const char* symbol,
  const alaqilV8FunctionCallback& _func) {
  obj->Set(alaqilV8_SYMBOL_NEW(symbol), alaqilV8_FUNCTEMPLATE_NEW(_func)->GetFunction());
}

/**
 * Registers a class method with given name for a given object.
 */
alaqilRUNTIME void alaqilV8_AddStaticVariable(v8::Handle<v8::Object> obj, const char* symbol,
  alaqilV8AccessorGetterCallback getter, alaqilV8AccessorSetterCallback setter) {
#if (V8_MAJOR_VERSION-0) < 5
  obj->SetAccessor(alaqilV8_SYMBOL_NEW(symbol), getter, setter);
#else
  obj->SetAccessor(alaqilV8_CURRENT_CONTEXT(), alaqilV8_SYMBOL_NEW(symbol), getter, setter);
#endif
}

#if (V8_MAJOR_VERSION-0) < 5
alaqilRUNTIME void JS_veto_set_variable(v8::Local<v8::String> property, v8::Local<v8::Value> value, const alaqilV8PropertyCallbackInfoVoid& info)
#else
alaqilRUNTIME void JS_veto_set_variable(v8::Local<v8::Name> property, v8::Local<v8::Value> value, const alaqilV8PropertyCallbackInfoVoid& info)
#endif
{
    char buffer[256];
    char msg[512];
    int res;

#if (V8_MAJOR_VERSION-0) < 5
    property->WriteUtf8(buffer, 256);
    res = sprintf(msg, "Tried to write read-only variable: %s.", buffer);
#else
    v8::Local<v8::String> sproperty;
    if (property->ToString(alaqilV8_CURRENT_CONTEXT()).ToLocal(&sproperty)) {
      alaqilV8_WRITE_UTF8(sproperty, buffer, 256);
      res = sprintf(msg, "Tried to write read-only variable: %s.", buffer);
    }
    else {
      res = -1;
    }
#endif

    if(res<0) {
      alaqil_exception(alaqil_ERROR, "Tried to write read-only variable.");
    } else {
      alaqil_exception(alaqil_ERROR, msg);
    }
fail: ;
}

%} // v8_helper_functions
