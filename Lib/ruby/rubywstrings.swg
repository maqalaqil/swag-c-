/* -----------------------------------------------------------------------------
 * rubywstrings.swg
 *
 *  utility methods for wchar_t strings 
 * ------------------------------------------------------------ */

%fragment("alaqil_AsWCharPtrAndSize","header",fragment="<wchar.h>",fragment="alaqil_pwchar_descriptor",fragment="alaqil_AsCharPtrAndSize",fragment="alaqil_ruby_wstring_encoding_init") {
alaqilINTERN int
alaqil_AsWCharPtrAndSize(VALUE obj, wchar_t **cptr, size_t *psize, int *alloc)
{
  rb_encoding* wstr_enc = alaqil_ruby_wstring_encoding;

  if (TYPE(obj) == T_STRING) {
    VALUE rstr = rb_str_conv_enc(obj, rb_enc_get(obj), wstr_enc);
    wchar_t* cstr = (wchar_t*) StringValuePtr(rstr);
    size_t   size = RSTRING_LEN(rstr) / sizeof(wchar_t) + 1;

    if ( RSTRING_LEN(rstr) % sizeof(wchar_t) != 0 ) {
        rb_raise(rb_eRuntimeError,
                 "The length of the byte sequence of converted string is not a multiplier of sizeof(wchar_t). Invalid byte sequence is given. Or invalid alaqil_RUBY_WSTRING_ENCODING is given when compiling this binding.");
    }
    if (cptr && alloc)  {
      *alloc = alaqil_NEWOBJ;
      *cptr = %new_array(size, wchar_t);
      memmove(*cptr, cstr, RSTRING_LEN(rstr));
    }
    if (psize) *psize = size;

    return alaqil_OK;
  } else {
    return alaqil_TypeError;
  }
}
}

%fragment("alaqil_FromWCharPtrAndSize","header",fragment="<wchar.h>",fragment="alaqil_pwchar_descriptor",fragment="alaqil_FromCharPtrAndSize",fragment="alaqil_ruby_wstring_encoding_init") {
alaqilINTERNINLINE VALUE 
alaqil_FromWCharPtrAndSize(const wchar_t * carray, size_t size)
{
  rb_encoding* wstr_enc = alaqil_ruby_wstring_encoding;
  rb_encoding* rb_enc   = alaqil_ruby_internal_encoding;

  if (carray && size <= LONG_MAX/sizeof(wchar_t)) {
    VALUE rstr = rb_str_new( (const char*)carray, %numeric_cast(size*sizeof(wchar_t),long) );
    rb_encoding* new_enc = rb_default_internal_encoding();

    rb_enc_associate(rstr, wstr_enc);
    if ( !new_enc ) {
      new_enc = rb_enc;
    }
    return rb_str_conv_enc(rstr, wstr_enc, new_enc);
  } else {
    return Qnil;
  }
}
}


