/* -----------------------------------------------------------------------------
 * std_common.i
 *
 * alaqil typemaps for STL - common utilities
 * ----------------------------------------------------------------------------- */

%include <std/std_except.i>

%apply size_t { std::size_t };

%fragment("<string>");
%{
alaqilINTERN
double alaqilSvToNumber(SV* sv) {
    return SvIOK(sv) ? double(SvIVX(sv)) : SvNVX(sv);
}
alaqilINTERN
std::string alaqilSvToString(SV* sv) {
    STRLEN len;
    char *ptr = SvPV(sv, len);
    return std::string(ptr, len);
}
alaqilINTERN
void alaqilSvFromString(SV* sv, const std::string& s) {
    sv_setpvn(sv,s.data(),s.size());
}
%}

