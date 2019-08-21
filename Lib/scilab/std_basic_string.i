/*
 * C++: basic_string<char>
 * Scilab: string
 */

#define %alaqil_basic_string(Type...)  %alaqil_sequence_methods_val(Type)

%fragment(alaqil_AsPtr_frag(std::basic_string<char>), "header", fragment="alaqil_SciString_AsCharPtrAndLength") {
alaqilINTERN int
alaqil_AsPtr_dec(std::basic_string<char>)(int _iVar, std::basic_string<char> **_pstValue) {
  char* buf = 0;
  size_t len = 0;
  int alloc = alaqil_OLDOBJ;

  if (alaqil_IsOK((alaqil_SciString_AsCharPtrAndSize(pvApiCtx, _iVar, &buf, &len, &alloc, alaqil_Scilab_GetFuncName())))) {
    if (buf) {
      if (_pstValue) {
        *_pstValue = new std::string(buf, len - 1);
      }
      if (alloc == alaqil_NEWOBJ) {
        delete[] buf;
      }
      return alaqil_NEWOBJ;
    } else {
      if (_pstValue) {
        *_pstValue = NULL;
      }
      return alaqil_OLDOBJ;
    }
  } else {
    return alaqil_ERROR;
  }
}
}

%fragment(alaqil_From_frag(std::basic_string<char>), "header", fragment="alaqil_SciString_FromCharPtr") {
alaqilINTERN int
alaqil_From_dec(std::basic_string<char>)(std::basic_string<char> _pstValue) {
    return alaqil_SciString_FromCharPtr(pvApiCtx, alaqil_Scilab_GetOutputPosition(), _pstValue.c_str());
}
}

%include <std/std_basic_string.i>


