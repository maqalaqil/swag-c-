
// Documentation for use with the autodoc feature.

#ifdef alaqil_DOC_DOXYGEN_STYLE
%typemap(doc) alaqilTYPE "@param $1_name $1_type";
%typemap(doc) alaqilTYPE * "@param $1_name $1_type";
%typemap(doc) const alaqilTYPE & "@param $1_name $1_type";
%typemap(doc) const alaqilTYPE && "@param $1_name $1_type";
%typemap(doc) enum alaqilTYPE "@param $1_name enum $1_type";

%typemap(doc) alaqilTYPE *INOUT, alaqilTYPE &INOUT "@param $1_name $1_type (input/output)";
%typemap(doc) alaqilTYPE *INPUT, alaqilTYPE &INPUT "@param $1_name $1_type (input)";
%typemap(doc) alaqilTYPE *OUTPUT, alaqilTYPE &OUTPUT "@param $1_name $1_type (output)";
#else
%typemap(doc) alaqilTYPE "$1_name: $1_type";
%typemap(doc) alaqilTYPE * "$1_name: $1_type";
%typemap(doc) const alaqilTYPE & "$1_name: $1_type";
%typemap(doc) const alaqilTYPE && "$1_name: $1_type";
%typemap(doc) enum alaqilTYPE "$1_name: enum $1_type";

%typemap(doc) alaqilTYPE *INOUT, alaqilTYPE &INOUT "$1_name: $1_type (input/output)";
%typemap(doc) alaqilTYPE *INPUT, alaqilTYPE &INPUT "$1_name: $1_type (input)";
%typemap(doc) alaqilTYPE *OUTPUT, alaqilTYPE &OUTPUT "$1_name: $1_type (output)";
#endif


// Types to use in Python documentation for the parameters of the given C++ type.
%typemap(doctype) bool "boolean";

%define int_doctype_for_cppint_type(cppint_type)
    %typemap(doctype) cppint_type, unsigned cppint_type "int";
%enddef
%formacro(int_doctype_for_cppint_type, short, int, long, long long)

%typemap(doctype) size_t "int";

%typemap(doctype) enum alaqilTYPE "int";

%typemap(doctype) float, double, long double "float";

%typemap(doctype) char*, std::string "string";

%typemap(doctype) alaqilTYPE "$1_basetype"
%typemap(doctype) alaqilTYPE * "$typemap(doctype, $*1_ltype)"
%typemap(doctype) alaqilTYPE & "$typemap(doctype, $*1_ltype)"
