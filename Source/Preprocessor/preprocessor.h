/* -----------------------------------------------------------------------------
 * This file is part of alaqil, which is licensed as a whole under version 3 
 * (or any later version) of the GNU General Public License. Some additional
 * terms also apply to certain portions of alaqil. The full details of the alaqil
 * license and copyrights can be found in the LICENSE and COPYRIGHT files
 * included with the alaqil source code as distributed by the alaqil developers
 * and at http://www.alaqil.org/legal.html.
 *
 * preprocessor.h
 *
 * alaqil preprocessor module.
 * ----------------------------------------------------------------------------- */

#ifndef alaqil_PREPROCESSOR_H_
#define alaqil_PREPROCESSOR_H_

#include "alaqilwarn.h"

#ifdef __cplusplus
extern "C" {
#endif
  extern int Preprocessor_expr(String *s, int *error);
  extern const char *Preprocessor_expr_error(void);
  extern Hash *Preprocessor_define(const_String_or_char_ptr str, int alaqilmacro);
  extern void Preprocessor_undef(const_String_or_char_ptr name);
  extern void Preprocessor_init(void);
  extern void Preprocessor_delete(void);
  extern String *Preprocessor_parse(String *s);
  extern void Preprocessor_include_all(int);
  extern void Preprocessor_import_all(int);
  extern void Preprocessor_ignore_missing(int);
  extern void Preprocessor_error_as_warning(int);
  extern List *Preprocessor_depend(void);
  extern void Preprocessor_expr_init(void);
  extern void Preprocessor_expr_delete(void);

#ifdef __cplusplus
}
#endif
#endif
