/* ------------------------------------------------------------
 * Primitive Types
 * ------------------------------------------------------------ */


// boolean

%fragment(alaqil_From_frag(bool),"header") {
alaqilINTERNINLINE octave_value
  alaqil_From_dec(bool)(bool value)
{
  return octave_value(value);
}
}

%fragment(alaqil_AsVal_frag(bool),"header",
	  fragment=alaqil_AsVal_frag(long)) {
alaqilINTERN int
alaqil_AsVal_dec(bool)(const octave_value& ov, bool *val)
{
%#if alaqil_OCTAVE_PREREQ(4,4,0)
  if (!ov.islogical())
%#else
  if (!ov.is_bool_type())
%#endif
    return alaqil_ERROR;
  if (val)
    *val = ov.bool_value();
  return alaqil_OK;
}
}

// long

%fragment(alaqil_From_frag(long),"header") {
  alaqilINTERNINLINE octave_value alaqil_From_dec(long)  (long value)
    {    
      return octave_value(value);
    }
}


%fragment(alaqil_AsVal_frag(long),"header") {
  alaqilINTERN int alaqil_AsVal_dec(long)(const octave_value& ov, long* val)
    {
      if (!ov.is_scalar_type())
	return alaqil_TypeError;
      if (ov.is_complex_scalar())
	return alaqil_TypeError;
      if (ov.is_double_type()||ov.is_single_type()) {
	double v=ov.double_value();
	if (v!=floor(v))
	  return alaqil_TypeError;
      }
      if (val)
	*val = ov.long_value();
      return alaqil_OK;
    }
}

// unsigned long

%fragment(alaqil_From_frag(unsigned long),"header") {
  alaqilINTERNINLINE octave_value alaqil_From_dec(unsigned long)  (unsigned long value)
    {    
      return octave_value(value);
    }
}


%fragment(alaqil_AsVal_frag(unsigned long),"header") {
  alaqilINTERN int alaqil_AsVal_dec(unsigned long)(const octave_value& ov, unsigned long* val)
    {
      if (!ov.is_scalar_type())
	return alaqil_TypeError;
      if (ov.is_complex_scalar())
	return alaqil_TypeError;
      if (ov.is_double_type()||ov.is_single_type()) {
	double v=ov.double_value();
	if (v<0)
	  return alaqil_OverflowError;  
	if (v!=floor(v))
	  return alaqil_TypeError;
      }
      if (ov.is_int8_type()||ov.is_int16_type()||
	  ov.is_int32_type()) {
	long v=ov.long_value();
	if (v<0)
	  return alaqil_OverflowError;  
      }
      if (ov.is_int64_type()) {
	long long v=ov.int64_scalar_value().value();
	if (v<0)
	  return alaqil_OverflowError;  
      }
      if (val)
	*val = ov.ulong_value();
      return alaqil_OK;
    }
}

// long long

%fragment(alaqil_From_frag(long long),"header",
	  fragment="alaqil_LongLongAvailable") {
%#ifdef alaqil_LONG_LONG_AVAILABLE
  alaqilINTERNINLINE octave_value alaqil_From_dec(long long)  (long long value)
    {    
      return octave_int64(value);
    }
%#endif
}


%fragment(alaqil_AsVal_frag(long long),"header",
	  fragment="alaqil_LongLongAvailable") {
%#ifdef alaqil_LONG_LONG_AVAILABLE
  alaqilINTERN int alaqil_AsVal_dec(long long)(const octave_value& ov, long long* val)
    {
      if (!ov.is_scalar_type())
	return alaqil_TypeError;
      if (ov.is_complex_scalar())
	return alaqil_TypeError;
      if (ov.is_double_type()||ov.is_single_type()) {
	double v=ov.double_value();
	if (v!=floor(v))
	  return alaqil_TypeError;
      }
      if (val) {
	if (ov.is_int64_type())
	  *val = ov.int64_scalar_value().value();
	else if (ov.is_uint64_type())
	  *val = ov.uint64_scalar_value().value();
	else
	  *val = ov.long_value();
      }
      return alaqil_OK;
    }
%#endif
}

%fragment(alaqil_From_frag(unsigned long long),"header",
	  fragment="alaqil_LongLongAvailable") {
%#ifdef alaqil_LONG_LONG_AVAILABLE
  alaqilINTERNINLINE octave_value alaqil_From_dec(unsigned long long)  (unsigned long long value)
    {    
      return octave_uint64(value);
    }
%#endif
}

%fragment(alaqil_AsVal_frag(unsigned long long),"header",
	  fragment="alaqil_LongLongAvailable") {
%#ifdef alaqil_LONG_LONG_AVAILABLE
  alaqilINTERN int alaqil_AsVal_dec(unsigned long long)(const octave_value& ov, unsigned long long* val)
    {
      if (!ov.is_scalar_type())
	return alaqil_TypeError;
      if (ov.is_complex_scalar())
	return alaqil_TypeError;
      if (ov.is_double_type()||ov.is_single_type()) {
	double v=ov.double_value();
	if (v<0)
	  return alaqil_OverflowError;  
	if (v!=floor(v))
	  return alaqil_TypeError;
      }
      if (ov.is_int8_type()||ov.is_int16_type()||
	  ov.is_int32_type()) {
	long v=ov.long_value();
	if (v<0)
	  return alaqil_OverflowError;  
      }
      if (ov.is_int64_type()) {
	long long v=ov.int64_scalar_value().value();
	if (v<0)
	  return alaqil_OverflowError;  
      }
      if (val) {
	if (ov.is_int64_type())
	  *val = ov.int64_scalar_value().value();
	else if (ov.is_uint64_type())
	  *val = ov.uint64_scalar_value().value();
	else
	  *val = ov.long_value();
      }
      return alaqil_OK;
    }
%#endif
}

// double

%fragment(alaqil_From_frag(double),"header") {
  alaqilINTERNINLINE octave_value alaqil_From_dec(double)  (double value)
    {    
      return octave_value(value);
    }
}


%fragment(alaqil_AsVal_frag(double),"header") {
  alaqilINTERN int alaqil_AsVal_dec(double)(const octave_value& ov, double* val)
    {
      if (!ov.is_scalar_type())
	return alaqil_TypeError;
      if (ov.is_complex_scalar())
	return alaqil_TypeError;
      if (val)
	*val = ov.double_value();
      return alaqil_OK;
    }
}

// const char* (strings)

%fragment("alaqil_AsCharPtrAndSize","header") {
alaqilINTERN int
alaqil_AsCharPtrAndSize(octave_value ov, char** cptr, size_t* psize, int *alloc)
{
  if (
%#if alaqil_OCTAVE_PREREQ(4,4,0)
    ov.iscell()
%#else
    ov.is_cell()
%#endif
    && ov.rows() == 1 && ov.columns() == 1)
    ov = ov.cell_value()(0);
  if (!ov.is_string())
    return alaqil_TypeError;
  
  std::string str=ov.string_value();
  size_t len=str.size();
  char* cstr=(char*)str.c_str();
  if (alloc) {
    *cptr = %new_copy_array(cstr, len + 1, char);
    *alloc = alaqil_NEWOBJ;
  } else if (cptr)
    *cptr = cstr;
  if (psize)
    *psize = len + 1;
  return alaqil_OK;
}
}

%fragment("alaqil_FromCharPtrAndSize","header",fragment="alaqil_pchar_descriptor") {
alaqilINTERNINLINE octave_value
alaqil_FromCharPtrAndSize(const char* carray, size_t size)
{
  return std::string(carray,carray+size);
}
}


