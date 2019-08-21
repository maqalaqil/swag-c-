/*
 *
 * Scilab matrix of bool <-> C++ bool container
 *
 */

%include <scibool.swg>

%fragment(alaqil_AsCheck_Sequence_frag(bool), "header") {

alaqilINTERN int
alaqil_AsCheck_Sequence_dec(bool)(alaqilSciObject obj) {
  SciErr sciErr;
  int *piAddrVar;

  sciErr = getVarAddressFromPosition(pvApiCtx, obj, &piAddrVar);
  if (sciErr.iErr) {
    printError(&sciErr, 0);
    return alaqil_ERROR;
  }

  if (isBooleanType(pvApiCtx, piAddrVar)) {
    return alaqil_OK;
  }
  else {
    Scierror(SCILAB_API_ARGUMENT_ERROR, _("%s: Wrong type for input argument #%d: A boolean is expected.\n"), alaqil_Scilab_GetFuncName(), obj);
    return alaqil_ERROR;
  }
}
}

%fragment(alaqil_AsGet_Sequence_frag(bool), "header",
  fragment="alaqil_SciBoolean_AsIntArrayAndSize") {

alaqilINTERN int
alaqil_AsGet_Sequence_dec(bool)(alaqilSciObject obj, int **pSequence) {
  int iMatrixRowCount;
  int iMatrixColCount;
  return (alaqil_SciBoolean_AsIntArrayAndSize(pvApiCtx, obj, &iMatrixRowCount, &iMatrixColCount, pSequence, alaqil_Scilab_GetFuncName()));
}
}

%fragment(alaqil_AsSize_Sequence_frag(bool), "header",
  fragment="alaqil_SciBoolean_AsIntArrayAndSize") {

alaqilINTERN int
alaqil_AsSize_Sequence_dec(bool)(alaqilSciObject obj, int *piSize) {
  int *piMatrix;
  int iMatrixRowCount;
  int iMatrixColCount;
  if (alaqil_SciBoolean_AsIntArrayAndSize(pvApiCtx, obj, &iMatrixRowCount, &iMatrixColCount, &piMatrix, alaqil_Scilab_GetFuncName()) == alaqil_OK) {
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

%fragment(alaqil_FromCreate_Sequence_frag(bool), "header") {

alaqilINTERN int
alaqil_FromCreate_Sequence_dec(bool)(int size, int **pSequence) {
  *pSequence = new int[size];
  return *pSequence != NULL ? alaqil_OK : alaqil_ERROR;
}
}

%fragment(alaqil_FromSet_Sequence_frag(bool), "header",
  fragment="alaqil_SciBoolean_FromIntArrayAndSize") {

alaqilINTERN alaqilSciObject
alaqil_FromSet_Sequence_dec(bool)(int size, int *pSequence) {
  alaqilSciObject obj = alaqil_SciBoolean_FromIntArrayAndSize(pvApiCtx, alaqil_Scilab_GetOutputPosition(), 1, size, pSequence);
  delete (int *)pSequence;
  return obj;
}
}

%fragment(alaqil_AsVal_SequenceItem_frag(bool), "header") {

alaqilINTERN bool
alaqil_AsVal_SequenceItem_dec(bool)(alaqilSciObject obj, int *pSequence, int iItemIndex) {
  return (bool) pSequence[iItemIndex];
}
}

%fragment(alaqil_From_SequenceItem_frag(bool), "header") {

alaqilINTERN int
alaqil_From_SequenceItem_dec(bool)(int *pSequence, int iItemIndex, bool itemValue) {
  pSequence[iItemIndex] = itemValue;
  return alaqil_OK;
}
}
