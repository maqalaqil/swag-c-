/*
 * C-type: bool
 * Scilab type: boolean scalar
 */
%fragment(alaqil_AsVal_frag(bool), "header") {
alaqilINTERN int
alaqil_AsVal_dec(bool)(alaqilSciObject iVar, bool *pbValue) {
  SciErr sciErr;
  int iRet = 0;
  int *piAddrVar = NULL;
  int iTempValue = 0;

  sciErr = getVarAddressFromPosition(pvApiCtx, iVar, &piAddrVar);
  if (sciErr.iErr) {
    printError(&sciErr, 0);
    return alaqil_ERROR;
  }

  if (!isBooleanType(pvApiCtx, piAddrVar)) {
      Scierror(SCILAB_API_ARGUMENT_ERROR, _("%s: Wrong type for input argument #%d: A boolean expected.\n"), alaqil_Scilab_GetFuncName(), iVar);
    return alaqil_ERROR;
  }

  if (!isScalar(pvApiCtx, piAddrVar)) {
    Scierror(SCILAB_API_ARGUMENT_ERROR, _("%s: Wrong size for input argument #%d: A boolean expected.\n"), alaqil_Scilab_GetFuncName(), iVar);
    return alaqil_ERROR;
  }

  iRet = getScalarBoolean(pvApiCtx, piAddrVar, &iTempValue);
  if (iRet) {
    return alaqil_ERROR;
  }

  *pbValue = iTempValue;

  return alaqil_OK;
}
}

%fragment(alaqil_From_frag(bool), "header") {
alaqilINTERN int
alaqil_From_dec(bool)(bool bValue) {
  if (createScalarBoolean(pvApiCtx, alaqil_NbInputArgument(pvApiCtx)
    + alaqil_Scilab_GetOutputPosition(), bValue))
    return alaqil_ERROR;
  return alaqil_OK;
}
}

/*
 * C-type: bool[]
 * Scilab type: boolean matrix
 */
%fragment("alaqil_SciBoolean_AsBoolArrayAndSize", "header") {
alaqilINTERN int
alaqil_SciBoolean_AsBoolArrayAndSize(void *pvApiCtx, int iVar, int *iRows, int *iCols, bool **pbValue, char *fname) {
  SciErr sciErr;
  int *piAddrVar = NULL;
  int *piValue = NULL;

  sciErr = getVarAddressFromPosition(pvApiCtx, iVar, &piAddrVar);
  if (sciErr.iErr) {
    printError(&sciErr, 0);
    return alaqil_ERROR;
  }

  if (isBooleanType(pvApiCtx, piAddrVar)) {
    int i;
    sciErr = getMatrixOfBoolean(pvApiCtx, piAddrVar, iRows, iCols, &piValue);
    if (sciErr.iErr) {
      printError(&sciErr, 0);
      return alaqil_ERROR;
    }

    *pbValue = (bool*) malloc((*iRows) * (*iCols) * sizeof(bool));
    for (i = 0; i < (*iRows) * (*iCols); i++)
      (*pbValue)[i] = piValue[i] != 0;
  }
  else {
    Scierror(SCILAB_API_ARGUMENT_ERROR, _("%s: Wrong type for input argument #%d: A boolean matrix expected.\n"), fname, iVar);
    return alaqil_ERROR;
  }

  return alaqil_OK;
}
}

%fragment("alaqil_SciBoolean_FromBoolArrayAndSize", "header") {
alaqilINTERN int
alaqil_SciBoolean_FromBoolArrayAndSize(void *pvApiCtx, int iVarOut, int iRows, int iCols, bool *pbValue) {
  SciErr sciErr;
  int *piValue = NULL;
  int i;

  piValue = (int*) malloc(iRows * iCols * sizeof(int));
  for (i = 0; i < iRows * iCols; i++)
    piValue[i] = pbValue[i];

  sciErr = createMatrixOfBoolean(pvApiCtx, alaqil_NbInputArgument(pvApiCtx) + iVarOut, iRows, iCols, piValue);
  if(sciErr.iErr) {
    printError(&sciErr, 0);
    free(piValue);
    return alaqil_ERROR;
  }

  free(piValue);
  return alaqil_OK;
}
}

/*
 * C-type: int[]
 * Scilab type: boolean matrix
 */
%fragment("alaqil_SciBoolean_AsIntArrayAndSize", "header") {
alaqilINTERN int
alaqil_SciBoolean_AsIntArrayAndSize(void *pvApiCtx, int iVar, int *iRows, int *iCols, int **piValue, char *fname) {
  SciErr sciErr;
  int *piAddrVar = NULL;

  sciErr = getVarAddressFromPosition(pvApiCtx, iVar, &piAddrVar);
  if (sciErr.iErr) {
    printError(&sciErr, 0);
    return alaqil_ERROR;
  }

  if (isBooleanType(pvApiCtx, piAddrVar)) {
    sciErr = getMatrixOfBoolean(pvApiCtx, piAddrVar, iRows, iCols, piValue);
    if (sciErr.iErr) {
      printError(&sciErr, 0);
      return alaqil_ERROR;
    }
  }
  else {
    Scierror(SCILAB_API_ARGUMENT_ERROR, _("%s: Wrong type for input argument #%d: A boolean matrix expected.\n"), fname, iVar);
    return alaqil_ERROR;
  }

  return alaqil_OK;
}
}

%fragment("alaqil_SciBoolean_FromIntArrayAndSize", "header") {
alaqilINTERN int
alaqil_SciBoolean_FromIntArrayAndSize(void *pvApiCtx, int iVarOut, int iRows, int iCols, int *piValue) {
  SciErr sciErr;

  sciErr = createMatrixOfBoolean(pvApiCtx, alaqil_NbInputArgument(pvApiCtx) + iVarOut, iRows, iCols, piValue);
  if(sciErr.iErr) {
    printError(&sciErr, 0);
    return alaqil_ERROR;
  }

  return alaqil_OK;
}
}
