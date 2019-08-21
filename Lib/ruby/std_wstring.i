%{
#ifdef __cplusplus
extern "C" {
#endif

#ifdef HAVE_RUBY_ENCODING_H
#include "ruby/encoding.h"
#endif

/**
 *  The internal encoding of std::wstring is defined based on
 *  the size of wchar_t. If it is not appropriate for your library,
 *  alaqil_RUBY_WSTRING_ENCODING must be given when compiling.
 */
#ifndef alaqil_RUBY_WSTRING_ENCODING

#if WCHAR_MAX == 0x7fff || WCHAR_MAX == 0xffff
#define alaqil_RUBY_WSTRING_ENCODING "UTF-16LE"
#elif WCHAR_MAX == 0x7fffffff || WCHAR_MAX == 0xffffffff
#define alaqil_RUBY_WSTRING_ENCODING "UTF-32LE"
#else
#error unsupported wchar_t size. alaqil_RUBY_WSTRING_ENCODING must be given.
#endif

#endif

/**
 *  If Encoding.default_internal is nil, this encoding will be used
 *  when converting from std::wstring to String object in Ruby.
 */
#ifndef alaqil_RUBY_INTERNAL_ENCODING
#define alaqil_RUBY_INTERNAL_ENCODING "UTF-8"
#endif

static rb_encoding *alaqil_ruby_wstring_encoding;
static rb_encoding *alaqil_ruby_internal_encoding;

#ifdef __cplusplus
}
#endif
%}

%fragment("alaqil_ruby_wstring_encoding_init", "init") {
  alaqil_ruby_wstring_encoding  = rb_enc_find( alaqil_RUBY_WSTRING_ENCODING );
  alaqil_ruby_internal_encoding = rb_enc_find( alaqil_RUBY_INTERNAL_ENCODING );
}

%warnfilter(alaqilWARN_RUBY_WRONG_NAME) std::basic_string<wchar_t>;

%include <rubywstrings.swg>
%include <typemaps/std_wstring.swg>

