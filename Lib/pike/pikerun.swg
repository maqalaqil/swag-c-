/* -----------------------------------------------------------------------------
 * pikerun.swg
 *
 * This file contains the runtime support for Pike modules
 * and includes code for managing global variables and pointer
 * type checking.
 * ----------------------------------------------------------------------------- */

#ifdef __cplusplus
extern "C" {
#endif
#include "pike/object.h"
#include "pike/program.h"
#ifdef __cplusplus
}
#endif
#include <assert.h>

/* Stores information about a wrapped object */
typedef struct alaqil_object_wrapper {
    void *self;
    alaqil_type_info *type;
} alaqil_object_wrapper;

#ifdef THIS
#undef THIS
#endif
#define THIS (((alaqil_object_wrapper *) Pike_fp->current_storage)->self)

#define alaqil_ConvertPtr alaqil_Pike_ConvertPtr
#define alaqil_NewPointerObj alaqil_Pike_NewPointerObj
#define alaqil_GetModule(clientdata) alaqil_Pike_GetModule(clientdata)
#define alaqil_SetModule(clientdata, pointer) alaqil_Pike_SetModule(pointer)

/* These need to be filled in before type sharing between modules will work */
static alaqil_module_info *alaqil_Pike_GetModule(void *alaqilUNUSEDPARM(clientdata)) {
  return 0;
}

static void alaqil_Pike_SetModule(alaqil_module_info *pointer) {

}

/* Convert a pointer value */
static int
alaqil_Pike_ConvertPtr(struct object *obj, void **ptr, alaqil_type_info *ty, int flags) {
    struct program *pr;
    alaqil_cast_info *tc;
    alaqil_object_wrapper *obj_wrapper;
    
    if (ty) {
        pr = (struct program *) ty->clientdata;
        obj_wrapper = (alaqil_object_wrapper *) get_storage(obj, pr);
        if (obj_wrapper && obj_wrapper->type) {
            tc = alaqil_TypeCheckStruct(obj_wrapper->type, ty);
            if (tc) {
                int newmemory = 0;
                *ptr = alaqil_TypeCast(tc, obj_wrapper->self, &newmemory);
                assert(!newmemory); /* newmemory handling not yet implemented */
                return 0;
            }
        }
    }
    return -1;
}

/* Create a new pointer object */
static struct object *
alaqil_Pike_NewPointerObj(void *ptr, alaqil_type_info *type, int own) {
    return 0;
}
