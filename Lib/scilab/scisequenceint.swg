/*
 *
 * Scilab matrix of int <-> C++ int container
 *
 */

%include <sciint.swg>

%fragment(alaqil_AsCheck_Sequence_frag(int), "header") {

alaqilINTERN int
alaqil_AsCheck_Sequence_dec(int)(alaqilSciObject obj) {
  SciErr sciErr;
  int *piAddrVar;
  int iType = 0;

  sciErr = getVarAddressFromPosition(pvApiCtx, obj, &piAddrVar);
  if (sciErr.iErr) {
    printError(&sciErr, 0);
    return alaqil_ERROR;
  }

  sciErr = getVarType(pvApiCtx, piAddrVar, &iType);
  if (sciErr.iErr) {
    printError(&sciErr, 0);
    return alaqil_ERROR;
  }

  if ((iType == sci_matrix) || (iType == sci_ints)) {
    return alaqil_OK;
  }
  else {
    Scierror(SCILAB_API_ARGUMENT_ERROR, _("%s: Wrong type for input argument #%d: An integer is expected.\n"), alaqil_Scilab_GetFuncName(), obj);
    return alaqil_ERROR;
  }
}
}

%fragment(alaqil_AsGet_Sequence_frag(int), "header",
  fragment="alaqil_SciDoubleOrInt32_AsIntArrayAndSize") {
alaqilINTERN int
alaqil_AsGet_Sequence_dec(int)(alaqilSciObject obj, int **pSequence) {
  int iMatrixRowCount;
  int iMatrixColCount;
  return (alaqil_SciDoubleOrInt32_AsIntArrayAndSize(pvApiCtx, obj, &iMatrixRowCount, &iMatrixColCount, pSequence, alaqil_Scilab_GetFuncName()));
}
}

%fragment(alaqil_AsSize_Sequence_frag(int), "header",
  fragment="alaqil_SciDoubleOrInt32_AsIntArrayAndSize") {

alaqilINTERN int
alaqil_AsSize_Sequence_dec(int)(alaqilSciObject obj, int *piSize) {
  int *piMatrix;
  int iMatrixRowCount;
  int iMatrixColCount;
  if (alaqil_SciDoubleOrInt32_AsIntArrayAndSize(pvApiCtx, obj, &iMatrixRowCount, &iMatrixColCount, &piMatrix, alaqil_Scilab_GetFuncName()) == alaqil_OK) {
    if ((iMatrixRowCount > 1) && (iMatrixColCount > 1)) {
      Scierror(SCILAB_API_ARGUMENT_ERROR, _("%s: Wrong size for input argument #%d: An integer vector is expected.\n"), alaqil_Scilab_GetFuncName(), obj);
      return alaqil_ERROR;
    }
    *piSize = iMatrixRowCount * iMatrixColCount;
    return alaqil_OK;
  }
  return alaqil_ERROR;
}
}

%fragment(alaqil_FromCreate_Sequence_frag(int), "header") {

alaqilINTERN int
alaqil_FromCreate_Sequence_dec(int)(int size, int **pSequence) {
  *pSequence = new int[size];
  return *pSequence != NULL ? alaqil_OK : alaqil_ERROR;
}
}

%fragment(alaqil_FromSet_Sequence_frag(int), "header",
  fragment="alaqil_SciDouble_FromIntArrayAndSize") {

alaqilINTERN alaqilSciObject
alaqil_FromSet_Sequence_dec(int)(int size, int *pSequence) {
  alaqilSciObject obj = alaqil_SciDouble_FromIntArrayAndSize(pvApiCtx, alaqil_Scilab_GetOutputPosition(), 1, size, pSequence);
  delete (int *)pSequence;
  return obj;
}
}

%fragment(alaqil_AsVal_SequenceItem_frag(int), "header") {

alaqilINTERN int
alaqil_AsVal_SequenceItem_dec(int)(alaqilSciObject obj, int *pSequence, int iItemIndex) {
  return pSequence[iItemIndex];
}
}

%fragment(alaqil_From_SequenceItem_frag(int), "header") {

alaqilINTERN int
alaqil_From_SequenceItem_dec(int)(int *pSequence, int iItemIndex, int itemValue) {
  pSequence[iItemIndex] = itemValue;
  return alaqil_OK;
}
}
