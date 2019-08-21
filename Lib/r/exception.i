%include <typemaps/exception.swg>


%insert("runtime") {
  %define_as(alaqil_exception(code, msg), 
%block(switch (code) {case alaqil_IndexError: return Rf_ScalarLogical(NA_LOGICAL); default: %error(code, msg); alaqil_fail;} ))
}

