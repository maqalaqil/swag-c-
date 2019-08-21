/* -----------------------------------------------------------------------------
 * error manipulation
 * ----------------------------------------------------------------------------- */

alaqilINTERN const char*
alaqil_Tcl_ErrorType(int code) {
  const char* type = 0;
  switch(code) {
  case alaqil_MemoryError:
    type = "MemoryError";
    break;
  case alaqil_IOError:
    type = "IOError";
    break;
  case alaqil_RuntimeError:
    type = "RuntimeError";
    break;
  case alaqil_IndexError:
    type = "IndexError";
    break;
  case alaqil_TypeError:
    type = "TypeError";
    break;
  case alaqil_DivisionByZero:
    type = "ZeroDivisionError";
    break;
  case alaqil_OverflowError:
    type = "OverflowError";
    break;
  case alaqil_SyntaxError:
    type = "SyntaxError";
    break;
  case alaqil_ValueError:
    type = "ValueError";
    break;
  case alaqil_SystemError:
    type = "SystemError";
    break;
  case alaqil_AttributeError:
    type = "AttributeError";
    break;
  default:
    type = "RuntimeError";
  }
  return type;
}


alaqilINTERN void
alaqil_Tcl_SetErrorObj(Tcl_Interp *interp, const char *ctype, Tcl_Obj *obj)
{
  Tcl_ResetResult(interp);
  Tcl_SetObjResult(interp, obj);
  Tcl_SetErrorCode(interp, "alaqil", ctype, NULL);
}

alaqilINTERN void
alaqil_Tcl_SetErrorMsg(Tcl_Interp *interp, const char *ctype, const char *mesg)
{
  Tcl_ResetResult(interp);
  Tcl_SetErrorCode(interp, "alaqil", ctype, NULL);
  Tcl_AppendResult(interp, ctype, " ", mesg, NULL);
  /*
  Tcl_AddErrorInfo(interp, ctype);
  Tcl_AddErrorInfo(interp, " ");
  Tcl_AddErrorInfo(interp, mesg);
  */
}

alaqilINTERNINLINE void
alaqil_Tcl_AddErrorMsg(Tcl_Interp *interp, const char* mesg)
{
  Tcl_AddErrorInfo(interp, mesg);
}


