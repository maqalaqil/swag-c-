/* -----------------------------------------------------------------------------
 * This file is part of alaqil, which is licensed as a whole under version 3 
 * (or any later version) of the GNU General Public License. Some additional
 * terms also apply to certain portions of alaqil. The full details of the alaqil
 * license and copyrights can be found in the LICENSE and COPYRIGHT files
 * included with the alaqil source code as distributed by the alaqil developers
 * and at http://www.alaqil.org/legal.html.
 *
 * cparse.h
 *
 * alaqil parser module.
 * ----------------------------------------------------------------------------- */

#ifndef alaqil_CPARSE_H_
#define alaqil_CPARSE_H_

#include "alaqil.h"
#include "alaqilwarn.h"

#ifdef __cplusplus
extern "C" {
#endif

/* cscanner.c */
  extern String *cparse_file;
  extern int cparse_line;
  extern int cparse_cplusplus;
  extern int cparse_cplusplusout;
  extern int cparse_start_line;
  extern String *cparse_unknown_directive;
  extern int scan_doxygen_comments;

  extern void alaqil_cparse_cplusplus(int);
  extern void alaqil_cparse_cplusplusout(int);
  extern void scanner_file(File *);
  extern void scanner_next_token(int);
  extern void skip_balanced(int startchar, int endchar);
  extern String *get_raw_text_balanced(int startchar, int endchar);
  extern void skip_decl(void);
  extern void scanner_check_typedef(void);
  extern void scanner_ignore_typedef(void);
  extern void scanner_last_id(int);
  extern void scanner_clear_rename(void);
  extern void scanner_set_location(String *file, int line);
  extern void scanner_set_main_input_file(String *file);
  extern String *scanner_get_main_input_file();
  extern void alaqil_cparse_follow_locators(int);
  extern void start_inline(char *, int);
  extern String *scanner_ccode;
  extern int yylex(void);

/* parser.y */
  extern alaqilType *alaqil_cparse_type(String *);
  extern Node *alaqil_cparse(File *);
  extern Hash *alaqil_cparse_features(void);
  extern void alaqil_cparse_set_compact_default_args(int defargs);
  extern int alaqil_cparse_template_reduce(int treduce);

/* util.c */
  extern void alaqil_cparse_replace_descriptor(String *s);
  extern alaqilType *alaqil_cparse_smartptr(Node *n);
  extern void cparse_normalize_void(Node *);
  extern Parm *alaqil_cparse_parm(String *s);
  extern ParmList *alaqil_cparse_parms(String *s, Node *file_line_node);
  extern Node *alaqil_cparse_new_node(const_String_or_char_ptr tag);

/* templ.c */
  extern int alaqil_cparse_template_expand(Node *n, String *rname, ParmList *tparms, Symtab *tscope);
  extern Node *alaqil_cparse_template_locate(String *name, ParmList *tparms, Symtab *tscope);
  extern void alaqil_cparse_debug_templates(int);

#ifdef __cplusplus
}
#endif
#define alaqil_WARN_NODE_BEGIN(Node) \
 { \
  String *wrnfilter = Node ? Getattr(Node,"feature:warnfilter") : 0; \
  if (wrnfilter) alaqil_warnfilter(wrnfilter,1)
#define alaqil_WARN_NODE_END(Node) \
  if (wrnfilter) alaqil_warnfilter(wrnfilter,0); \
 }

#define COMPOUND_EXPR_VAL(dtype) \
  ((dtype).type == T_CHAR || (dtype).type == T_WCHAR ? (dtype).rawval : (dtype).val)
#endif
