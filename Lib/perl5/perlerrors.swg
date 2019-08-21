/* -----------------------------------------------------------------------------
 * error manipulation
 * ----------------------------------------------------------------------------- */

alaqilINTERN const char*
alaqil_Perl_ErrorType(int code) {
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

