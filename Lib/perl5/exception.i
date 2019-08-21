%include <typemaps/exception.swg>

%insert("runtime") {
  %define_as(alaqil_exception(code, msg), %block(%error(code, msg); alaqil_fail; ))
}
