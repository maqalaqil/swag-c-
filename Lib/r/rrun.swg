
/* Remove global namespace pollution */
#if !defined(alaqil_NO_R_NO_REMAP)
# define R_NO_REMAP
#endif
#if !defined(alaqil_NO_STRICT_R_HEADERS)
# define STRICT_R_HEADERS
#endif

#include <Rdefines.h>
#include <Rversion.h>

#ifdef __cplusplus
#include <exception>
extern "C" {
#endif

/* for raw pointer */
#define alaqil_ConvertPtr(obj, pptr, type, flags)         alaqil_R_ConvertPtr(obj, pptr, type, flags)
#define alaqil_ConvertPtrAndOwn(obj,pptr,type,flags,own)  alaqil_R_ConvertPtr(obj, pptr, type, flags)
#define alaqil_NewPointerObj(ptr, type, flags)            alaqil_R_NewPointerObj(ptr, type, flags)

#include <stdio.h>
#include <stdlib.h>
#include <assert.h>

#if R_VERSION >= R_Version(2,6,0)
#define VMAXTYPE void *
#else
#define VMAXTYPE char *
#endif

/*
  This is mainly a way to avoid having lots of local variables that may 
  conflict with those in the routine.

   Change name to R_alaqil_Callb....
*/
typedef struct RCallbackFunctionData {

  SEXP fun;
  SEXP userData;


  SEXP expr;
  SEXP retValue;
  int errorOccurred;

  SEXP el;  /* Temporary pointer used in the construction of the expression to call the R function. */

  struct RCallbackFunctionData *previous;   /* Stack */

} RCallbackFunctionData;

static RCallbackFunctionData  *callbackFunctionDataStack;


alaqilRUNTIME SEXP
R_alaqil_debug_getCallbackFunctionData()
{
  int n, i;
  SEXP ans;
  RCallbackFunctionData  *p = callbackFunctionDataStack;

  n = 0;
  while(p) { 
    n++;
    p = p->previous;
  }

  Rf_protect(ans = Rf_allocVector(VECSXP, n));
  for(p = callbackFunctionDataStack, i = 0; i < n; p = p->previous, i++) 
      SET_VECTOR_ELT(ans, i, p->fun);

  Rf_unprotect(1);

  return(ans);
}



alaqilRUNTIME RCallbackFunctionData *
R_alaqil_pushCallbackFunctionData(SEXP fun, SEXP userData)
{
   RCallbackFunctionData *el;
   el = (RCallbackFunctionData *) calloc(1, sizeof(RCallbackFunctionData));
   el->fun = fun;
   el->userData = userData;
   el->previous = callbackFunctionDataStack;

   callbackFunctionDataStack = el;

   return(el);
}


alaqilRUNTIME SEXP
R_alaqil_R_pushCallbackFunctionData(SEXP fun, SEXP userData)
{
    R_alaqil_pushCallbackFunctionData(fun, userData);
    return R_NilValue;
}

alaqilRUNTIME RCallbackFunctionData *
R_alaqil_getCallbackFunctionData()
{
  if(!callbackFunctionDataStack) {
    Rf_error("Supposedly impossible error occurred in the alaqil callback mechanism."
            "  No callback function data set.");
  }
  
  return callbackFunctionDataStack;
}

alaqilRUNTIME void
R_alaqil_popCallbackFunctionData(int doFree)
{
  RCallbackFunctionData  *el = NULL;
  if(!callbackFunctionDataStack)
    return ; /* Error !!! */

  el = callbackFunctionDataStack ;
  callbackFunctionDataStack = callbackFunctionDataStack->previous;

  if(doFree)
     free(el);
}


/*
  Interface to S function
      is(obj, type)
  which is to be used to determine if an 
  external pointer inherits from the right class.

  Ideally, we would like to be able to do this without an explicit call to the is() function.
  When the S4 class system uses its own SEXP types, then we will hopefully be able to do this
  in the C code.

  Should we make the expression static and preserve it to avoid the overhead of 
  allocating each time.
*/
alaqilRUNTIME int
R_alaqil_checkInherits(SEXP obj, SEXP tag, const char *type)
{
  SEXP e, val;
  int check_err = 0;

  Rf_protect(e = Rf_allocVector(LANGSXP, 3));
  SETCAR(e, Rf_install("extends"));

  SETCAR(CDR(e), Rf_mkString(CHAR(PRINTNAME(tag))));
  SETCAR(CDR(CDR(e)), Rf_mkString(type));

  val = R_tryEval(e, R_GlobalEnv, &check_err);
  Rf_unprotect(1);
  if(check_err) 
    return(0);


  return(LOGICAL(val)[0]);
}


alaqilRUNTIME void *
R_alaqil_resolveExternalRef(SEXP arg, const char * const type, const char * const argName, Rboolean nullOk)
{
  void *ptr;
  SEXP orig = arg;

  if(TYPEOF(arg) != EXTPTRSXP) 
    arg = GET_SLOT(arg, Rf_mkString("ref"));

  
  if(TYPEOF(arg) != EXTPTRSXP) {
    Rf_error("argument %s must be an external pointer (from an ExternalReference)", argName);
  }


  ptr = R_ExternalPtrAddr(arg);

  if(ptr == NULL && nullOk == (Rboolean) FALSE) {
    Rf_error("the external pointer (of type %s) for argument %s has value NULL", argName, type);
  }

  if(type[0] && R_ExternalPtrTag(arg) != Rf_install(type) && strcmp(type, "voidRef")
      && !R_alaqil_checkInherits(orig,  R_ExternalPtrTag(arg), type)) {
    Rf_error("the external pointer for argument %s has tag %s, not the expected value %s",
             argName, CHAR(PRINTNAME(R_ExternalPtrTag(arg))), type);
  }


  return(ptr);
}

alaqilRUNTIME void
R_alaqil_ReferenceFinalizer(SEXP el)
{
  void *ptr = R_alaqil_resolveExternalRef(el, "", "<finalizer>",  (Rboolean) 1);
  fprintf(stderr, "In R_alaqil_ReferenceFinalizer for %p\n", ptr);
  Rf_PrintValue(el);

  if(ptr) {
     if(TYPEOF(el) != EXTPTRSXP)
        el = GET_SLOT(el, Rf_mkString("ref"));

     if(TYPEOF(el) == EXTPTRSXP)
        R_ClearExternalPtr(el);

     free(ptr);
  }

  return;
}

alaqilRUNTIME SEXP
alaqil_MakePtr(void *ptr, const char *typeName, int flags)
{
  SEXP external, r_obj;

  Rf_protect(external = R_MakeExternalPtr(ptr, Rf_install(typeName), R_NilValue));
  Rf_protect(r_obj = NEW_OBJECT(MAKE_CLASS((char *) typeName)));

  if (flags & alaqil_POINTER_OWN)
    R_RegisterCFinalizer(external, R_alaqil_ReferenceFinalizer);

  r_obj = SET_SLOT(r_obj, Rf_mkString((char *) "ref"), external);
  SET_S4_OBJECT(r_obj);
  Rf_unprotect(2);

  return(r_obj);
}


alaqilRUNTIME SEXP
R_alaqil_create_alaqil_R_Array(const char *typeName, SEXP ref, int len)
{
   SEXP arr;

/*XXX remove the char * cast when we can. MAKE_CLASS should be declared appropriately. */
   Rf_protect(arr = NEW_OBJECT(MAKE_CLASS((char *) typeName)));
   Rf_protect(arr = R_do_slot_assign(arr, Rf_mkString("ref"), ref));
   Rf_protect(arr = R_do_slot_assign(arr, Rf_mkString("dims"), Rf_ScalarInteger(len)));

   Rf_unprotect(3); 			   
   SET_S4_OBJECT(arr);	
   return arr;
}

#define ADD_OUTPUT_ARG(result, pos, value, name)  r_ans = AddOutputArgToReturn(pos, value, name, OutputValues);

alaqilRUNTIME SEXP
AddOutputArgToReturn(int pos, SEXP value, const char *name, SEXP output)
{
  SET_VECTOR_ELT(output, pos, value);

  return(output);
}

/* Create a new pointer object */
alaqilRUNTIMEINLINE SEXP
alaqil_R_NewPointerObj(void *ptr, alaqil_type_info *type, int flags) {
  SEXP rptr;
  if (!ptr) {
     return R_NilValue;
  }
  rptr = R_MakeExternalPtr(ptr, 
  R_MakeExternalPtr(type, R_NilValue, R_NilValue), R_NilValue); 
  SET_S4_OBJECT(rptr);
  return rptr;
}


/* Convert a pointer value */
alaqilRUNTIMEINLINE int
alaqil_R_ConvertPtr(SEXP obj, void **ptr, alaqil_type_info *ty, int flags) {
  void *vptr;
  if (!obj) return alaqil_ERROR;
  if (obj == R_NilValue) {
    if (ptr) *ptr = NULL;
    return (flags & alaqil_POINTER_NO_NULL) ? alaqil_NullReferenceError : alaqil_OK;
  }

  vptr = R_ExternalPtrAddr(obj);
  if (ty) {
    alaqil_type_info *to = (alaqil_type_info*) 
      R_ExternalPtrAddr(R_ExternalPtrTag(obj));
    if (to == ty) {
      if (ptr) *ptr = vptr;
    } else {
      alaqil_cast_info *tc = alaqil_TypeCheck(to->name,ty);
      int newmemory = 0;
      if (ptr) *ptr = alaqil_TypeCast(tc,vptr,&newmemory);
      assert(!newmemory); /* newmemory handling not yet implemented */
    }
  } else {
      if (ptr) *ptr = vptr;
 }
  return alaqil_OK;
}

alaqilRUNTIME alaqil_module_info *
alaqil_GetModule(void *alaqilUNUSEDPARM(clientdata)) {
  static void *type_pointer = (void *)0;
  return (alaqil_module_info *) type_pointer;
}

alaqilRUNTIME void
alaqil_SetModule(void *v, alaqil_module_info *alaqil_module) {
}

typedef struct {
  void *pack;
  alaqil_type_info *ty;
  size_t size;
} RalaqilPacked;

/* Create a new packed object */

alaqilRUNTIMEINLINE SEXP RalaqilPacked_New(void *ptr, size_t sz,
		  alaqil_type_info *ty) {
  SEXP rptr;
  RalaqilPacked *sobj = 
  (RalaqilPacked*) malloc(sizeof(RalaqilPacked));
  if (sobj) {
    void *pack = malloc(sz);
    if (pack) {
      memcpy(pack, ptr, sz);
      sobj->pack = pack;
      sobj->ty   = ty;
      sobj->size = sz;
    } else {
      sobj = 0;
    }
  }
  rptr = R_MakeExternalPtr(sobj, R_NilValue, R_NilValue); 
  return rptr;
}

alaqilRUNTIME alaqil_type_info *
RalaqilPacked_UnpackData(SEXP obj, void *ptr, size_t size)
{
    RalaqilPacked *sobj = 
        (RalaqilPacked *)R_ExternalPtrAddr(obj);
    if (sobj->size != size) return 0;
    memcpy(ptr, sobj->pack, size);
    return sobj->ty;
}

alaqilRUNTIMEINLINE SEXP
alaqil_R_NewPackedObj(void *ptr, size_t sz, alaqil_type_info *type) {
  return ptr ? RalaqilPacked_New((void *) ptr, sz, type) : R_NilValue;
}

/* Convert a packed pointer value */

alaqilRUNTIME int
alaqil_R_ConvertPacked(SEXP obj, void *ptr, size_t sz, alaqil_type_info *ty) {
  alaqil_type_info *to = RalaqilPacked_UnpackData(obj, ptr, sz);
  if (!to) return alaqil_ERROR;
  if (ty) {
    if (to != ty) {
      /* check type cast? */
      alaqil_cast_info *tc = alaqil_TypeCheck(to->name,ty);
      if (!tc) return alaqil_ERROR;
    }
  }
  return alaqil_OK;
}  

#ifdef __cplusplus
#define alaqil_exception_noreturn(code, msg) do { throw std::runtime_error(msg); } while(0)
#else
#define alaqil_exception_noreturn(code, msg) do { return result; } while(0)
#endif

#ifdef __cplusplus
}
#endif
