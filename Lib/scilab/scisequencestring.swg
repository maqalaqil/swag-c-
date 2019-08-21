/*
 *
 * Scilab matrix of string <-> C++ std::string container
 *
 */

%include <scichar.swg>

%fragment(alaqil_AsCheck_Sequence_frag(std::string), "header") {

alaqilINTERN int
alaqil_AsCheck_Sequence_dec(std::string)(alaqilSciObject obj) {
  SciErr sciErr;
  int *piAddrVar;

  sciErr = getVarAddressFromPosition(pvApiCtx, obj, &piAddrVar);
  if (sciErr.iErr) {
    printError(&sciErr, 0);
    return alaqil_ERROR;
  }

  if (isStringType(pvApiCtx, piAddrVar)) {
    return alaqil_OK;
  }
  else {
    Scierror(SCILAB_API_ARGUMENT_ERROR, _("%s: Wrong type for input argument #%d: A string is expected.\n"), alaqil_Scilab_GetFuncName(), obj);
    return alaqil_ERROR;
  }
}
}

%fragment(alaqil_AsGet_Sequence_frag(std::string), "header",
  fragment="alaqil_SciString_AsCharPtrArrayAndSize") {

alaqilINTERN int
alaqil_AsGet_Sequence_dec(std::string)(alaqilSciObject obj, char ***pSequence) {
  int iRows = 0;
  int iCols = 0;
  return (alaqil_SciString_AsCharPtrArrayAndSize(pvApiCtx, obj, &iRows, &iCols, pSequence, alaqil_Scilab_GetFuncName()));
}
}

%fragment(alaqil_AsSize_Sequence_frag(std::string), "header",
  fragment="alaqil_SciString_AsCharPtrArrayAndSize") {

alaqilINTERN int
alaqil_AsSize_Sequence_dec(std::string)(alaqilSciObject obj, int *piSize) {
  char **pstMatrix;
  int iCols = 0;
  int iRows = 0;
  if (alaqil_SciString_AsCharPtrArrayAndSize(pvApiCtx, obj, &iRows, &iCols, &pstMatrix, alaqil_Scilab_GetFuncName()) == alaqil_OK) {
    *piSize = iRows * iCols;
    return alaqil_OK;
  }
  return alaqil_ERROR;
}
}

%fragment(alaqil_FromCreate_Sequence_frag(std::string), "header") {

alaqilINTERN int
alaqil_FromCreate_Sequence_dec(std::string)(int size, char ***pSequence) {
  *pSequence = new char*[size];
  return *pSequence != NULL ? alaqil_OK : alaqil_ERROR;
}
}

%fragment(alaqil_FromSet_Sequence_frag(std::string), "header",
  fragment="alaqil_SciString_FromCharPtrArrayAndSize") {

alaqilINTERN alaqilSciObject
alaqil_FromSet_Sequence_dec(std::string)(int size, char **pSequence) {
  alaqilSciObject obj = alaqil_SciString_FromCharPtrArrayAndSize(pvApiCtx, alaqil_Scilab_GetOutputPosition(), 1, size, pSequence);
  delete (char **)pSequence;
  return obj;
}
}

%fragment(alaqil_AsVal_SequenceItem_frag(std::string), "header") {

alaqilINTERN std::string
alaqil_AsVal_SequenceItem_dec(std::string)(alaqilSciObject obj, char **pSequence, int iItemIndex) {
  return std::string(pSequence[iItemIndex]);
}
}

%fragment(alaqil_From_SequenceItem_frag(std::string), "header") {

alaqilINTERN int
alaqil_From_SequenceItem_dec(std::string)(char **pSequence, int iItemIndex, std::string itemValue) {
  char *pChar = new char((int) itemValue.size() + 1);
  strcpy(pChar, itemValue.c_str());
  pSequence[iItemIndex] = pChar;
  return alaqil_OK;
}
}

