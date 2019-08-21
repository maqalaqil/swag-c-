/* ------------------------------------------------------------
 * The start of the Tcl initialization function 
 * ------------------------------------------------------------ */

%insert(init) "alaqilinit.swg"

/* This initialization code exports the module initialization function */

%header %{

#ifdef __cplusplus
extern "C" {
#endif
#ifdef MAC_TCL
#pragma export on
#endif
alaqilEXPORT int alaqil_init(Tcl_Interp *);
#ifdef MAC_TCL
#pragma export off
#endif
#ifdef __cplusplus
}
#endif

/* Compatibility version for TCL stubs */
#ifndef alaqil_TCL_STUBS_VERSION
#define alaqil_TCL_STUBS_VERSION "8.1"
#endif

%}

%init %{
#ifdef __cplusplus
extern "C" {   
#endif

/* -----------------------------------------------------------------------------
 * constants/methods manipulation
 * ----------------------------------------------------------------------------- */

/* Install Constants */

alaqilINTERN void
alaqil_Tcl_InstallConstants(Tcl_Interp *interp, alaqil_const_info constants[]) {
  size_t i;
  Tcl_Obj *obj;

  if (!alaqilconstTableinit) {
    Tcl_InitHashTable(&alaqilconstTable, TCL_STRING_KEYS);
    alaqilconstTableinit = 1;
  }
  for (i = 0; constants[i].type; i++) {
    switch(constants[i].type) {
    case alaqil_TCL_POINTER:
      obj = alaqil_NewPointerObj(constants[i].pvalue, *(constants[i]).ptype,0);
      break;
    case alaqil_TCL_BINARY:
      obj = alaqil_NewPackedObj(constants[i].pvalue, constants[i].lvalue, *(constants[i].ptype));
      break;
    default:
      obj = 0;
      break;
    }
    if (obj) {
      alaqil_Tcl_SetConstantObj(interp, constants[i].name, obj);
    }
  }
}

/* Create fast method lookup tables */

alaqilINTERN void
alaqil_Tcl_InstallMethodLookupTables(void) {
  size_t i;

  for (i = 0; i < alaqil_module.size; ++i) {
    alaqil_type_info *type = alaqil_module.type_initial[i];
    if (type->clientdata) {
      alaqil_class* klass = (alaqil_class*) type->clientdata;
      alaqil_method* meth;
      Tcl_InitHashTable(&(klass->hashtable), TCL_STRING_KEYS);
      for (meth = klass->methods; meth && meth->name; ++meth) {
        int newEntry;
        Tcl_HashEntry* hashentry = Tcl_CreateHashEntry(&(klass->hashtable), meth->name, &newEntry);
        Tcl_SetHashValue(hashentry, (ClientData)meth->method);
      }
    }
  }
}

#ifdef __cplusplus
}
#endif

/* -----------------------------------------------------------------------------*
 *  Partial Init method
 * -----------------------------------------------------------------------------*/

alaqilEXPORT int alaqil_init(Tcl_Interp *interp) {
  size_t i;
  if (interp == 0) return TCL_ERROR;
#ifdef USE_TCL_STUBS
  /* (char*) cast is required to avoid compiler warning/error for Tcl < 8.4. */
  if (Tcl_InitStubs(interp, (char*)alaqil_TCL_STUBS_VERSION, 0) == NULL) {
    return TCL_ERROR;
  }
#endif  
#ifdef USE_TK_STUBS
  /* (char*) cast is required to avoid compiler warning/error. */
  if (Tk_InitStubs(interp, (char*)alaqil_TCL_STUBS_VERSION, 0) == NULL) {
    return TCL_ERROR;
  }
#endif

  Tcl_PkgProvide(interp, (char*)alaqil_name, (char*)alaqil_version);
  
#ifdef alaqil_namespace
  Tcl_Eval(interp, "namespace eval " alaqil_namespace " { }");
#endif
  
  alaqil_InitializeModule((void *) interp);
  alaqil_PropagateClientData();
  
  for (i = 0; alaqil_commands[i].name; i++) {
    Tcl_CreateObjCommand(interp, (char *) alaqil_commands[i].name, (alaqil_wrapper_func) alaqil_commands[i].wrapper,
			 alaqil_commands[i].clientdata, NULL);
  }
  for (i = 0; alaqil_variables[i].name; i++) {
    Tcl_SetVar(interp, (char *) alaqil_variables[i].name, (char *) "", TCL_GLOBAL_ONLY);
    Tcl_TraceVar(interp, (char *) alaqil_variables[i].name, TCL_TRACE_READS | TCL_GLOBAL_ONLY, 
		 (Tcl_VarTraceProc *) alaqil_variables[i].get, (ClientData) alaqil_variables[i].addr);
    Tcl_TraceVar(interp, (char *) alaqil_variables[i].name, TCL_TRACE_WRITES | TCL_GLOBAL_ONLY, 
		 (Tcl_VarTraceProc *) alaqil_variables[i].set, (ClientData) alaqil_variables[i].addr);
  }

  alaqil_Tcl_InstallConstants(interp, alaqil_constants);
  alaqil_Tcl_InstallMethodLookupTables();

%}

/* Note: the initialization function is closed after all code is generated */
