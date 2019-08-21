/* -----------------------------------------------------------------------------
 * typecheck.i
 *
 * Typechecking rules
 * ----------------------------------------------------------------------------- */

%typecheck(alaqil_TYPECHECK_INT8) char, signed char, const char &, const signed char & {
  if( !Is_block($input) ) $1 = 0;
  else {
      switch( alaqil_Tag_val($input) ) {
      case C_char: $1 = 1; break;
      default: $1 = 0; break;
      }
  }
}

%typecheck(alaqil_TYPECHECK_UINT8) unsigned char, const unsigned char & {
  if( !Is_block($input) ) $1 = 0;
  else {
      switch( alaqil_Tag_val($input) ) {
      case C_uchar: $1 = 1; break;
      default: $1 = 0; break;
      }
  }
}

%typecheck(alaqil_TYPECHECK_INT16) short, signed short, const short &, const signed short &, wchar_t {
  if( !Is_block($input) ) $1 = 0;
  else {
      switch( alaqil_Tag_val($input) ) {
      case C_short: $1 = 1; break;
      default: $1 = 0; break;
      }
  }
}

%typecheck(alaqil_TYPECHECK_UINT16) unsigned short, const unsigned short & {
  if( !Is_block($input) ) $1 = 0;
  else {
      switch( alaqil_Tag_val($input) ) {
      case C_ushort: $1 = 1; break;
      default: $1 = 0; break;
      }
  }
}

// XXX arty 
// Will move enum alaqilTYPE later when I figure out what to do with it...

%typecheck(alaqil_TYPECHECK_INT32) int, signed int, const int &, const signed int &, enum alaqilTYPE {
  if( !Is_block($input) ) $1 = 0;
  else {
      switch( alaqil_Tag_val($input) ) {
      case C_int: $1 = 1; break;
      default: $1 = 0; break;
      }
  }
}

%typecheck(alaqil_TYPECHECK_UINT32) unsigned int, const unsigned int & {
  if( !Is_block($input) ) $1 = 0;
  else {
      switch( alaqil_Tag_val($input) ) {
      case C_uint: $1 = 1; break;
      case C_int32: $1 = 1; break;
      default: $1 = 0; break;
      }
  }
}

%typecheck(alaqil_TYPECHECK_INT64)
  long, signed long, unsigned long,
  long long, signed long long, unsigned long long,
  const long &, const signed long &, const unsigned long &,
  const long long &, const signed long long &, const unsigned long long &,
  size_t, const size_t &
{
  if( !Is_block($input) ) $1 = 0;
  else {
      switch( alaqil_Tag_val($input) ) {
      case C_int64: $1 = 1; break;
      default: $1 = 0; break;
      }
  }
}

%typecheck(alaqil_TYPECHECK_BOOL) bool, const bool & {
  if( !Is_block($input) ) $1 = 0;
  else {
      switch( alaqil_Tag_val($input) ) {
      case C_bool: $1 = 1; break;
      default: $1 = 0; break;
      }
  }
}

%typecheck(alaqil_TYPECHECK_FLOAT) float, const float & {
  if( !Is_block($input) ) $1 = 0;
  else {
      switch( alaqil_Tag_val($input) ) {
      case C_float: $1 = 1; break;
      default: $1 = 0; break;
      }
  }  
}

%typecheck(alaqil_TYPECHECK_DOUBLE) double, const double & {
  if( !Is_block($input) ) $1 = 0;
  else {
      switch( alaqil_Tag_val($input) ) {
      case C_double: $1 = 1; break;
      default: $1 = 0; break;
      }
  }  
}

%typecheck(alaqil_TYPECHECK_STRING) char * {
  if( !Is_block($input) ) $1 = 0;
  else {
      switch( alaqil_Tag_val($input) ) {
      case C_string: $1 = 1; break;
      case C_ptr: {
	alaqil_type_info *typeinfo = 
	    (alaqil_type_info *)(long)alaqil_Int64_val(alaqil_Field($input,1));
	$1 = alaqil_TypeCheck("char *",typeinfo) ||
	     alaqil_TypeCheck("signed char *",typeinfo) ||
	     alaqil_TypeCheck("unsigned char *",typeinfo) ||
	     alaqil_TypeCheck("const char *",typeinfo) ||
	     alaqil_TypeCheck("const signed char *",typeinfo) ||
	     alaqil_TypeCheck("const unsigned char *",typeinfo) ||
	     alaqil_TypeCheck("std::string",typeinfo);
      } break;
      default: $1 = 0; break;
      }
  }    
}

%typecheck(alaqil_TYPECHECK_POINTER) alaqilTYPE *, alaqilTYPE &, alaqilTYPE &&, alaqilTYPE [] {
  if (!Is_block($input) || !(alaqil_Tag_val($input) == C_obj || alaqil_Tag_val($input) == C_ptr)) {
    $1 = 0;
  } else {
    void *ptr;
    $1 = !caml_ptr_val_internal($input, &ptr, $descriptor);
  }
}

%typecheck(alaqil_TYPECHECK_POINTER) alaqilTYPE {
  alaqil_type_info *typeinfo;
  if (!Is_block($input)) {
    $1 = 0;
  } else {
    switch (alaqil_Tag_val($input)) {
      case C_obj: {
        void *ptr;
        $1 = !caml_ptr_val_internal($input, &ptr, $&1_descriptor);
        break;
      }
      case C_ptr: {
        typeinfo = (alaqil_type_info *)alaqil_Int64_val(alaqil_Field($input, 1));
        $1 = alaqil_TypeCheck("$1_type", typeinfo) != NULL;
        break;
      }
      default: $1 = 0; break;
    }
  }
}

%typecheck(alaqil_TYPECHECK_VOIDPTR) void * {
  void *ptr;
  $1 = !caml_ptr_val_internal($input, &ptr, 0);
}

%typecheck(alaqil_TYPECHECK_alaqilOBJECT) CAML_VALUE "$1 = 1;"

/* ------------------------------------------------------------
 * Exception handling
 * ------------------------------------------------------------ */

%typemap(throws) int, 
                  long, 
                  short, 
                  unsigned int, 
                  unsigned long, 
                  unsigned short {
  char error_msg[256];
  sprintf(error_msg, "C++ $1_type exception thrown, value: %d", $1);
  alaqil_OCamlThrowException(alaqil_OCamlRuntimeException, error_msg);
}

%typemap(throws) alaqilTYPE, alaqilTYPE &, alaqilTYPE &&, alaqilTYPE *, alaqilTYPE [], alaqilTYPE [ANY] {
  (void)$1;
  alaqil_OCamlThrowException(alaqil_OCamlRuntimeException, "C++ $1_type exception thrown");
}

%typemap(throws) char * {
  alaqil_OCamlThrowException(alaqil_OCamlRuntimeException, $1);
}
