/* -----------------------------------------------------------------------------
 * alaqil API. Portion that goes into the runtime
 * ----------------------------------------------------------------------------- */
#ifdef __cplusplus
extern "C" {
#endif

/* -----------------------------------------------------------------------------
 * Constant declarations
 * ----------------------------------------------------------------------------- */

/* Constant Types */
#define alaqil_TCL_POINTER 4
#define alaqil_TCL_BINARY  5

/* Constant information structure */
typedef struct alaqil_const_info {
    int type;
    const char *name;
    long lvalue;
    double dvalue;
    void   *pvalue;
    alaqil_type_info **ptype;
} alaqil_const_info;

typedef int   (*alaqil_wrapper)(ClientData, Tcl_Interp *, int, Tcl_Obj *CONST []);
typedef int   (*alaqil_wrapper_func)(ClientData, Tcl_Interp *, int, Tcl_Obj *CONST []);
typedef char *(*alaqil_variable_func)(ClientData, Tcl_Interp *, char *, char *, int);
typedef void  (*alaqil_delete_func)(ClientData);

typedef struct alaqil_method {
  const char     *name;
  alaqil_wrapper   method;
} alaqil_method;

typedef struct alaqil_attribute {
  const char     *name;
  alaqil_wrapper   getmethod;
  alaqil_wrapper   setmethod;
} alaqil_attribute;

typedef struct alaqil_class {
  const char         *name;
  alaqil_type_info   **type;
  alaqil_wrapper       constructor;
  void              (*destructor)(void *);
  alaqil_method        *methods;
  alaqil_attribute     *attributes;
  struct alaqil_class **bases;
  const char              **base_names;
  alaqil_module_info   *module;
  Tcl_HashTable       hashtable;
} alaqil_class;

typedef struct alaqil_instance {
  Tcl_Obj       *thisptr;
  void          *thisvalue;
  alaqil_class   *classptr;
  int            destroy;
  Tcl_Command    cmdtok;
} alaqil_instance;

/* Structure for command table */
typedef struct {
  const char *name;
  int       (*wrapper)(ClientData, Tcl_Interp *, int, Tcl_Obj *CONST []);
  ClientData  clientdata;
} alaqil_command_info;

/* Structure for variable linking table */
typedef struct {
  const char *name;
  void *addr;
  char * (*get)(ClientData, Tcl_Interp *, char *, char *, int);
  char * (*set)(ClientData, Tcl_Interp *, char *, char *, int);
} alaqil_var_info;


/* -----------------------------------------------------------------------------*
 *  Install a constant object 
 * -----------------------------------------------------------------------------*/

static Tcl_HashTable   alaqilconstTable;
static int             alaqilconstTableinit = 0;

alaqilINTERN void
alaqil_Tcl_SetConstantObj(Tcl_Interp *interp, const char* name, Tcl_Obj *obj) {
  int newobj;
  Tcl_ObjSetVar2(interp,Tcl_NewStringObj(name,-1), NULL, obj, TCL_GLOBAL_ONLY);
  Tcl_SetHashValue(Tcl_CreateHashEntry(&alaqilconstTable, name, &newobj), (ClientData) obj);
}

alaqilINTERN Tcl_Obj *
alaqil_Tcl_GetConstantObj(const char *key) {
  Tcl_HashEntry *entryPtr;
  if (!alaqilconstTableinit) return 0;
  entryPtr = Tcl_FindHashEntry(&alaqilconstTable, key);
  if (entryPtr) {
    return (Tcl_Obj *) Tcl_GetHashValue(entryPtr);
  }
  return 0;
}

#ifdef __cplusplus
}
#endif


