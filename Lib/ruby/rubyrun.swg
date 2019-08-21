/* -----------------------------------------------------------------------------
 * rubyrun.swg
 *
 * This file contains the runtime support for Ruby modules
 * and includes code for managing global variables and pointer
 * type checking.
 * ----------------------------------------------------------------------------- */

/* For backward compatibility only */
#define alaqil_POINTER_EXCEPTION  0

/* for raw pointers */
#define alaqil_ConvertPtr(obj, pptr, type, flags)         alaqil_Ruby_ConvertPtrAndOwn(obj, pptr, type, flags, 0)
#define alaqil_ConvertPtrAndOwn(obj,pptr,type,flags,own)  alaqil_Ruby_ConvertPtrAndOwn(obj, pptr, type, flags, own)
#define alaqil_NewPointerObj(ptr, type, flags)            alaqil_Ruby_NewPointerObj(ptr, type, flags)
#define alaqil_AcquirePtr(ptr, own)                       alaqil_Ruby_AcquirePtr(ptr, own)
#define alaqil_owntype                                    alaqil_ruby_owntype

/* for raw packed data */
#define alaqil_ConvertPacked(obj, ptr, sz, ty)            alaqil_Ruby_ConvertPacked(obj, ptr, sz, ty, flags)
#define alaqil_NewPackedObj(ptr, sz, type)                alaqil_Ruby_NewPackedObj(ptr, sz, type)

/* for class or struct pointers */
#define alaqil_ConvertInstance(obj, pptr, type, flags)    alaqil_ConvertPtr(obj, pptr, type, flags)
#define alaqil_NewInstanceObj(ptr, type, flags)           alaqil_NewPointerObj(ptr, type, flags)

/* for C or C++ function pointers */
#define alaqil_ConvertFunctionPtr(obj, pptr, type)        alaqil_ConvertPtr(obj, pptr, type, 0)
#define alaqil_NewFunctionPtrObj(ptr, type)               alaqil_NewPointerObj(ptr, type, 0)

/* for C++ member pointers, ie, member methods */
#define alaqil_ConvertMember(obj, ptr, sz, ty)            alaqil_Ruby_ConvertPacked(obj, ptr, sz, ty)
#define alaqil_NewMemberObj(ptr, sz, type)                alaqil_Ruby_NewPackedObj(ptr, sz, type)


/* Runtime API */

#define alaqil_GetModule(clientdata)                      alaqil_Ruby_GetModule(clientdata)
#define alaqil_SetModule(clientdata, pointer) 		alaqil_Ruby_SetModule(pointer)


/* Error manipulation */

#define alaqil_ErrorType(code)                            alaqil_Ruby_ErrorType(code)               
#define alaqil_Error(code, msg)            		rb_raise(alaqil_Ruby_ErrorType(code), "%s", msg)
#define alaqil_fail                        		goto fail				 


/* Ruby-specific alaqil API */

#define alaqil_InitRuntime()                              alaqil_Ruby_InitRuntime()              
#define alaqil_define_class(ty)                        	alaqil_Ruby_define_class(ty)
#define alaqil_NewClassInstance(value, ty)             	alaqil_Ruby_NewClassInstance(value, ty)
#define alaqil_MangleStr(value)                        	alaqil_Ruby_MangleStr(value)		  
#define alaqil_CheckConvert(value, ty)                 	alaqil_Ruby_CheckConvert(value, ty)	  

#include "assert.h"

/* -----------------------------------------------------------------------------
 * pointers/data manipulation
 * ----------------------------------------------------------------------------- */

#ifdef __cplusplus
extern "C" {
#endif

typedef struct {
  VALUE klass;
  VALUE mImpl;
  void  (*mark)(void *);
  void  (*destroy)(void *);
  int trackObjects;
} alaqil_class;


/* Global pointer used to keep some internal alaqil stuff */
static VALUE _calaqil_Pointer = Qnil;
static VALUE alaqil_runtime_data_type_pointer = Qnil;

/* Global IDs used to keep some internal alaqil stuff */
static ID alaqil_arity_id = 0;
static ID alaqil_call_id  = 0;

/*
  If your alaqil extension is to be run within an embedded ruby and has
  director callbacks, you should set -DRUBY_EMBEDDED during compilation.  
  This will reset ruby's stack frame on each entry point from the main 
  program the first time a virtual director function is invoked (in a 
  non-recursive way).
  If this is not done, you run the risk of Ruby trashing the stack.
*/

#ifdef RUBY_EMBEDDED

#  define alaqil_INIT_STACK                            \
      if ( !alaqil_virtual_calls ) { RUBY_INIT_STACK } \
      ++alaqil_virtual_calls;
#  define alaqil_RELEASE_STACK --alaqil_virtual_calls;
#  define Ruby_DirectorTypeMismatchException(x) \
          rb_raise( rb_eTypeError, "%s", x ); return c_result;

      static unsigned int alaqil_virtual_calls = 0;

#else  /* normal non-embedded extension */

#  define alaqil_INIT_STACK
#  define alaqil_RELEASE_STACK
#  define Ruby_DirectorTypeMismatchException(x) \
          throw alaqil::DirectorTypeMismatchException( x );

#endif  /* RUBY_EMBEDDED */


alaqilRUNTIME VALUE 
getExceptionClass(void) {
  static int init = 0;
  static VALUE rubyExceptionClass ;
  if (!init) {
    init = 1;
    rubyExceptionClass = rb_const_get(_malaqil, rb_intern("Exception"));
  }
  return rubyExceptionClass;
} 

/* This code checks to see if the Ruby object being raised as part
   of an exception inherits from the Ruby class Exception.  If so,
   the object is simply returned.  If not, then a new Ruby exception
   object is created and that will be returned to Ruby.*/
alaqilRUNTIME VALUE
alaqil_Ruby_ExceptionType(alaqil_type_info *desc, VALUE obj) {
  VALUE exceptionClass = getExceptionClass();
  if (rb_obj_is_kind_of(obj, exceptionClass)) {
    return obj;
  }  else {
    return rb_exc_new3(rb_eRuntimeError, rb_obj_as_string(obj));
  }
}

/* Initialize Ruby runtime support */
alaqilRUNTIME void
alaqil_Ruby_InitRuntime(void)
{
  if (_malaqil == Qnil) {
    _malaqil = rb_define_module("alaqil");
    alaqil_call_id  = rb_intern("call");
    alaqil_arity_id = rb_intern("arity");
  }
}

/* Define Ruby class for C type */
alaqilRUNTIME void
alaqil_Ruby_define_class(alaqil_type_info *type)
{
  char *klass_name = (char *) malloc(4 + strlen(type->name) + 1);
  sprintf(klass_name, "TYPE%s", type->name);
  if (NIL_P(_calaqil_Pointer)) {
    _calaqil_Pointer = rb_define_class_under(_malaqil, "Pointer", rb_cObject);
    rb_undef_method(CLASS_OF(_calaqil_Pointer), "new");
  }
  rb_define_class_under(_malaqil, klass_name, _calaqil_Pointer);
  free((void *) klass_name);
}

/* Create a new pointer object */
alaqilRUNTIME VALUE
alaqil_Ruby_NewPointerObj(void *ptr, alaqil_type_info *type, int flags)
{
  int own =  flags & alaqil_POINTER_OWN; 
  int track;
  char *klass_name;
  alaqil_class *sklass;
  VALUE klass;
  VALUE obj;

  if (!ptr)
    return Qnil;

  assert(type);
  if (type->clientdata) {
    sklass = (alaqil_class *) type->clientdata;
		
    /* Are we tracking this class and have we already returned this Ruby object? */
    track = sklass->trackObjects;
    if (track) {
      obj = alaqil_RubyInstanceFor(ptr);

      /* Check the object's type and make sure it has the correct type.
        It might not in cases where methods do things like 
        downcast methods. */
      if (obj != Qnil) {
        VALUE value = rb_iv_get(obj, "@__alaqiltype__");
        const char* type_name = RSTRING_PTR(value);
				
        if (strcmp(type->name, type_name) == 0) {
          return obj;
        }
      }
    }

    /* Create a new Ruby object */
    obj = Data_Wrap_Struct(sklass->klass, VOIDFUNC(sklass->mark), 
			   ( own ? VOIDFUNC(sklass->destroy) : 
			     (track ? VOIDFUNC(alaqil_RubyRemoveTracking) : 0 )
			     ), ptr);

    /* If tracking is on for this class then track this object. */
    if (track) {
      alaqil_RubyAddTracking(ptr, obj);
    }
  } else {
    klass_name = (char *) malloc(4 + strlen(type->name) + 1);
    sprintf(klass_name, "TYPE%s", type->name);
    klass = rb_const_get(_malaqil, rb_intern(klass_name));
    free((void *) klass_name);
    obj = Data_Wrap_Struct(klass, 0, 0, ptr);
  }
  rb_iv_set(obj, "@__alaqiltype__", rb_str_new2(type->name));

  return obj;
}

/* Create a new class instance (always owned) */
alaqilRUNTIME VALUE
alaqil_Ruby_NewClassInstance(VALUE klass, alaqil_type_info *type)
{
  VALUE obj;
  alaqil_class *sklass = (alaqil_class *) type->clientdata;
  obj = Data_Wrap_Struct(klass, VOIDFUNC(sklass->mark), VOIDFUNC(sklass->destroy), 0);
  rb_iv_set(obj, "@__alaqiltype__", rb_str_new2(type->name));
  return obj;
}

/* Get type mangle from class name */
alaqilRUNTIMEINLINE char *
alaqil_Ruby_MangleStr(VALUE obj)
{
  VALUE stype = rb_iv_get(obj, "@__alaqiltype__");
  return StringValuePtr(stype);
}

/* Acquire a pointer value */
typedef struct {
  void (*datafree)(void *);
  int own;
} alaqil_ruby_owntype;

alaqilRUNTIME alaqil_ruby_owntype
alaqil_Ruby_AcquirePtr(VALUE obj, alaqil_ruby_owntype own) {
  alaqil_ruby_owntype oldown = {0, 0};
  if (TYPE(obj) == T_DATA && !RTYPEDDATA_P(obj)) {
    oldown.datafree = RDATA(obj)->dfree;
    RDATA(obj)->dfree = own.datafree;
  }
  return oldown;
}

/* Convert a pointer value */
alaqilRUNTIME int
alaqil_Ruby_ConvertPtrAndOwn(VALUE obj, void **ptr, alaqil_type_info *ty, int flags, alaqil_ruby_owntype *own)
{
  char *c;
  alaqil_cast_info *tc;
  void *vptr = 0;

  /* Grab the pointer */
  if (NIL_P(obj)) {
    if (ptr)
      *ptr = 0;
    return (flags & alaqil_POINTER_NO_NULL) ? alaqil_NullReferenceError : alaqil_OK;
  } else {
    if (TYPE(obj) != T_DATA || (TYPE(obj) == T_DATA && RTYPEDDATA_P(obj))) {
      return alaqil_ERROR;
    }
    Data_Get_Struct(obj, void, vptr);
  }
  
  if (own) {
    own->datafree = RDATA(obj)->dfree;
    own->own = 0;
  }
    
  /* Check to see if the input object is giving up ownership
     of the underlying C struct or C++ object.  If so then we
     need to reset the destructor since the Ruby object no 
     longer owns the underlying C++ object.*/ 
  if (flags & alaqil_POINTER_DISOWN) {
    /* Is tracking on for this class? */
    int track = 0;
    if (ty && ty->clientdata) {
      alaqil_class *sklass = (alaqil_class *) ty->clientdata;
      track = sklass->trackObjects;
    }
		
    if (track) {
      /* We are tracking objects for this class.  Thus we change the destructor
       * to alaqil_RubyRemoveTracking.  This allows us to
       * remove the mapping from the C++ to Ruby object
       * when the Ruby object is garbage collected.  If we don't
       * do this, then it is possible we will return a reference 
       * to a Ruby object that no longer exists thereby crashing Ruby. */
      RDATA(obj)->dfree = alaqil_RubyRemoveTracking;
    } else {    
      RDATA(obj)->dfree = 0;
    }
  }

  /* Do type-checking if type info was provided */
  if (ty) {
    if (ty->clientdata) {
      if (rb_obj_is_kind_of(obj, ((alaqil_class *) (ty->clientdata))->klass)) {
        if (vptr == 0) {
          /* The object has already been deleted */
          return alaqil_ObjectPreviouslyDeletedError;
        }
      }
    }
    if ((c = alaqil_MangleStr(obj)) == NULL) {
      return alaqil_ERROR;
    }
    tc = alaqil_TypeCheck(c, ty);
    if (!tc) {
      return alaqil_ERROR;
    } else {
      if (ptr) {
        if (tc->type == ty) {
          *ptr = vptr;
        } else {
          int newmemory = 0;
          *ptr = alaqil_TypeCast(tc, vptr, &newmemory);
          if (newmemory == alaqil_CAST_NEW_MEMORY) {
            assert(own); /* badly formed typemap which will lead to a memory leak - it must set and use own to delete *ptr */
            if (own)
              own->own = own->own | alaqil_CAST_NEW_MEMORY;
          }
        }
      }
    }
  } else {
    if (ptr)
      *ptr = vptr;
  }
  
  return alaqil_OK;
}

/* Check convert */
alaqilRUNTIMEINLINE int
alaqil_Ruby_CheckConvert(VALUE obj, alaqil_type_info *ty)
{
  char *c = alaqil_MangleStr(obj);
  if (!c) return 0;
  return alaqil_TypeCheck(c,ty) != 0;
}

alaqilRUNTIME VALUE
alaqil_Ruby_NewPackedObj(void *ptr, int sz, alaqil_type_info *type) {
  char result[1024];
  char *r = result;
  if ((2*sz + 1 + strlen(type->name)) > 1000) return 0;
  *(r++) = '_';
  r = alaqil_PackData(r, ptr, sz);
  strcpy(r, type->name);
  return rb_str_new2(result);
}

/* Convert a packed pointer value */
alaqilRUNTIME int
alaqil_Ruby_ConvertPacked(VALUE obj, void *ptr, int sz, alaqil_type_info *ty) {
  alaqil_cast_info *tc;
  const char  *c;

  if (TYPE(obj) != T_STRING) goto type_error;
  c = StringValuePtr(obj);
  /* Pointer values must start with leading underscore */
  if (*c != '_') goto type_error;
  c++;
  c = alaqil_UnpackData(c, ptr, sz);
  if (ty) {
    tc = alaqil_TypeCheck(c, ty);
    if (!tc) goto type_error;
  }
  return alaqil_OK;

 type_error:
  return alaqil_ERROR;
}

alaqilRUNTIME alaqil_module_info *
alaqil_Ruby_GetModule(void *alaqilUNUSEDPARM(clientdata))
{
  VALUE pointer;
  alaqil_module_info *ret = 0;
  VALUE verbose = rb_gv_get("VERBOSE");

 /* temporarily disable warnings, since the pointer check causes warnings with 'ruby -w' */
  rb_gv_set("VERBOSE", Qfalse);
  
  /* first check if pointer already created */
  pointer = rb_gv_get("$alaqil_runtime_data_type_pointer" alaqil_RUNTIME_VERSION alaqil_TYPE_TABLE_NAME);
  if (pointer != Qnil) {
    Data_Get_Struct(pointer, alaqil_module_info, ret);
  }

  /* reinstate warnings */
  rb_gv_set("VERBOSE", verbose);
  return ret;
}

alaqilRUNTIME void 
alaqil_Ruby_SetModule(alaqil_module_info *pointer)
{
  /* register a new class */
  VALUE cl = rb_define_class("alaqil_runtime_data", rb_cObject);
  /* create and store the structure pointer to a global variable */
  alaqil_runtime_data_type_pointer = Data_Wrap_Struct(cl, 0, 0, pointer);
  rb_define_readonly_variable("$alaqil_runtime_data_type_pointer" alaqil_RUNTIME_VERSION alaqil_TYPE_TABLE_NAME, &alaqil_runtime_data_type_pointer);
}

/* This function can be used to check whether a proc or method or similarly
   callable function has been passed.  Usually used in a %typecheck, like:

   %typecheck(c_callback_t, precedence=alaqil_TYPECHECK_POINTER) {
        $result = alaqil_Ruby_isCallable( $input );
   }
 */
alaqilINTERN
int alaqil_Ruby_isCallable( VALUE proc )
{
  if ( rb_respond_to( proc, alaqil_call_id ) )
    return 1;
  return 0;
}

/* This function can be used to check the arity (number of arguments)
   a proc or method can take.  Usually used in a %typecheck.
   Valid arities will be that equal to minimal or those < 0
   which indicate a variable number of parameters at the end.
 */
alaqilINTERN
int alaqil_Ruby_arity( VALUE proc, int minimal )
{
  if ( rb_respond_to( proc, alaqil_arity_id ) )
    {
      VALUE num = rb_funcall( proc, alaqil_arity_id, 0 );
      int arity = NUM2INT(num);
      if ( arity < 0 && (arity+1) < -minimal ) return 1;
      if ( arity == minimal ) return 1;
      return 1;
    }
  return 0;
}


#ifdef __cplusplus
}
#endif
