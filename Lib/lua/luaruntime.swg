/* -----------------------------------------------------------------------------
 * luaruntime.swg
 *
 * all the runtime code for .
 * ----------------------------------------------------------------------------- */

%runtime "alaqilrun.swg"          /* Common C API type-checking code */
%runtime "alaqilerrors.swg"       /* alaqil errors */
%runtime "luarun.swg"           /* Lua runtime stuff */

%insert(initbeforefunc) "alaqilinit.swg"

%insert(initbeforefunc) %{

/* Forward declaration of where the user's %init{} gets inserted */
void alaqil_init_user(lua_State* L );
    
#ifdef __cplusplus
extern "C" {
#endif
/* this is the initialization function
  added at the very end of the code
  the function is always called alaqil_init, but an earlier #define will rename it
*/
#if ((alaqil_LUA_TARGET == alaqil_LUA_FLAVOR_ELUA) || (alaqil_LUA_TARGET == alaqil_LUA_FLAVOR_ELUAC))
LUALIB_API int alaqil_init(lua_State* L)
#else
alaqilEXPORT int alaqil_init(lua_State* L) /* default Lua action */
#endif
{
#if (alaqil_LUA_TARGET != alaqil_LUA_FLAVOR_ELUAC) /* valid for both Lua and eLua */
  int i;
  int globalRegister = 0;
  /* start with global table */
  lua_pushglobaltable (L);
  /* alaqil's internal initialisation */
  alaqil_InitializeModule((void*)L);
  alaqil_PropagateClientData();
#endif

#if ((alaqil_LUA_TARGET != alaqil_LUA_FLAVOR_ELUA) && (alaqil_LUA_TARGET != alaqil_LUA_FLAVOR_ELUAC)) || defined(alaqil_LUA_ELUA_EMULATE)
  /* add a global fn */
  alaqil_Lua_add_function(L,"alaqil_type",alaqil_Lua_type);
  alaqil_Lua_add_function(L,"alaqil_equals",alaqil_Lua_class_equal);
#endif

#if (alaqil_LUA_TARGET != alaqil_LUA_FLAVOR_ELUAC)
  /* set up base class pointers (the hierarchy) */
  for (i = 0; alaqil_types[i]; i++){
    if (alaqil_types[i]->clientdata){
      alaqil_Lua_init_base_class(L,(alaqil_lua_class*)(alaqil_types[i]->clientdata));
    }
  }
#ifdef alaqil_LUA_MODULE_GLOBAL
  globalRegister = 1;
#endif


#if (alaqil_LUA_TARGET == alaqil_LUA_FLAVOR_LUA)
  alaqil_Lua_namespace_register(L,&alaqil_alaqilModule, globalRegister);
#endif

#if (alaqil_LUA_TARGET == alaqil_LUA_FLAVOR_ELUA) || (alaqil_LUA_TARGET == alaqil_LUA_FLAVOR_ELUAC)
  for (i = 0; alaqil_types[i]; i++){
    if (alaqil_types[i]->clientdata){
      alaqil_Lua_elua_class_register_instance(L,(alaqil_lua_class*)(alaqil_types[i]->clientdata));
    }
  }
#endif

#if defined(alaqil_LUA_ELUA_EMULATE)
  lua_newtable(L);
  alaqil_Lua_elua_emulate_register(L,alaqil_alaqilModule.ns_methods);
  alaqil_Lua_elua_emulate_register_clear(L);
  if(globalRegister) {
    lua_pushstring(L,alaqil_alaqilModule.name);
    lua_pushvalue(L,-2);
    lua_rawset(L,-4);
  }
#endif

#endif

#if (alaqil_LUA_TARGET != alaqil_LUA_FLAVOR_ELUAC)
  /* invoke user-specific initialization */
  alaqil_init_user(L);
  /* end module */
  /* Note: We do not clean up the stack here (Lua will do this for us). At this
     point, we have the globals table and out module table on the stack. Returning
     one value makes the module table the result of the require command. */
  return 1;
#else
  return 0;
#endif
}

#ifdef __cplusplus
}
#endif

%}

/* Note: the initialization function is closed after all code is generated */

