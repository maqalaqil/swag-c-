/* -----------------------------------------------------------------------------*
   Standard alaqil API for use inside user code.
 
   Don't include this file directly, run the command
   alaqil -python -external-runtime
   Also, read the Modules chapter of the alaqil Manual.
 
 * -----------------------------------------------------------------------------*/

#ifdef alaqil_MODULE_CLIENTDATA_TYPE

alaqilRUNTIMEINLINE alaqil_type_info *
alaqil_TypeQuery(alaqil_MODULE_CLIENTDATA_TYPE clientdata, const char *name) {
  alaqil_module_info *module = alaqil_GetModule(clientdata);
  return alaqil_TypeQueryModule(module, module, name);
}

alaqilRUNTIMEINLINE alaqil_type_info *
alaqil_MangledTypeQuery(alaqil_MODULE_CLIENTDATA_TYPE clientdata, const char *name) {
  alaqil_module_info *module = alaqil_GetModule(clientdata);
  return alaqil_MangledTypeQueryModule(module, module, name);
}

#else

alaqilRUNTIMEINLINE alaqil_type_info *
alaqil_TypeQuery(const char *name) {
  alaqil_module_info *module = alaqil_GetModule(NULL);
  return alaqil_TypeQueryModule(module, module, name);
}

alaqilRUNTIMEINLINE alaqil_type_info *
alaqil_MangledTypeQuery(const char *name) {
  alaqil_module_info *module = alaqil_GetModule(NULL);
  return alaqil_MangledTypeQueryModule(module, module, name);
}

#endif
