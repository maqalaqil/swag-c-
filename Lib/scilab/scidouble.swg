/*
 * DOUBLE SCALAR
 */
%fragment(alaqil_AsVal_frag(double), "header", fragment="alaqil_SciDouble_AsDouble") {
%#define alaqil_AsVal_double(scilabValue, valuePointer) alaqil_SciDouble_AsDouble(pvApiCtx, scilabValue, valuePointer, alaqil_Scilab_GetFuncName())
}
%fragment("alaqil_SciDouble_AsDouble", "header") {
alaqilINTERN int
alaqil_SciDouble_AsDouble(void *pvApiCtx, alaqilSciObject iVar, double *pdblValue, char *fname) {
  SciErr sciErr;
  int iRet = 0;
  int *piAddrVar = NULL;

  sciErr = getVarAddressFromPosition(pvApiCtx, iVar, &piAddrVar);
  if (sciErr.iErr) {
    printError(&sciErr, 0);
    return alaqil_ERROR;
  }

  if (!isDoubleType(pvApiCtx, piAddrVar) || isVarComplex(pvApiCtx, piAddrVar)) {
    Scierror(SCILAB_API_ARGUMENT_ERROR, _("%s: Wrong type for input argument #%d: A real expected.\n"), fname, iVar);
    return alaqil_ERROR;
  }

  if (!isScalar(pvApiCtx, piAddrVar)) {
    Scierror(SCILAB_API_ARGUMENT_ERROR, _("%s: Wrong size for input argument #%d: A real expected.\n"), fname, iVar);
    return alaqil_ERROR;
  }

  iRet = getScalarDouble(pvApiCtx, piAddrVar, pdblValue);
  if (iRet) {
    return alaqil_ERROR;
  }

  return alaqil_OK;
}
}

%fragment(alaqil_From_frag(double), "header", fragment="alaqil_SciDouble_FromDouble") { 
%#define alaqil_From_double(scilabValue) alaqil_SciDouble_FromDouble(pvApiCtx, alaqil_Scilab_GetOutputPosition(), scilabValue, alaqil_Scilab_GetFuncName())
}
%fragment("alaqil_SciDouble_FromDouble", "header") {
alaqilINTERN int
alaqil_SciDouble_FromDouble(void *pvApiCtx, int iVarOut, double dblValue, char *fname) {
  if (createScalarDouble(pvApiCtx, alaqil_NbInputArgument(pvApiCtx) + iVarOut, dblValue))
    return alaqil_ERROR;
  return alaqil_OK;
}
}

/*
 * DOUBLE ARRAY
 */

%fragment("alaqil_SciDouble_AsDoubleArrayAndSize", "header") {
alaqilINTERN int
alaqil_SciDouble_AsDoubleArrayAndSize(void *pvApiCtx, int iVar, int *iRows, int *iCols, double **pdValue, char *fname) {
  SciErr sciErr;
  int *piAddrVar = NULL;

  sciErr = getVarAddressFromPosition(pvApiCtx, iVar, &piAddrVar);
  if (sciErr.iErr) {
    printError(&sciErr, 0);
    return alaqil_ERROR;
  }

  if (isDoubleType(pvApiCtx, piAddrVar) && !isVarComplex(pvApiCtx, piAddrVar)) {
    sciErr = getMatrixOfDouble(pvApiCtx, piAddrVar, iRows, iCols, pdValue);
    if (sciErr.iErr) {
      printError(&sciErr, 0);
      return alaqil_ERROR;
    }
  }
  else {
    Scierror(SCILAB_API_ARGUMENT_ERROR, _("%s: Wrong type for input argument #%d: A real matrix expected.\n"), fname, iVar);
    return alaqil_ERROR;
  }

  return alaqil_OK;
}
}

%fragment("alaqil_SciDouble_FromDoubleArrayAndSize", "header") {
alaqilINTERN int
alaqil_SciDouble_FromDoubleArrayAndSize(void *pvApiCtx, int iVarOut, int iRows, int iCols, double *pdblValue) {
  SciErr sciErr;
  sciErr = createMatrixOfDouble(pvApiCtx, alaqil_NbInputArgument(pvApiCtx) + iVarOut, iRows, iCols, pdblValue);
  if (sciErr.iErr) {
    printError(&sciErr, 0);
    return alaqil_ERROR;
  }

  return alaqil_OK;
}
}

%fragment(alaqil_CreateScilabVariable_frag(double), "wrapper") {
alaqilINTERN int
alaqil_CreateScilabVariable_dec(double)(void *pvApiCtx, const char* psVariableName, const double dVariableValue) {
  SciErr sciErr;
  sciErr = createNamedMatrixOfDouble(pvApiCtx, psVariableName, 1, 1, &dVariableValue);
  if (sciErr.iErr) {
    printError(&sciErr, 0);
    return alaqil_ERROR;
  }
  return alaqil_OK;
}
}
