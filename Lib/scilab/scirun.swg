/* -----------------------------------------------------------------------------
 * Scilab support runtime
 * -----------------------------------------------------------------------------*/

/* Scilab version macro */

#include "version.h"
#define alaqil_SCILAB_VERSION (SCI_VERSION_MAJOR * 100) + (SCI_VERSION_MINOR * 10) + SCI_VERSION_MAINTENANCE

/* Scilab standard headers */

#ifdef __cplusplus
extern "C" {
#endif
#include "api_scilab.h"
#if alaqil_SCILAB_VERSION < 540
#define __USE_DEPRECATED_STACK_FUNCTIONS__
#include "stack-c.h"
#endif
#if alaqil_SCILAB_VERSION < 600
#include "MALLOC.h"
#endif
#include "Scierror.h"
#include "localization.h"
#include "freeArrayOfString.h"
#include <sci_gateway.h>
#include <mex.h>
#ifdef __cplusplus
}
#endif

/* Gateway signature */

#if alaqil_SCILAB_VERSION >= 600
#define alaqil_GatewayParameters char* fname, void *pvApiCtx
#define alaqil_GatewayArguments fname, pvApiCtx
#else
#define alaqil_GatewayParameters char* fname, unsigned long fname_len
#define alaqil_GatewayArguments fname, fname_len
#endif

/* Function name management functions */

#include <stdlib.h>
static char *alaqilFuncName = NULL;
static char *alaqil_Scilab_GetFuncName(void) {
  return alaqilFuncName;
}
static void alaqil_Scilab_SetFuncName(char *funcName) {
  if (alaqilFuncName != NULL) {
    free(alaqilFuncName);
    alaqilFuncName = NULL;
  }
  if (funcName) {
    alaqilFuncName = (char *)malloc(strlen(funcName) + 1);
    if (alaqilFuncName)
      strcpy(alaqilFuncName, funcName);
  }
}

/* Api context management functions */

#if alaqil_SCILAB_VERSION >= 600
static void *pvApiCtx = NULL;
static void alaqil_Scilab_SetApiContext(void *apiCtx) {
  pvApiCtx = apiCtx;
}
#else
#define alaqil_Scilab_SetApiContext(apiCtx)
#endif

/* Argument management functions */

#if alaqil_SCILAB_VERSION >= 540
#define alaqil_CheckInputArgument(pvApiCtx, minInputArgument, maxInputArgument) CheckInputArgument(pvApiCtx, minInputArgument, maxInputArgument)
#define alaqil_CheckInputArgumentAtLeast(pvApiCtx, minInputArgument) CheckInputArgumentAtLeast(pvApiCtx, minInputArgument)
#define alaqil_CheckOutputArgument(pvApiCtx, minOutputArgument, maxOutputArgument) CheckOutputArgument(pvApiCtx, minOutputArgument, maxOutputArgument)
#define alaqil_NbInputArgument(pvApiCtx) nbInputArgument(pvApiCtx)
#define alaqil_AssignOutputArgument(pvApiCtx, outputArgumentPos, argumentPos) AssignOutputVariable(pvApiCtx, outputArgumentPos) = argumentPos
#else
#define alaqil_CheckInputArgument(pvApiCtx, minInputArgument, maxInputArgument) CheckRhs(minInputArgument, maxInputArgument)
#define alaqil_CheckInputArgumentAtLeast(pvApiCtx, minInputArgument) CheckRhs(minInputArgument, 256)
#define alaqil_CheckOutputArgument(pvApiCtx, minOutputArgument, maxOutputArgument) CheckLhs(minOutputArgument, maxOutputArgument)
#define alaqil_NbInputArgument(pvApiCtx) Rhs
#define alaqil_AssignOutputArgument(pvApiCtx, outputArgumentPos, argumentPos) LhsVar(outputArgumentPos) = argumentPos
#endif

typedef int alaqilSciObject;

static int alaqilOutputPosition = -1;
static int alaqil_Scilab_GetOutputPosition(void) {
  return alaqilOutputPosition;
}
static void alaqil_Scilab_SetOutputPosition(int outputPosition) {
  alaqilOutputPosition = outputPosition;
}

alaqilRUNTIME int
alaqil_Scilab_SetOutput(void *pvApiCtx, alaqilSciObject output) {
  int outputPosition = alaqil_Scilab_GetOutputPosition();
  if (outputPosition < 0)
      return alaqil_ERROR;
  alaqil_AssignOutputArgument(pvApiCtx, outputPosition,
    alaqil_NbInputArgument(pvApiCtx) + outputPosition);
  return alaqil_OK;
}

/* Error functions */

#define SCILAB_API_ARGUMENT_ERROR 999

alaqilINTERN const char*
alaqil_Scilab_ErrorType(int code) {
  switch(code) {
  case alaqil_MemoryError:
    return "MemoryError";
  case alaqil_IOError:
    return "IOError";
  case alaqil_RuntimeError:
    return "RuntimeError";
  case alaqil_IndexError:
    return "IndexError";
  case alaqil_TypeError:
    return "TypeError";
  case alaqil_DivisionByZero:
    return "ZeroDivisionError";
  case alaqil_OverflowError:
    return "OverflowError";
  case alaqil_SyntaxError:
    return "SyntaxError";
  case alaqil_ValueError:
    return "ValueError";
  case alaqil_SystemError:
    return "SystemError";
  case alaqil_AttributeError:
    return "AttributeError";
  default:
    return "RuntimeError";
  }
}
#define alaqil_ErrorType(code) alaqil_Scilab_ErrorType(code)

#ifndef alaqil_SCILAB_ERROR
#define alaqil_SCILAB_ERROR 20000
#endif

alaqilINTERN void
alaqil_Scilab_Error(int code, const char *msg) {
  Scierror(alaqil_SCILAB_ERROR - code, _("alaqil/Scilab: %s: %s\n"), alaqil_Scilab_ErrorType(code), msg);
}

#define alaqil_Error(code, msg) alaqil_Scilab_Error(code, msg)

#define alaqil_fail return alaqil_ERROR;

alaqilRUNTIME void
alaqil_Scilab_Raise_Ex(const char *obj, const char *type, alaqil_type_info *descriptor) {
  if (type) {
    if (obj)
      Scierror(alaqil_SCILAB_ERROR, "alaqil/Scilab: Exception (%s) occurred: %s\n", type, obj);
    else
      Scierror(alaqil_SCILAB_ERROR, "alaqil/Scilab: Exception (%s) occurred.\n", type);
  }
}

alaqilRUNTIME void
alaqil_Scilab_Raise(const int obj, const char *type, alaqil_type_info *descriptor) {
  Scierror(alaqil_SCILAB_ERROR, "alaqil/Scilab: Exception (%s) occurred.\n", type);
}

/* Module initialization */

static int alaqil_module_initialized = 0;

alaqilRUNTIME int
alaqil_Module_Initialized() {
  return alaqil_module_initialized;
}

/* Pointer conversion functions */

alaqilRUNTIME alaqil_type_info *
alaqil_Scilab_TypeQuery(const char *name);

alaqilINTERN int
alaqilScilabCheckPtr(void *pvApiCtx, int iVar, alaqil_type_info *descriptor, char *fname) {
  SciErr sciErr;
  int *piAddrVar = NULL;
  int iType = 0;

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

  if (iType == sci_mlist) {
    int iItemCount = 0;
    void *pvTypeinfo = NULL;

    sciErr = getListItemNumber(pvApiCtx, piAddrVar, &iItemCount);
    if (sciErr.iErr) {
      printError(&sciErr, 0);
      return alaqil_ERROR;
    }
    if (iItemCount < 3) {
      return alaqil_ERROR;
    }

    sciErr = getPointerInList(pvApiCtx, piAddrVar, 2, &pvTypeinfo);
    if (sciErr.iErr) {
      printError(&sciErr, 0);
      return alaqil_ERROR;
    }

    if (descriptor) {
      alaqil_cast_info *cast = alaqil_TypeCheck(alaqil_TypeName((alaqil_type_info*)pvTypeinfo), descriptor);
      return (cast != NULL);
    }
    else {
      return alaqil_ERROR;
    }
  }
  else {
    return (iType == sci_pointer);
  }
}

alaqilINTERN int
alaqilScilabPtrToObject(void *pvApiCtx, int iVar, void **pvObj, alaqil_type_info *descriptor, int flags, char *fname) {
  SciErr sciErr;
  int *piAddrVar = NULL;
  int iType = 0;
  void *pvPtr = NULL;

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

  if (iType == sci_mlist) {
    int iItemCount = 0;
    void *pvTypeinfo = NULL;

    sciErr = getListItemNumber(pvApiCtx, piAddrVar, &iItemCount);
    if (sciErr.iErr) {
      printError(&sciErr, 0);
      return alaqil_ERROR;
    }
    if (iItemCount < 3) {
      return alaqil_ERROR;
    }

    sciErr = getPointerInList(pvApiCtx, piAddrVar, 2, &pvTypeinfo);
    if (sciErr.iErr) {
      printError(&sciErr, 0);
      return alaqil_ERROR;
    }

    sciErr = getPointerInList(pvApiCtx, piAddrVar, 3, &pvPtr);
    if (sciErr.iErr) {
      printError(&sciErr, 0);
      return alaqil_ERROR;
    }

    if (pvPtr) {
      if (descriptor) {
        alaqil_cast_info *cast = alaqil_TypeCheck(alaqil_TypeName((alaqil_type_info *)pvTypeinfo), descriptor);
        if (cast) {
          int newmemory = 0;
          pvPtr = alaqil_TypeCast(cast, pvPtr, &newmemory);
          // TODO newmemory
        }
        else {
          return alaqil_ERROR;
        }
      }
    }
  }
  else if (iType == sci_pointer) {
    sciErr = getPointer(pvApiCtx, piAddrVar, &pvPtr);
    if (sciErr.iErr) {
      printError(&sciErr, 0);
      return alaqil_ERROR;
    }
  }
  else {
    return alaqil_ERROR;
  }

  if (pvObj) {
    *pvObj = pvPtr;
    if (pvPtr)
      return alaqil_OK;
    else
      return (flags & alaqil_POINTER_NO_NULL) ? alaqil_NullReferenceError : alaqil_OK;
  }
  else {
    return alaqil_ERROR;
  }
}

alaqilRUNTIMEINLINE int
alaqilScilabPtrFromObject(void *pvApiCtx, int iVarOut, void *pvObj, alaqil_type_info *descriptor, int flags, const char *pstTypeName) {
  SciErr sciErr;

  if (descriptor) {
    int *piMListAddr = NULL;

    sciErr = createMList(pvApiCtx, alaqil_NbInputArgument(pvApiCtx) + iVarOut, 3, &piMListAddr);
    if (sciErr.iErr) {
      printError(&sciErr, 0);
      return alaqil_ERROR;
    }

    if (pstTypeName == NULL) {
      pstTypeName = alaqil_TypeName(descriptor);
    }

    sciErr = createMatrixOfStringInList(pvApiCtx, alaqil_NbInputArgument(pvApiCtx) + iVarOut, piMListAddr, 1, 1, 1, &pstTypeName);
    if (sciErr.iErr) {
      printError(&sciErr, 0);
      return alaqil_ERROR;
    }

    sciErr = createPointerInList(pvApiCtx, alaqil_NbInputArgument(pvApiCtx) + iVarOut, piMListAddr, 2, descriptor);
    if (sciErr.iErr) {
      printError(&sciErr, 0);
      return alaqil_ERROR;
    }

    sciErr = createPointerInList(pvApiCtx, alaqil_NbInputArgument(pvApiCtx) + iVarOut, piMListAddr, 3, pvObj);
    if (sciErr.iErr) {
      printError(&sciErr, 0);
      return alaqil_ERROR;
    }
  }
  else {
    sciErr = createPointer(pvApiCtx, alaqil_NbInputArgument(pvApiCtx) + iVarOut, pvObj);
    if (sciErr.iErr) {
      printError(&sciErr, 0);
      return alaqil_ERROR;
    }
  }

  return alaqil_OK;
}

/* Pointer argument conversions */


alaqilRUNTIME int
alaqil_Scilab_ConvertPacked(void *pvApiCtx, int iVar, void *ptr, int sz, alaqil_type_info *ty, char *fname) {
  alaqil_cast_info *tc;
  int *piAddrVar = NULL;
  char *pstString = NULL;
  char *pstStringPtr = NULL;
  SciErr sciErr;

  sciErr = getVarAddressFromPosition(pvApiCtx, iVar, &piAddrVar);
  if (sciErr.iErr) {
    printError(&sciErr, 0);
    return alaqil_ERROR;
  }

  if (getAllocatedSingleString(pvApiCtx, piAddrVar, &pstString)) {
    return alaqil_ERROR;
  }

  /* Pointer values must start with leading underscore */
  if (*pstString != '_') {
    freeAllocatedSingleString(pstString);
    return alaqil_ERROR;
  }

  pstStringPtr = pstString;
  pstStringPtr++;
  pstStringPtr = (char*)alaqil_UnpackData(pstStringPtr, ptr, sz);

  if (ty) {
    if (!pstStringPtr) {
      freeAllocatedSingleString(pstString);
      return alaqil_ERROR;
    }
    tc = alaqil_TypeCheck(pstStringPtr, ty);
    if (!tc) {
      freeAllocatedSingleString(pstString);
      return alaqil_ERROR;
    }
  }

  freeAllocatedSingleString(pstString);
  return alaqil_OK;
}

alaqilRUNTIME int
alaqil_Scilab_NewMemberObj(void *pvApiCtx, int iVarOut, void *ptr, int sz, alaqil_type_info *type) {
  char result[1024];
  char *r = result;

  if ((2*sz + 1 + strlen(type->name)) > 1000) {
    return alaqil_ERROR;
  }
  *(r++) = '_';
  r = alaqil_PackData(r, ptr, sz);
  strcpy(r, type->name);

  if (createSingleString(pvApiCtx, alaqil_NbInputArgument(pvApiCtx) + iVarOut, &result[0]))
    return alaqil_ERROR;

  return alaqil_OK;
}




/*
 *  Pointer utility functions
 */

#include <stdint.h>

#ifdef __cplusplus
extern "C"
#endif
int alaqil_this(alaqil_GatewayParameters) {
  void *ptrValue = NULL;
  if (alaqilScilabPtrToObject(pvApiCtx, 1, &ptrValue, NULL, 0, fname) == alaqil_OK) {
    alaqil_Scilab_SetOutputPosition(1);
    return alaqil_Scilab_SetOutput(pvApiCtx,
      createScalarDouble(pvApiCtx, alaqil_NbInputArgument(pvApiCtx) + 1,
        (double)(uintptr_t)ptrValue));
  }
  else {
    Scierror(SCILAB_API_ARGUMENT_ERROR, _("%s: Incorrect value for input argument #%d: The value is not a pointer.\n"), fname, 1);
    return alaqil_ERROR;
  }
}

#ifdef __cplusplus
extern "C"
#endif
int alaqil_ptr(alaqil_GatewayParameters) {
  if (alaqil_NbInputArgument(pvApiCtx) > 0) {
    SciErr sciErr;
    int *piAddrVar1 = NULL;
    int iTypeVar1 = 0;
    char *pstInputPtrTypeName = NULL;
    char *pstOutputMListTypeName = NULL;
    if (alaqil_NbInputArgument(pvApiCtx) > 2) {
      int *piAddrVar2 = NULL;
      int *piAddrVar3 = NULL;
      sciErr = getVarAddressFromPosition(pvApiCtx, 2, &piAddrVar2);
      if (sciErr.iErr) {
        printError(&sciErr, 0);
        return alaqil_ERROR;
      }
      if (getAllocatedSingleString(pvApiCtx, piAddrVar2, &pstInputPtrTypeName)) {
        return alaqil_ERROR;
      }
      sciErr = getVarAddressFromPosition(pvApiCtx, 3, &piAddrVar3);
      if (sciErr.iErr) {
        printError(&sciErr, 0);
        return alaqil_ERROR;
      }
      if (getAllocatedSingleString(pvApiCtx, piAddrVar3, &pstOutputMListTypeName)) {
        return alaqil_ERROR;
      }
    }

    sciErr = getVarAddressFromPosition(pvApiCtx, 1, &piAddrVar1);
    if (sciErr.iErr) {
      printError(&sciErr, 0);
      return alaqil_ERROR;
    }
    sciErr = getVarType(pvApiCtx, piAddrVar1, &iTypeVar1);
    if (sciErr.iErr) {
      printError(&sciErr, 0);
      return alaqil_ERROR;
    }

    if ((iTypeVar1 == sci_pointer) || (iTypeVar1 == sci_mlist)) {
      void *ptrValue = NULL;
      if (alaqilScilabPtrToObject(pvApiCtx, 1, &ptrValue, alaqil_Scilab_TypeQuery(pstInputPtrTypeName), 0, (char *) "alaqil_ptr") == alaqil_OK) {
        alaqil_Scilab_SetOutputPosition(1);
        return alaqil_Scilab_SetOutput(pvApiCtx,
          alaqilScilabPtrFromObject(pvApiCtx, 1, ptrValue, alaqil_Scilab_TypeQuery(pstInputPtrTypeName), 0, pstOutputMListTypeName));
      }
      else {
        return alaqil_ERROR;
      }
    }
    else if (iTypeVar1 == sci_matrix) {
      double dValue = 0;
      if (getScalarDouble(pvApiCtx, piAddrVar1, &dValue) == 0) {
        if (dValue != (uintptr_t)dValue) {
          Scierror(SCILAB_API_ARGUMENT_ERROR, _("%s: Incorrect value for input argument #%d: The double value cannot be converted to a pointer.\n"), fname, 1);
          return alaqil_ValueError;
        }
        if ((dValue < 0) || (dValue > ULONG_MAX)) {
          Scierror(SCILAB_API_ARGUMENT_ERROR, _("%s: Overflow error for input argument #%d: The double value cannot be converted to a pointer.\n"), fname, 1);
          return alaqil_OverflowError;
        }
        alaqil_Scilab_SetOutputPosition(1);
        return alaqil_Scilab_SetOutput(pvApiCtx,
          alaqilScilabPtrFromObject(pvApiCtx, 1, (void *) (uintptr_t)dValue, alaqil_Scilab_TypeQuery(pstInputPtrTypeName), 0, pstOutputMListTypeName));
      }
      else {
        return alaqil_TypeError;
      }
    }
    else {
      Scierror(SCILAB_API_ARGUMENT_ERROR, _("%s: Wrong type for input argument #%d: A mlist, pointer or a double expected.\n"), (char *) "alaqil_ptr", 1);
      return alaqil_TypeError;
    }
  }
  else {
    Scierror(SCILAB_API_ARGUMENT_ERROR, _("%s: A mlist, pointer, or a double expected.\n"), "alaqil_ptr", 1);
    return alaqil_TypeError;
  }
}
