/* -----------------------------------------------------------------------------
 * guile_scm_run.swg
 * ----------------------------------------------------------------------------- */

#include <libguile.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <assert.h>

#ifdef __cplusplus
extern "C" {
#endif


/* In the code below, use guile 2.0 compatible functions where possible.
   Functions that don't exist in older versions will be mapped to
   a deprecated equivalent for those versions only */
#if defined (SCM_MAJOR_VERSION) && (SCM_MAJOR_VERSION < 2)

static SCM
scm_module_variable (SCM module, SCM sym)
{
  return scm_sym2var (sym, scm_module_lookup_closure (module), SCM_BOOL_F);
}

#define scm_to_utf8_string scm_to_locale_string
#define scm_from_utf8_string scm_from_locale_string
#endif

#if SCM_MAJOR_VERSION >= 2
/* scm_c_define_gsubr takes a different parameter type depending on the guile version */

typedef scm_t_subr alaqil_guile_proc;
#else
typedef SCM (*alaqil_guile_proc)();
#endif
typedef SCM (*guile_destructor)(SCM);

typedef struct alaqil_guile_clientdata {
  guile_destructor destroy;
  SCM goops_class;
} alaqil_guile_clientdata;

#define alaqil_scm2str(s) \
  alaqil_Guile_scm2newstr(s, NULL)
#define alaqil_str02scm(str) \
  str ? scm_from_utf8_string(str) : SCM_BOOL_F 
# define alaqil_malloc(size) \
  scm_malloc(size)
# define alaqil_free(mem) \
  free(mem)
#define alaqil_ConvertPtr(s, result, type, flags) \
  alaqil_Guile_ConvertPtr(s, result, type, flags)
#define alaqil_MustGetPtr(s, type, argnum, flags) \
  alaqil_Guile_MustGetPtr(s, type, argnum, flags, FUNC_NAME)
#define alaqil_NewPointerObj(ptr, type, owner) \
  alaqil_Guile_NewPointerObj((void*)ptr, type, owner)
#define alaqil_PointerAddress(object) \
  alaqil_Guile_PointerAddress(object)
#define alaqil_PointerType(object) \
  alaqil_Guile_PointerType(object)
#define alaqil_IsPointerOfType(object, type) \
  alaqil_Guile_IsPointerOfType(object, type)
#define alaqil_IsPointer(object) \
  alaqil_Guile_IsPointer(object)
#define alaqil_contract_assert(expr, msg)				\
  if (!(expr))							\
    scm_error(scm_from_locale_symbol("alaqil-contract-assertion-failed"),	\
	      (char *) FUNC_NAME, (char *) msg,			\
	      SCM_EOL, SCM_BOOL_F); else

/* for C++ member pointers, ie, member methods */
#define alaqil_ConvertMember(obj, ptr, sz, ty) \
  alaqil_Guile_ConvertMember(obj, ptr, sz, ty, FUNC_NAME)
#define alaqil_NewMemberObj(ptr, sz, type) \
  alaqil_Guile_NewMemberObj(ptr, sz, type, FUNC_NAME)
  
/* Runtime API */
static alaqil_module_info *alaqil_Guile_GetModule(void *alaqilUNUSEDPARM(clientdata));
#define alaqil_GetModule(clientdata) alaqil_Guile_GetModule(clientdata)
#define alaqil_SetModule(clientdata, pointer) alaqil_Guile_SetModule(pointer)
  
alaqilINTERN char *
alaqil_Guile_scm2newstr(SCM str, size_t *len) {
#define FUNC_NAME "alaqil_Guile_scm2newstr"
  char *ret;

  SCM_ASSERT (scm_is_string(str), str, 1, FUNC_NAME);

  ret = scm_to_utf8_string(str);
  if (!ret) return NULL;

  if (len) *len = strlen(ret) - 1;
  return ret;
#undef FUNC_NAME
}

static int alaqil_initialized = 0;
static scm_t_bits alaqil_tag = 0;
static scm_t_bits alaqil_collectable_tag = 0;
static scm_t_bits alaqil_finalized_tag = 0;
static scm_t_bits alaqil_destroyed_tag = 0;
static scm_t_bits alaqil_member_function_tag = 0;
static SCM alaqil_make_func = SCM_EOL;
static SCM alaqil_keyword = SCM_EOL;
static SCM alaqil_symbol = SCM_EOL;

#define alaqil_Guile_GetSmob(x) \
  ( !scm_is_null(x) && SCM_INSTANCEP(x) && scm_is_true(scm_slot_exists_p(x, alaqil_symbol)) \
      ? scm_slot_ref(x, alaqil_symbol) : (x) )

alaqilINTERN SCM
alaqil_Guile_NewPointerObj(void *ptr, alaqil_type_info *type, int owner)
{
  if (ptr == NULL)
    return SCM_EOL;
  else {
    SCM smob;
    alaqil_guile_clientdata *cdata = (alaqil_guile_clientdata *) type->clientdata;
    if (owner)
      SCM_NEWSMOB2(smob, alaqil_collectable_tag, ptr, (void *) type);
    else
      SCM_NEWSMOB2(smob, alaqil_tag, ptr, (void *) type);

    if (!cdata || SCM_NULLP(cdata->goops_class) || alaqil_make_func == SCM_EOL ) {
      return smob;
    } else {
      /* the scm_make() C function only handles the creation of gf,
	 methods and classes (no instances) the (make ...) function is
	 later redefined in goops.scm.  So we need to call that
	 Scheme function. */
      return scm_apply(alaqil_make_func,
		       scm_list_3(cdata->goops_class,
				  alaqil_keyword,
				  smob),
		       SCM_EOL);
    }
  }
}

alaqilINTERN unsigned long
alaqil_Guile_PointerAddress(SCM object)
{
  SCM smob = alaqil_Guile_GetSmob(object);
  if (SCM_NULLP(smob)) return 0;
  else if (SCM_SMOB_PREDICATE(alaqil_tag, smob)
	   || SCM_SMOB_PREDICATE(alaqil_collectable_tag, smob)
	   || SCM_SMOB_PREDICATE(alaqil_destroyed_tag, smob)) {
    return (unsigned long) (void *) SCM_CELL_WORD_1(smob);
  }
  else scm_wrong_type_arg("alaqil-Guile-PointerAddress", 1, object);
}

alaqilINTERN alaqil_type_info *
alaqil_Guile_PointerType(SCM object)
{
  SCM smob = alaqil_Guile_GetSmob(object);
  if (SCM_NULLP(smob)) return NULL;
  else if (SCM_SMOB_PREDICATE(alaqil_tag, smob)
	   || SCM_SMOB_PREDICATE(alaqil_collectable_tag, smob)
	   || SCM_SMOB_PREDICATE(alaqil_destroyed_tag, smob)) {
    return (alaqil_type_info *) SCM_CELL_WORD_2(smob);
  }
  else scm_wrong_type_arg("alaqil-Guile-PointerType", 1, object);
}

alaqilINTERN int
alaqil_Guile_IsValidSmob(SCM smob)
{
  /* We do not accept smobs representing destroyed pointers, but we have to
     allow finalized smobs because Guile >= 2.0.12 sets all smob instances
     to the 'finalized' type before calling their 'free' function. This change
     was introduced to Guile in commit 8dff3af087c6eaa83ae0d72aa8b22aef5c65d65d */
  return SCM_SMOB_PREDICATE(alaqil_tag, smob)
    || SCM_SMOB_PREDICATE(alaqil_collectable_tag, smob)
    || SCM_SMOB_PREDICATE(alaqil_finalized_tag, smob);
}

alaqilINTERN int
alaqil_Guile_ConvertPtr(SCM s, void **result, alaqil_type_info *type, int flags)
{
  alaqil_cast_info *cast;
  alaqil_type_info *from;
  SCM smob = alaqil_Guile_GetSmob(s);

  if (SCM_NULLP(smob)) {
    *result = NULL;
    return (flags & alaqil_POINTER_NO_NULL) ? alaqil_NullReferenceError : alaqil_OK;
#if SCM_MAJOR_VERSION >= 2
  } else if (SCM_POINTER_P(s)) {
    *result = SCM_POINTER_VALUE(s);
    return alaqil_OK;
#endif /* if SCM_MAJOR_VERSION >= 2 */
  } else if (alaqil_Guile_IsValidSmob(smob)) {
    from = (alaqil_type_info *) SCM_CELL_WORD_2(smob);
    if (!from) return alaqil_ERROR;
    if (type) {
      cast = alaqil_TypeCheckStruct(from, type);
      if (cast) {
        int newmemory = 0;
        *result = alaqil_TypeCast(cast, (void *) SCM_CELL_WORD_1(smob), &newmemory);
        assert(!newmemory); /* newmemory handling not yet implemented */
        return alaqil_OK;
      } else {
        return alaqil_ERROR;
      }
    } else {
      *result = (void *) SCM_CELL_WORD_1(smob);
      return alaqil_OK;
    }
  }
  return alaqil_ERROR;
}

alaqilINTERNINLINE void *
alaqil_Guile_MustGetPtr (SCM s, alaqil_type_info *type,
		       int argnum, int flags, const char *func_name)
{
  void *result;
  int res = alaqil_Guile_ConvertPtr(s, &result, type, flags);
  if (!alaqil_IsOK(res)) {
    /* type mismatch */
    scm_wrong_type_arg((char *) func_name, argnum, s);
  }
  return result;
}

alaqilINTERNINLINE int
alaqil_Guile_IsPointerOfType (SCM s, alaqil_type_info *type)
{
  void *result;
  if (alaqil_Guile_ConvertPtr(s, &result, type, 0)) {
    /* type mismatch */
    return 0;
  }
  else return 1;
}

alaqilINTERNINLINE int
alaqil_Guile_IsPointer (SCM s)
{
  /* module might not be initialized yet, so initialize it */
  alaqil_GetModule(0);
  return alaqil_Guile_IsPointerOfType (s, NULL);
}

/* Mark a pointer object non-collectable */
alaqilINTERN void
alaqil_Guile_MarkPointerNoncollectable(SCM s)
{
  SCM smob = alaqil_Guile_GetSmob(s);
  if (!SCM_NULLP(smob)) {
    if (alaqil_Guile_IsValidSmob(smob)) {
      SCM_SET_CELL_TYPE(smob, alaqil_tag);
    }
    else scm_wrong_type_arg(NULL, 0, s);
  }
}

/* Mark a pointer object destroyed */
alaqilINTERN void
alaqil_Guile_MarkPointerDestroyed(SCM s)
{
  SCM smob = alaqil_Guile_GetSmob(s);
  if (!SCM_NULLP(smob)) {
    if (alaqil_Guile_IsValidSmob(smob)) {
      SCM_SET_CELL_TYPE(smob, alaqil_destroyed_tag);
    }
    else scm_wrong_type_arg(NULL, 0, s);
  }
}

/* Member functions */

alaqilINTERN SCM
alaqil_Guile_NewMemberObj(void *ptr, size_t sz, alaqil_type_info *type,
			const char *func_name)
{
  SCM smob;
  void *copy = malloc(sz);
  memcpy(copy, ptr, sz);
  SCM_NEWSMOB2(smob, alaqil_member_function_tag, copy, (void *) type);
  return smob;
}

alaqilINTERN int
alaqil_Guile_ConvertMember(SCM smob, void *ptr, size_t sz, alaqil_type_info *type,
			 const char *func_name)
{
  alaqil_cast_info *cast;
  alaqil_type_info *from;

  if (SCM_SMOB_PREDICATE(alaqil_member_function_tag, smob)) {
    from = (alaqil_type_info *) SCM_CELL_WORD_2(smob);
    if (!from) return alaqil_ERROR;
    if (type) {
      cast = alaqil_TypeCheckStruct(from, type);
      if (!cast) return alaqil_ERROR;
    }
    memcpy(ptr, (void *) SCM_CELL_WORD_1(smob), sz);
    return alaqil_OK;
  }
  return alaqil_ERROR;
}
     

/* Init */

alaqilINTERN int
print_alaqil_aux (SCM alaqil_smob, SCM port, scm_print_state *pstate, 
                const char *attribute)
{
  alaqil_type_info *type;
  
  type = (alaqil_type_info *) SCM_CELL_WORD_2(alaqil_smob);
  if (type) {
    scm_puts((char *) "#<", port);
    scm_puts((char *) attribute, port);
    scm_puts((char *) "alaqil-pointer ", port);
    scm_puts((char *) alaqil_TypePrettyName(type), port);
    scm_puts((char *) " ", port);
    scm_intprint((long) SCM_CELL_WORD_1(alaqil_smob), 16, port);
    scm_puts((char *) ">", port);
    /* non-zero means success */
    return 1;
  } else {
    return 0;
  }
}

  
alaqilINTERN int
print_alaqil (SCM alaqil_smob, SCM port, scm_print_state *pstate)
{
  return print_alaqil_aux(alaqil_smob, port, pstate, "");
}

alaqilINTERN int
print_collectable_alaqil (SCM alaqil_smob, SCM port, scm_print_state *pstate)
{
  return print_alaqil_aux(alaqil_smob, port, pstate, "collectable-");
}

alaqilINTERN int
print_destroyed_alaqil (SCM alaqil_smob, SCM port, scm_print_state *pstate)
{
  return print_alaqil_aux(alaqil_smob, port, pstate, "destroyed-");
}

alaqilINTERN int
print_member_function_alaqil (SCM alaqil_smob, SCM port, scm_print_state *pstate)
{
  alaqil_type_info *type;
  type = (alaqil_type_info *) SCM_CELL_WORD_2(alaqil_smob);
  if (type) {
    scm_puts((char *) "#<", port);
    scm_puts((char *) "alaqil-member-function-pointer ", port);
    scm_puts((char *) alaqil_TypePrettyName(type), port);
    scm_puts((char *) " >", port);
    /* non-zero means success */
    return 1;
  } else {
    return 0;
  }
}

alaqilINTERN SCM
equalp_alaqil (SCM A, SCM B)
{
  if (SCM_CELL_WORD_0(A) == SCM_CELL_WORD_0(B) && SCM_CELL_WORD_1(A) == SCM_CELL_WORD_1(B) 
      && SCM_CELL_WORD_2(A) == SCM_CELL_WORD_2(B))
    return SCM_BOOL_T;
  else return SCM_BOOL_F;
}

alaqilINTERN size_t
free_alaqil(SCM A)
{
  alaqil_type_info *type = (alaqil_type_info *) SCM_CELL_WORD_2(A);
  if (type) {
    if (type->clientdata && ((alaqil_guile_clientdata *)type->clientdata)->destroy)
      ((alaqil_guile_clientdata *)type->clientdata)->destroy(A);
  } 
  return 0;
}

alaqilINTERN size_t
free_alaqil_member_function(SCM A)
{
  free((alaqil_type_info *) SCM_CELL_WORD_1(A));
  return 0;
}

alaqilINTERN int
ensure_smob_tag(SCM alaqil_module,
		scm_t_bits *tag_variable,
		const char *smob_name,
		const char *scheme_variable_name)
{
  SCM variable = scm_module_variable(alaqil_module,
                             scm_from_locale_symbol(scheme_variable_name));
  if (scm_is_false(variable)) {
    *tag_variable = scm_make_smob_type((char*)scheme_variable_name, 0);
    scm_c_module_define(alaqil_module, scheme_variable_name, 
                        scm_from_ulong(*tag_variable));
    return 1;
  }
  else {
    *tag_variable = scm_to_ulong(SCM_VARIABLE_REF(variable));
    return 0;
  }
}

alaqilINTERN SCM
alaqil_Guile_Init ()
{
  static SCM alaqil_module;
  
  if (alaqil_initialized) return alaqil_module;
  alaqil_initialized = 1;

  alaqil_module = scm_c_resolve_module("alaqil alaqilrun");
  if (ensure_smob_tag(alaqil_module, &alaqil_tag,
		      "alaqil-pointer", "alaqil-pointer-tag")) {
    scm_set_smob_print(alaqil_tag, print_alaqil);
    scm_set_smob_equalp(alaqil_tag, equalp_alaqil);
  }
  if (ensure_smob_tag(alaqil_module, &alaqil_collectable_tag,
		      "collectable-alaqil-pointer", "collectable-alaqil-pointer-tag")) {
    scm_set_smob_print(alaqil_collectable_tag, print_collectable_alaqil);
    scm_set_smob_equalp(alaqil_collectable_tag, equalp_alaqil);
    scm_set_smob_free(alaqil_collectable_tag, free_alaqil);
    /* For Guile >= 2.0.12. See libguile/smob.c:clear_smobnum */
    alaqil_finalized_tag = alaqil_collectable_tag & ~0xff00;
  }
  if (ensure_smob_tag(alaqil_module, &alaqil_destroyed_tag,
		      "destroyed-alaqil-pointer", "destroyed-alaqil-pointer-tag")) {
    scm_set_smob_print(alaqil_destroyed_tag, print_destroyed_alaqil);
    scm_set_smob_equalp(alaqil_destroyed_tag, equalp_alaqil);
  }
  if (ensure_smob_tag(alaqil_module, &alaqil_member_function_tag,
		      "alaqil-member-function-pointer", "alaqil-member-function-pointer-tag")) {
    scm_set_smob_print(alaqil_member_function_tag, print_member_function_alaqil);
    scm_set_smob_free(alaqil_member_function_tag, free_alaqil_member_function);
  }
  alaqil_make_func = scm_permanent_object(
  scm_variable_ref(scm_c_module_lookup(scm_c_resolve_module("oop goops"), "make")));
  alaqil_keyword = scm_permanent_object(scm_from_locale_keyword((char*) "init-smob"));
  alaqil_symbol = scm_permanent_object(scm_from_locale_symbol("alaqil-smob"));
#ifdef alaqil_INIT_RUNTIME_MODULE
  alaqil_INIT_RUNTIME_MODULE
#endif

  return alaqil_module;
}

alaqilINTERN alaqil_module_info *
alaqil_Guile_GetModule(void *alaqilUNUSEDPARM(clientdata))
{
  SCM module = alaqil_Guile_Init();
  SCM variable = scm_module_variable(module, scm_from_locale_symbol("alaqil-type-list-address" alaqil_RUNTIME_VERSION alaqil_TYPE_TABLE_NAME));
  if (scm_is_false(variable)) {
    return NULL;
  } else {
    return (alaqil_module_info *) scm_to_ulong(SCM_VARIABLE_REF(variable));
  }
}

alaqilINTERN void
alaqil_Guile_SetModule(alaqil_module_info *alaqil_module)
{
  SCM module = alaqil_Guile_Init();
  scm_module_define(module,
                    scm_from_locale_symbol("alaqil-type-list-address" alaqil_RUNTIME_VERSION alaqil_TYPE_TABLE_NAME),
                    scm_from_ulong((unsigned long) alaqil_module));
}

alaqilINTERN int
alaqil_Guile_GetArgs (SCM *dest, SCM rest,
		    int reqargs, int optargs,
		    const char *procname)
{
  int i;
  int num_args_passed = 0;
  for (i = 0; i<reqargs; i++) {
    if (!SCM_CONSP(rest))
      scm_wrong_num_args(scm_from_utf8_string(procname ? (char *) procname : "unknown procedure"));
    *dest++ = SCM_CAR(rest);
    rest = SCM_CDR(rest);
    num_args_passed++;
  }
  for (i = 0; i<optargs && SCM_CONSP(rest); i++) {
    *dest++ = SCM_CAR(rest);
    rest = SCM_CDR(rest);
    num_args_passed++;
  }
  for (; i<optargs; i++)
    *dest++ = SCM_UNDEFINED;
  if (!SCM_NULLP(rest))
      scm_wrong_num_args(scm_from_utf8_string(procname ? (char *) procname : "unknown procedure"));
  return num_args_passed;
}

#ifdef __cplusplus
}
#endif
