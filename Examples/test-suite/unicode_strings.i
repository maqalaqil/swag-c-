%module unicode_strings

%include <std_string.i>

%begin %{
#define alaqil_PYTHON_2_UNICODE
%}

%inline %{

const char* non_utf8_c_str(void) {
        return "h\xe9llo w\xc3\xb6rld";
}

std::string non_utf8_std_string(void) {
        return std::string("h\xe9llo w\xc3\xb6rld");
}

char *charstring(char *s) {
  return s;
}

void instring(const char *s) {
}
%}
