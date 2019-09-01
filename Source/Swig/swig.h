/* ----------------------------------------------------------------------------- 
 * This file is part of alaqil, which is licensed as a whole under version 3 
 * (or any later version) of the GNU General Public License. Some additional
 * terms also apply to certain portions of alaqil. The full details of the alaqil
 * license and copyrights can be found in the LICENSE and COPYRIGHT files
 * included with the alaqil source code as distributed by the alaqil developers
 * and at http://www.alaqil.org/legal.html.
 *
 * alaqil.h
 *
 * Header file for the alaqil core.
 * ----------------------------------------------------------------------------- */

#ifndef alaqilCORE_H_
#define alaqilCORE_H_

#ifndef MACalaqil
#include "alaqilconfig.h"
#endif

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <assert.h>

#ifdef __cplusplus
extern "C" {
#endif

#include "doh.h"

/* Status codes */

#define alaqil_OK         1
#define alaqil_ERROR      0
#define alaqil_NOWRAP     0

/* Global macros */
#define NSPACE_SEPARATOR "." /* Namespace separator for the nspace feature - this should be changed to a target language configurable variable */
#define NSPACE_TODO 0 /* Languages that still need to implement and test the nspace feature use this */

/* Short names for common data types */

  typedef DOH String;
  typedef DOH Hash;
  typedef DOH List;
  typedef DOH String_or_char;
  typedef DOH File;
  typedef DOH Parm;
  typedef DOH ParmList;
  typedef DOH Node;
  typedef DOH Symtab;
  typedef DOH Typetab;
  typedef DOH alaqilType;

/* --- Legacy DataType interface.  These type codes are provided solely 
       for backwards compatibility with older modules --- */

/* --- The ordering of type values is used to determine type-promotion 
       in the parser.  Do not change */

/* Numeric types */

#define   T_BOOL       1
#define   T_SCHAR      2
#define   T_UCHAR      3
#define   T_SHORT      4
#define   T_USHORT     5
#define   T_ENUM       6
#define   T_INT        7
#define   T_UINT       8
#define   T_LONG       9
#define   T_ULONG      10
#define   T_LONGLONG   11
#define   T_ULONGLONG  12
#define   T_FLOAT      20
#define   T_DOUBLE     21
#define   T_LONGDOUBLE 22
#define   T_FLTCPLX    23
#define   T_DBLCPLX    24
#define   T_NUMERIC    25
#define   T_AUTO       26

#define   T_COMPLEX    T_DBLCPLX

/* non-numeric */

#define   T_CHAR       29
#define   T_WCHAR      30
#define   T_USER       31
#define   T_VOID       32
#define   T_STRING     33
#define   T_POINTER    34
#define   T_REFERENCE  35
#define   T_ARRAY      36
#define   T_FUNCTION   37
#define   T_MPOINTER   38
#define   T_VARARGS    39
#define   T_RVALUE_REFERENCE  40
#define   T_WSTRING    41

#define   T_SYMBOL     98
#define   T_ERROR      99



/* --- File interface --- */

#include "alaqilfile.h"

/* --- Command line parsing --- */

#include "alaqilopt.h"

/* --- Scanner Interface --- */

#include "alaqilscan.h"

/* --- Functions for manipulating the string-based type encoding --- */

  extern alaqilType *NewalaqilType(int typecode);
  extern alaqilType *alaqilType_del_element(alaqilType *t);
  extern alaqilType *alaqilType_add_pointer(alaqilType *t);
  extern alaqilType *alaqilType_add_memberpointer(alaqilType *t, const_String_or_char_ptr qual);
  extern alaqilType *alaqilType_del_memberpointer(alaqilType *t);
  extern alaqilType *alaqilType_del_pointer(alaqilType *t);
  extern alaqilType *alaqilType_add_array(alaqilType *t, const_String_or_char_ptr size);
  extern alaqilType *alaqilType_del_array(alaqilType *t);
  extern alaqilType *alaqilType_pop_arrays(alaqilType *t);
  extern alaqilType *alaqilType_add_reference(alaqilType *t);
  extern alaqilType *alaqilType_del_reference(alaqilType *t);
  extern alaqilType *alaqilType_add_rvalue_reference(alaqilType *t);
  extern alaqilType *alaqilType_del_rvalue_reference(alaqilType *t);
  extern alaqilType *alaqilType_add_qualifier(alaqilType *t, const_String_or_char_ptr qual);
  extern alaqilType *alaqilType_del_qualifier(alaqilType *t);
  extern alaqilType *alaqilType_add_function(alaqilType *t, ParmList *parms);
  extern alaqilType *alaqilType_add_template(alaqilType *t, ParmList *parms);
  extern alaqilType *alaqilType_pop_function(alaqilType *t);
  extern alaqilType *alaqilType_pop_function_qualifiers(alaqilType *t);
  extern ParmList *alaqilType_function_parms(const alaqilType *t, Node *file_line_node);
  extern List *alaqilType_split(const alaqilType *t);
  extern String *alaqilType_pop(alaqilType *t);
  extern void alaqilType_push(alaqilType *t, String *s);
  extern List *alaqilType_parmlist(const alaqilType *p);
  extern String *alaqilType_parm(const alaqilType *p);
  extern String *alaqilType_str(const alaqilType *s, const_String_or_char_ptr id);
  extern String *alaqilType_lstr(const alaqilType *s, const_String_or_char_ptr id);
  extern String *alaqilType_rcaststr(const alaqilType *s, const_String_or_char_ptr id);
  extern String *alaqilType_lcaststr(const alaqilType *s, const_String_or_char_ptr id);
  extern String *alaqilType_manglestr(const alaqilType *t);
  extern alaqilType *alaqilType_ltype(const alaqilType *t);
  extern int alaqilType_ispointer(const alaqilType *t);
  extern int alaqilType_ispointer_return(const alaqilType *t);
  extern int alaqilType_isfunctionpointer(const alaqilType *t);
  extern int alaqilType_ismemberpointer(const alaqilType *t);
  extern int alaqilType_isreference(const alaqilType *t);
  extern int alaqilType_isreference_return(const alaqilType *t);
  extern int alaqilType_isrvalue_reference(const alaqilType *t);
  extern int alaqilType_isarray(const alaqilType *t);
  extern int alaqilType_prefix_is_simple_1D_array(const alaqilType *t);
  extern int alaqilType_isfunction(const alaqilType *t);
  extern int alaqilType_isqualifier(const alaqilType *t);
  extern int alaqilType_isconst(const alaqilType *t);
  extern int alaqilType_issimple(const alaqilType *t);
  extern int alaqilType_ismutable(const alaqilType *t);
  extern int alaqilType_isvarargs(const alaqilType *t);
  extern int alaqilType_istemplate(const alaqilType *t);
  extern int alaqilType_isenum(const alaqilType *t);
  extern int alaqilType_check_decl(const alaqilType *t, const_String_or_char_ptr decl);
  extern alaqilType *alaqilType_strip_qualifiers(const alaqilType *t);
  extern alaqilType *alaqilType_strip_single_qualifier(const alaqilType *t);
  extern alaqilType *alaqilType_functionpointer_decompose(alaqilType *t);
  extern String *alaqilType_base(const alaqilType *t);
  extern String *alaqilType_namestr(const alaqilType *t);
  extern String *alaqilType_templateprefix(const alaqilType *t);
  extern String *alaqilType_templatesuffix(const alaqilType *t);
  extern String *alaqilType_istemplate_templateprefix(const alaqilType *t);
  extern String *alaqilType_istemplate_only_templateprefix(const alaqilType *t);
  extern String *alaqilType_templateargs(const alaqilType *t);
  extern String *alaqilType_prefix(const alaqilType *t);
  extern int alaqilType_array_ndim(const alaqilType *t);
  extern String *alaqilType_array_getdim(const alaqilType *t, int n);
  extern void alaqilType_array_setdim(alaqilType *t, int n, const_String_or_char_ptr rep);
  extern alaqilType *alaqilType_array_type(const alaqilType *t);
  extern alaqilType *alaqilType_default_create(const alaqilType *ty);
  extern alaqilType *alaqilType_default_deduce(const alaqilType *t);
  extern void alaqilType_typename_replace(alaqilType *t, String *pat, String *rep);
  extern alaqilType *alaqilType_remove_global_scope_prefix(const alaqilType *t);
  extern alaqilType *alaqilType_alttype(const alaqilType *t, int ltmap);

/* --- Type-system management --- */
  extern void alaqilType_typesystem_init(void);
  extern int alaqilType_typedef(const alaqilType *type, const_String_or_char_ptr name);
  extern int alaqilType_typedef_class(const_String_or_char_ptr name);
  extern int alaqilType_typedef_using(const_String_or_char_ptr qname);
  extern void alaqilType_inherit(String *subclass, String *baseclass, String *cast, String *conversioncode);
  extern int alaqilType_issubtype(const alaqilType *subtype, const alaqilType *basetype);
  extern void alaqilType_scope_alias(String *aliasname, Typetab *t);
  extern void alaqilType_using_scope(Typetab *t);
  extern void alaqilType_new_scope(const_String_or_char_ptr name);
  extern void alaqilType_inherit_scope(Typetab *scope);
  extern Typetab *alaqilType_pop_scope(void);
  extern Typetab *alaqilType_set_scope(Typetab *h);
  extern void alaqilType_print_scope(void);
  extern alaqilType *alaqilType_typedef_resolve(const alaqilType *t);
  extern alaqilType *alaqilType_typedef_resolve_all(const alaqilType *t);
  extern alaqilType *alaqilType_typedef_qualified(const alaqilType *t);
  extern int alaqilType_istypedef(const alaqilType *t);
  extern int alaqilType_isclass(const alaqilType *t);
  extern void alaqilType_attach_symtab(Symtab *syms);
  extern void alaqilType_remember(const alaqilType *t);
  extern void alaqilType_remember_clientdata(const alaqilType *t, const_String_or_char_ptr clientdata);
  extern void alaqilType_remember_mangleddata(String *mangled, const_String_or_char_ptr clientdata);
  extern void (*alaqilType_remember_trace(void (*tf) (const alaqilType *, String *, String *))) (const alaqilType *, String *, String *);
  extern void alaqilType_emit_type_table(File *f_headers, File *f_table);
  extern int alaqilType_type(const alaqilType *t);

/* --- Symbol table module --- */

  extern void alaqil_symbol_print_tables(Symtab *symtab);
  extern void alaqil_symbol_print_tables_summary(void);
  extern void alaqil_symbol_print_symbols(void);
  extern void alaqil_symbol_print_csymbols(void);
  extern void alaqil_symbol_init(void);
  extern void alaqil_symbol_setscopename(const_String_or_char_ptr name);
  extern String *alaqil_symbol_getscopename(void);
  extern String *alaqil_symbol_qualifiedscopename(Symtab *symtab);
  extern String *alaqil_symbol_qualified_language_scopename(Symtab *symtab);
  extern Symtab *alaqil_symbol_newscope(void);
  extern Symtab *alaqil_symbol_setscope(Symtab *);
  extern Symtab *alaqil_symbol_getscope(const_String_or_char_ptr symname);
  extern Symtab *alaqil_symbol_global_scope(void);
  extern Symtab *alaqil_symbol_current(void);
  extern Symtab *alaqil_symbol_popscope(void);
  extern Node *alaqil_symbol_add(const_String_or_char_ptr symname, Node *node);
  extern void alaqil_symbol_cadd(const_String_or_char_ptr symname, Node *node);
  extern Node *alaqil_symbol_clookup(const_String_or_char_ptr symname, Symtab *tab);
  extern Node *alaqil_symbol_clookup_check(const_String_or_char_ptr symname, Symtab *tab, int (*check) (Node *));
  extern Node *alaqil_symbol_clookup_no_inherit(const_String_or_char_ptr name, Symtab *n);
  extern Symtab *alaqil_symbol_cscope(const_String_or_char_ptr symname, Symtab *tab);
  extern Node *alaqil_symbol_clookup_local(const_String_or_char_ptr symname, Symtab *tab);
  extern Node *alaqil_symbol_clookup_local_check(const_String_or_char_ptr symname, Symtab *tab, int (*check) (Node *));
  extern String *alaqil_symbol_qualified(Node *node);
  extern Node *alaqil_symbol_isoverloaded(Node *node);
  extern void alaqil_symbol_remove(Node *node);
  extern void alaqil_symbol_alias(const_String_or_char_ptr aliasname, Symtab *tab);
  extern void alaqil_symbol_inherit(Symtab *tab);
  extern alaqilType *alaqil_symbol_type_qualify(const alaqilType *ty, Symtab *tab);
  extern String *alaqil_symbol_string_qualify(String *s, Symtab *tab);
  extern alaqilType *alaqil_symbol_typedef_reduce(const alaqilType *ty, Symtab *tab);

  extern ParmList *alaqil_symbol_template_defargs(Parm *parms, Parm *targs, Symtab *tscope, Symtab *tsdecl);
  extern alaqilType *alaqil_symbol_template_deftype(const alaqilType *type, Symtab *tscope);
  extern alaqilType *alaqil_symbol_template_param_eval(const alaqilType *p, Symtab *symtab);

/* --- Parameters and Parameter Lists --- */

#include "alaqilparm.h"

extern String    *ParmList_errorstr(ParmList *);
extern int        ParmList_is_compactdefargs(ParmList *p);

/* --- Parse tree support --- */

#include "alaqiltree.h"

/* -- Wrapper function Object */

#include "alaqilwrap.h"

/* --- Naming functions --- */

  extern void alaqil_name_register(const_String_or_char_ptr method, const_String_or_char_ptr format);
  extern void alaqil_name_unregister(const_String_or_char_ptr method);
  extern String *alaqil_name_mangle(const_String_or_char_ptr s);
  extern String *alaqil_name_wrapper(const_String_or_char_ptr fname);
  extern String *alaqil_name_member(const_String_or_char_ptr nspace, const_String_or_char_ptr classname, const_String_or_char_ptr membername);
  extern String *alaqil_name_get(const_String_or_char_ptr nspace, const_String_or_char_ptr vname);
  extern String *alaqil_name_set(const_String_or_char_ptr nspace, const_String_or_char_ptr vname);
  extern String *alaqil_name_construct(const_String_or_char_ptr nspace, const_String_or_char_ptr classname);
  extern String *alaqil_name_copyconstructor(const_String_or_char_ptr nspace, const_String_or_char_ptr classname);
  extern String *alaqil_name_destroy(const_String_or_char_ptr nspace, const_String_or_char_ptr classname);
  extern String *alaqil_name_disown(const_String_or_char_ptr nspace, const_String_or_char_ptr classname);

  extern void alaqil_naming_init(void);
  extern void alaqil_name_namewarn_add(String *prefix, String *name, alaqilType *decl, Hash *namewrn);
  extern void alaqil_name_rename_add(String *prefix, String *name, alaqilType *decl, Hash *namewrn, ParmList *declaratorparms);
  extern void alaqil_name_inherit(String *base, String *derived);
  extern List *alaqil_make_inherit_list(String *clsname, List *names, String *Namespaceprefix);
  extern void alaqil_inherit_base_symbols(List *bases);
  extern int alaqil_need_protected(Node *n);
  extern int alaqil_need_redefined_warn(Node *a, Node *b, int InClass);

  extern String *alaqil_name_make(Node *n, String *prefix, const_String_or_char_ptr cname, alaqilType *decl, String *oldname);
  extern String *alaqil_name_warning(Node *n, String *prefix, String *name, alaqilType *decl);
  extern String *alaqil_name_str(Node *n);
  extern String *alaqil_name_decl(Node *n);
  extern String *alaqil_name_fulldecl(Node *n);

/* --- parameterized rename functions --- */

  extern void alaqil_name_object_set(Hash *namehash, String *name, alaqilType *decl, DOH *object);
  extern DOH *alaqil_name_object_get(Hash *namehash, String *prefix, String *name, alaqilType *decl);
  extern void alaqil_name_object_inherit(Hash *namehash, String *base, String *derived);
  extern void alaqil_features_get(Hash *features, String *prefix, String *name, alaqilType *decl, Node *n);
  extern void alaqil_feature_set(Hash *features, const_String_or_char_ptr name, alaqilType *decl, const_String_or_char_ptr featurename, const_String_or_char_ptr value, Hash *featureattribs);

/* --- Misc --- */
  extern char *alaqil_copy_string(const char *c);
  extern void alaqil_set_fakeversion(const char *version);
  extern const char *alaqil_package_version(void);
  extern void alaqil_banner(File *f);
  extern void alaqil_banner_target_lang(File *f, const_String_or_char_ptr commentchar);
  extern String *alaqil_strip_c_comments(const String *s);
  extern String *alaqil_new_subdirectory(String *basedirectory, String *subdirectory);
  extern void alaqil_filename_correct(String *filename);
  extern String *alaqil_filename_escape(String *filename);
  extern void alaqil_filename_unescape(String *filename);
  extern int alaqil_storage_isextern(Node *n);
  extern int alaqil_storage_isexternc(Node *n);
  extern int alaqil_storage_isstatic_custom(Node *n, const_String_or_char_ptr storage);
  extern int alaqil_storage_isstatic(Node *n);
  extern String *alaqil_string_escape(String *s);
  extern String *alaqil_string_mangle(const String *s);
  extern void alaqil_scopename_split(const String *s, String **prefix, String **last);
  extern String *alaqil_scopename_prefix(const String *s);
  extern String *alaqil_scopename_last(const String *s);
  extern String *alaqil_scopename_first(const String *s);
  extern String *alaqil_scopename_suffix(const String *s);
  extern List *alaqil_scopename_tolist(const String *s);
  extern int alaqil_scopename_check(const String *s);
  extern String *alaqil_string_lower(String *s);
  extern String *alaqil_string_upper(String *s);
  extern String *alaqil_string_title(String *s);
  extern void alaqil_offset_string(String *s, int number);
  extern String *alaqil_pcre_version(void);
  extern void alaqil_init(void);

  extern int alaqil_value_wrapper_mode(int mode);
  extern int alaqil_is_generated_overload(Node *n);

  typedef enum { EMF_STANDARD, EMF_MICROSOFT } ErrorMessageFormat;

  extern void alaqil_warning(int num, const_String_or_char_ptr filename, int line, const char *fmt, ...);
  extern void alaqil_error(const_String_or_char_ptr filename, int line, const char *fmt, ...);
  extern int alaqil_error_count(void);
  extern void alaqil_error_silent(int s);
  extern void alaqil_warnfilter(const_String_or_char_ptr wlist, int val);
  extern void alaqil_warnall(void);
  extern int alaqil_warn_count(void);
  extern void alaqil_error_msg_format(ErrorMessageFormat format);
  extern void alaqil_diagnostic(const_String_or_char_ptr filename, int line, const char *fmt, ...);
  extern String *alaqil_stringify_with_location(DOH *object);

/* --- C Wrappers --- */
  extern void alaqil_cresult_name_set(const char *new_name);
  extern const char *alaqil_cresult_name(void);
  extern String *alaqil_cparm_name(Parm *p, int i);
  extern String *alaqil_wrapped_var_type(alaqilType *t, int varcref);
  extern int alaqil_cargs(Wrapper *w, ParmList *l);
  extern String *alaqil_cresult(alaqilType *t, const_String_or_char_ptr name, const_String_or_char_ptr decl);

  extern String *alaqil_cfunction_call(const_String_or_char_ptr name, ParmList *parms);
  extern String *alaqil_cconstructor_call(const_String_or_char_ptr name);
  extern String *alaqil_cppconstructor_call(const_String_or_char_ptr name, ParmList *parms);
  extern String *alaqil_unref_call(Node *n);
  extern String *alaqil_ref_call(Node *n, const String *lname);
  extern String *alaqil_cdestructor_call(Node *n);
  extern String *alaqil_cppdestructor_call(Node *n);
  extern String *alaqil_cmemberset_call(const_String_or_char_ptr name, alaqilType *type, String *self, int varcref);
  extern String *alaqil_cmemberget_call(const_String_or_char_ptr name, alaqilType *t, String *self, int varcref);

  extern int alaqil_add_extension_code(Node *n, const String *function_name, ParmList *parms, alaqilType *return_type, const String *code, int cplusplus, const String *self);
  extern void alaqil_replace_special_variables(Node *n, Node *parentnode, String *code);

/* --- Transformations --- */

  extern int alaqil_MethodToFunction(Node *n, const_String_or_char_ptr nspace, String *classname, int flags, alaqilType *director_type, int is_director);
  extern int alaqil_ConstructorToFunction(Node *n, const_String_or_char_ptr nspace, String *classname, String *none_comparison, String *director_ctor, int cplus, int flags, String *directorname);
  extern int alaqil_DestructorToFunction(Node *n, const_String_or_char_ptr nspace, String *classname, int cplus, int flags);
  extern int alaqil_MembersetToFunction(Node *n, String *classname, int flags);
  extern int alaqil_MembergetToFunction(Node *n, String *classname, int flags);
  extern int alaqil_VargetToFunction(Node *n, int flags);
  extern int alaqil_VarsetToFunction(Node *n, int flags);

#define  CWRAP_EXTEND                 0x01
#define  CWRAP_SMART_POINTER          0x02
#define  CWRAP_NATURAL_VAR            0x04
#define  CWRAP_DIRECTOR_ONE_CALL      0x08
#define  CWRAP_DIRECTOR_TWO_CALLS     0x10
#define  CWRAP_ALL_PROTECTED_ACCESS   0x20
#define  CWRAP_SMART_POINTER_OVERLOAD 0x40

/* --- Director Helpers --- */
  extern Node *alaqil_methodclass(Node *n);
  extern int alaqil_directorclass(Node *n);
  extern Node *alaqil_directormap(Node *n, String *type);

/* --- Legacy Typemap API (somewhat simplified, ha!) --- */

  extern void alaqil_typemap_init(void);
  extern void alaqil_typemap_register(const_String_or_char_ptr tmap_method, ParmList *pattern, const_String_or_char_ptr code, ParmList *locals, ParmList *kwargs);
  extern int alaqil_typemap_copy(const_String_or_char_ptr tmap_method, ParmList *srcpattern, ParmList *pattern);
  extern void alaqil_typemap_clear(const_String_or_char_ptr tmap_method, ParmList *pattern);
  extern int alaqil_typemap_apply(ParmList *srcpat, ParmList *destpat);
  extern void alaqil_typemap_clear_apply(ParmList *pattern);
  extern void alaqil_typemap_replace_embedded_typemap(String *s, Node *file_line_node);
  extern void alaqil_typemap_debug(void);
  extern void alaqil_typemap_search_debug_set(void);
  extern void alaqil_typemap_used_debug_set(void);
  extern void alaqil_typemap_register_debug_set(void);

  extern String *alaqil_typemap_lookup(const_String_or_char_ptr tmap_method, Node *n, const_String_or_char_ptr lname, Wrapper *f);
  extern String *alaqil_typemap_lookup_out(const_String_or_char_ptr tmap_method, Node *n, const_String_or_char_ptr lname, Wrapper *f, String *actioncode);

  extern void alaqil_typemap_attach_parms(const_String_or_char_ptr tmap_method, ParmList *parms, Wrapper *f);

/* --- Code fragment support --- */

  extern void alaqil_fragment_register(Node *fragment);
  extern void alaqil_fragment_emit(String *name);
  extern void alaqil_fragment_clear(String *section);

/* --- Extension support --- */

  extern Hash *alaqil_extend_hash(void);
  extern void alaqil_extend_merge(Node *cls, Node *am);
  extern void alaqil_extend_append_previous(Node *cls, Node *am);
  extern void alaqil_extend_unused_check(void);

/* hacks defined in C++ ! */
  extern int alaqil_director_mode(void);
  extern int alaqil_director_protected_mode(void);
  extern int alaqil_all_protected_mode(void);
  extern void Wrapper_director_mode_set(int);
  extern void Wrapper_director_protected_mode_set(int);
  extern void Wrapper_all_protected_mode_set(int);
  extern void Language_replace_special_variables(String *method, String *tm, Parm *parm);
  extern void alaqil_print(DOH *object, int count);
  extern void alaqil_print_with_location(DOH *object, int count);


/* -- template init -- */
  extern void alaqilType_template_init(void);


#ifdef __cplusplus
}
#endif
#endif
