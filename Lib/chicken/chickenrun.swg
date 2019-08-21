/* -----------------------------------------------------------------------------
 * chickenrun.swg
 * ----------------------------------------------------------------------------- */

#include <chicken.h>
#include <assert.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#if defined(_MSC_VER) || defined(__BORLANDC__) || defined(_WATCOM)
# ifndef snprintf
#  define snprintf _snprintf
# endif
#endif

#ifdef __cplusplus
extern "C" {
#endif

#define alaqil_malloc(size) \
  malloc(size)
#define alaqil_free(mem) \
  free(mem)
#define alaqil_MakeString(c) \
  alaqil_Chicken_MakeString(c)
#define alaqil_ConvertPtr(s, result, type, flags) \
  alaqil_Chicken_ConvertPtr(s, result, type, flags)
#define alaqil_MustGetPtr(s, type, argnum, flags) \
  alaqil_Chicken_MustGetPtr(s, type, argnum, flags)
#define alaqil_NewPointerObj(ptr, type, owner) \
  alaqil_Chicken_NewPointerObj((void*)ptr, type, owner, &known_space)
#define alaqil_barf alaqil_Chicken_Barf
#define alaqil_ThrowException(val) alaqil_Chicken_ThrowException(val)

#define alaqil_contract_assert(expr, message) if (!(expr)) { \
                                              alaqil_Chicken_Barf(alaqil_BARF1_CONTRACT_ASSERT, C_text(message)); } else

/* Runtime API */
#define alaqil_GetModule(clientdata) alaqil_Chicken_GetModule(clientdata)
#define alaqil_SetModule(clientdata, pointer) alaqil_Chicken_SetModule(pointer)

#define C_alaqil_is_bool(x) C_truep (C_booleanp (x))
#define C_alaqil_is_char(x) C_truep (C_charp (x))
#define C_alaqil_is_fixnum(x) C_truep (C_fixnump (x))
#define C_alaqil_is_flonum(x) (C_truep (C_blockp (x)) && C_truep (C_flonump (x)))
#define C_alaqil_is_string(x) (C_truep (C_blockp (x)) && C_truep (C_stringp (x)))
#define C_alaqil_is_vector(x) (C_truep (C_blockp (x)) && C_truep (C_vectorp (x)))
#define C_alaqil_is_list(x) (C_truep (C_i_listp (x)))
#define C_alaqil_is_pair(x) (C_truep (C_blockp(x)) && C_truep (C_pairp(x)))
#define C_alaqil_is_ptr(x) (C_truep (C_blockp (x)) && C_truep (C_pointerp (x)))
#define C_alaqil_is_alaqilpointer(x) (C_truep (C_blockp(x)) && C_truep (C_alaqilpointerp(x)))
#define C_alaqil_is_closurep(x) (C_truep (C_blockp(x)) && C_truep(C_closurep(x)))
#define C_alaqil_is_number(x) (C_alaqil_is_fixnum(x) || C_alaqil_is_flonum(x))
#define C_alaqil_is_long(x) C_alaqil_is_number(x)

#define C_alaqil_sizeof_closure(num) (num+1)

#define alaqil_Chicken_SetupArgout { \
  C_word *a = C_alloc(C_alaqil_sizeof_closure(2)); \
  C_word *closure = a; \
  *(a++)=C_CLOSURE_TYPE|2; \
  *(a++)=(C_word)alaqil_Chicken_ApplyResults; \
  *(a++)=continuation; \
  continuation=(C_word)closure; \
}

#define alaqil_APPEND_VALUE(obj) { \
  C_word val = (C_word)(obj); \
  if (val != C_SCHEME_UNDEFINED) { \
    C_word *a = C_alloc(C_alaqil_sizeof_closure(3)); \
    C_word *closure = a; \
    *(a++)=C_CLOSURE_TYPE|3; \
    *(a++)=(C_word)alaqil_Chicken_MultiResultBuild; \
    *(a++)=(C_word)continuation; \
    *(a++)=val; \
    continuation=(C_word)closure; \
  } }

#define alaqil_Chicken_FindCreateProxy(func,obj) \
  if (C_alaqil_is_alaqilpointer(obj)) { \
    alaqil_type_info *t = (alaqil_type_info *) C_block_item(obj, 1); \
    if (t && t->clientdata &&    ((alaqil_chicken_clientdata *)t->clientdata)->gc_proxy_create) { \
      func = CHICKEN_gc_root_ref( ((alaqil_chicken_clientdata *)t->clientdata)->gc_proxy_create); \
    } else { \
      func = C_SCHEME_FALSE; \
    } \
  } else { \
    func = C_SCHEME_FALSE; \
  }


enum {
  alaqil_BARF1_BAD_ARGUMENT_TYPE /* 1 arg */,
  alaqil_BARF1_ARGUMENT_NULL /* 1 arg */,
  alaqil_BARF1_CONTRACT_ASSERT /* 1 arg */,
};

typedef C_word (*alaqil_chicken_destructor)(C_word,C_word,C_word,C_word);
typedef struct alaqil_chicken_clientdata {
  void *gc_proxy_create;
  alaqil_chicken_destructor destroy;
} alaqil_chicken_clientdata;
  
static char *
alaqil_Chicken_MakeString(C_word str) {
  char *ret;
  size_t l;

  l = C_header_size(str);
  ret = (char *) alaqil_malloc( (l + 1) * sizeof(char));
  if (!ret) return NULL;

  memcpy(ret, C_c_string(str), l);
  ret[l] = '\0';
  return ret;
}

static C_word alaqil_Chicken_LookupSymbol(char *name, C_SYMBOL_TABLE *stable) {
  C_word *a = C_alloc(C_SIZEOF_STRING (strlen (name)));
  C_word n = C_string2(&a, name);
  C_word sym = C_find_symbol(n, stable);
  if (C_truep(sym)) {
    return C_symbol_value(sym);
  } else {
    return C_SCHEME_FALSE;
  }
}

/* Just a helper function.  Do not export it */
static void alaqil_Chicken_Panic (C_char *) C_noret;
static void alaqil_Chicken_Panic (C_char *msg)
{
  C_word *a = C_alloc (C_SIZEOF_STRING (strlen (msg)));
  C_word scmmsg = C_string2 (&a, msg);
  C_halt (scmmsg);
  exit (5); /* should never get here */
}

static void
alaqil_Chicken_Barf(int code, C_char *msg, ...) C_noret;
static void
alaqil_Chicken_Barf(int code, C_char *msg, ...)
{
  char *errorhook = C_text("\003syserror-hook");
  C_word *a = C_alloc (C_SIZEOF_STRING (strlen (errorhook)));
  C_word err = C_intern2 (&a, errorhook);
  int c = -1;
  int i, barfval;
  va_list v;

  
  C_temporary_stack = C_temporary_stack_bottom;
  err = C_block_item(err, 0);

  if(C_immediatep (err))
    alaqil_Chicken_Panic (C_text ("`##sys#error-hook' is not defined"));

  switch (code) {
  case alaqil_BARF1_BAD_ARGUMENT_TYPE:
    barfval = C_BAD_ARGUMENT_TYPE_ERROR;
    c = 1;
    break;
  case alaqil_BARF1_ARGUMENT_NULL:
    barfval = C_BAD_ARGUMENT_TYPE_ERROR;
    c = 1;
    break;
  case alaqil_BARF1_CONTRACT_ASSERT:
    barfval = C_BAD_ARGUMENT_TYPE_ERROR;
    c = 1;
    break;
  default:
    alaqil_Chicken_Panic (C_text (msg));
  };

  if(c > 0 && !C_immediatep (err)) {
    C_save (C_fix (barfval));

    i = c;
    if (i) {
      C_word *b = C_alloc (C_SIZEOF_STRING (strlen (msg)));
      C_word scmmsg = C_string2 (&b, msg);
      C_save (scmmsg);
      i--;
    }

    va_start (v, msg);

    while(i--)
      C_save (va_arg (v, C_word));

    va_end (v);
    C_do_apply (c + 1, err, 
		C_SCHEME_UNDEFINED);  /* <- no continuation is passed:
					 '##sys#error-hook' may not
					 return! */
  }
  else if (msg) {
    alaqil_Chicken_Panic (msg);
  }
  else {
    alaqil_Chicken_Panic (C_text ("unspecified panic"));
  }
}

static void alaqil_Chicken_ThrowException(C_word value) C_noret;
static void alaqil_Chicken_ThrowException(C_word value)
{
  char *aborthook = C_text("\003sysabort");
  C_word *a = C_alloc(C_SIZEOF_STRING(strlen(aborthook)));
  C_word abort = C_intern2(&a, aborthook);

  abort = C_block_item(abort, 0);
  if (C_immediatep(abort))
    alaqil_Chicken_Panic(C_text("`##sys#abort' is not defined"));

  C_save(value);
  C_do_apply(1, abort, C_SCHEME_UNDEFINED);
}

static void
alaqil_Chicken_Finalizer(C_word argc, C_word closure, C_word continuation, C_word s)
{
  alaqil_type_info *type;
  alaqil_chicken_clientdata *cdata;

  if (argc == 3 && s != C_SCHEME_FALSE && C_alaqil_is_alaqilpointer(s)) {
    type = (alaqil_type_info *) C_block_item(s, 1);
    if (type) {
      cdata = (alaqil_chicken_clientdata *) type->clientdata;
      if (cdata && cdata->destroy) {
	/* this will not return, but will continue correctly */
        cdata->destroy(3,closure,continuation,s);
      }
    }
  }
  C_kontinue(continuation, C_SCHEME_UNDEFINED);
}
static C_word finalizer_obj[2] = {(C_word) (C_CLOSURE_TYPE|1), (C_word) alaqil_Chicken_Finalizer};

static C_word
alaqil_Chicken_NewPointerObj(void *ptr, alaqil_type_info *type, int owner, C_word **data)
{
  alaqil_chicken_clientdata *cdata = (alaqil_chicken_clientdata *) type->clientdata;

  if (ptr == NULL)
    return C_SCHEME_FALSE;
  else {
    C_word cptr = C_alaqilmpointer(data, ptr, type);
    /* add finalizer to object */
    #ifndef alaqil_CHICKEN_NO_COLLECTION
    if (owner)
      C_do_register_finalizer(cptr, (C_word) finalizer_obj);
    #endif

    return cptr;
  }
}

/* Return 0 if successful. */
static int
alaqil_Chicken_ConvertPtr(C_word s, void **result, alaqil_type_info *type, int flags)
{
  alaqil_cast_info *cast;
  alaqil_type_info *from;

  if (s == C_SCHEME_FALSE) {
    *result = NULL;
    return (flags & alaqil_POINTER_NO_NULL) ? alaqil_NullReferenceError : alaqil_OK;
  } else if (C_alaqil_is_alaqilpointer(s)) {
    /* try and convert type */
    from = (alaqil_type_info *) C_block_item(s, 1);
    if (!from) return 1;
    if (type) {
      cast = alaqil_TypeCheckStruct(from, type);
      if (cast) {
        int newmemory = 0;
        *result = alaqil_TypeCast(cast, (void *) C_block_item(s, 0), &newmemory);
        assert(!newmemory); /* newmemory handling not yet implemented */
      } else {
        return 1;
      }
    } else {
      *result = (void *) C_block_item(s, 0);
    }

    /* check if we are disowning this object */
    if (flags & alaqil_POINTER_DISOWN) {
      C_do_unregister_finalizer(s);
    }
  } else {
    return 1;
  }

  return 0;
}

static alaqilINLINE void *
alaqil_Chicken_MustGetPtr (C_word s, alaqil_type_info *type, int argnum, int flags)
{
  void *result;
  char err_msg[256];
  if (alaqil_Chicken_ConvertPtr(s, &result, type, flags)) {
    /* type mismatch */
    snprintf(err_msg, sizeof(err_msg), "Type error in argument #%i: expected %s", argnum, (type->str ? type->str : type->name));
    alaqil_Chicken_Barf(alaqil_BARF1_BAD_ARGUMENT_TYPE, err_msg);
  }
  return result;
}

static char *chicken_runtimevar_name = "type_pointer" alaqil_TYPE_TABLE_NAME;

static alaqil_module_info *
alaqil_Chicken_GetModule(void *alaqilUNUSEDPARM(clientdata)) {
    alaqil_module_info *ret = 0;
    C_word sym;

    /* lookup the type pointer... it is stored in its own symbol table */
    C_SYMBOL_TABLE *stable = C_find_symbol_table("alaqil_runtime_data" alaqil_RUNTIME_VERSION);
    if (stable != NULL) {
      sym = alaqil_Chicken_LookupSymbol(chicken_runtimevar_name, stable);
      if (C_truep(sym) && C_alaqil_is_ptr(sym)) {
        ret = (alaqil_module_info *) C_block_item(sym, 0);
      }
    }

    return ret;
}

static void
alaqil_Chicken_SetModule(alaqil_module_info *module) {
    C_word *a;
    C_SYMBOL_TABLE *stable;
    C_word sym;
    C_word pointer;
    static C_word *space = 0;
    
    /* type pointer is stored in its own symbol table */
    stable = C_find_symbol_table("alaqil_runtime_data" alaqil_RUNTIME_VERSION);
    if (stable == NULL) {
      stable = C_new_symbol_table("alaqil_runtime_data" alaqil_RUNTIME_VERSION, 16);
    }

    if (!space) {
      space = (C_word *) C_malloc((C_SIZEOF_POINTER + C_SIZEOF_INTERNED_SYMBOL(C_strlen(chicken_runtimevar_name))) * sizeof(C_word));
    }
    a = space;
    pointer = C_mpointer(&a, (void *) module);
    sym = C_intern_in(&a, C_strlen(chicken_runtimevar_name), chicken_runtimevar_name, stable);
    C_set_block_item(sym, 0, pointer);
}

static C_word alaqil_Chicken_MultiResultBuild(C_word num, C_word closure, C_word lst) {
  C_word cont = C_block_item(closure,1);
  C_word obj = C_block_item(closure,2);
  C_word func;

  alaqil_Chicken_FindCreateProxy(func,obj);

  if (C_alaqil_is_closurep(func)) {
    ((C_proc4)(void *)C_block_item(func, 0))(4,func,cont,obj,lst);
  } else {
    C_word *a = C_alloc(C_SIZEOF_PAIR);
    C_kontinue(cont,C_pair(&a,obj,lst));
  }
  return C_SCHEME_UNDEFINED; /* never reached */
}

static C_word alaqil_Chicken_ApplyResults(C_word num, C_word closure, C_word result) {
  C_apply_values(3,C_SCHEME_UNDEFINED,C_block_item(closure,1),result);
  return C_SCHEME_UNDEFINED; /* never reached */
}

#ifdef __cplusplus
}
#endif
