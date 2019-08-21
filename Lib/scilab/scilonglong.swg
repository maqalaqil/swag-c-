/*
 * C-type: long long
 * Scilab 5 type: NONE
 * Scilab 6 type: int64
 */
%fragment(alaqil_AsVal_frag(long long), "header", fragment="alaqil_SciInt64_ToLongLong") {
%#define alaqil_AsVal_long_SS_long(scilabValue, valuePointer) alaqil_SciInt64_ToLongLong(pvApiCtx, scilabValue, valuePointer, alaqil_Scilab_GetFuncName())
}
%fragment("alaqil_SciInt64_ToLongLong", "header") {
alaqilINTERN int
alaqil_SciInt64_ToLongLong(void *pvApiCtx, int iVar, long long *pllValue, char *fname) {
  Scierror(SCILAB_API_ARGUMENT_ERROR, _("%s: Scilab 5.X does not manage '%s' data type.\n"), "alaqil_SciInt64_ToLongLong", "int64");
  return alaqil_ERROR;
}
}

%fragment(alaqil_From_frag(long long), "header", fragment="alaqil_SciInt64_FromLongLong") {
#define alaqil_From_long_SS_long(value) alaqil_SciInt64_FromLongLong(pvApiCtx, $result, value)
}
%fragment("alaqil_SciInt64_FromLongLong", "header") {
alaqilINTERN int
alaqil_SciInt64_FromLongLong(void *pvApiCtx, int iVarOut, long long llValue) {
  Scierror(SCILAB_API_ARGUMENT_ERROR, _("%s: Scilab 5.X does not manage '%s' data type.\n"), "alaqil_SciInt64_ToLongLong", "int64");
  return alaqil_ERROR;
}
}

/*
 * C-type: unsigned long long
 * Scilab 5 type: NONE
 * Scilab 6 type: uint64
 */
%fragment(alaqil_AsVal_frag(unsigned long long), "header", fragment="alaqil_SciUint64_ToUnsignedLongLong") {
#define alaqil_AsVal_unsigned_SS_long_SS_long(scilabValue, valuePointer) alaqil_SciUint64_ToUnsignedLongLong(pvApiCtx, scilabValue, valuePointer, alaqil_Scilab_GetFuncName())
}
%fragment("alaqil_SciUint64_ToUnsignedLongLong", "header") {
alaqilINTERN int
alaqil_SciUint64_ToUnsignedLongLong(void *pvApiCtx, int iVar, unsigned long long *pullValue, char *fname) {
  Scierror(SCILAB_API_ARGUMENT_ERROR, _("%s: Scilab 5.X does not manage '%s' data type.\n"), "alaqil_SciUint64_ToLongLong", "uint64");
  return alaqil_ERROR;
}
}

%fragment(alaqil_From_frag(unsigned long long), "header", fragment="alaqil_SciUint64_FromUnsignedLongLong") {
#define alaqil_From_unsigned_SS_long_SS_long(value) alaqil_SciUint64_FromUnsignedLongLong(pvApiCtx, $result, value)
}
%fragment("alaqil_SciUint64_FromUnsignedLongLong", "header") {
alaqilINTERN int
alaqil_SciUint64_FromUnsignedLongLong(void *pvApiCtx, int iVarOut, unsigned long long llValue) {
  Scierror(SCILAB_API_ARGUMENT_ERROR, _("%s: Scilab 5.X does not manage '%s' data type.\n"), "alaqil_SciUint64_ToLongLong", "uint64");
  return alaqil_ERROR;
}
}

