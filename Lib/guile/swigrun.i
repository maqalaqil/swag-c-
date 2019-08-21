/* -*- mode: c -*- */

%module alaqilrun

#ifdef alaqilGUILE_SCM

/* Hook the runtime module initialization
   into the shared initialization function alaqil_Guile_Init. */
%runtime %{
/* Hook the runtime module initialization
   into the shared initialization function alaqil_Guile_Init. */
#include <libguile.h>
#ifdef __cplusplus
extern "C"
#endif
SCM scm_init_alaqil_alaqilrun_module (void);
#define alaqil_INIT_RUNTIME_MODULE scm_init_alaqil_alaqilrun_module();
%}

/* The runtime type system from common.swg */

typedef struct alaqil_type_info alaqil_type_info;

const char *
alaqil_TypeName(const alaqil_type_info *type);

const char *
alaqil_TypePrettyName(const alaqil_type_info *type);

alaqil_type_info *
alaqil_TypeQuery(const char *);

/* Language-specific stuff */

%apply bool { int };

int
alaqil_IsPointer(SCM object);

int
alaqil_IsPointerOfType(SCM object, alaqil_type_info *type);

unsigned long
alaqil_PointerAddress(SCM object);

alaqil_type_info *
alaqil_PointerType(SCM object);

#endif
