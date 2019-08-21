/*
 * C-type: unsigned long
 * Scilab type: see unsigned int
 */

%fragment(alaqil_AsVal_frag(unsigned long), "header", fragment="alaqil_UnsignedInt_AsUnsignedLong") {
#define alaqil_AsVal_unsigned_SS_long(scilabValue, valuePointer) alaqil_UnsignedInt_AsUnsignedLong(pvApiCtx, scilabValue, valuePointer, alaqil_Scilab_GetFuncName())
}
%fragment("alaqil_UnsignedInt_AsUnsignedLong", "header", fragment=alaqil_AsVal_frag(unsigned int)) {
alaqilINTERN int
alaqil_UnsignedInt_AsUnsignedLong(void *pvApiCtx, alaqilSciObject iVar, unsigned long *pulValue, char *fname) {
  unsigned int uiValue = 0;
  if(alaqil_AsVal_unsigned_SS_int(iVar, &uiValue) != alaqil_OK) {
    return alaqil_ERROR;
  }
  *pulValue = (unsigned long) uiValue;
  return alaqil_OK;
}
}

%fragment(alaqil_From_frag(unsigned long), "header", fragment="alaqil_UnsignedInt_FromUnsignedLong") {
#define alaqil_From_unsigned_SS_long(scilabValue) alaqil_UnsignedInt_FromUnsignedLong(pvApiCtx, alaqil_Scilab_GetOutputPosition(), scilabValue, alaqil_Scilab_GetFuncName())
}
%fragment("alaqil_UnsignedInt_FromUnsignedLong", "header", fragment=alaqil_From_frag(unsigned int)) {
alaqilINTERN int
alaqil_UnsignedInt_FromUnsignedLong(void *pvApiCtx, int iVarOut, unsigned long ulValue, char *fname) {
  return alaqil_From_unsigned_SS_int((unsigned int)ulValue);
}
}

%fragment("alaqil_SciDouble_FromUnsignedLongArrayAndSize", "header") {
alaqilINTERN int
alaqil_SciDouble_FromUnsignedLongArrayAndSize(void *pvApiCtx, int iVarOut, int iRows, int iCols, const unsigned long *pulValues) {
  SciErr sciErr;
  double *pdValues = NULL;
  int i;

  pdValues = (double*) malloc(iRows * iCols * sizeof(double));
  for (i=0; i<iRows * iCols; i++) {
    pdValues[i] = pulValues[i];
  }

  sciErr = createMatrixOfDouble(pvApiCtx, alaqil_NbInputArgument(pvApiCtx) + iVarOut, iRows, iCols, pdValues);
  if (sciErr.iErr) {
    printError(&sciErr, 0);
    free(pdValues);
    return alaqil_ERROR;
  }

  free(pdValues);
  return alaqil_OK;
}
}
