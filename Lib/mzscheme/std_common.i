/* -----------------------------------------------------------------------------
 * std_common.i
 *
 * alaqil typemaps for STL - common utilities
 * ----------------------------------------------------------------------------- */

%include <std/std_except.i>

%apply size_t { std::size_t };

%{
#include <string>

alaqilINTERNINLINE
std::string alaqil_scm_to_string(Scheme_Object *x) {
    return std::string(SCHEME_STR_VAL(x));
}

alaqilINTERNINLINE
Scheme_Object *alaqil_make_string(const std::string &s) {
    return scheme_make_string(s.c_str());
}
%}
