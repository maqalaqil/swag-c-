/*
 * Exception typemaps (throws)
 */

%include <exception.i>

%typemap(throws, noblock=1) int, unsigned int, signed int,
                            int&,unsigned int&, signed int&,
                            long, unsigned long, signed long,
                            short, unsigned short,signed short,
                            long long, unsigned long long,
                            unsigned char, signed char,
                            long&, unsigned long&, signed long&,
                            short&, unsigned short&, signed short&,
                            long long&, unsigned long long&,
                            unsigned char&, signed char&,
                            size_t, size_t&,
                            ptrdiff_t, ptrdiff_t& {
  char obj[20];
  sprintf(obj, "%d", (int)$1);
  alaqil_Scilab_Raise_Ex(obj, "$type", $descriptor);
}

%typemap(throws, noblock=1) enum alaqilTYPE {
  char obj[20];
  sprintf(obj, "%d", (int)$1);
  alaqil_Scilab_Raise_Ex(obj, "$type", $descriptor);
}

%typemap(throws, noblock=1) float, double,
                            float&, double& {
  char obj[20];
  sprintf(obj, "%5.3f", (double)$1);
  alaqil_Scilab_Raise_Ex(obj, "$type", $descriptor);
}

%typemap(throws, noblock=1) bool, bool& {
  alaqil_Scilab_Raise_Ex($1 ? "true" : "false", "$type", $descriptor);
}

%typemap(throws, noblock=1) char*, char[ANY] {
  alaqil_Scilab_Raise_Ex($1, "$type", $descriptor);
}

%typemap(throws, noblock=1) char, char& {
  char obj[2];
  sprintf(obj, "%c", (char)$1);
  alaqil_Scilab_Raise_Ex(obj, "$type", $descriptor);
}

%typemap(throws, noblock=1) alaqilTYPE,
                            alaqilTYPE*,
                            alaqilTYPE [ANY],
                            alaqilTYPE & {
  alaqil_Scilab_Raise_Ex((char*)NULL, "$type", $descriptor);
}

%typemap(throws, noblock=1) (...) {
  alaqil_exception(alaqil_RuntimeError, "unknown exception");
}
