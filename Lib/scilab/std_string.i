/*
 * POINTER
 */
%fragment(alaqil_AsPtr_frag(std::string), "header", fragment="alaqil_SciString_AsCharPtrAndSize") {
alaqilINTERN int
alaqil_AsPtr_dec(std::string)(int iVar, std::string **pstValue) {
  char* buf = 0;
  size_t size = 0;
  int alloc = alaqil_OLDOBJ;

  if (alaqil_IsOK((alaqil_SciString_AsCharPtrAndSize(pvApiCtx, iVar, &buf, &size, &alloc, alaqil_Scilab_GetFuncName())))) {
    if (buf) {
      if (pstValue) {
        *pstValue = new std::string(buf, size);
      }
      if (alloc == alaqil_NEWOBJ) {
        delete[] buf;
      }
      return alaqil_NEWOBJ;
    } else {
      if (pstValue) {
        *pstValue = NULL;
      }
      return alaqil_OLDOBJ;
    }
  } else {
    return alaqil_ERROR;
  }
}
}

%fragment(alaqil_From_frag(std::string), "header", fragment="alaqil_SciString_FromCharPtr") {
alaqilINTERN int
alaqil_From_dec(std::string)(std::string pstValue) {
    return alaqil_SciString_FromCharPtr(pvApiCtx, alaqil_Scilab_GetOutputPosition(), pstValue.c_str());
}
}

%include <typemaps/std_string.swg>
