/*
 * Scilab list related functions
 *
 */

%fragment("alaqil_ScilabList", "header")
{
alaqilINTERN int
alaqil_GetScilabList(alaqilSciObject obj, int **piListAddr)
{
  SciErr sciErr;

  sciErr = getVarAddressFromPosition(pvApiCtx, obj, piListAddr);
  if (sciErr.iErr) {
    printError(&sciErr, 0);
    return alaqil_ERROR;
  }

  return alaqil_OK;
}

alaqilINTERN int
alaqil_GetScilabListSize(alaqilSciObject obj, int *piListSize)
{
  SciErr sciErr;
  int *piListAddr;

  sciErr = getVarAddressFromPosition(pvApiCtx, obj, &piListAddr);
  if (sciErr.iErr) {
    printError(&sciErr, 0);
    return alaqil_ERROR;
  }

  sciErr = getListItemNumber(pvApiCtx, piListAddr, piListSize);
  if (sciErr.iErr) {
    printError(&sciErr, 0);
    return alaqil_ERROR;
  }

  return alaqil_OK;
}

alaqilINTERN int
alaqil_GetScilabListAndSize(alaqilSciObject obj, int **piListAddr, int *piListSize)
{
  SciErr sciErr;

  sciErr = getVarAddressFromPosition(pvApiCtx, obj, piListAddr);
  if (sciErr.iErr) {
    printError(&sciErr, 0);
    return alaqil_ERROR;
  }

  sciErr = getListItemNumber(pvApiCtx, *piListAddr, piListSize);
  if (sciErr.iErr) {
    printError(&sciErr, 0);
    return alaqil_ERROR;
  }

  return alaqil_OK;
}

alaqilINTERN int
alaqil_CheckScilabList(alaqilSciObject obj)
{
  SciErr sciErr;
  int *piListAddr;
  int iType;

  sciErr = getVarAddressFromPosition(pvApiCtx, obj, &piListAddr);
  if (sciErr.iErr) {
    printError(&sciErr, 0);
    return alaqil_ERROR;
  }

  sciErr = getVarType(pvApiCtx, piListAddr, &iType);
  if (sciErr.iErr) {
    printError(&sciErr, 0);
    return alaqil_ERROR;
  }

  if ((iType != sci_list) && (iType != sci_tlist) && (iType != sci_mlist)) {
    Scierror(SCILAB_API_ARGUMENT_ERROR, _("%s: Wrong type for input argument #%d: A list is expected.\n"), alaqil_Scilab_GetFuncName(), obj);
    return alaqil_ERROR;
  }

  return alaqil_OK;
}

}

