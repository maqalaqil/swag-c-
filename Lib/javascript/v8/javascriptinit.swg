%insert(header) %{
#include <assert.h>
%}

%insert(init) %{

alaqilRUNTIME void
alaqil_V8_SetModule(void *, alaqil_module_info *alaqil_module) {
  v8::Local<v8::Object> global_obj = alaqilV8_CURRENT_CONTEXT()->Global();
  v8::Local<v8::External> mod = alaqilV8_EXTERNAL_NEW(alaqil_module);
  assert(!mod.IsEmpty());
#if (V8_MAJOR_VERSION-0) < 5
  global_obj->SetHiddenValue(alaqilV8_STRING_NEW("alaqil_module_info_data"), mod);
#else
  v8::Local<v8::Private> privateKey = v8::Private::ForApi(v8::Isolate::GetCurrent(), alaqilV8_STRING_NEW("alaqil_module_info_data"));
  global_obj->SetPrivate(alaqilV8_CURRENT_CONTEXT(), privateKey, mod);
#endif
}

alaqilRUNTIME alaqil_module_info *
alaqil_V8_GetModule(void *) {
  v8::Local<v8::Object> global_obj = alaqilV8_CURRENT_CONTEXT()->Global();
#if (V8_MAJOR_VERSION-0) < 5
  v8::Local<v8::Value> moduleinfo = global_obj->GetHiddenValue(alaqilV8_STRING_NEW("alaqil_module_info_data"));
#else
  v8::Local<v8::Private> privateKey = v8::Private::ForApi(v8::Isolate::GetCurrent(), alaqilV8_STRING_NEW("alaqil_module_info_data"));
  v8::Local<v8::Value> moduleinfo;
  if (!global_obj->GetPrivate(alaqilV8_CURRENT_CONTEXT(), privateKey).ToLocal(&moduleinfo))
    return 0;
#endif

  if (moduleinfo.IsEmpty() || moduleinfo->IsNull() || moduleinfo->IsUndefined())
  {
    // It's not yet loaded
    return 0;
  }

  v8::Local<v8::External> moduleinfo_extern = v8::Local<v8::External>::Cast(moduleinfo);

  if (moduleinfo_extern.IsEmpty() || moduleinfo_extern->IsNull() || moduleinfo_extern->IsUndefined())
  {
    // Something's not right
    return 0;
  }

  void *ptr = moduleinfo_extern->Value();
  assert(ptr);
  alaqil_module_info *retptr = static_cast<alaqil_module_info *>(ptr);
  assert(retptr);
  return retptr;
}

#define alaqil_GetModule(clientdata)                alaqil_V8_GetModule(clientdata)
#define alaqil_SetModule(clientdata, pointer)       alaqil_V8_SetModule(clientdata, pointer)

%}

%insert(init) "alaqilinit.swg"

// Open the initializer function definition here

%fragment ("js_initializer_define", "templates") %{
#define alaqilV8_INIT $jsname_initialize
%}

%insert(init) %{
// Note: 'extern "C"'' disables name mangling which makes it easier to load the symbol manually
// TODO: is it ok to do that?
extern "C"
#if (NODE_MODULE_VERSION < 0x000C)
void alaqilV8_INIT (v8::Handle<v8::Object> exports)
#else
void alaqilV8_INIT (v8::Handle<v8::Object> exports, v8::Handle<v8::Object> /*module*/)
#endif
{
  alaqil_InitializeModule(static_cast<void *>(&exports));

  alaqilV8_HANDLESCOPE();
  
  v8::Handle<v8::Object> exports_obj = exports;
%}


/* -----------------------------------------------------------------------------
 * js_initializer:  template for the module initializer function
 *   - $jsname:                   module name
 *   - $jsv8nspaces:              part with code creating namespace objects
 *   - $jsv8classtemplates:       part with code creating class templates
 *   - $jsv8wrappers:             part with code that registers wrapper functions
 *   - $jsv8inheritance:          part with inherit statements
 *   - $jsv8classinstances:       part with code creating class objects
 *   - $jsv8staticwrappers:       part with code adding static functions to class objects
 *   - $jsv8registerclasses:      part with code that registers class objects in namespaces
 *   - $jsv8registernspaces:      part with code that registers namespaces in parent namespaces
 * ----------------------------------------------------------------------------- */
%fragment("js_initializer", "templates")
%{
  // a class template for creating proxies of undefined types
  alaqilV8_SET_CLASS_TEMPL(alaqilV8_alaqilTYPE_Proxy_class_templ, alaqilV8_CreateClassTemplate("alaqilProxy"));

  /* create objects for namespaces */
  $jsv8nspaces

  /* create class templates */
  $jsv8classtemplates

  /* register wrapper functions */
  $jsv8wrappers

  /* setup inheritances */
  $jsv8inheritance

  /* class instances */
  $jsv8classinstances

  /* add static class functions and variables */
  $jsv8staticwrappers

  /* register classes */
  $jsv8registerclasses

  /* create and register namespace objects */
  $jsv8registernspaces
}

#if defined(BUILDING_NODE_EXTENSION)
NODE_MODULE($jsname, $jsname_initialize)
#endif
%}
