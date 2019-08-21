/* -----------------------------------------------------------------------------
 * luatypemaps.swg
 *
 * basic typemaps for Lua.
 * ----------------------------------------------------------------------------- */

/* -----------------------------------------------------------------------------
 *                          standard typemaps
 * ----------------------------------------------------------------------------- */
/* NEW LANGUAGE NOTE:
   the 'checkfn' param is something that I added for typemap(in)
   it is an optional fn call to check the type of the lua object
   the fn call must be of the form
     int checkfn(lua_State *L, int index);
   and return 1/0 depending upon if this is the correct type
   For the typemap(out), an additional alaqil_arg parameter must be incremented
   to reflect the number of values returned (normally alaqil_arg++; will do)
*/
// numbers
%typemap(in,checkfn="lua_isnumber") int, short, long,
             signed char, float, double
%{$1 = ($type)lua_tonumber(L, $input);%}
 
// additional check for unsigned numbers, to not permit negative input
%typemap(in,checkfn="lua_isnumber") unsigned int,
             unsigned short, unsigned long, unsigned char
%{alaqil_contract_assert((lua_tonumber(L,$input)>=0),"number must not be negative")
$1 = ($type)lua_tonumber(L, $input);%}

%typemap(out) int,short,long,
             unsigned int,unsigned short,unsigned long,
             signed char,unsigned char,
             float,double
%{  lua_pushnumber(L, (lua_Number) $1); alaqil_arg++;%}

// we must also provide typemaps for primitives by const reference:
// given a function:
//	int intbyref(const int& i);
// alaqil assumes that this code will need a pointer to int to be passed in
// (this might be ok for objects by const ref, but not for numeric primitives)
// therefore we add a set of typemaps to fix this (for both in & out)
%typemap(in,checkfn="lua_isnumber") const int&($basetype temp)
%{ temp=($basetype)lua_tonumber(L,$input); $1=&temp;%}

%typemap(in,checkfn="lua_isnumber") const unsigned int&($basetype temp)
%{alaqil_contract_assert((lua_tonumber(L,$input)>=0),"number must not be negative")
temp=($basetype)lua_tonumber(L,$input); $1=&temp;%}

%typemap(out) const int&, const unsigned int&
%{  lua_pushnumber(L, (lua_Number) *$1); alaqil_arg++;%}

// for the other numbers we can just use an apply statement to cover them
%apply const int & {const short&,const long&,const signed char&,
             const float&,const double&};

%apply const unsigned int & {const unsigned short&,const unsigned long&,
             const unsigned char&};

/* enums have to be handled slightly differently
	VC++ .net will not allow a cast from lua_Number(double) to enum directly.
*/
%typemap(in,checkfn="lua_isnumber") enum alaqilTYPE
%{$1 = ($type)(int)lua_tonumber(L, $input);%}

%typemap(out) enum alaqilTYPE
%{  lua_pushnumber(L, (lua_Number)(int)($1)); alaqil_arg++;%}

// and const refs
%typemap(in,checkfn="lua_isnumber") const enum alaqilTYPE &($basetype temp)
%{ temp=($basetype)(int)lua_tonumber(L,$input); $1=&temp;%}
%typemap(in,checkfn="lua_isnumber") const enum alaqilTYPE &&($basetype temp)
%{ temp=($basetype)(int)lua_tonumber(L,$input); $1=&temp;%}
%typemap(out) const enum alaqilTYPE &
%{  lua_pushnumber(L, (lua_Number) *$1); alaqil_arg++;%}
%typemap(out) const enum alaqilTYPE &&
%{  lua_pushnumber(L, (lua_Number) *$1); alaqil_arg++;%}


// boolean (which is a special type in lua)
// note: lua_toboolean() returns 1 or 0
// note: 1 & 0 are not booleans in lua, only true & false
%typemap(in,checkfn="lua_isboolean") bool
%{$1 = (lua_toboolean(L, $input)!=0);%}

%typemap(out) bool
%{  lua_pushboolean(L,(int)($1!=0)); alaqil_arg++;%}

// for const bool&, alaqil treats this as a const bool* so we must dereference it
%typemap(in,checkfn="lua_isboolean") const bool& (bool temp)
%{temp=(lua_toboolean(L, $input)!=0);
  $1=&temp;%}

%typemap(out) const bool&
%{  lua_pushboolean(L,(int)((*$1)!=0)); alaqil_arg++;%}

// strings (char * and char[])
%fragment("alaqil_lua_isnilstring", "header") {
alaqilINTERN int alaqil_lua_isnilstring(lua_State *L, int idx) {
  int ret = lua_isstring(L, idx);
  if (!ret)
   ret = lua_isnil(L, idx);
  return ret;
}
}

%typemap(in,checkfn="alaqil_lua_isnilstring",fragment="alaqil_lua_isnilstring") const char *, char *
%{$1 = ($ltype)lua_tostring(L, $input);%}

%typemap(in,checkfn="alaqil_lua_isnilstring",fragment="alaqil_lua_isnilstring") const char[ANY], char[ANY]
%{$1 = ($ltype)lua_tostring(L, $input);%}

%typemap(out) const char *, char *
%{  lua_pushstring(L,(const char *)$1); alaqil_arg++;%}

%typemap(out) const char[ANY], char[ANY]
%{  lua_pushstring(L,(const char *)$1); alaqil_arg++;%}

// char's
// currently treating chars as small strings, not as numbers
// (however signed & unsigned char's are numbers...)
%typemap(in,checkfn="alaqil_lua_isnilstring",fragment="alaqil_lua_isnilstring") char
%{$1 = (lua_tostring(L, $input))[0];%}

%typemap(out) char
%{  lua_pushlstring(L, &$1, 1); alaqil_arg++;%}

// by const ref
%typemap(in,checkfn="alaqil_lua_isnilstring",fragment="alaqil_lua_isnilstring") const char& (char temp)
%{temp = (lua_tostring(L, $input))[0]; $1=&temp;%}

%typemap(out) const char&
%{  lua_pushlstring(L, $1, 1); alaqil_arg++;%}

// pointers and references
// under alaqil rules, it is ok, to have a pass in a lua nil,
// it should be converted to a alaqil NULL.
// This will only be allowed for pointers & arrays, not refs or by value
// the checkfn lua_isuserdata will only work for userdata
// the checkfn alaqil_isptrtype will work for both userdata and nil
%typemap(in,checkfn="alaqil_isptrtype") alaqilTYPE*,alaqilTYPE[]
%{
  if (!alaqil_IsOK(alaqil_ConvertPtr(L,$input,(void**)&$1,$descriptor,$disown))){
    alaqil_fail_ptr("$symname",$argnum,$descriptor);
  }
%}

%typemap(in,checkfn="lua_isuserdata") alaqilTYPE&
%{
  if (!alaqil_IsOK(alaqil_ConvertPtr(L,$input,(void**)&$1,$descriptor,$disown))){
    alaqil_fail_ptr("$symname",$argnum,$descriptor);
  }
%}

%typemap(in,checkfn="lua_isuserdata") alaqilTYPE&&
%{
  if (!alaqil_IsOK(alaqil_ConvertPtr(L,$input,(void**)&$1,$descriptor,$disown))){
    alaqil_fail_ptr("$symname",$argnum,$descriptor);
  }
%}

// out is simple
%typemap(out) alaqilTYPE*,alaqilTYPE&
%{alaqil_NewPointerObj(L,$1,$descriptor,$owner); alaqil_arg++; %}
%typemap(out) alaqilTYPE*,alaqilTYPE&&
%{alaqil_NewPointerObj(L,$1,$descriptor,$owner); alaqil_arg++; %}

// dynamic casts
// this uses the alaqil_TypeDynamicCast() which relies on RTTI to find out what the pointer really is
// the we return it as the correct type
%typemap(out) alaqilTYPE *DYNAMIC,
              alaqilTYPE &DYNAMIC
{
  alaqil_type_info *ty = alaqil_TypeDynamicCast($1_descriptor, (void **) &$1);
  alaqil_NewPointerObj(L,(void*)$1,ty,$owner); alaqil_arg++; 
}


// passing objects by value
// alaqil_ConvertPtr wants an object pointer (the $&ltype argp)
// then dereferences it to get the object
%typemap(in,checkfn="lua_isuserdata") alaqilTYPE ($&ltype argp)
%{
   if (!alaqil_IsOK(alaqil_ConvertPtr(L,$input,(void**)&argp,$&descriptor,0))){
     alaqil_fail_ptr("$symname",$argnum,$&descriptor);
   }
   $1 = *argp;
%}

// Also needed for object ptrs by const ref
// eg A* const& ref_pointer(A* const& a);
// found in mixed_types.i
%typemap(in,checkfn="alaqil_isptrtype") alaqilTYPE *const&($*ltype temp)
%{temp=($*ltype)alaqil_MustGetPtr(L,$input,$*descriptor,0,$argnum,"$symname");
$1=($1_ltype)&temp;%}

%typemap(out) alaqilTYPE *const&
%{alaqil_NewPointerObj(L,*$1,$*descriptor,$owner); alaqil_arg++; %}


// DISOWN-ing typemaps
// if you have an object pointer which must be disowned, use this typemap
// eg. for void destroy_foo(Foo* toDie);
// use %apply alaqilTYPE* DISOWN {Foo* toDie};
// you could just use %delobject, but this is more flexible
%typemap(in,checkfn="alaqil_isptrtype") alaqilTYPE* DISOWN,alaqilTYPE DISOWN[]
%{  if (!alaqil_IsOK(alaqil_ConvertPtr(L,$input,(void**)&$1,$descriptor,alaqil_POINTER_DISOWN))){
    alaqil_fail_ptr("$symname",$argnum,$descriptor);
  }
%}


// Primitive types--return by value
// must make a new object, copy the data & return the new object
// Note: the brackets are {...} and not %{..%}, because we want them to be included in the wrapper
// this is because typemap(out) does not support local variables, like in typemap(in) does
// and we need the $&1_ltype resultptr; to be declared
#ifdef __cplusplus
%typemap(out) alaqilTYPE
{
  $&1_ltype resultptr = new $1_ltype((const $1_ltype &) $1);
  alaqil_NewPointerObj(L,(void *) resultptr,$&1_descriptor,1); alaqil_arg++;
}
#else
%typemap(out) alaqilTYPE
{
  $&1_ltype resultptr;
  resultptr = ($&1_ltype) malloc(sizeof($1_type));
  memmove(resultptr, &$1, sizeof($1_type));
  alaqil_NewPointerObj(L,(void *) resultptr,$&1_descriptor,1); alaqil_arg++;
}
#endif

// member function pointer
// a member fn ptr is not 4 bytes like a normal pointer, but 8 bytes (at least on mingw)
// so the standard wrapping cannot be done
// nor can you cast a member function pointer to a void* (obviously)
// therefore a special wrapping functions alaqil_ConvertMember() & alaqil_NewMemberObj() were written
%typemap(in,checkfn="lua_isuserdata") alaqilTYPE (CLASS::*)
%{
  if (!alaqil_IsOK(alaqil_ConvertMember(L,$input,(void*)(&$1),sizeof($type),$descriptor)))
    alaqil_fail_ptr("$symname",$argnum,$descriptor);
%}

%typemap(out) alaqilTYPE (CLASS::*)
%{ 
  alaqil_NewMemberObj(L,(void*)(&$1),sizeof($type),$descriptor); alaqil_arg++; 
%}


// void (must be empty without the alaqil_arg++)
%typemap(out) void "";

/* void* is a special case
A function void fn(void*) should take any kind of pointer as a parameter (just like C/C++ does)
but if its an output, then it should be wrapped like any other alaqil object (using default typemap)
*/
%typemap(in,checkfn="alaqil_isptrtype") void*
%{$1=($1_ltype)alaqil_MustGetPtr(L,$input,0,0,$argnum,"$symname");%}

/* long long is another special case:
as lua only supports one numeric type (lua_Number), we will just
cast it to that & accept the loss of precision.
An alternative solution would be a long long struct or class
with the relevant operators.
*/
%apply long {long long, signed long long, unsigned long long};
%apply const long& {const long long&, const signed long long&, const unsigned long long&};

/* It is possible to also pass a lua_State* into a function, so
void fn(int a, float b, lua_State* s) is wrappable as
> fn(1,4.3) -- note: the state is implicitly passed in
*/
%typemap(in, numinputs=0) lua_State* 
%{$1 = L;%}



/* -----------------------------------------------------------------------------
 *                          typecheck rules
 * ----------------------------------------------------------------------------- */
/* These are needed for the overloaded functions
These define the detection routines which will spot what
parameters match which function
*/

// unfortunately lua only considers one type of number
// so all numbers (int,float,double) match
// you could add an advanced fn to get type & check if its integral
%typecheck(alaqil_TYPECHECK_INTEGER)
	 int, short, long,
 	 unsigned int, unsigned short, unsigned long,
	 signed char, unsigned char,
	 long long, unsigned long long, signed long long,
	 const int &, const short &, const long &,
 	 const unsigned int &, const unsigned short &, const unsigned long &,
	 const signed char&, const unsigned char&,
	 const long long &, const unsigned long long &,
	 enum alaqilTYPE,	const enum alaqilTYPE&, const enum alaqilTYPE &&,
	 float, double, const float &, const double&
{
  $1 = lua_isnumber(L,$input);
}

%typecheck(alaqil_TYPECHECK_BOOL)
    bool, const bool &
{
  $1 = lua_isboolean(L,$input);
}

// special check for a char (string of length 1)
%typecheck(alaqil_TYPECHECK_CHAR,fragment="alaqil_lua_isnilstring") char, const char& {
  $1 = alaqil_lua_isnilstring(L,$input) && (lua_rawlen(L,$input)==1);
}

%typecheck(alaqil_TYPECHECK_STRING,fragment="alaqil_lua_isnilstring") char *, char[] {
  $1 = alaqil_lua_isnilstring(L,$input);
}

%typecheck(alaqil_TYPECHECK_POINTER) alaqilTYPE *, alaqilTYPE [] {
  void *ptr;
  if (alaqil_isptrtype(L,$input)==0 || alaqil_ConvertPtr(L,$input, (void **) &ptr, $1_descriptor, 0)) {
    $1 = 0;
  } else {
    $1 = 1;
  }
}

%typecheck(alaqil_TYPECHECK_POINTER) alaqilTYPE & {
  void *ptr;
  if (lua_isuserdata(L,$input)==0 || alaqil_ConvertPtr(L,$input, (void **) &ptr, $1_descriptor, alaqil_POINTER_NO_NULL)) {
    $1 = 0;
  } else {
    $1 = 1;
  }
}

%typecheck(alaqil_TYPECHECK_POINTER) alaqilTYPE && {
  void *ptr;
  if (lua_isuserdata(L,$input)==0 || alaqil_ConvertPtr(L,$input, (void **) &ptr, $1_descriptor, alaqil_POINTER_NO_NULL)) {
    $1 = 0;
  } else {
    $1 = 1;
  }
}

%typecheck(alaqil_TYPECHECK_POINTER) alaqilTYPE {
  void *ptr;
  if (lua_isuserdata(L,$input)==0 || alaqil_ConvertPtr(L,$input, (void **) &ptr, $&1_descriptor, alaqil_POINTER_NO_NULL)) {
    $1 = 0;
  } else {
    $1 = 1;
  }
}

%typecheck(alaqil_TYPECHECK_VOIDPTR) void * {
  void *ptr;
  if (alaqil_isptrtype(L,$input)==0 || alaqil_ConvertPtr(L,$input, (void **) &ptr, 0, 0)) {
    $1 = 0;
  } else {
    $1 = 1;
  }
}

// Also needed for object pointers by const ref
// eg const A* ref_pointer(A* const& a);
// found in mixed_types.i
%typecheck(alaqil_TYPECHECK_POINTER) alaqilTYPE *const&
{
  void *ptr;
  if (alaqil_isptrtype(L,$input)==0 || alaqil_ConvertPtr(L,$input, (void **) &ptr, $*descriptor, 0)) {
    $1 = 0;
  } else {
    $1 = 1;
  }
}

/* -----------------------------------------------------------------------------
 *                          Others
 * ----------------------------------------------------------------------------- */

// Array reference typemaps
%apply alaqilTYPE & { alaqilTYPE ((&)[ANY]) }
%apply alaqilTYPE && { alaqilTYPE ((&&)[ANY]) }

/* const pointers */
%apply alaqilTYPE * { alaqilTYPE *const }
%apply alaqilTYPE (CLASS::*) { alaqilTYPE (CLASS::*const) }
%apply alaqilTYPE & { alaqilTYPE (CLASS::*const&) }

// size_t (which is just a unsigned long)
%apply unsigned long { size_t };
%apply const unsigned long & { const size_t & };


/* -----------------------------------------------------------------------------
 *                          Specials
 * ----------------------------------------------------------------------------- */
// alaqil::LANGUAGE_OBJ was added to allow containers of native objects
// however its rather difficult to do this in lua, as you cannot hold pointers
// to native objects (they are held in the interpreter)
// therefore for now: just ignoring this feature
#ifdef __cplusplus
%ignore alaqil::LANGUAGE_OBJ;

//%inline %{
%{
namespace alaqil {
typedef struct{} LANGUAGE_OBJ;
}
%}

#endif // __cplusplus
