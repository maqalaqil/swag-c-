%insert(init) %{
alaqilRUNTIME void
alaqil_JSC_SetModule(alaqil_module_info *alaqil_module) {}

alaqilRUNTIME alaqil_module_info *
alaqil_JSC_GetModule(void) {
  return 0;
}

#define alaqil_GetModule(clientdata)                alaqil_JSC_GetModule()
#define alaqil_SetModule(clientdata, pointer)       alaqil_JSC_SetModule(pointer)
%}

%insert(init) "alaqilinit.swg"

%fragment ("js_initializer_define", "templates") %{
#define alaqilJSC_INIT $jsname_initialize
%}

// Open the initializer function
%insert(init)
%{

#ifdef __cplusplus
extern "C" {
#endif

bool alaqilJSC_INIT (JSGlobalContextRef context, JSObjectRef *exports) {
    alaqil_InitializeModule(0);
%}

/* -----------------------------------------------------------------------------
 * js_initializer:  template for the module initializer function
 *   - $jsname:                   module name
 *   - $jscreatenamespaces:       part with code for creating namespace objects
 *   - $jscreateclasses:          part with code for creating classes
 *   - $jsregisternamespaces:     part with code for registration of namespaces
 * ----------------------------------------------------------------------------- */
%fragment ("js_initializer", "templates") %{
    /* Initialize the base alaqil type object */
    _alaqilObject_objectDefinition.staticFunctions = _alaqilObject_functions;
    _alaqilObject_objectDefinition.staticValues = _alaqilObject_values;
    _alaqilObject_classRef = JSClassCreate(&_alaqilObject_objectDefinition);

    /* Initialize the PackedData class */
    _alaqilPackedData_objectDefinition.staticFunctions = _alaqilPackedData_functions;
    _alaqilPackedData_objectDefinition.staticValues = _alaqilPackedData_values;
    _alaqilPackedData_objectDefinition.finalize = _wrap_alaqilPackedData_delete;
    _alaqilPackedData_classRef = JSClassCreate(&_alaqilPackedData_objectDefinition);

    /* Create objects for namespaces */
    $jscreatenamespaces

    /* Register classes */
    $jsregisterclasses

    /* Register namespaces */
    $jsregisternamespaces

    *exports = exports_object;

    return true;
}
#ifdef __cplusplus
}
#endif
%}
