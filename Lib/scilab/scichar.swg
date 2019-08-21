/*
 * C-type: char or char*
 * Scilab type: string
 */

/*
 * CHAR
 */

%fragment(alaqil_AsVal_frag(char), "header", fragment="alaqil_SciString_AsChar") {
#define alaqil_AsVal_char(scilabValue, valuePointer) alaqil_SciString_AsChar(pvApiCtx, scilabValue, valuePointer, alaqil_Scilab_GetFuncName())
}
%fragment("alaqil_SciString_AsChar", "header") {
alaqilINTERN int
alaqil_SciString_AsChar(void *pvApiCtx, int iVar, char *pcValue, char *fname) {
  SciErr sciErr;
  int *piAddrVar = NULL;
  char *pstValue = NULL;
  int iRet;

  sciErr = getVarAddressFromPosition(pvApiCtx, iVar, &piAddrVar);
  if (sciErr.iErr) {
    printError(&sciErr, 0);
    return alaqil_ERROR;
  }

  if (isStringType(pvApiCtx, piAddrVar) == 0)
  {
      Scierror(SCILAB_API_ARGUMENT_ERROR, _("%s: Wrong type for input argument #%d: A single string expected.\n"), fname, iVar);
      return alaqil_TypeError;
  }

  iRet = getAllocatedSingleString(pvApiCtx, piAddrVar, &pstValue);
  if (iRet) {
    return alaqil_ERROR;
  }

  if (pcValue != NULL) {
    *pcValue = pstValue[0];
  }

  freeAllocatedSingleString(pstValue);
  return alaqil_OK;
}
}

%fragment(alaqil_From_frag(char), "header", fragment="alaqil_SciString_FromChar") {
#define alaqil_From_char(value) alaqil_SciString_FromChar(pvApiCtx, alaqil_Scilab_GetOutputPosition(), value)
}
%fragment("alaqil_SciString_FromChar", "header") {
alaqilINTERN int
alaqil_SciString_FromChar(void *pvApiCtx, int iVarOut, char chValue) {
  char *pchValue = (char*)malloc(sizeof(char) * 2);
  pchValue[0] = chValue;
  pchValue[1] = '\0';

  if (createSingleString(pvApiCtx, alaqil_NbInputArgument(pvApiCtx) + iVarOut, pchValue))
    return alaqil_ERROR;

  free(pchValue);
  return alaqil_OK;
}
}

/*
 * CHAR *
*/

%fragment("alaqil_AsCharArray", "header", fragment = "alaqil_SciString_AsCharPtr") {
#define alaqil_AsCharArray(scilabValue, charPtrPointer, charPtrLength) alaqil_SciString_AsCharPtr(pvApiCtx, scilabValue, charPtrPointer, charPtrLength, alaqil_Scilab_GetFuncName())
}
%fragment("alaqil_SciString_AsCharPtr", "header") {
alaqilINTERN int
alaqil_SciString_AsCharPtr(void *pvApiCtx, int iVar, char *pcValue, int iLength, char *fname) {
  SciErr sciErr;
  int *piAddrVar = NULL;
  char* pcTmpValue = NULL;
  int iRet;

  sciErr = getVarAddressFromPosition(pvApiCtx, iVar, &piAddrVar);
  if (sciErr.iErr) {
    printError(&sciErr, 0);
    return alaqil_ERROR;
  }

  iRet = getAllocatedSingleString(pvApiCtx, piAddrVar, &pcTmpValue);
  if (iRet) {
    return alaqil_ERROR;
  }

  if (pcValue != NULL) {
    strncpy(pcValue, pcTmpValue, iLength);
  }

  freeAllocatedSingleString(pcTmpValue);
  return alaqil_OK;
}
}

%fragment("alaqil_AsCharPtrAndSize", "header", fragment = "alaqil_SciString_AsCharPtrAndSize") {
#define alaqil_AsCharPtrAndSize(scilabValue, charPtrPointer, charPtrLength, allocMemory) alaqil_SciString_AsCharPtrAndSize(pvApiCtx, scilabValue, charPtrPointer, charPtrLength, allocMemory, alaqil_Scilab_GetFuncName())
}
%fragment("alaqil_SciString_AsCharPtrAndSize", "header") {
alaqilINTERN int
alaqil_SciString_AsCharPtrAndSize(void *pvApiCtx, int iVar, char **pcValue, size_t *piLength, int *alloc, char *fname) {
  SciErr sciErr;
  int *piAddrVar = NULL;
  char *pstString = NULL;
  int iRows = 0;
  int iCols = 0;
  int iLen = 0;

  sciErr = getVarAddressFromPosition(pvApiCtx, iVar, &piAddrVar);
  if (sciErr.iErr) {
    printError(&sciErr, 0);
    return alaqil_ERROR;
  }

  if (isScalar(pvApiCtx, piAddrVar) == 0 || isStringType(pvApiCtx, piAddrVar) == 0)
  {
      Scierror(SCILAB_API_ARGUMENT_ERROR, _("%s: Wrong type for input argument #%d: A single string expected.\n"), fname, iVar);
      return alaqil_TypeError;
  }

  sciErr = getMatrixOfString(pvApiCtx, piAddrVar, &iRows, &iCols, &iLen, NULL);
  if (sciErr.iErr)
  {
      printError(&sciErr, 0);
      return alaqil_ERROR;
  }

  pstString = %new_array(iLen + 1, char);

  sciErr = getMatrixOfString(pvApiCtx, piAddrVar, &iRows, &iCols, &iLen, &pstString);
  if (sciErr.iErr)
  {
      printError(&sciErr, 0);
      return alaqil_ERROR;
  }

  // TODO: return alaqil_ERROR if pcValue NULL (now returning alaqil_ERROR fails some typechecks)
  if (pcValue) {
    *pcValue = pstString;
  }

  if (alloc != NULL) {
    *alloc = alaqil_NEWOBJ;
  }

  if (piLength != NULL) {
    *piLength = strlen(pstString);
  }

  return alaqil_OK;
}
}

%fragment("alaqil_FromCharPtr", "header", fragment = "alaqil_SciString_FromCharPtr") {
#define alaqil_FromCharPtr(charPtr) alaqil_SciString_FromCharPtr(pvApiCtx, alaqil_Scilab_GetOutputPosition(), charPtr)
}
%fragment("alaqil_SciString_FromCharPtr", "header") {
alaqilINTERN int
alaqil_SciString_FromCharPtr(void *pvApiCtx, int iVarOut, const char *pchValue) {
  if (pchValue) {
    SciErr sciErr;
    const char* pstStrings[1];
    pstStrings[0] = pchValue;

    sciErr = createMatrixOfString(pvApiCtx, alaqil_NbInputArgument(pvApiCtx) + iVarOut, 1, 1, pstStrings);
    if (sciErr.iErr) {
      printError(&sciErr, 0);
      return alaqil_ERROR;
    }
  }
  else {
    int iRet = createEmptyMatrix(pvApiCtx, alaqil_NbInputArgument(pvApiCtx) + iVarOut);
    if (iRet) {
      return alaqil_ERROR;
    }
  }

  return alaqil_OK;
}
}

/*
 * CHAR * ARRAY
 */

%fragment("alaqil_SciString_AsCharPtrArrayAndSize", "header") {
alaqilINTERN int
alaqil_SciString_AsCharPtrArrayAndSize(void *pvApiCtx, int iVar, int *iRows, int *iCols, char ***charPtrArray, char *fname) {
  SciErr sciErr;
  int i = 0;
  int *piAddrVar = NULL;
  int* piLength = NULL;

  sciErr = getVarAddressFromPosition(pvApiCtx, iVar, &piAddrVar);
  if (sciErr.iErr) {
    printError(&sciErr, 0);
    return alaqil_ERROR;
  }

  sciErr = getMatrixOfString(pvApiCtx, piAddrVar, iRows, iCols, NULL, NULL);
  if (sciErr.iErr) {
    printError(&sciErr, 0);
    return alaqil_ERROR;
  }

  piLength = (int*) malloc((*iRows) * (*iCols) * sizeof(int));

  sciErr = getMatrixOfString(pvApiCtx, piAddrVar, iRows, iCols, piLength, NULL);
  if (sciErr.iErr) {
    printError(&sciErr, 0);
    return alaqil_ERROR;
  }

  *charPtrArray = (char**) malloc((*iRows) * (*iCols) * sizeof(char*));
  for(i = 0 ; i < (*iRows) * (*iCols); i++) {
    (*charPtrArray)[i] = (char*) malloc(sizeof(char) * (piLength[i] + 1));
  }

  sciErr = getMatrixOfString(pvApiCtx, piAddrVar, iRows, iCols, piLength, *charPtrArray);
  if (sciErr.iErr) {
    printError(&sciErr, 0);
    return alaqil_ERROR;
  }

  free(piLength);
  return alaqil_OK;
}
}

%fragment("alaqil_SciString_FromCharPtrArrayAndSize", "header") {
alaqilINTERN int
alaqil_SciString_FromCharPtrArrayAndSize(void *pvApiCtx, int iVarOut, int iRows, int iCols, char **charPtrArray) {
  SciErr sciErr;

  sciErr = createMatrixOfString(pvApiCtx, alaqil_NbInputArgument(pvApiCtx) + iVarOut, iRows, iCols, (const char* const*) charPtrArray);
  if (sciErr.iErr) {
    printError(&sciErr, 0);
    return alaqil_ERROR;
  }

  return alaqil_OK;
}
}

%fragment("alaqil_FromCharPtrAndSize", "header", fragment = "alaqil_SciString_FromCharPtr") {
#define alaqil_FromCharPtrAndSize(charPtr, charPtrLength) alaqil_SciString_FromCharPtr(pvApiCtx, alaqil_Scilab_GetOutputPosition(), charPtr)
}


/*
 * Char* Scilab variable
 */

%fragment(alaqil_CreateScilabVariable_frag(char), "wrapper") {
alaqilINTERN int
alaqil_CreateScilabVariable_dec(char)(void *pvApiCtx, const char* psVariableName, const char cVariableValue) {
  SciErr sciErr;
  char sValue[2];
  const char* psStrings[1];

  sValue[0] = cVariableValue;
  sValue[1] = '\0';
  psStrings[0] = sValue;

  sciErr = createNamedMatrixOfString(pvApiCtx, psVariableName, 1, 1, psStrings);
  if (sciErr.iErr) {
    printError(&sciErr, 0);
    return alaqil_ERROR;
  }
  return alaqil_OK;
}
}

%fragment(alaqil_CreateScilabVariable_frag(charptr), "wrapper") {
alaqilINTERN int
alaqil_CreateScilabVariable_dec(charptr)(void *pvApiCtx, const char* psVariableName, const char* psVariableValue) {
  SciErr sciErr;
  const char* psStrings[1];
  psStrings[0] = psVariableValue;

  sciErr = createNamedMatrixOfString(pvApiCtx, psVariableName, 1, 1, psStrings);
  if (sciErr.iErr) {
    printError(&sciErr, 0);
    return alaqil_ERROR;
  }
  return alaqil_OK;
}
}
