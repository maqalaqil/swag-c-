/* ----------------------------------------------------------------------------- 
 * This file is part of alaqil, which is licensed as a whole under version 3 
 * (or any later version) of the GNU General Public License. Some additional
 * terms also apply to certain portions of alaqil. The full details of the alaqil
 * license and copyrights can be found in the LICENSE and COPYRIGHT files
 * included with the alaqil source code as distributed by the alaqil developers
 * and at http://www.alaqil.org/legal.html.
 *
 * alaqilwrap.h
 *
 * Functions related to wrapper objects.
 * ----------------------------------------------------------------------------- */

typedef struct Wrapper {
    Hash *localh;
    String *def;
    String *locals;
    String *code;
} Wrapper;

extern Wrapper *NewWrapper(void);
extern void     DelWrapper(Wrapper *w);
extern void     Wrapper_compact_print_mode_set(int flag);
extern void     Wrapper_pretty_print(String *str, File *f);
extern void     Wrapper_compact_print(String *str, File *f);
extern void     Wrapper_print(Wrapper *w, File *f);
extern int      Wrapper_add_local(Wrapper *w, const_String_or_char_ptr name, const_String_or_char_ptr decl);
extern int      Wrapper_add_localv(Wrapper *w, const_String_or_char_ptr name, ...);
extern int      Wrapper_check_local(Wrapper *w, const_String_or_char_ptr name);
extern char    *Wrapper_new_local(Wrapper *w, const_String_or_char_ptr name, const_String_or_char_ptr decl);
extern char    *Wrapper_new_localv(Wrapper *w, const_String_or_char_ptr name, ...);
