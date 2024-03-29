/* -----------------------------------------------------------------------------
 * std_string.i
 *
 * alaqil typemaps for std::string
 * ----------------------------------------------------------------------------- */

%{
#include <string>
%}

namespace std {
    %naturalvar string;
  

    %insert(closprefix) %{ (declare (hide <std-string>)) %}
    %nodefault string;
    %rename("std-string") string;
    class string {
      public:
	~string() {}
    };
    %extend string {
      char *str;
    }
    %{
      #define std_string_str_get(s) ((char *)((s)->c_str()))
      #define std_string_str_set(s,v) (s->assign((char *)(v)))
    %}

    %typemap(typecheck) string = char *;
    %typemap(typecheck) const string & = char *;

    %typemap(in) string (char * tempptr) {
      if ($input == C_SCHEME_FALSE) {
	$1.resize(0);
      } else { 
	if (!C_alaqil_is_string ($input)) {
	  alaqil_barf (alaqil_BARF1_BAD_ARGUMENT_TYPE, 
		     "Argument #$argnum is not a string");
	}
	tempptr = alaqil_MakeString($input);
	$1.assign(tempptr);
	if (tempptr) alaqil_free(tempptr);
      }
    }

    %typemap(in) const string& ($*1_ltype temp, char *tempptr) {

      if ($input == C_SCHEME_FALSE) {
	temp.resize(0);
	$1 = &temp;
      } else { 
	if (!C_alaqil_is_string ($input)) {
	  alaqil_barf (alaqil_BARF1_BAD_ARGUMENT_TYPE, 
		     "Argument #$argnum is not a string");
	}
	tempptr = alaqil_MakeString($input);
	temp.assign(tempptr);
	if (tempptr) alaqil_free(tempptr);
	$1 = &temp;
      }
    }

    %typemap(out) string { 
      int size = $1.size();
      C_word *space = C_alloc (C_SIZEOF_STRING (size));
      $result = C_string (&space, size, (char *) $1.c_str());
    }

    %typemap(out) const string& { 
      int size = $1->size();
      C_word *space = C_alloc (C_SIZEOF_STRING (size));
      $result = C_string (&space, size, (char *) $1->c_str());
    }

    %typemap(varin) string {
      if ($input == C_SCHEME_FALSE) {
	$1.resize(0);
      } else { 
        char *tempptr;
	if (!C_alaqil_is_string ($input)) {
	  alaqil_barf (alaqil_BARF1_BAD_ARGUMENT_TYPE, 
		     "Argument #$argnum is not a string");
   	}
	tempptr = alaqil_MakeString($input);
	$1.assign(tempptr);
	if (tempptr) alaqil_free(tempptr);
      }
    }

    %typemap(varout) string { 
      int size = $1.size();
      C_word *space = C_alloc (C_SIZEOF_STRING (size));
      $result = C_string (&space, size, (char *) $1.c_str());
    }
}
