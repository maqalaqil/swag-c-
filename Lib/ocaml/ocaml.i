/* -----------------------------------------------------------------------------
 * ocaml.i
 *
 * alaqil Configuration File for Ocaml
 * ----------------------------------------------------------------------------- */

/* Insert common stuff */
%insert(runtime) "alaqilrun.swg"

/* Include headers */
%insert(runtime) "ocamldec.swg"

/* Type registration */
%insert(init) "alaqilinit.swg"
%insert(init) "typeregister.swg"

%insert(mlitail) %{
  val alaqil_val : c_enum_type -> c_obj -> alaqil.c_obj
%}

%insert(mltail) %{
  let rec alaqil_val t v = 
    match v with
        C_enum e -> enum_to_int t v
      | C_list l -> alaqil.C_list (List.map (alaqil_val t) l)
      | C_array a -> alaqil.C_array (Array.map (alaqil_val t) a)
      | _ -> Obj.magic v
%}

/*#ifndef alaqil_NOINCLUDE*/
%insert(runtime) "ocaml.swg"
/*#endif*/

%insert(classtemplate) "class.swg"

/* Definitions */
#define alaqil_malloc(size) alaqil_malloc(size, FUNC_NAME)
#define alaqil_free(mem) free(mem)

/* Read in standard typemaps. */
%include <alaqil.swg>
%include <typemaps.i>
%include <typecheck.i>
%include <exception.i>
%include <preamble.swg>

/* ocaml keywords */
/* There's no need to use this, because of my rewriting machinery.  C++
 * words never collide with ocaml keywords */

/* still we include the file, but the warning says that the offending
   name will be properly renamed. Just to let the user to know about
   it. */
%include <ocamlkw.swg>
