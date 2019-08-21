/* -----------------------------------------------------------------------------
 * Python API portion that goes into the runtime
 * ----------------------------------------------------------------------------- */

#ifdef __cplusplus
extern "C" {
#endif

/* -----------------------------------------------------------------------------
 * Constant declarations
 * ----------------------------------------------------------------------------- */

/* Constant Types */
#define alaqil_PY_POINTER 4
#define alaqil_PY_BINARY  5

/* Constant information structure */
typedef struct alaqil_const_info {
  int type;
  const char *name;
  long lvalue;
  double dvalue;
  void   *pvalue;
  alaqil_type_info **ptype;
} alaqil_const_info;

#ifdef __cplusplus
}
#endif

