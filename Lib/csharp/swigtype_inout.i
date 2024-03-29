/* -----------------------------------------------------------------------------
 * alaqiltype_inout.i
 *
 * Pointer pointer and pointer reference handling typemap library for non-primitive types
 *
 * These mappings provide support for input/output arguments and common
 * uses for C/C++ pointer references and pointer to pointers.
 *
 * These are named typemaps (OUTPUT) and can be used like any named typemap.
 * Alternatively they can be made the default by using %apply:
 *   %apply alaqilTYPE *& OUTPUT { alaqilTYPE *& }
 * ----------------------------------------------------------------------------- */

/*
 * OUTPUT typemaps. Example usage wrapping:
 *
 *   void f(XXX *& x) { x = new XXX(111); }
 *
 * would be:
 *
 *   XXX x = null;
 *   f(out x);
 *   // use x
 *   x.Dispose(); // manually clear memory or otherwise leave out and leave it to the garbage collector
 */
%typemap(ctype) alaqilTYPE *& OUTPUT "void **"
%typemap(imtype, out="global::System.IntPtr") alaqilTYPE *& OUTPUT "out global::System.IntPtr"
%typemap(cstype) alaqilTYPE *& OUTPUT "out $*csclassname"
%typemap(csin,
         pre="    global::System.IntPtr cPtr_$csinput = global::System.IntPtr.Zero;",
         post="      $csinput = (cPtr_$csinput == global::System.IntPtr.Zero) ? null : new $*csclassname(cPtr_$csinput, true);",
         cshin="out $csinput") alaqilTYPE *& OUTPUT "out cPtr_$csinput"
%typemap(in) alaqilTYPE *& OUTPUT %{ $1 = ($1_ltype)$input; %}
%typemap(freearg) alaqilTYPE *& OUTPUT ""
