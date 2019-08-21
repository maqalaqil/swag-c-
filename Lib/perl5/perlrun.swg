/* -----------------------------------------------------------------------------
 * perlrun.swg
 *
 * This file contains the runtime support for Perl modules
 * and includes code for managing global variables and pointer
 * type checking.
 * ----------------------------------------------------------------------------- */

#ifdef PERL_OBJECT
#define alaqil_PERL_OBJECT_DECL CPerlObj *alaqilUNUSEDPARM(pPerl),
#define alaqil_PERL_OBJECT_CALL pPerl,
#else
#define alaqil_PERL_OBJECT_DECL
#define alaqil_PERL_OBJECT_CALL
#endif

/* Common alaqil API */

/* for raw pointers */
#define alaqil_ConvertPtr(obj, pp, type, flags)           alaqil_Perl_ConvertPtr(alaqil_PERL_OBJECT_CALL obj, pp, type, flags)
#define alaqil_ConvertPtrAndOwn(obj, pp, type, flags,own) alaqil_Perl_ConvertPtrAndOwn(alaqil_PERL_OBJECT_CALL obj, pp, type, flags, own)
#define alaqil_NewPointerObj(p, type, flags)              alaqil_Perl_NewPointerObj(alaqil_PERL_OBJECT_CALL p, type, flags)
#define alaqil_AcquirePtr(ptr, src)                       alaqil_Perl_AcquirePtr(ptr, src)
#define alaqil_owntype                                    int

/* for raw packed data */
#define alaqil_ConvertPacked(obj, p, s, type)             alaqil_Perl_ConvertPacked(alaqil_PERL_OBJECT_CALL obj, p, s, type)
#define alaqil_NewPackedObj(p, s, type)	                alaqil_Perl_NewPackedObj(alaqil_PERL_OBJECT_CALL p, s, type)

/* for class or struct pointers */
#define alaqil_ConvertInstance(obj, pptr, type, flags)    alaqil_ConvertPtr(obj, pptr, type, flags)
#define alaqil_NewInstanceObj(ptr, type, flags)           alaqil_NewPointerObj(ptr, type, flags)

/* for C or C++ function pointers */
#define alaqil_ConvertFunctionPtr(obj, pptr, type)        alaqil_ConvertPtr(obj, pptr, type, 0)
#define alaqil_NewFunctionPtrObj(ptr, type)               alaqil_NewPointerObj(ptr, type, 0)

/* for C++ member pointers, ie, member methods */
#define alaqil_ConvertMember(obj, ptr, sz, ty)            alaqil_ConvertPacked(obj, ptr, sz, ty)
#define alaqil_NewMemberObj(ptr, sz, type)                alaqil_NewPackedObj(ptr, sz, type)


/* Runtime API */

#define alaqil_GetModule(clientdata)                      alaqil_Perl_GetModule(clientdata)
#define alaqil_SetModule(clientdata, pointer)             alaqil_Perl_SetModule(pointer)


/* Error manipulation */

#define alaqil_ErrorType(code)                            alaqil_Perl_ErrorType(code)               
#define alaqil_Error(code, msg)            		sv_setpvf(get_sv("@", GV_ADD), "%s %s", alaqil_ErrorType(code), msg)
#define alaqil_fail                        		goto fail						    

/* Perl-specific alaqil API */

#define alaqil_MakePtr(sv, ptr, type, flags)              alaqil_Perl_MakePtr(alaqil_PERL_OBJECT_CALL sv, ptr, type, flags)
#define alaqil_MakePackedObj(sv, p, s, type)	        alaqil_Perl_MakePackedObj(alaqil_PERL_OBJECT_CALL sv, p, s, type)
#define alaqil_SetError(str)                              alaqil_Error(alaqil_RuntimeError, str)


#define alaqil_PERL_DECL_ARGS_1(arg1)                     (alaqil_PERL_OBJECT_DECL arg1)
#define alaqil_PERL_CALL_ARGS_1(arg1)                     (alaqil_PERL_OBJECT_CALL arg1)
#define alaqil_PERL_DECL_ARGS_2(arg1, arg2)               (alaqil_PERL_OBJECT_DECL arg1, arg2)
#define alaqil_PERL_CALL_ARGS_2(arg1, arg2)               (alaqil_PERL_OBJECT_CALL arg1, arg2)

/* -----------------------------------------------------------------------------
 * pointers/data manipulation
 * ----------------------------------------------------------------------------- */

/* For backward compatibility only */
#define alaqil_POINTER_EXCEPTION  0

#ifdef __cplusplus
extern "C" {
#endif

#define alaqil_OWNER   alaqil_POINTER_OWN
#define alaqil_SHADOW  alaqil_OWNER << 1

#define alaqil_MAYBE_PERL_OBJECT alaqil_PERL_OBJECT_DECL

/* alaqil Perl macros */

/* Macro to declare an XS function */
#ifndef XSPROTO
#   define XSPROTO(name) void name(pTHX_ CV* cv)
#endif

/* Macro to call an XS function */
#ifdef PERL_OBJECT 
#  define alaqil_CALLXS(_name) _name(cv,pPerl) 
#else 
#  ifndef MULTIPLICITY 
#    define alaqil_CALLXS(_name) _name(cv) 
#  else 
#    define alaqil_CALLXS(_name) _name(PERL_GET_THX, cv) 
#  endif 
#endif 

#ifdef PERL_OBJECT
#define MAGIC_PPERL  CPerlObj *pPerl = (CPerlObj *) this;

#ifdef __cplusplus
extern "C" {
#endif
typedef int (CPerlObj::*alaqilMagicFunc)(SV *, MAGIC *);
#ifdef __cplusplus
}
#endif

#define alaqil_MAGIC(a,b) (SV *a, MAGIC *b)
#define alaqilCLASS_STATIC

#else /* PERL_OBJECT */

#define MAGIC_PPERL
#define alaqilCLASS_STATIC static alaqilUNUSED

#ifndef MULTIPLICITY
#define alaqil_MAGIC(a,b) (SV *a, MAGIC *b)

#ifdef __cplusplus
extern "C" {
#endif
typedef int (*alaqilMagicFunc)(SV *, MAGIC *);
#ifdef __cplusplus
}
#endif

#else /* MULTIPLICITY */

#define alaqil_MAGIC(a,b) (struct interpreter *interp, SV *a, MAGIC *b)

#ifdef __cplusplus
extern "C" {
#endif
typedef int (*alaqilMagicFunc)(struct interpreter *, SV *, MAGIC *);
#ifdef __cplusplus
}
#endif

#endif /* MULTIPLICITY */
#endif /* PERL_OBJECT */

#  ifdef PERL_OBJECT
#    define alaqil_croak_null() alaqil_Perl_croak_null(pPerl)
static void alaqilUNUSED alaqil_Perl_croak_null(CPerlObj *pPerl)
#  else
static void alaqilUNUSED alaqil_croak_null()
#  endif
{
  SV *err = get_sv("@", GV_ADD);
#  if (PERL_VERSION < 6)
  croak("%_", err);
#  else
  if (sv_isobject(err))
    croak(0);
  else
    croak("%s", SvPV_nolen(err));
#  endif
}


/* 
   Define how strict is the cast between strings and integers/doubles
   when overloading between these types occurs.
   
   The default is making it as strict as possible by using alaqil_AddCast
   when needed.
   
   You can use -Dalaqil_PERL_NO_STRICT_STR2NUM at compilation time to
   disable the alaqil_AddCast, making the casting between string and
   numbers less strict.

   In the end, we try to solve the overloading between strings and
   numerical types in the more natural way, but if you can avoid it,
   well, avoid it using %rename, for example.
*/
#ifndef alaqil_PERL_NO_STRICT_STR2NUM
# ifndef alaqil_PERL_STRICT_STR2NUM
#  define alaqil_PERL_STRICT_STR2NUM
# endif
#endif
#ifdef alaqil_PERL_STRICT_STR2NUM
/* string takes precedence */
#define alaqil_Str2NumCast(x) alaqil_AddCast(x)  
#else
/* number takes precedence */
#define alaqil_Str2NumCast(x) x
#endif



#include <stdlib.h>

alaqilRUNTIME const char *
alaqil_Perl_TypeProxyName(const alaqil_type_info *type) {
  if (!type) return NULL;
  if (type->clientdata != NULL) {
    return (const char*) type->clientdata;
  } 
  else {
    return type->name;
  }
}

/* Identical to alaqil_TypeCheck, except for strcmp comparison */
alaqilRUNTIME alaqil_cast_info *
alaqil_TypeProxyCheck(const char *c, alaqil_type_info *ty) {
  if (ty) {
    alaqil_cast_info *iter = ty->cast;
    while (iter) {
      if (strcmp(alaqil_Perl_TypeProxyName(iter->type), c) == 0) {
        if (iter == ty->cast)
          return iter;
        /* Move iter to the top of the linked list */
        iter->prev->next = iter->next;
        if (iter->next)
          iter->next->prev = iter->prev;
        iter->next = ty->cast;
        iter->prev = 0;
        if (ty->cast) ty->cast->prev = iter;
        ty->cast = iter;
        return iter;
      }
      iter = iter->next;
    }
  }
  return 0;
}

/* Acquire a pointer value */

alaqilRUNTIME int
alaqil_Perl_AcquirePtr(alaqil_MAYBE_PERL_OBJECT SV *sv, int own) {
  /* TODO */
  return 0;
}

/* Function for getting a pointer value */

alaqilRUNTIME int
alaqil_Perl_ConvertPtrAndOwn(alaqil_MAYBE_PERL_OBJECT SV *sv, void **ptr, alaqil_type_info *_t, int flags, int *own) {
  alaqil_cast_info *tc;
  void *voidptr = (void *)0;
  SV *tsv = 0;

  if (own)
    *own = 0;

  /* If magical, apply more magic */
  if (SvGMAGICAL(sv))
    mg_get(sv);

  /* Check to see if this is an object */
  if (sv_isobject(sv)) {
    IV tmp = 0;
    tsv = (SV*) SvRV(sv);
    if ((SvTYPE(tsv) == SVt_PVHV)) {
      MAGIC *mg;
      if (SvMAGICAL(tsv)) {
        mg = mg_find(tsv,'P');
        if (mg) {
          sv = mg->mg_obj;
          if (sv_isobject(sv)) {
	    tsv = (SV*)SvRV(sv);
            tmp = SvIV(tsv);
          }
        }
      } else {
        return alaqil_ERROR;
      }
    } else {
      tmp = SvIV(tsv);
    }
    voidptr = INT2PTR(void *,tmp);
  } else if (! SvOK(sv)) {            /* Check for undef */
    *(ptr) = (void *) 0;
    return (flags & alaqil_POINTER_NO_NULL) ? alaqil_NullReferenceError : alaqil_OK;
  } else if (SvTYPE(sv) == SVt_RV) {  /* Check for NULL pointer */
    if (!SvROK(sv)) {
      /* In Perl 5.12 and later, SVt_RV == SVt_IV, so sv could be a valid integer value.  */
      if (SvIOK(sv)) {
        return alaqil_ERROR;
      } else {
        /* NULL pointer (reference to undef). */
        *(ptr) = (void *) 0;
        return alaqil_OK;
      }
    } else {
      return alaqil_ERROR;
    }
  } else {                            /* Don't know what it is */
    return alaqil_ERROR;
  }
  if (_t) {
    /* Now see if the types match */
    char *_c = HvNAME(SvSTASH(SvRV(sv)));
    tc = alaqil_TypeProxyCheck(_c,_t);
#ifdef alaqil_DIRECTORS
    if (!tc && !sv_derived_from(sv,alaqil_Perl_TypeProxyName(_t))) {
#else
    if (!tc) {
#endif
      return alaqil_ERROR;
    }
    {
      int newmemory = 0;
      *ptr = alaqil_TypeCast(tc,voidptr,&newmemory);
      if (newmemory == alaqil_CAST_NEW_MEMORY) {
        assert(own); /* badly formed typemap which will lead to a memory leak - it must set and use own to delete *ptr */
        if (own)
          *own = *own | alaqil_CAST_NEW_MEMORY;
      }
    }
  } else {
    *ptr = voidptr;
  }

  /* 
   *  DISOWN implementation: we need a perl guru to check this one.
   */
  if (tsv && (flags & alaqil_POINTER_DISOWN)) {
    /* 
     *  almost copy paste code from below alaqil_POINTER_OWN setting
     */
    SV *obj = sv;
    HV *stash = SvSTASH(SvRV(obj));
    GV *gv = *(GV**)hv_fetch(stash, "OWNER", 5, TRUE);
    if (isGV(gv)) {
      HV *hv = GvHVn(gv);
      /*
       * To set ownership (see below), a newSViv(1) entry is added. 
       * Hence, to remove ownership, we delete the entry.
       */
      if (hv_exists_ent(hv, obj, 0)) {
	hv_delete_ent(hv, obj, 0, 0);
      }
    }
  }
  return alaqil_OK;
}

alaqilRUNTIME int
alaqil_Perl_ConvertPtr(alaqil_MAYBE_PERL_OBJECT SV *sv, void **ptr, alaqil_type_info *_t, int flags) {
  return alaqil_Perl_ConvertPtrAndOwn(sv, ptr, _t, flags, 0);
}

alaqilRUNTIME void
alaqil_Perl_MakePtr(alaqil_MAYBE_PERL_OBJECT SV *sv, void *ptr, alaqil_type_info *t, int flags) {
  if (ptr && (flags & (alaqil_SHADOW | alaqil_POINTER_OWN))) {
    SV *self;
    SV *obj=newSV(0);
    HV *hash=newHV();
    HV *stash;
    sv_setref_pv(obj, alaqil_Perl_TypeProxyName(t), ptr);
    stash=SvSTASH(SvRV(obj));
    if (flags & alaqil_POINTER_OWN) {
      HV *hv;
      GV *gv = *(GV**)hv_fetch(stash, "OWNER", 5, TRUE);
      if (!isGV(gv))
        gv_init(gv, stash, "OWNER", 5, FALSE);
      hv=GvHVn(gv);
      hv_store_ent(hv, obj, newSViv(1), 0);
    }
    sv_magic((SV *)hash, (SV *)obj, 'P', Nullch, 0);
    SvREFCNT_dec(obj);
    self=newRV_noinc((SV *)hash);
    sv_setsv(sv, self);
    SvREFCNT_dec((SV *)self);
    sv_bless(sv, stash);
  }
  else {
    sv_setref_pv(sv, alaqil_Perl_TypeProxyName(t), ptr);
  }
}

alaqilRUNTIMEINLINE SV *
alaqil_Perl_NewPointerObj(alaqil_MAYBE_PERL_OBJECT void *ptr, alaqil_type_info *t, int flags) {
  SV *result = sv_newmortal();
  alaqil_MakePtr(result, ptr, t, flags);
  return result;
}

alaqilRUNTIME void
alaqil_Perl_MakePackedObj(alaqil_MAYBE_PERL_OBJECT SV *sv, void *ptr, int sz, alaqil_type_info *type) {
  char result[1024];
  char *r = result;
  if ((2*sz + 1 + strlen(alaqil_Perl_TypeProxyName(type))) > 1000) return;
  *(r++) = '_';
  r = alaqil_PackData(r,ptr,sz);
  strcpy(r,alaqil_Perl_TypeProxyName(type));
  sv_setpv(sv, result);
}

alaqilRUNTIME SV *
alaqil_Perl_NewPackedObj(alaqil_MAYBE_PERL_OBJECT void *ptr, int sz, alaqil_type_info *type) {
  SV *result = sv_newmortal();
  alaqil_Perl_MakePackedObj(result, ptr, sz, type);
  return result;
}

/* Convert a packed pointer value */
alaqilRUNTIME int
alaqil_Perl_ConvertPacked(alaqil_MAYBE_PERL_OBJECT SV *obj, void *ptr, int sz, alaqil_type_info *ty) {
  alaqil_cast_info *tc;
  const char  *c = 0;

  if ((!obj) || (!SvOK(obj))) return alaqil_ERROR;
  c = SvPV_nolen(obj);
  /* Pointer values must start with leading underscore */
  if (*c != '_') return alaqil_ERROR;
  c++;
  c = alaqil_UnpackData(c,ptr,sz);
  if (ty) {
    tc = alaqil_TypeCheck(c,ty);
    if (!tc) return alaqil_ERROR;
  }
  return alaqil_OK;
}


/* Macros for low-level exception handling */
#define alaqil_croak(x)    { alaqil_Error(alaqil_RuntimeError, x); alaqil_fail; }


typedef XSPROTO(alaqilPerlWrapper);
typedef alaqilPerlWrapper *alaqilPerlWrapperPtr;

/* Structure for command table */
typedef struct {
  const char         *name;
  alaqilPerlWrapperPtr  wrapper;
} alaqil_command_info;

/* Information for constant table */

#define alaqil_INT     1
#define alaqil_FLOAT   2
#define alaqil_STRING  3
#define alaqil_POINTER 4
#define alaqil_BINARY  5

/* Constant information structure */
typedef struct alaqil_constant_info {
    int              type;
    const char      *name;
    long             lvalue;
    double           dvalue;
    void            *pvalue;
    alaqil_type_info **ptype;
} alaqil_constant_info;


/* Structure for variable table */
typedef struct {
  const char   *name;
  alaqilMagicFunc   set;
  alaqilMagicFunc   get;
  alaqil_type_info  **type;
} alaqil_variable_info;

/* Magic variable code */
#ifndef PERL_OBJECT
# ifdef __cplusplus
#  define alaqil_create_magic(s,a,b,c) _alaqil_create_magic(s,const_cast<char*>(a),b,c)
# else
#  define alaqil_create_magic(s,a,b,c) _alaqil_create_magic(s,(char*)(a),b,c)
# endif
# ifndef MULTIPLICITY
alaqilRUNTIME void _alaqil_create_magic(SV *sv, char *name, int (*set)(SV *, MAGIC *), int (*get)(SV *,MAGIC *)) 
# else
alaqilRUNTIME void _alaqil_create_magic(SV *sv, char *name, int (*set)(struct interpreter*, SV *, MAGIC *), int (*get)(struct interpreter*, SV *,MAGIC *)) 
# endif
#else
#  define alaqil_create_magic(s,a,b,c) _alaqil_create_magic(pPerl,s,a,b,c)
alaqilRUNTIME void _alaqil_create_magic(CPerlObj *pPerl, SV *sv, const char *name, int (CPerlObj::*set)(SV *, MAGIC *), int (CPerlObj::*get)(SV *, MAGIC *)) 
#endif
{
  MAGIC *mg;
  sv_magic(sv,sv,'U',name,strlen(name));
  mg = mg_find(sv,'U');
  mg->mg_virtual = (MGVTBL *) malloc(sizeof(MGVTBL));
  mg->mg_virtual->svt_get = (alaqilMagicFunc) get;
  mg->mg_virtual->svt_set = (alaqilMagicFunc) set;
  mg->mg_virtual->svt_len = 0;
  mg->mg_virtual->svt_clear = 0;
  mg->mg_virtual->svt_free = 0;
}


alaqilRUNTIME alaqil_module_info *
alaqil_Perl_GetModule(void *alaqilUNUSEDPARM(clientdata)) {
  static void *type_pointer = (void *)0;
  SV *pointer;

  /* first check if pointer already created */
  if (!type_pointer) {
    pointer = get_sv("alaqil_runtime_data::type_pointer" alaqil_RUNTIME_VERSION alaqil_TYPE_TABLE_NAME, FALSE | GV_ADDMULTI);
    if (pointer && SvOK(pointer)) {
      type_pointer = INT2PTR(alaqil_type_info **, SvIV(pointer));
    }
  }

  return (alaqil_module_info *) type_pointer;
}

alaqilRUNTIME void
alaqil_Perl_SetModule(alaqil_module_info *module) {
  SV *pointer;

  /* create a new pointer */
  pointer = get_sv("alaqil_runtime_data::type_pointer" alaqil_RUNTIME_VERSION alaqil_TYPE_TABLE_NAME, TRUE | GV_ADDMULTI);
  sv_setiv(pointer, PTR2IV(module));
}

#ifdef __cplusplus
}
#endif
