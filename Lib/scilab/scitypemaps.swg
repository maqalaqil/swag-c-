// Scilab fragments for primitive types
%include <sciprimtypes.swg>

%include <scienum.swg>

// Scilab object type
#define alaqil_Object int

#define %append_output(obj)         if (!alaqil_IsOK(alaqil_Scilab_SetOutput(pvApiCtx, obj))) return alaqil_ERROR
#define %set_constant(name, obj)    if (!alaqil_IsOK(alaqil_Scilab_SetOutput(pvApiCtx, obj))) return alaqil_ERROR // Name is managed by the function name
#define %raise(obj, type, desc)     alaqil_Scilab_Raise(obj, type, desc)
#define %set_output(obj)            if (!alaqil_IsOK(alaqil_Scilab_SetOutput(pvApiCtx, obj))) return alaqil_ERROR
#define %set_varoutput(obj)         if (!alaqil_IsOK(alaqil_Scilab_SetOutput(pvApiCtx, obj))) return alaqil_ERROR
#define %set_argoutput(obj)         if (!alaqil_IsOK(alaqil_Scilab_SetOutput(pvApiCtx, obj))) return alaqil_ERROR

// Include the unified typemap library
%include <typemaps/alaqiltypemaps.swg>

/* ---------------------------------------------------------------------------*/
/* Generic typmemaps                                                          */
/*                                                                            */
/* This typemap is used when Scilab does not store this type directly         */
/* For example, a 'float' is stored in Scilab as a 'double'                   */
/* So we read a 'double' in Scilab and cast it to a 'float'                   */
/* ---------------------------------------------------------------------------*/

%define %scilab_in_typemap_withcast(TYPEMAPTYPE, FRAGMENTNAME, CTYPE, TEMPTYPE, TEMPINIT)
%typemap(TYPEMAPTYPE, fragment="FRAGMENTNAME") CTYPE {
  TEMPTYPE tempValue = TEMPINIT;
  if(FRAGMENTNAME(pvApiCtx, $input, &tempValue, alaqil_Scilab_GetFuncName()) != alaqil_OK) {
    return alaqil_ERROR;
  }
  $1 = (CTYPE) tempValue;
}
%enddef
%define %scilab_inptr_typemap(TYPEMAPTYPE, FRAGMENTNAME, CTYPE)
%typemap(TYPEMAPTYPE, noblock=1, fragment="FRAGMENTNAME") CTYPE {
  if (FRAGMENTNAME(pvApiCtx, $input, %as_voidptrptr(&$1), alaqil_Scilab_GetFuncName()) != alaqil_OK) {
    return alaqil_ERROR;
  }
}
%enddef

%define %scilab_out_typemap(TYPEMAPTYPE, FRAGMENTNAME, CTYPE)
%typemap(TYPEMAPTYPE, noblock=1, fragment="FRAGMENTNAME") CTYPE {
  if (FRAGMENTNAME(pvApiCtx, $result, $1) != alaqil_OK) {
    return alaqil_ERROR;
  }
}
%enddef

%define %scilab_outptr_typemap(TYPEMAPTYPE, FRAGMENTNAME, CTYPE)
%typemap(TYPEMAPTYPE, noblock=1, fragment="FRAGMENTNAME") CTYPE {
  if (FRAGMENTNAME(pvApiCtx, $result, %as_voidptr($1)) != alaqil_OK) {
    return alaqil_ERROR;
  }
}
%enddef

%define %scilab_varout_typemap(TYPEMAPTYPE, FRAGMENTNAME, CTYPE)
%typemap(TYPEMAPTYPE, noblock=1, fragment="FRAGMENTNAME") CTYPE {
  if (FRAGMENTNAME(pvApiCtx, $result, $value) != alaqil_OK) {
    return alaqil_ERROR;
  }
}
%enddef

%define %scilab_varoutptr_typemap(TYPEMAPTYPE, FRAGMENTNAME, CTYPE)
%typemap(TYPEMAPTYPE, noblock=1, fragment="FRAGMENTNAME") CTYPE {
  if (FRAGMENTNAME(pvApiCtx, $result, %as_voidptr($value)) != alaqil_OK) {
    return alaqil_ERROR;
  }
}
%enddef

%define %scilab_in_typemap(TYPEMAPTYPE, FRAGMENTNAME, CTYPE)
%typemap(TYPEMAPTYPE, noblock=1, fragment="FRAGMENTNAME") CTYPE {
  if (FRAGMENTNAME(pvApiCtx, $input, &$1, alaqil_Scilab_GetFuncName()) != alaqil_OK) {
    return alaqil_ERROR;
  }
}
%enddef


/* ---------------------------------------------------------------------------*/
/* Array typmemaps                                                            */
/* ---------------------------------------------------------------------------*/

%include <sciarray.swg>


/* ---------------------------------------------------------------------------*/
/* Enum typemaps                                                              */
/* ---------------------------------------------------------------------------*/

%typemap(in, noblock=1, fragment=alaqil_AsVal_frag(Enum)) enum alaqilTYPE (int val) {
  if (alaqil_AsVal_dec(Enum)($input, &val) != alaqil_OK) {
    return alaqil_ERROR;
  }
  $1 = %static_cast(val, $1_ltype);
}

%typemap(out, fragment=alaqil_From_frag(Enum)) enum alaqilTYPE {
  if (alaqil_From_dec(Enum)($1) != alaqil_OK) {
    return alaqil_ERROR;
  }
}

/* ---------------------------------------------------------------------------*/
/* Typecheck typemaps                                                         */
/* ---------------------------------------------------------------------------*/

%define %scilab_typecheck_generic(PRECEDENCE, TYPE_CHECK_FUNCTION, TYPE)
%typecheck(PRECEDENCE) TYPE {
  int *piAddrVar = NULL;
  SciErr sciErr = getVarAddressFromPosition(pvApiCtx, $input, &piAddrVar);
  if (sciErr.iErr) {
    printError(&sciErr, 0);
    return alaqil_ERROR;
  }
  $1 = TYPE_CHECK_FUNCTION(pvApiCtx, piAddrVar);
}
%enddef

%fragment("alaqil_Check_SciDoubleOrInt", "header") {
alaqilINTERN int
alaqil_Check_SciDoubleOrInt(void *pvApiCtx, alaqilSciObject iVar, int iIntegerType) {
  int *piAddrVar = NULL;
  int ret = 0;
  SciErr sciErr = getVarAddressFromPosition(pvApiCtx, iVar, &piAddrVar);
  if (sciErr.iErr) {
    printError(&sciErr, 0);
    return 0;
  }
  ret = isIntegerType(pvApiCtx, piAddrVar);
  if (ret == 1) {
    int iPrec = 0;
    sciErr = getMatrixOfIntegerPrecision(pvApiCtx, piAddrVar, &iPrec);
    if (sciErr.iErr) {
      printError(&sciErr, 0);
      return 0;
    }
    ret = (iPrec == iIntegerType) ? 1 : 0;
  }
  else {
    ret = isDoubleType(pvApiCtx, piAddrVar);
  }
  return ret;
}
}

/* Scilab equivalent for C integers can be sci_intXX or sci_matrix */
%define %scilab_typecheck_integer(PRECEDENCE, INTTYPE, TYPE)
%typecheck(PRECEDENCE, fragment="alaqil_Check_SciDoubleOrInt") TYPE {
  $1 = alaqil_Check_SciDoubleOrInt(pvApiCtx, $input, INTTYPE);
}
%enddef

%define %scilab_typecheck_pointer(PRECEDENCE, TYPE)
%typecheck(PRECEDENCE) TYPE {
  $1 = alaqilScilabCheckPtr(pvApiCtx, $input, $descriptor, alaqil_Scilab_GetFuncName());
}
%enddef


// Double (and Float) have priority over before Integer type.

// Primitive types
%scilab_typecheck_pointer(alaqil_TYPECHECK_VOIDPTR, alaqilTYPE *)
%scilab_typecheck_pointer(alaqil_TYPECHECK_POINTER, alaqilTYPE *)
%scilab_typecheck_generic(alaqil_TYPECHECK_BOOL, isBooleanType,    bool)
%scilab_typecheck_generic(16, isDoubleType,                      double)
%scilab_typecheck_generic(17, isDoubleType,                      float)
%scilab_typecheck_integer(alaqil_TYPECHECK_INT8, SCI_INT8,         signed char)
%scilab_typecheck_integer(alaqil_TYPECHECK_UINT8, SCI_UINT8,       unsigned char)
%scilab_typecheck_integer(alaqil_TYPECHECK_INT16, SCI_INT16,       short)
%scilab_typecheck_integer(alaqil_TYPECHECK_UINT16, SCI_UINT16,     unsigned short)
%scilab_typecheck_integer(alaqil_TYPECHECK_INT32, SCI_INT32,       int)
%scilab_typecheck_integer(alaqil_TYPECHECK_INT32, SCI_INT32,       long)
%scilab_typecheck_integer(alaqil_TYPECHECK_UINT32, SCI_UINT32,     unsigned int)
%scilab_typecheck_integer(alaqil_TYPECHECK_UINT32, SCI_UINT32,     unsigned long)
%scilab_typecheck_integer(alaqil_TYPECHECK_INT32, SCI_INT32,       enum alaqilTYPE)
%scilab_typecheck_generic(alaqil_TYPECHECK_CHAR, isStringType,     char)

// Arrays
%scilab_typecheck_generic(alaqil_TYPECHECK_BOOL_ARRAY, isBooleanType,  bool)
%scilab_typecheck_generic(1016, isDoubleType,                        double [ANY])
%scilab_typecheck_generic(1017, isDoubleType,                        float [ANY])
%scilab_typecheck_integer(alaqil_TYPECHECK_INT8_ARRAY, SCI_INT8,       signed char [ANY])
%scilab_typecheck_integer(1026, SCI_UINT8,                           unsigned char [ANY])
%scilab_typecheck_integer(alaqil_TYPECHECK_INT16_ARRAY, SCI_INT16,     short [ANY])
%scilab_typecheck_integer(1036, SCI_UINT16,                          unsigned short [ANY])
%scilab_typecheck_integer(alaqil_TYPECHECK_INT32_ARRAY, SCI_INT32,     int [ANY])
%scilab_typecheck_integer(alaqil_TYPECHECK_INT32_ARRAY, SCI_INT32,     long [ANY])
%scilab_typecheck_integer(1046, SCI_UINT32,                          unsigned int [ANY])
%scilab_typecheck_integer(1046, SCI_UINT32,                          unsigned long [ANY])
%scilab_typecheck_generic(alaqil_TYPECHECK_CHAR_ARRAY, isStringType,   char [ANY])
%scilab_typecheck_generic(alaqil_TYPECHECK_STRING_ARRAY, isStringType, char *[ANY])
%scilab_typecheck_generic(alaqil_TYPECHECK_STRING_ARRAY, isStringType, char **)


/* ---------------------------------------------------------------------------*/
/* %scilabconstcode() feature typemaps                                        */
/* ---------------------------------------------------------------------------*/

%typemap(scilabconstcode, fragment=alaqil_CreateScilabVariable_frag(double)) double
%{
  if (alaqil_CreateScilabVariable_double(pvApiCtx, "$result", $value) != alaqil_OK)
    return alaqil_ERROR;
%}

%typemap(scilabconstcode, fragment=alaqil_CreateScilabVariable_frag(int)) int
%{
  if (alaqil_CreateScilabVariable_int(pvApiCtx, "$result", $value) != alaqil_OK)
    return alaqil_ERROR;
%}

%typemap(scilabconstcode, fragment=alaqil_CreateScilabVariable_frag(uint)) unsigned int
%{
  if (alaqil_CreateScilabVariable_uint(pvApiCtx, "$result", $value) != alaqil_OK)
    return alaqil_ERROR;
%}

%typemap(scilabconstcode, fragment=alaqil_CreateScilabVariable_frag(int)) long
%{
  if (alaqil_CreateScilabVariable_int(pvApiCtx, "$result", $value) != alaqil_OK)
    return alaqil_ERROR;
%}

%typemap(scilabconstcode, fragment=alaqil_CreateScilabVariable_frag(uint)) unsigned long
%{
  if (alaqil_CreateScilabVariable_uint(pvApiCtx, "$result", $value) != alaqil_OK)
    return alaqil_ERROR;
%}

%typemap(scilabconstcode, fragment=alaqil_CreateScilabVariable_frag(char)) char
%{
  if (alaqil_CreateScilabVariable_char(pvApiCtx, "$result", $value) != alaqil_OK)
    return alaqil_ERROR;
%}

%typemap(scilabconstcode, fragment=alaqil_CreateScilabVariable_frag(charptr)) char *
%{
  if (alaqil_CreateScilabVariable_charptr(pvApiCtx, "$result", $value) != alaqil_OK)
    return alaqil_ERROR;
%}

%typemap(scilabconstcode, fragment=alaqil_CreateScilabVariable_frag(double)) enum alaqilTYPE
%{
  if (alaqil_CreateScilabVariable_double(pvApiCtx, "$result", $value) != alaqil_OK)
    return alaqil_ERROR;
%}


/* ---------------------------------------------------------------------------*/
/* Exception typmemaps                                                        */
/* ---------------------------------------------------------------------------*/

%include <sciexception.swg>
