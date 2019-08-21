/*
 * C-type: long
 * Scilab type: double or int32
 */

%fragment(alaqil_AsVal_frag(long), "header", fragment="alaqil_SciDoubleOrInt32_AsLong", fragment="<limits.h>") {
%#define alaqil_AsVal_long(scilabValue, valuePointer) alaqil_SciDoubleOrInt32_AsLong(pvApiCtx, scilabValue, valuePointer, alaqil_Scilab_GetFuncName());
}
%fragment("alaqil_SciDoubleOrInt32_AsLong", "header") {
alaqilINTERN int
alaqil_SciDoubleOrInt32_AsLong(void *pvApiCtx, alaqilSciObject iVar, long *plValue, char *fname) {
  SciErr sciErr;
  int iType = 0;
  int iRows = 0;
  int iCols = 0;
  int *piAddrVar = NULL;

  sciErr = getVarAddressFromPosition(pvApiCtx, iVar, &piAddrVar);
  if (sciErr.iErr) {
    printError(&sciErr, 0);
    return alaqil_ERROR;
  }

  sciErr = getVarType(pvApiCtx, piAddrVar, &iType);
  if (sciErr.iErr) {
    printError(&sciErr, 0);
    return alaqil_ERROR;
  }

  if (iType == sci_ints) {
    int iPrec = 0;
    int *piData = NULL;

    sciErr = getMatrixOfIntegerPrecision(pvApiCtx, piAddrVar, &iPrec);
    if (sciErr.iErr) {
      printError(&sciErr, 0);
      return alaqil_ERROR;
    }
    if (iPrec != SCI_INT32) {
      Scierror(SCILAB_API_ARGUMENT_ERROR, _("%s: Wrong type for input argument #%d: A 32-bit signed integer or a double expected.\n"), fname, iVar);
      return alaqil_TypeError;
    }
    sciErr = getMatrixOfInteger32(pvApiCtx, piAddrVar, &iRows, &iCols, &piData);
    if (sciErr.iErr) {
      printError(&sciErr, 0);
      return alaqil_ERROR;
    }
    if (iRows * iCols != 1) {
      Scierror(SCILAB_API_ARGUMENT_ERROR, _("%s: Wrong size for input argument #%d: A 32-bit signed integer or a double expected.\n"), fname, iVar);
      return alaqil_TypeError;
    }
    *plValue = (long) *piData;
  }
  else if (iType == sci_matrix) {
    double *pdData = NULL;
    double dValue = 0.0f;

    sciErr = getMatrixOfDouble(pvApiCtx, piAddrVar, &iRows, &iCols, &pdData);
    if (sciErr.iErr) {
      printError(&sciErr, 0);
      return alaqil_ERROR;
    }
    if (iRows * iCols != 1) {
      Scierror(SCILAB_API_ARGUMENT_ERROR, _("%s: Wrong size for input argument #%d: A 32-bit signed integer or a double expected.\n"), fname, iVar);
      return alaqil_TypeError;
    }
    dValue = *pdData;
    if (dValue != floor(dValue)) {
      Scierror(SCILAB_API_ARGUMENT_ERROR, _("%s: Incorrect value for input argument #%d: The double value cannot be converted to a 32-bit signed integer.\n"), fname, iVar);
      return alaqil_ValueError;
    }
    if ((dValue < LONG_MIN) || (dValue > LONG_MAX)) {
      Scierror(SCILAB_API_ARGUMENT_ERROR, _("%s: Overflow error for input argument #%d: The double value cannot be converted to a 32-bit signed integer.\n"), fname, iVar);
      return alaqil_OverflowError;
    }
    *plValue = (long) dValue;
  }
  else {
    Scierror(SCILAB_API_ARGUMENT_ERROR, _("%s: Wrong type for input argument #%d: A 32-bit signed integer or a double expected.\n"), fname, iVar);
    return alaqil_TypeError;
  }

  return alaqil_OK;
}
}

%fragment(alaqil_From_frag(long), "header", fragment="alaqil_SciDouble_FromLong") {
%#define alaqil_From_long(scilabValue) alaqil_SciDouble_FromLong(pvApiCtx, alaqil_Scilab_GetOutputPosition(), scilabValue, alaqil_Scilab_GetFuncName())
}
%fragment("alaqil_SciDouble_FromLong", "header") {
alaqilINTERN int
alaqil_SciDouble_FromLong(void *pvApiCtx, int iVarOut, long lValue, char *fname) {
  if (createScalarDouble(pvApiCtx,
    alaqil_NbInputArgument(pvApiCtx) + iVarOut, (double) lValue))
    return alaqil_ERROR;
  return alaqil_OK;
}
}


%fragment("alaqil_SciDouble_FromLongArrayAndSize", "header") {
alaqilINTERN int
alaqil_SciDouble_FromLongArrayAndSize(void *pvApiCtx, int iVarOut, int iRows, int iCols, const long *plData) {
  SciErr sciErr;
  int i;
  double *pdValues = NULL;

  pdValues = (double*) malloc(iRows * iCols * sizeof(double));
  for (i=0; i<iRows * iCols; i++) {
    pdValues[i] = plData[i];
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

