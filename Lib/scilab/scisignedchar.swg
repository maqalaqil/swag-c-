/*
 * C-type: signed char
 * Scilab type: double or int8
 */
%fragment(alaqil_AsVal_frag(signed char), "header", fragment="alaqil_SciDoubleOrInt8_AsSignedChar", fragment="<limits.h>") {
#define alaqil_AsVal_signed_SS_char(scilabValue, valuePointer) alaqil_SciDoubleOrInt8_AsSignedChar(pvApiCtx, scilabValue, valuePointer, alaqil_Scilab_GetFuncName())
}
%fragment("alaqil_SciDoubleOrInt8_AsSignedChar", "header") {
alaqilINTERN int
alaqil_SciDoubleOrInt8_AsSignedChar(void *pvApiCtx, int iVar, signed char *pscValue, char *fname) {
  SciErr sciErr;
  int iType = 0;
  int iRows = 0;
  int iCols = 0;
  int iPrec = 0;
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
    char *pcData = NULL;

    sciErr = getMatrixOfIntegerPrecision(pvApiCtx, piAddrVar, &iPrec);
    if (sciErr.iErr) {
      printError(&sciErr, 0);
      return alaqil_ERROR;
    }
    if (iPrec != SCI_INT8) {
      Scierror(SCILAB_API_ARGUMENT_ERROR, _("%s: Wrong type for input argument #%d: A 8-bit signed integer or a double expected.\n"), fname, iVar);
      return alaqil_TypeError;
    }
    sciErr = getMatrixOfInteger8(pvApiCtx, piAddrVar, &iRows, &iCols, &pcData);
    if (sciErr.iErr) {
      printError(&sciErr, 0);
      return alaqil_ERROR;
    }
    if (iRows * iCols != 1) {
      Scierror(SCILAB_API_ARGUMENT_ERROR, _("%s: Wrong size for input argument #%d: A 8-bit signed integer or a double expected.\n"), fname, iVar);
      return alaqil_TypeError;
    }
    *pscValue = *pcData;
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
      Scierror(SCILAB_API_ARGUMENT_ERROR, _("%s: Wrong size for input argument #%d: A 8-bit signed integer or a double expected.\n"), fname, iVar);
      return alaqil_TypeError;
    }
    dValue = *pdData;
    if (dValue != floor(dValue)) {
      Scierror(SCILAB_API_ARGUMENT_ERROR, _("%s: Incorrect value for input argument #%d: The double value cannot be converted to a 8-bit signed integer.\n"), fname, iVar);
      return alaqil_ValueError;
    }
    if ((dValue < SCHAR_MIN) || (dValue > SCHAR_MAX)) {
      Scierror(SCILAB_API_ARGUMENT_ERROR, _("%s: Overflow error for input argument #%d: The double value cannot be converted to a 8-bit signed integer.\n"), fname, iVar);
      return alaqil_OverflowError;
    }
    *pscValue = (signed char) dValue;
  }
  else {
     Scierror(SCILAB_API_ARGUMENT_ERROR, _("%s: Wrong type for input argument #%d: A 8-bit signed integer or a double expected.\n"), fname, iVar);
    return alaqil_TypeError;
  }

  return alaqil_OK;
}
}

%fragment(alaqil_From_frag(signed char), "header", fragment="alaqil_SciDouble_FromSignedChar") {
#define alaqil_From_signed_SS_char(scilabValue) alaqil_SciDouble_FromSignedChar(pvApiCtx, alaqil_Scilab_GetOutputPosition(), scilabValue)
}
%fragment("alaqil_SciDouble_FromSignedChar", "header") {
alaqilINTERN int
alaqil_SciDouble_FromSignedChar(void *pvApiCtx, int iVarOut, signed char scValue) {
  if (createScalarDouble(pvApiCtx,
    alaqil_NbInputArgument(pvApiCtx) + iVarOut, (double) scValue))
    return alaqil_ERROR;
  return alaqil_OK;
}
}

/*
 * C-type: signed char[]
 * Scilab type: double or int8 matrix
 */
%fragment("alaqil_SciDoubleOrInt8_AsSignedCharArrayAndSize", "header") {
alaqilINTERN int
alaqil_SciDoubleOrInt8_AsSignedCharArrayAndSize(void *pvApiCtx, int iVar, int *iRows, int *iCols, signed char **pscValue, char *fname) {
  SciErr sciErr;
  int iType = 0;
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

  if (iType == sci_matrix) {
    double *pdData = NULL;
    int size = 0;
    int i;

    sciErr = getMatrixOfDouble(pvApiCtx, piAddrVar, iRows, iCols, &pdData);
    if (sciErr.iErr) {
      printError(&sciErr, 0);
      return alaqil_ERROR;
    }

    size = (*iRows) * (*iCols);
    *pscValue = (signed char*) malloc(size * sizeof(int*));
    for (i = 0; i < size; i++)
      (*pscValue)[i] = (signed char) pdData[i];
  }
  else if (iType == sci_ints) {
    int iPrec = 0;
    sciErr = getMatrixOfIntegerPrecision(pvApiCtx, piAddrVar, &iPrec);
    if (sciErr.iErr) {
      printError(&sciErr, 0);
      return alaqil_ERROR;
    }
    if (iPrec != SCI_INT8) {
      Scierror(SCILAB_API_ARGUMENT_ERROR, _("%s: Wrong type for input argument #%d: A 8-bit signed integer or a double matrix expected.\n"), fname, iVar);
      return alaqil_ERROR;
    }

    sciErr = getMatrixOfInteger8(pvApiCtx, piAddrVar, iRows, iCols, (char **)pscValue);
    if (sciErr.iErr) {
      printError(&sciErr, 0);
      return alaqil_ERROR;
    }
  }
  else {
    Scierror(SCILAB_API_ARGUMENT_ERROR, _("%s: Wrong type for input argument #%d: A 8-bit signed integer or a double matrix expected.\n"), fname, iVar);
    return alaqil_ERROR;
  }
  return alaqil_OK;
}
}

%fragment("alaqil_SciDouble_FromSignedCharArrayAndSize", "header") {
alaqilINTERN int
alaqil_SciDouble_FromSignedCharArrayAndSize(void *pvApiCtx, int iVarOut, int iRows, int iCols, const signed char *pscValue) {
  SciErr sciErr;
  int i;
  double *pdValues = NULL;

  pdValues = (double*) malloc(iRows * iCols * sizeof(double));
  for (i=0; i<iRows * iCols; i++)
    pdValues[i] = pscValue[i];

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
