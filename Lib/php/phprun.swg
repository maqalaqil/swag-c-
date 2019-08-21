/* -----------------------------------------------------------------------------
 * phprun.swg
 *
 * PHP runtime library
 * ----------------------------------------------------------------------------- */

#ifdef __cplusplus
extern "C" {
#endif
#include "zend.h"
#include "zend_API.h"
#include "zend_exceptions.h"
#include "php.h"

#if PHP_MAJOR_VERSION != 7
# error These bindings need PHP7 - to generate PHP5 bindings use: alaqil < 4.0.0 and alaqil -php5
#endif

#include "ext/standard/php_string.h"
#include <stdlib.h> /* for abort(), used in generated code. */

/* This indirection is to work around const correctness issues in older PHP.
 * FIXME: Remove for PHP7?  Or might user code be using it? */
#define alaqil_ZEND_NAMED_FE(ZN, N, A) ZEND_NAMED_FE(ZN, N, A)

#define alaqil_BOOL_CONSTANT(N, V) REGISTER_BOOL_CONSTANT(#N, V, CONST_CS | CONST_PERSISTENT)
#define alaqil_LONG_CONSTANT(N, V) REGISTER_LONG_CONSTANT(#N, V, CONST_CS | CONST_PERSISTENT)
#define alaqil_DOUBLE_CONSTANT(N, V) REGISTER_DOUBLE_CONSTANT(#N, V, CONST_CS | CONST_PERSISTENT)
#define alaqil_STRING_CONSTANT(N, V) REGISTER_STRING_CONSTANT(#N, (char*)V, CONST_CS | CONST_PERSISTENT)
#define alaqil_CHAR_CONSTANT(N, V) do {\
    char alaqil_char = (V);\
    REGISTER_STRINGL_CONSTANT(#N, &alaqil_char, 1, CONST_CS | CONST_PERSISTENT);\
} while (0)

/* ZEND_CONSTANT_SET_FLAGS is new in PHP 7.3. */
#ifdef ZEND_CONSTANT_SET_FLAGS
# define alaqil_ZEND_CONSTANT_SET_FLAGS ZEND_CONSTANT_SET_FLAGS
#else
# define alaqil_ZEND_CONSTANT_SET_FLAGS(C, F, N) do { (C)->flags = (F); (C)->module_number = (N); } while (0)
#endif

#ifdef __cplusplus
}
#endif

#define alaqil_fail goto fail

static const char *default_error_msg = "Unknown error occurred";
static int default_error_code = E_ERROR;

#define alaqil_PHP_Arg_Error_Msg(argnum,extramsg) "Error in argument " #argnum " "#extramsg

#define alaqil_PHP_Error(code,msg) do { alaqil_ErrorCode() = code; alaqil_ErrorMsg() = msg; alaqil_fail; } while (0)

#define alaqil_contract_assert(expr,msg) \
  if (!(expr) ) { zend_printf("Contract Assert Failed %s\n",msg ); } else

/* Standard alaqil API */
#define alaqil_GetModule(clientdata) alaqil_Php_GetModule()
#define alaqil_SetModule(clientdata, pointer) alaqil_Php_SetModule(pointer, *(int*)clientdata)

/* used to wrap returned objects in so we know whether they are newobject
   and need freeing, or not */
typedef struct {
  void * ptr;
  int newobject;
} alaqil_object_wrapper;

#define alaqil_as_voidptr(a) const_cast< void * >(static_cast< const void * >(a))

static void
alaqil_SetPointerZval(zval *z, void *ptr, alaqil_type_info *type, int newobject) {
  /*
   * First test for Null pointers.  Return those as PHP native NULL
   */
  if (!ptr ) {
    ZVAL_NULL(z);
    return;
  }
  if (type->clientdata) {
    alaqil_object_wrapper *value;
    if (! (*(int *)(type->clientdata)))
      zend_error(E_ERROR, "Type: %s failed to register with zend",type->name);
    value=(alaqil_object_wrapper *)emalloc(sizeof(alaqil_object_wrapper));
    value->ptr=ptr;
    value->newobject=(newobject & 1);
    if ((newobject & 2) == 0) {
      /* Just register the pointer as a resource. */
      ZVAL_RES(z, zend_register_resource(value, *(int *)(type->clientdata)));
    } else {
      /*
       * Wrap the resource in an object, the resource will be accessible
       * via the "_cPtr" member. This is currently only used by
       * directorin typemaps.
       */
      zval resource;
      zend_class_entry *ce = NULL;
      const char *type_name = type->name+3; /* +3 so: _p_Foo -> Foo */
      size_t type_name_len;
      const char * p;
      HashTable * ht;

      /* Namespace__Foo -> Foo */
      /* FIXME: ugly and goes wrong for classes with __ in their names. */
      while ((p = strstr(type_name, "__")) != NULL) {
        type_name = p + 2;
      }
      type_name_len = strlen(type_name);

      ZVAL_RES(&resource, zend_register_resource(value, *(int *)(type->clientdata)));
      if (alaqil_PREFIX_LEN > 0) {
        zend_string * classname = zend_string_alloc(alaqil_PREFIX_LEN + type_name_len, 0);
        memcpy(classname->val, alaqil_PREFIX, alaqil_PREFIX_LEN);
        memcpy(classname->val + alaqil_PREFIX_LEN, type_name, type_name_len);
        ce = zend_lookup_class(classname);
        zend_string_release(classname);
      } else {
        zend_string * classname = zend_string_init(type_name, type_name_len, 0);
        ce = zend_lookup_class(classname);
        zend_string_release(classname);
      }
      if (ce == NULL) {
        /* class does not exist */
        ce = zend_standard_class_def;
      }

      ALLOC_HASHTABLE(ht);
      zend_hash_init(ht, 1, NULL, NULL, 0);
      zend_hash_str_update(ht, "_cPtr", sizeof("_cPtr") - 1, &resource);
      object_and_properties_init(z, ce, ht);
    }
    return;
  }
  zend_error(E_ERROR, "Type: %s not registered with zend",type->name);
}

/* This pointer conversion routine takes the native pointer p (along with
   its type name) and converts it by calling appropriate casting functions
   according to ty.  The resultant pointer is returned, or NULL is returned
   if the pointer can't be cast.

   Sadly PHP has no API to find a type name from a type id, only from an
   instance of a resource of the type id, so we have to pass type_name as well.

   The two functions which might call this are:
   alaqil_ConvertResourcePtr which gets the type name from the resource
   and the registered zend destructors for which we have one per type each
   with the type name hard wired in. */
static void *
alaqil_ConvertResourceData(void * p, const char *type_name, alaqil_type_info *ty) {
  alaqil_cast_info *tc;
  void *result = 0;

  if (!ty) {
    /* They don't care about the target type, so just pass on the pointer! */
    return p;
  }

  if (! type_name) {  
    /* can't convert p to ptr type ty if we don't know what type p is */
    return NULL;
  }

  /* convert and cast p from type_name to ptr as ty. */
  tc = alaqil_TypeCheck(type_name, ty);
  if (tc) {
    int newmemory = 0;
    result = alaqil_TypeCast(tc, p, &newmemory);
    assert(!newmemory); /* newmemory handling not yet implemented */
  }
  return result;
}

/* This function returns a pointer of type ty by extracting the pointer
   and type info from the resource in z.  z must be a resource.
   If it fails, NULL is returned.
   It uses alaqil_ConvertResourceData to do the real work. */
static void *
alaqil_ConvertResourcePtr(zval *z, alaqil_type_info *ty, int flags) {
  alaqil_object_wrapper *value;
  void *p;
  const char *type_name;

  if (Z_RES_TYPE_P(z) == -1) return NULL;
  value = (alaqil_object_wrapper *) Z_RES_VAL_P(z);
  if (flags & alaqil_POINTER_DISOWN) {
    value->newobject = 0;
  }
  p = value->ptr;

  type_name=zend_rsrc_list_get_rsrc_type(Z_RES_P(z));

  return alaqil_ConvertResourceData(p, type_name, ty);
}

/* We allow passing of a RESOURCE pointing to the object or an OBJECT whose
   _cPtr is a resource pointing to the object */
static int
alaqil_ConvertPtr(zval *z, void **ptr, alaqil_type_info *ty, int flags) {
  if (z == NULL) {
    *ptr = 0;
    return 0;
  }

  switch (Z_TYPE_P(z)) {
    case IS_OBJECT: {
      HashTable * ht = Z_OBJ_HT_P(z)->get_properties(z);
      if (ht) {
        zval * _cPtr = zend_hash_str_find(ht, "_cPtr", sizeof("_cPtr") - 1);
        if (_cPtr) {
          if (Z_TYPE_P(_cPtr) == IS_INDIRECT) {
            _cPtr = Z_INDIRECT_P(_cPtr);
          }
          if (Z_TYPE_P(_cPtr) == IS_RESOURCE) {
            *ptr = alaqil_ConvertResourcePtr(_cPtr, ty, flags);
            return (*ptr == NULL ? -1 : 0);
          }
        }
      }
      break;
    }
    case IS_RESOURCE:
      *ptr = alaqil_ConvertResourcePtr(z, ty, flags);
      return (*ptr == NULL ? -1 : 0);
    case IS_NULL:
      *ptr = 0;
      return (flags & alaqil_POINTER_NO_NULL) ? alaqil_NullReferenceError : alaqil_OK;
  }

  return -1;
}

static const char const_name[] = "alaqil_runtime_data_type_pointer";
static alaqil_module_info *alaqil_Php_GetModule() {
  zval *pointer = zend_get_constant_str(const_name, sizeof(const_name) - 1);
  if (pointer) {
    if (Z_TYPE_P(pointer) == IS_LONG) {
      return (alaqil_module_info *) pointer->value.lval;
    }
  } 
  return NULL;
}

static void alaqil_Php_SetModule(alaqil_module_info *pointer, int module_number) {
  REGISTER_LONG_CONSTANT(const_name, (long) pointer, CONST_CS | CONST_PERSISTENT);
}
