
// Include fundamental fragment definitions
%include <typemaps/fragments.swg>

// Look for user fragments file.
%include <octfragments.swg>

// Octave fragments for primitive types
%include <octprimtypes.swg>

// Octave fragments for char* strings
//%include <octstrings.swg>


#ifndef alaqil_DIRECTOR_TYPEMAPS
#define alaqil_DIRECTOR_TYPEMAPS
#endif

// Octave types
#define alaqil_Object                      octave_value
#define VOID_Object                      octave_value()

/*
// Octave allows implicit conversion
#define %implicitconv_flag              $implicitconv 
*/

// append output
#define alaqil_AppendOutput(result, obj)  alaqil_Octave_AppendOutput(result, obj)

// set constant
#define alaqil_SetConstant(name, obj)     alaqil_Octave_SetConstant(module_ns,name,obj) 

// raise
#define alaqil_Octave_Raise(OBJ, TYPE, DESC) error("C++ side threw an exception of type " TYPE)
#define alaqil_Raise(obj, type, desc)     alaqil_Octave_Raise(obj, type, desc)

// Include the unified typemap library
%include <typemaps/alaqiltypemaps.swg>

%typecheck(alaqil_TYPECHECK_alaqilOBJECT) alaqil_Object "$1 = (*$input).is_defined();";
%typecheck(alaqil_TYPECHECK_alaqilOBJECT) octave_value_list "$1 = true;";

%typemap(in) (octave_value_list varargs,...) {
  for (int j=$argnum-1;j<args.length();++j)
    $1.append(args(j));
}
%typecheck(2000) (octave_value_list varargs,...) {
  $1=1;
}

%typemap(in) (const octave_value_list& varargs,...) (octave_value_list tmp) {
  for (int j=$argnum-1;j<args.length();++j)
    tmp.append(args(j));
  $1=&tmp;
}
%typecheck(2000) (const octave_value_list& varargs,...) {
  $1=1;
}

%typemap(out) octave_value_list {
  _outp->append($1);
}
%typemap(out,noblock=1) octave_map, Octave_map {
  $result=$1;
}
%typemap(out,noblock=1) NDArray {
  $result=$1;
}
%typemap(out,noblock=1) Cell {
  $result=$1;
}

/*
// Smart Pointers
%typemap(out,noblock=1) const alaqilTYPE & SMARTPOINTER  {
  $result = alaqil_NewPointerObj(%new_copy(*$1, $*ltype), $descriptor, alaqil_POINTER_OWN | %newpointer_flags);
}

%typemap(ret) const alaqilTYPE & SMARTPOINTER, alaqilTYPE SMARTPOINTER {
  octave_alaqil_type* lobj=alaqil::alaqil_value_deref($result);
  if (lobj) {
    std::list<octave_value_list> idx;
    idx.push_back(octave_value("__deref__"));
    idx.push_back(octave_value_list());
    octave_value_list ovl(lobj->subsref(".(",idx));
    octave_alaqil_type* robj=ovl.length()>=1?alaqil::alaqil_value_deref(ovl(0)):0;
    if (robj && !error_state)
      lobj->append(robj);
  }
}
*/
