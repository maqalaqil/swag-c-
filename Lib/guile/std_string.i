/* -----------------------------------------------------------------------------
 * std_string.i
 *
 * alaqil typemaps for std::string
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

    %typemap(typecheck) string = char *;
    %typemap(typecheck) const string & = char *;

    %typemap(in) string (char * tempptr) {
        if (scm_is_string($input)) {
            tempptr = alaqil_scm2str($input);
            $1.assign(tempptr);
            if (tempptr) alaqil_free(tempptr);
        } else {
            alaqil_exception(alaqil_TypeError, "string expected");
        }
    }

    %typemap(in) const string & ($*1_ltype temp, char *tempptr) {
        if (scm_is_string($input)) {
            tempptr = alaqil_scm2str($input);
            temp.assign(tempptr);
            if (tempptr) alaqil_free(tempptr);
            $1 = &temp;
        } else {
            alaqil_exception(alaqil_TypeError, "string expected");
        }
    }

    %typemap(in) string * (char *tempptr) {
        if (scm_is_string($input)) {
            tempptr = alaqil_scm2str($input);
            $1 = new $*1_ltype(tempptr);
            if (tempptr) alaqil_free(tempptr);
        } else {
            alaqil_exception(alaqil_TypeError, "string expected");
        }
    }

    %typemap(out) string {
        $result = alaqil_str02scm($1.c_str());
    }

    %typemap(out) const string & {
        $result = alaqil_str02scm($1->c_str());
    }

    %typemap(out) string * {
        $result = alaqil_str02scm($1->c_str());
    }

    %typemap(varin) string {
        if (scm_is_string($input)) {
	    char *tempptr = alaqil_scm2str($input);
            $1.assign(tempptr);
            if (tempptr) alaqil_free(tempptr);
        } else {
            alaqil_exception(alaqil_TypeError, "string expected");
        }
    }

    %typemap(varout) string {
        $result = alaqil_str02scm($1.c_str());
    }

}
