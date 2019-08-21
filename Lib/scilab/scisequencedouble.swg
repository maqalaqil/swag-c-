/*
 *
 * Scilab matrix of double <-> C++ double container
 *
 */

%include <scidouble.swg>

%fragment(alaqil_AsCheck_Sequence_frag(double), "header") {

alaqilINTERN int
alaqil_AsCheck_Sequence_dec(double)(alaqilSciObject obj) {
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

%fragment(alaqil_AsGet_Sequence_frag(double), "header",
  fragment="alaqil_SciDouble_AsDoubleArrayAndSize") {

alaqilINTERN int
alaqil_AsGet_Sequence_dec(double)(alaqilSciObject obj, double **pSequence) {
  int iMatrixRowCount;
  int iMatrixColCount;
  return (alaqil_SciDouble_AsDoubleArrayAndSize(pvApiCtx, obj, &iMatrixRowCount, &iMatrixColCount, pSequence, alaqil_Scilab_GetFuncName()));
}
}

%fragment(alaqil_AsSize_Sequence_frag(double), "header",
  fragment="alaqil_SciDouble_AsDoubleArrayAndSize") {

alaqilINTERN int
alaqil_AsSize_Sequence_dec(double)(alaqilSciObject obj, int *piSize) {
  double *pdblMatrix;
  int iMatrixRowCount;
  int iMatrixColCount;
  if (alaqil_SciDouble_AsDoubleArrayAndSize(pvApiCtx, obj, &iMatrixRowCount, &iMatrixColCount, &pdblMatrix, alaqil_Scilab_GetFuncName()) == alaqil_OK) {
    if ((iMatrixRowCount > 1) && (iMatrixColCount > 1)) {
      Scierror(SCILAB_API_ARGUMENT_ERROR, _("%s: Wrong size for input argument #%d: A double vector is expected.\n"), alaqil_Scilab_GetFuncName(), obj);
      return alaqil_ERROR;
    }
    *piSize = iMatrixRowCount * iMatrixColCount;
    return alaqil_OK;
  }
  return alaqil_ERROR;
}
}

%fragment(alaqil_FromCreate_Sequence_frag(double), "header") {

alaqilINTERN int
alaqil_FromCreate_Sequence_dec(double)(int size, double **pSequence) {
  *pSequence = new double[size];
  return *pSequence != NULL ? alaqil_OK : alaqil_ERROR;
}
}

%fragment(alaqil_FromSet_Sequence_frag(double), "header",
  fragment="alaqil_SciDouble_FromDoubleArrayAndSize") {

alaqilINTERN alaqilSciObject
alaqil_FromSet_Sequence_dec(double)(int size, double *pSequence) {
  alaqilSciObject obj = alaqil_SciDouble_FromDoubleArrayAndSize(pvApiCtx, alaqil_Scilab_GetOutputPosition(), 1, size, pSequence);
  delete (double *)pSequence;
  return obj;
}
}

%fragment(alaqil_AsVal_SequenceItem_frag(double), "header") {

alaqilINTERN double
alaqil_AsVal_SequenceItem_dec(double)(alaqilSciObject obj, double *pSequence, int iItemIndex) {
  return pSequence[iItemIndex];
}
}

%fragment(alaqil_From_SequenceItem_frag(double), "header") {

alaqilINTERN int
alaqil_From_SequenceItem_dec(double)(double *pSequence, int iItemIndex, double itemValue) {
  pSequence[iItemIndex] = itemValue;
  return alaqil_OK;
}
}

