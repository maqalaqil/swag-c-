%insert(runtime) "alaqilrun.swg";
%insert(runtime) "alaqilerrors.swg";

%insert(runtime) "scirun.swg";

%insert(init) %{
/* Module management functions */

#define alaqil_GetModule(clientdata) alaqil_Scilab_GetModule()
#define alaqil_SetModule(clientdata, pointer) alaqil_Scilab_SetModule(pointer)

alaqilRUNTIME alaqil_module_info*
alaqil_Scilab_GetModule(void) {
  return NULL;
}

alaqilRUNTIME void
alaqil_Scilab_SetModule(alaqil_module_info *alaqil_module) {
}
%}

%insert(init) "alaqilinit.swg"

%insert(init) %{
alaqilRUNTIME alaqil_type_info *
alaqil_Scilab_TypeQuery(const char *name) {
  if (alaqil_Module_Initialized()) {
    if (name) {
      return alaqil_TypeQuery(name);
    }
  }
  else {
    alaqil_Error(alaqil_RuntimeError, "the module is not initialized");
  }
  return NULL;
}
%}

%insert(init) %{
#ifdef __cplusplus
extern "C"
#endif
int <module>_Init(alaqil_GatewayParameters) {
  alaqil_InitializeModule(NULL);
  alaqil_CreateScilabVariables(pvApiCtx);
  alaqil_module_initialized = 1;
%}
