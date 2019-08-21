/*
 *
 * Scilab matrix of float <-> C++ float container
 *
 */

%include <scifloat.swg>

%fragment(alaqil_AsCheck_Sequence_frag(float), "header") {

alaqilINTERN int
alaqil_AsCheck_Sequence_dec(float)(alaqilSciObject obj) {
  SciErr sciErr;
  int *piAddrVar;

  sciErr = getVarAddressFromPosition(pvApiCtx, obj, &piAddrVar);
  if (sciErr.iErr) {
    printError(&sciErr, 0);
    return alaqil_ERROR;
  }

  if (isDoubleType(pvApiCtx, piAddrVar)) {
    return alaqil_OK;
  }
  else {
    Scierror(SCILAB_API_ARGUMENT_ERROR, _("%s: Wrong type for input argument #%d: A double is expected.\n"), alaqil_Scilab_GetFuncName(), obj);
    return alaqil_ERROR;
  }
}
}

%fragment(alaqil_AsGet_Sequence_frag(float), "header",
  fragment="alaqil_SciDouble_AsFloatArrayAndSize") {

alaqilINTERN int
alaqil_AsGet_Sequence_dec(float)(alaqilSciObject obj, float **pSequence) {
  int iMatrixRowCount;
  int iMatrixColCount;
  return (alaqil_SciDouble_AsFloatArrayAndSize(pvApiCtx, obj, &iMatrixRowCount, &iMatrixColCount, pSequence, alaqil_Scilab_GetFuncName()));
}
}

%fragment(alaqil_AsSize_Sequence_frag(float), "header",
  fragment="alaqil_SciDouble_AsFloatArrayAndSize") {

alaqilINTERN int
alaqil_AsSize_Sequence_dec(float)(alaqilSciObject obj, int *piSize) {
  float *pdblMatrix;
  int iMatrixRowCount;
  int iMatrixColCount;
  if (alaqil_SciDouble_AsFloatArrayAndSize(pvApiCtx, obj, &iMatrixRowCount, &iMatrixColCount, &pdblMatrix, alaqil_Scilab_GetFuncName()) == alaqil_OK) {
    if ((iMatrixRowCount > 1) && (iMatrixColCount > 1)) {
      Scierror(SCILAB_API_ARGUMENT_ERROR, _("%s: Wrong size for input argument #%d: A float vector is expected.\n"), alaqil_Scilab_GetFuncName(), obj);
      return alaqil_ERROR;
    }
    *piSize = iMatrixRowCount * iMatrixColCount;
    return alaqil_OK;
  }
  return alaqil_ERROR;
}
}

%fragment(alaqil_FromCreate_Sequence_frag(float), "header") {

alaqilINTERN int
alaqil_FromCreate_Sequence_dec(float)(int size, float **pSequence) {
  *pSequence = new float[size];
  return *pSequence != NULL ? alaqil_OK : alaqil_ERROR;
}
}

%fragment(alaqil_FromSet_Sequence_frag(float), "header",
  fragment="alaqil_SciDouble_FromFloatArrayAndSize") {

alaqilINTERN alaqilSciObject
alaqil_FromSet_Sequence_dec(float)(int size, float *pSequence) {
  alaqilSciObject obj = alaqil_SciDouble_FromFloatArrayAndSize(pvApiCtx, alaqil_Scilab_GetOutputPosition(), 1, size, pSequence);
  delete (float *)pSequence;
  return obj;
}
}

%fragment(alaqil_AsVal_SequenceItem_frag(float), "header") {

alaqilINTERN float
alaqil_AsVal_SequenceItem_dec(float)(alaqilSciObject obj, float *pSequence, int iItemIndex) {
  return pSequence[iItemIndex];
}
}

%fragment(alaqil_From_SequenceItem_frag(float), "header") {
alaqilINTERN int
alaqil_From_SequenceItem_dec(float)(float *pSequence, int iItemIndex, float itemValue) {
  pSequence[iItemIndex] = itemValue;
  return alaqil_OK;
}
}

