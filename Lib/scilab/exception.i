%include <typemaps/exception.swg>


%insert("runtime") {
  %define_as(alaqil_exception(code, msg), alaqil_Scilab_Error(code, msg);)
}
