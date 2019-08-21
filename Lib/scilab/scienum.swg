/*
 * C-type: enum
 * Scilab type: double or int32
 */

%fragment(alaqil_AsVal_frag(Enum), "header", fragment="alaqil_Int_AsEnum") {
%#define alaqil_AsVal_Enum(scilabValue, valuePointer) alaqil_Int_AsEnum(pvApiCtx, scilabValue, valuePointer, alaqil_Scilab_GetFuncName())
}
%fragment("alaqil_Int_AsEnum", "header", fragment="alaqil_SciDoubleOrInt32_AsInt") {
alaqilINTERN int
alaqil_Int_AsEnum(void *pvApiCtx, int iVar, int *enumValue, char *fname) {
  int iValue = 0;
  if (alaqil_SciDoubleOrInt32_AsInt(pvApiCtx, iVar, &iValue, fname) != alaqil_OK)
    return alaqil_ERROR;
  *enumValue = iValue;
  return alaqil_OK;
}
}

%fragment(alaqil_From_frag(Enum), "header", fragment="alaqil_Int_FromEnum") {
%#define alaqil_From_Enum(scilabValue) alaqil_Int_FromEnum(pvApiCtx, alaqil_Scilab_GetOutputPosition(), scilabValue, alaqil_Scilab_GetFuncName())
}
%fragment("alaqil_Int_FromEnum", "header", fragment="alaqil_SciDouble_FromInt") {
alaqilINTERN int
alaqil_Int_FromEnum(void *pvApiCtx, int iVarOut, int enumValue, char *fname) {
  if (alaqil_SciDouble_FromInt(pvApiCtx, iVarOut, enumValue, fname) != alaqil_OK)
    return alaqil_ERROR;
  alaqil_Scilab_SetOutput(pvApiCtx, iVarOut);
  return alaqil_OK;
}
}
