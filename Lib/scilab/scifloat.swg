/*
 * FLOAT SCALAR
 */

%fragment(alaqil_AsVal_frag(float), "header", fragment=alaqil_AsVal_frag(double)) {
alaqilINTERN int
alaqil_AsVal_dec(float)(alaqilSciObject iVar, float *pfValue) {
  double dblValue = 0.0;
  if(alaqil_AsVal_dec(double)(iVar, &dblValue) != alaqil_OK) {
    return alaqil_ERROR;
  }
  if (pfValue)
    *pfValue = (float) dblValue;
  return alaqil_OK;
}
}

%fragment(alaqil_From_frag(float), "header") {
alaqilINTERN int
alaqil_From_dec(float)(float flValue) {
  if (createScalarDouble(pvApiCtx, alaqil_NbInputArgument(pvApiCtx)
    + alaqil_Scilab_GetOutputPosition(), (double)flValue))
    return alaqil_ERROR;
  return alaqil_OK;
}
}

%fragment("alaqil_SciDouble_AsFloatArrayAndSize", "header") {
alaqilINTERN int
alaqil_SciDouble_AsFloatArrayAndSize(void *pvApiCtx, int iVar, int *iRows, int *iCols, float **pfValue, char *fname) {
  SciErr sciErr;
  int *piAddrVar = NULL;
  double *pdValue = NULL;

  sciErr = getVarAddressFromPosition(pvApiCtx, iVar, &piAddrVar);
  if (sciErr.iErr) {
    printError(&sciErr, 0);
    return alaqil_ERROR;
  }

  if (isDoubleType(pvApiCtx, piAddrVar) && !isVarComplex(pvApiCtx, piAddrVar)) {
    int i;

    sciErr = getMatrixOfDouble(pvApiCtx, piAddrVar, iRows, iCols, &pdValue);
    if (sciErr.iErr) {
      printError(&sciErr, 0);
      return alaqil_ERROR;
    }

    *pfValue = (float *) malloc((*iRows) * (*iCols) * sizeof(float));
    for (i=0; i < (*iRows) * (*iCols); i++)
      (*pfValue)[i] = (float) pdValue[i];

    return alaqil_OK;
  }
  else {
    Scierror(SCILAB_API_ARGUMENT_ERROR, _("%s: Wrong type for input argument #%d: A real matrix expected.\n"), fname, iVar);
    return alaqil_ERROR;
  }
}
}

%fragment("alaqil_SciDouble_FromFloatArrayAndSize", "header") {
alaqilINTERN int
alaqil_SciDouble_FromFloatArrayAndSize(void *pvApiCtx, int iVarOut, int iRows, int iCols, float *pfValue) {
  SciErr sciErr;
  double *pdValue;
  int i;

  pdValue = (double *) malloc(iRows * iCols * sizeof(double));
  for (i = 0; i < iRows * iCols; i++)
    pdValue[i] = pfValue[i];

  sciErr = createMatrixOfDouble(pvApiCtx, alaqil_NbInputArgument(pvApiCtx) + iVarOut, iRows, iCols, pdValue);
  if (sciErr.iErr) {
    printError(&sciErr, 0);
    return alaqil_ERROR;
  }

  free(pdValue);
  return alaqil_OK;
}
}
