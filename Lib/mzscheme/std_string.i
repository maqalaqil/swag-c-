/* -----------------------------------------------------------------------------
 * std_string.i
 *
 * alaqil typemaps for std::string types
 * ----------------------------------------------------------------------------- */

// ------------------------------------------------------------------------
// std::string is typemapped by value
// This can prevent exporting methods which return a string
// in order for the user to modify it.
// However, I think I'll wait until someone asks for it...
// ------------------------------------------------------------------------

%include <exception.i>

%{
#include <string>
%}

namespace std {

    %naturalvar string;

    class string;

    /* Overloading check */

    %typemap(typecheck) string = char *;
    %typemap(typecheck) const string & = char *;

    %typemap(in) string {
        if (SCHEME_STRINGP($input))
            $1.assign(SCHEME_STR_VAL($input));
        else
            alaqil_exception(alaqil_TypeError, "string expected");
    }

    %typemap(in) const string & ($*1_ltype temp) {
        if (SCHEME_STRINGP($input)) {
            temp.assign(SCHEME_STR_VAL($input));
            $1 = &temp;
        } else {
            alaqil_exception(alaqil_TypeError, "string expected");
        }
    }

    %typemap(out) string {
        $result = scheme_make_string($1.c_str());
    }

    %typemap(out) const string & {
        $result = scheme_make_string($1->c_str());
    }

}


