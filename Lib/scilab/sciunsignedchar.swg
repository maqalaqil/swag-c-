/*
 * C-type: unsigned char
 * Scilab type: double or uint8
 */
%fragment(alaqil_AsVal_frag(unsigned char), "header", fragment="alaqil_SciDoubleOrUint8_AsUnsignedChar", fragment="<limits.h>") {
#define alaqil_AsVal_unsigned_SS_char(scilabValue, valuePointer) alaqil_SciDoubleOrUint8_AsUnsignedChar(pvApiCtx, scilabValue, valuePointer, alaqil_Scilab_GetFuncName())
}
%fragment("alaqil_SciDoubleOrUint8_AsUnsignedChar", "header") {
alaqilINTERN int
alaqil_SciDoubleOrUint8_AsUnsignedChar(void *pvApiCtx, int iVar, unsigned char *pucValue, char *fname) {
  SciErr sciErr;
  int iType = 0;
  int iRows = 0;
  int iCols = 0;
  int iPrec = 0;
  int *piAddrVar = NULL;
  unsigned char *pucData = NULL;

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
    if (pucValue) {
      sciErr = getMatrixOfIntegerPrecision(pvApiCtx, piAddrVar, &iPrec);
      if (sciErr.iErr) {
        printError(&sciErr, 0);
        return alaqil_ERROR;
      }
      if (iPrec != SCI_UINT8) {
        Scierror(SCILAB_API_ARGUMENT_ERROR, _("%s: Wrong type for input argument #%d: A 8-bit unsigned integer or a double expected.\n"), fname, iVar);
        return alaqil_ERROR;
      }

      sciErr = getMatrixOfUnsignedInteger8(pvApiCtx, piAddrVar, &iRows, &iCols, &pucData);
      if (sciErr.iErr) {
        printError(&sciErr, 0);
        return alaqil_ERROR;
      }
      if (iRows * iCols != 1) {
        Scierror(SCILAB_API_ARGUMENT_ERROR, _("%s: Wrong size for input argument #%d: A 8-bit unsigned integer or a double expected.\n"), fname, iVar);
        return alaqil_ERROR;
      }
      *pucValue = *pucData;
    }
  }
  else if (iType == sci_matrix) {
    if (pucValue) {
      double *pdData = NULL;
      double dValue = 0.0f;
      sciErr = getMatrixOfDouble(pvApiCtx, piAddrVar, &iRows, &iCols, &pdData);
      if (sciErr.iErr) {
        printError(&sciErr, 0);
        return alaqil_ERROR;
      }
      if (iRows * iCols != 1) {
        Scierror(SCILAB_API_ARGUMENT_ERROR, _("%s: Wrong size for input argument #%d: A 8-bit unsigned integer or a double expected.\n"), fname, iVar);
        return alaqil_TypeError;
      }
      dValue = *pdData;
      if (dValue != floor(dValue)) {
        Scierror(SCILAB_API_ARGUMENT_ERROR, _("%s: Incorrect value for input argument #%d: The double value cannot be converted to a 8-bit unsigned integer.\n"), fname, iVar);
        return alaqil_ValueError;
      }
      if ((dValue < 0) || (dValue > UCHAR_MAX)) {
        Scierror(SCILAB_API_ARGUMENT_ERROR, _("%s: Overflow error for input argument #%d: The double value cannot be converted to a 8-bit unsigned integer.\n"), fname, iVar);
        return alaqil_OverflowError;
      }
      *pucValue = (unsigned char) dValue;
    }
  }
  else {
    Scierror(SCILAB_API_ARGUMENT_ERROR, _("%s: Wrong type for input argument #%d: A 8-bit unsigned integer or a double expected.\n"), fname, iVar);
    return alaqil_ERROR;
  }

  return alaqil_OK;
}
}

%fragment(alaqil_From_frag(unsigned char), "header", fragment="alaqil_SciDouble_FromUnsignedChar") {
#define alaqil_From_unsigned_SS_char(value) alaqil_SciDouble_FromUnsignedChar(pvApiCtx, alaqil_Scilab_GetOutputPosition(), value)
}
%fragment("alaqil_SciDouble_FromUnsignedChar", "header") {
alaqilINTERN int
alaqil_SciDouble_FromUnsignedChar(void *pvApiCtx, int iVarOut, unsigned char ucValue) {
  if (createScalarDouble(pvApiCtx,
    alaqil_NbInputArgument(pvApiCtx) + iVarOut, (double) ucValue))
    return alaqil_ERROR;
  return alaqil_OK;
}
}

/*
 * C-type: unsigned char[]
  * Scilab type: double or uint8 matrix
 */
%fragment("alaqil_SciDoubleOrUint8_AsUnsignedCharArrayAndSize", "header") {
alaqilINTERN int
alaqil_SciDoubleOrUint8_AsUnsignedCharArrayAndSize(void *pvApiCtx, int iVar, int *iRows, int *iCols, unsigned char **pucValue, char *fname) {
  SciErr sciErr;
  int iType = 0;
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
    *pucValue = (unsigned char*) malloc(size * sizeof(int*));
    for (i = 0; i < size; i++)
      (*pucValue)[i] = (unsigned char) pdData[i];
  }
  else if (iType == sci_ints) {
    sciErr = getMatrixOfIntegerPrecision(pvApiCtx, piAddrVar, &iPrec);
    if (sciErr.iErr) {
      printError(&sciErr, 0);
      return alaqil_ERROR;
    }

    if (iPrec != SCI_UINT8) {
      Scierror(SCILAB_API_ARGUMENT_ERROR, _("%s: Wrong type for input argument #%d: A 8-bit unsigned integer or a double vector expected.\n"), fname, iVar);
      return alaqil_ERROR;
    }

    sciErr = getMatrixOfUnsignedInteger8(pvApiCtx, piAddrVar, iRows, iCols, pucValue);
    if (sciErr.iErr) {
      printError(&sciErr, 0);
      return alaqil_ERROR;
    }
  }
  else {
    Scierror(SCILAB_API_ARGUMENT_ERROR, _("%s: Wrong type for input argument #%d: A 8-bit unsigned integer or a double vector expected.\n"), fname, iVar);
    return alaqil_ERROR;
  }

  return alaqil_OK;
}
}

%fragment("alaqil_SciDouble_FromUnsignedCharArrayAndSize", "header") {
alaqilINTERN int
alaqil_SciDouble_FromUnsignedCharArrayAndSize(void *pvApiCtx, int iVarOut, int iRows, int iCols, const unsigned char *pucValues) {
  SciErr sciErr;
  double *pdValues = NULL;
  int i;

  pdValues = (double*) malloc(iRows * iCols * sizeof(double));
  for (i=0; i<iRows * iCols; i++)
    pdValues[i] = pucValues[i];

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
