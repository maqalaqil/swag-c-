/*
 *
 * Scilab list of pointer <-> C++ pointer container
 *
 */

%include <scilist.swg>

%fragment("<stdint.h>", "header") {
%#include <stdint.h>
}

%fragment(alaqil_AsCheck_Sequence_frag(ptr), "header",
  fragment="alaqil_ScilabList") {

alaqilINTERN int
alaqil_AsCheck_Sequence_dec(ptr)(alaqilSciObject obj) {
  return alaqil_CheckScilabList(obj);
}
}

%fragment(alaqil_AsGet_Sequence_frag(ptr), "header",
  fragment="alaqil_ScilabList") {

alaqilINTERN int
alaqil_AsGet_Sequence_dec(ptr)(alaqilSciObject obj, int **piSequence) {
  return alaqil_GetScilabList(obj, piSequence);
}
}

%fragment(alaqil_AsSize_Sequence_frag(ptr), "header",
  fragment="alaqil_ScilabList") {

alaqilINTERN int
alaqil_AsSize_Sequence_dec(ptr)(alaqilSciObject obj, int *piSize) {
  return alaqil_GetScilabListSize(obj, piSize);
}
}

%fragment(alaqil_FromCreate_Sequence_frag(ptr), "header",
  fragment="<stdint.h>") {

alaqilINTERN int
alaqil_FromCreate_Sequence_dec(ptr)(int size, uintptr_t **pSequence) {
  *pSequence = new uintptr_t[size];
  return *pSequence != NULL ? alaqil_OK : alaqil_ERROR;
}
}

%fragment(alaqil_FromSet_Sequence_frag(ptr), "header",
  fragment="<stdint.h>") {

alaqilINTERN alaqilSciObject
alaqil_FromSet_Sequence_dec(ptr)(int size, uintptr_t *pSequence) {
  SciErr sciErr;
  int *piListAddr;

  int iVarOut = alaqil_NbInputArgument(pvApiCtx) + alaqil_Scilab_GetOutputPosition();

  sciErr = createList(pvApiCtx, iVarOut, size, &piListAddr);
  if (sciErr.iErr) {
    printError(&sciErr, 0);
    return alaqil_ERROR;
  }

  for (int i=0; i<size; i++) {
    sciErr = createPointerInList(pvApiCtx, iVarOut, piListAddr, i + 1, (void *)pSequence[i]);
    if (sciErr.iErr) {
      printError(&sciErr, 0);
      return alaqil_ERROR;
    }
  }
  delete (int*)pSequence;
  return alaqil_OK;
}
}

%fragment(alaqil_AsVal_SequenceItem_frag(ptr), "header") {

alaqilINTERN void*
alaqil_AsVal_SequenceItem_dec(ptr)(alaqilSciObject obj, int *piSequence, int itemIndex)
{
  SciErr sciErr;
  int *piItemAddr;
  int iType;
  void* pItemValue = NULL;

  sciErr = getListItemAddress(pvApiCtx, piSequence, itemIndex + 1, &piItemAddr);
  if (sciErr.iErr) {
    printError(&sciErr, 0);
    return NULL;
  }

  sciErr = getVarType(pvApiCtx, piItemAddr, &iType);
  if (sciErr.iErr) {
    printError(&sciErr, 0);
    return NULL;
  }

  if (iType != sci_pointer) {
    Scierror(SCILAB_API_ARGUMENT_ERROR, _("%s: Wrong type for input argument #%d: A pointer is expected at list item #%d.\n"), alaqil_Scilab_GetFuncName(), obj, itemIndex + 1);
    return NULL;
  }

  sciErr = getPointerInList(pvApiCtx, piSequence, itemIndex + 1, &pItemValue);
  if (sciErr.iErr) {
    printError(&sciErr, 0);
    return NULL;
  }

  return pItemValue;
}
}

%fragment(alaqil_From_SequenceItem_frag(ptr), "header",
  fragment="<stdint.h>") {

alaqilINTERN int
alaqil_From_SequenceItem_dec(ptr)(uintptr_t *pSequence, int iItemIndex, uintptr_t itemValue) {
  pSequence[iItemIndex] = itemValue;
  return alaqil_OK;
}
}
