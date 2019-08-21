/* -----------------------------------------------------------------------------
 * std_common.i
 *
 * alaqil typemaps for STL - common utilities
 * ----------------------------------------------------------------------------- */

%include <std/std_except.i>

%apply size_t { std::size_t };

#define alaqil_bool2scm(b) scm_from_bool(b ? 1 : 0)
#define alaqil_string2scm(s) alaqil_str02scm(s.c_str())

%{
#include <string>

alaqilINTERNINLINE
std::string alaqil_scm2string(SCM x) {
    char* temp;
    temp = alaqil_scm2str(x);
    std::string s(temp);
    if (temp) alaqil_free(temp);
    return s;
}
%}
