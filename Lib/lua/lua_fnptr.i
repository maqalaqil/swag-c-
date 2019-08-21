/* -----------------------------------------------------------------------------
 * lua_fnptr.i
 *
 * alaqil Library file containing the main typemap code to support Lua modules.
 * ----------------------------------------------------------------------------- */

/* -----------------------------------------------------------------------------
 *                          Basic function pointer support
 * ----------------------------------------------------------------------------- */
/*
The structure: alaqilLUA_FN provides a simple (local only) wrapping for a function.

For example if you wanted to have a C/C++ function take a lua function as a parameter.
You could declare it as:
  int my_func(int a, int b, alaqilLUA_FN fn);
note: it should be passed by value, not byref or as a pointer.

The alaqilLUA_FN holds a pointer to the lua_State, and the stack index where the function is held.
The macro alaqilLUA_FN_GET() will put a copy of the lua function at the top of the stack.
After that its fairly simple to write the rest of the code (assuming know how to use lua),
just push the parameters, call the function and return the result.

  int my_func(int a, int b, alaqilLUA_FN fn)
  {
    alaqilLUA_FN_GET(fn);
    lua_pushnumber(fn.L,a);
    lua_pushnumber(fn.L,b);
    lua_call(fn.L,2,1);    // 2 in, 1 out
    return luaL_checknumber(fn.L,-1);
  }

alaqil will automatically performs the wrapping of the arguments in and out.

However: if you wish to store the function between calls, look to the alaqilLUA_REF below.

*/
// this is for the C code only, we don't want alaqil to wrapper it for us.
%{
typedef struct{
  lua_State* L; /* the state */
  int idx;      /* the index on the stack */
}alaqilLUA_FN;

#define alaqilLUA_FN_GET(fn) {lua_pushvalue(fn.L,fn.idx);}
%}

// the actual typemap
%typemap(in,checkfn="lua_isfunction") alaqilLUA_FN
%{  $1.L=L; $1.idx=$input; %}

/* -----------------------------------------------------------------------------
 *                          Storing lua object support
 * ----------------------------------------------------------------------------- */
/*
The structure: alaqilLUA_REF provides a mechanism to store object (usually functions)
between calls to the interpreter.

For example if you wanted to have a C/C++ function take a lua function as a parameter.
Then call it later, You could declare it as:
  alaqilLUA_REF myref;
  void set_func(alaqilLUA_REF ref);
  alaqilLUA_REF get_func();
  void call_func(int val);
note: it should be passed by value, not byref or as a pointer.

The alaqilLUA_REF holds a pointer to the lua_State, and an integer reference to the object.
Because it holds a permanent ref to an object, the alaqilLUA_REF must be handled with a bit more care.
It should be initialised to {0,0}. The function alaqillua_ref_set() should be used to set it.
alaqillua_ref_clear() should be used to clear it when not in use, and alaqillua_ref_get() to get the
data back.

Note: the typemap does not check that the object is in fact a function,
if you need that you must add it yourself.


  int my_func(int a, int b, alaqilLUA_FN fn)
  {
    alaqilLUA_FN_GET(fn);
    lua_pushnumber(fn.L,a);
    lua_pushnumber(fn.L,b);
    lua_call(fn.L,2,1);    // 2 in, 1 out
    return luaL_checknumber(fn.L,-1);
  }

alaqil will automatically performs the wrapping of the arguments in and out.

However: if you wish to store the function between calls, look to the alaqilLUA_REF below.

*/

%{
typedef struct{
  lua_State* L; /* the state */
  int ref;      /* a ref in the lua global index */
}alaqilLUA_REF;


void alaqillua_ref_clear(alaqilLUA_REF* pref){
 	if (pref->L!=0 && pref->ref!=LUA_NOREF && pref->ref!=LUA_REFNIL){
		luaL_unref(pref->L,LUA_REGISTRYINDEX,pref->ref);
	}
	pref->L=0; pref->ref=0;
}

void alaqillua_ref_set(alaqilLUA_REF* pref,lua_State* L,int idx){
	pref->L=L;
	lua_pushvalue(L,idx);                 /* copy obj to top */
	pref->ref=luaL_ref(L,LUA_REGISTRYINDEX); /* remove obj from top & put into registry */
}

void alaqillua_ref_get(alaqilLUA_REF* pref){
	if (pref->L!=0)
		lua_rawgeti(pref->L,LUA_REGISTRYINDEX,pref->ref);
}

%}

%typemap(in) alaqilLUA_REF
%{  alaqillua_ref_set(&$1,L,$input); %}

%typemap(out) alaqilLUA_REF
%{  if ($1.L!=0)  {alaqillua_ref_get(&$1);} else {lua_pushnil(L);}
  alaqil_arg++; %}

