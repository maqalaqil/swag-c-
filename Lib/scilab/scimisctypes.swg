// Other primitive such as size_t and ptrdiff_t

/*
 * C-type: size_t
 * Scilab type: double or int32
 */

%fragment(alaqil_AsVal_frag(size_t), "header", fragment="alaqil_Int_AsSize") {
%#define alaqil_AsVal_size_t(scilabValue, valuePointer) alaqil_Int_AsSize(pvApiCtx, scilabValue, valuePointer, alaqil_Scilab_GetFuncName())
}
%fragment("alaqil_Int_AsSize", "header", fragment=alaqil_AsVal_frag(int))
{
alaqilINTERN int
alaqil_Int_AsSize(void *pvApiCtx, alaqilSciObject iVar, size_t *piValue, char *fname) {
  int iValue = 0;
  if (alaqil_AsVal_dec(int)(iVar, &iValue) != alaqil_OK)
    return alaqil_ERROR;

  if (piValue)
    *piValue = (size_t) iValue;

  return alaqil_OK;
}
}

%fragment(alaqil_From_frag(size_t), "header", fragment="alaqil_Int_FromSize") {
%#define alaqil_From_size_t(scilabValue) alaqil_Int_FromSize(pvApiCtx, alaqil_Scilab_GetOutputPosition(), scilabValue, alaqil_Scilab_GetFuncName())
}
%fragment("alaqil_Int_FromSize", "header", fragment=alaqil_From_frag(int))
{
alaqilINTERN int
alaqil_Int_FromSize(void *pvApiCtx, int iVarOut, size_t iValue, char *fname) {
  return alaqil_From_dec(int)((int)iValue);
}
}

/*
 * C-type: ptrdiff_t
 * Scilab type: double or int32
 */

%fragment(alaqil_AsVal_frag(ptrdiff_t), "header", fragment="alaqil_Int_AsPtrDiff") {
%#define alaqil_AsVal_ptrdiff_t(scilabValue, valuePointer) alaqil_Int_AsPtrDiff(pvApiCtx, scilabValue, valuePointer, alaqil_Scilab_GetFuncName())
}
%fragment("alaqil_Int_AsPtrDiff", "header", fragment=alaqil_AsVal_frag(int))
{
alaqilINTERN int
alaqil_Int_AsPtrDiff(void *pvApiCtx, alaqilSciObject iVar, ptrdiff_t *piValue, char *fname) {
  int iValue = 0;
  if (alaqil_AsVal_dec(int)(iVar, &iValue) != alaqil_OK)
    return alaqil_ERROR;

  if (piValue)
    *piValue = (ptrdiff_t) iValue;

  return alaqil_OK;
}
}

%fragment(alaqil_From_frag(ptrdiff_t), "header", fragment="alaqil_Int_FromPtrDiff") {
%#define alaqil_From_ptrdiff_t(scilabValue) alaqil_Int_FromPtrDiff(pvApiCtx, alaqil_Scilab_GetOutputPosition(), scilabValue, alaqil_Scilab_GetFuncName())
}
%fragment("alaqil_Int_FromPtrDiff", "header", fragment=alaqil_From_frag(int)) {
alaqilINTERN int
alaqil_Int_FromPtrDiff(void *pvApiCtx, int iVarOut, ptrdiff_t iValue, char *fname) {
  return alaqil_From_dec(int)((int)iValue);
}
}

