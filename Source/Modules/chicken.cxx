/* -----------------------------------------------------------------------------
 * This file is part of alaqil, which is licensed as a whole under version 3 
 * (or any later version) of the GNU General Public License. Some additional
 * terms also apply to certain portions of alaqil. The full details of the alaqil
 * license and copyrights can be found in the LICENSE and COPYRIGHT files
 * included with the alaqil source code as distributed by the alaqil developers
 * and at http://www.alaqil.org/legal.html.
 *
 * chicken.cxx
 *
 * CHICKEN language module for alaqil.
 * ----------------------------------------------------------------------------- */

#include "alaqilmod.h"

#include <ctype.h>

static const char *usage = "\
\
CHICKEN Options (available with -chicken)\n\
     -closprefix <prefix>   - Prepend <prefix> to all clos identifiers\n\
     -noclosuses            - Do not (declare (uses ...)) in scheme file\n\
     -nocollection          - Do not register pointers with chicken garbage\n\
                              collector and export destructors\n\
     -nounit                - Do not (declare (unit ...)) in scheme file\n\
     -proxy                 - Export TinyCLOS class definitions\n\
     -unhideprimitive       - Unhide the primitive: symbols\n\
     -useclassprefix        - Prepend the class name to all clos identifiers\n\
\n";

static char *module = 0;
static const char *chicken_path = "chicken";
static int num_methods = 0;

static File *f_begin = 0;
static File *f_runtime = 0;
static File *f_header = 0;
static File *f_wrappers = 0;
static File *f_init = 0;
static String *chickentext = 0;
static String *closprefix = 0;
static String *alaqiltype_ptr = 0;


static String *f_sym_size = 0;

/* some options */
static int declare_unit = 1;
static int no_collection = 0;
static int clos_uses = 1;

/* C++ Support + Clos Classes */
static int clos = 0;
static String *c_class_name = 0;
static String *class_name = 0;
static String *short_class_name = 0;

static int in_class = 0;
static int have_constructor = 0;
static bool exporting_destructor = false;
static bool exporting_constructor = false;
static String *constructor_name = 0;
static String *member_name = 0;

/* sections of the .scm code */
static String *scm_const_defs = 0;
static String *clos_class_defines = 0;
static String *clos_methods = 0;

/* Some clos options */
static int useclassprefix = 0;
static String *clossymnameprefix = 0;
static int hide_primitive = 1;
static Hash *primitive_names = 0;

/* Used for overloading constructors */
static int has_constructor_args = 0;
static List *constructor_arg_types = 0;
static String *constructor_dispatch = 0;

static Hash *overload_parameter_lists = 0;

class CHICKEN:public Language {
public:

  virtual void main(int argc, char *argv[]);
  virtual int top(Node *n);
  virtual int functionWrapper(Node *n);
  virtual int variableWrapper(Node *n);
  virtual int constantWrapper(Node *n);
  virtual int classHandler(Node *n);
  virtual int memberfunctionHandler(Node *n);
  virtual int membervariableHandler(Node *n);
  virtual int constructorHandler(Node *n);
  virtual int destructorHandler(Node *n);
  virtual int validIdentifier(String *s);
  virtual int staticmembervariableHandler(Node *n);
  virtual int staticmemberfunctionHandler(Node *n);
  virtual int importDirective(Node *n);

protected:
  void addMethod(String *scheme_name, String *function);
  /* Return true iff T is a pointer type */
  int isPointer(alaqilType *t);
  void dispatchFunction(Node *n);

  String *chickenNameMapping(String *, const_String_or_char_ptr );
  String *chickenPrimitiveName(String *);

  String *runtimeCode();
  String *defaultExternalRuntimeFilename();
  String *buildClosFunctionCall(List *types, const_String_or_char_ptr closname, const_String_or_char_ptr funcname);
};

/* -----------------------------------------------------------------------
 * alaqil_chicken()    - Instantiate module
 * ----------------------------------------------------------------------- */

static Language *new_alaqil_chicken() {
  return new CHICKEN();
}

extern "C" {
  Language *alaqil_chicken(void) {
    return new_alaqil_chicken();
  }
}

void CHICKEN::main(int argc, char *argv[]) {
  int i;

  alaqil_library_directory(chicken_path);

  // Look for certain command line options
  for (i = 1; i < argc; i++) {
    if (argv[i]) {
      if (strcmp(argv[i], "-help") == 0) {
	fputs(usage, stdout);
	alaqil_exit(0);
      } else if (strcmp(argv[i], "-proxy") == 0) {
	clos = 1;
	alaqil_mark_arg(i);
      } else if (strcmp(argv[i], "-closprefix") == 0) {
	if (argv[i + 1]) {
	  clossymnameprefix = NewString(argv[i + 1]);
	  alaqil_mark_arg(i);
	  alaqil_mark_arg(i + 1);
	  i++;
	} else {
	  alaqil_arg_error();
	}
      } else if (strcmp(argv[i], "-useclassprefix") == 0) {
	useclassprefix = 1;
	alaqil_mark_arg(i);
      } else if (strcmp(argv[i], "-unhideprimitive") == 0) {
	hide_primitive = 0;
	alaqil_mark_arg(i);
      } else if (strcmp(argv[i], "-nounit") == 0) {
	declare_unit = 0;
	alaqil_mark_arg(i);
      } else if (strcmp(argv[i], "-noclosuses") == 0) {
	clos_uses = 0;
	alaqil_mark_arg(i);
      } else if (strcmp(argv[i], "-nocollection") == 0) {
	no_collection = 1;
	alaqil_mark_arg(i);
      }
    }
  }

  if (!clos)
    hide_primitive = 0;

  // Add a symbol for this module
  Preprocessor_define("alaqilCHICKEN 1", 0);

  // Set name of typemaps

  alaqil_typemap_lang("chicken");

  // Read in default typemaps */
  alaqil_config_file("chicken.swg");
  allow_overloading();
}

int CHICKEN::top(Node *n) {
  String *chicken_filename = NewString("");
  File *f_scm;
  String *scmmodule;

  /* Initialize all of the output files */
  String *outfile = Getattr(n, "outfile");

  f_begin = NewFile(outfile, "w", alaqil_output_files());
  if (!f_begin) {
    FileErrorDisplay(outfile);
    alaqil_exit(EXIT_FAILURE);
  }
  f_runtime = NewString("");
  f_init = NewString("");
  f_header = NewString("");
  f_wrappers = NewString("");
  chickentext = NewString("");
  closprefix = NewString("");
  f_sym_size = NewString("");
  primitive_names = NewHash();
  overload_parameter_lists = NewHash();

  /* Register file targets with the alaqil file handler */
  alaqil_register_filebyname("header", f_header);
  alaqil_register_filebyname("wrapper", f_wrappers);
  alaqil_register_filebyname("begin", f_begin);
  alaqil_register_filebyname("runtime", f_runtime);
  alaqil_register_filebyname("init", f_init);

  alaqil_register_filebyname("chicken", chickentext);
  alaqil_register_filebyname("closprefix", closprefix);

  clos_class_defines = NewString("");
  clos_methods = NewString("");
  scm_const_defs = NewString("");

  alaqil_banner(f_begin);

  Printf(f_runtime, "\n\n#ifndef alaqilCHICKEN\n#define alaqilCHICKEN\n#endif\n\n");

  if (no_collection)
    Printf(f_runtime, "#define alaqil_CHICKEN_NO_COLLECTION 1\n");

  Printf(f_runtime, "\n");

  /* Set module name */
  module = alaqil_copy_string(Char(Getattr(n, "name")));
  scmmodule = NewString(module);
  Replaceall(scmmodule, "_", "-");

  Printf(f_header, "#define alaqil_init alaqil_%s_init\n", module);
  Printf(f_header, "#define alaqil_name \"%s\"\n", scmmodule);

  Printf(f_wrappers, "#ifdef __cplusplus\n");
  Printf(f_wrappers, "extern \"C\" {\n");
  Printf(f_wrappers, "#endif\n\n");

  Language::top(n);

  alaqilType_emit_type_table(f_runtime, f_wrappers);

  Printf(f_wrappers, "#ifdef __cplusplus\n");
  Printf(f_wrappers, "}\n");
  Printf(f_wrappers, "#endif\n");

  Printf(f_init, "C_kontinue (continuation, ret);\n");
  Printf(f_init, "}\n\n");

  Printf(f_init, "#ifdef __cplusplus\n");
  Printf(f_init, "}\n");
  Printf(f_init, "#endif\n");

  Printf(chicken_filename, "%s%s.scm", alaqil_output_directory(), module);
  if ((f_scm = NewFile(chicken_filename, "w", alaqil_output_files())) == 0) {
    FileErrorDisplay(chicken_filename);
    alaqil_exit(EXIT_FAILURE);
  }

  alaqil_banner_target_lang(f_scm, ";;");
  Printf(f_scm, "\n");

  if (declare_unit)
    Printv(f_scm, "(declare (unit ", scmmodule, "))\n\n", NIL);
  Printv(f_scm, "(declare \n",
	 tab4, "(hide alaqil-init alaqil-init-return)\n",
	 tab4, "(foreign-declare \"C_extern void alaqil_", module, "_init(C_word,C_word,C_word) C_noret;\"))\n", NIL);
  Printv(f_scm, "(define alaqil-init (##core#primitive \"alaqil_", module, "_init\"))\n", NIL);
  Printv(f_scm, "(define alaqil-init-return (alaqil-init))\n\n", NIL);

  if (clos) {
    //Printf (f_scm, "(declare (uses tinyclos))\n");
    //New chicken versions have tinyclos as an egg
    Printf(f_scm, "(require-extension tinyclos)\n");
    Replaceall(closprefix, "$module", scmmodule);
    Printf(f_scm, "%s\n", closprefix);
    Printf(f_scm, "%s\n", clos_class_defines);
    Printf(f_scm, "%s\n", clos_methods);
  } else {
    Printf(f_scm, "%s\n", scm_const_defs);
  }

  Printf(f_scm, "%s\n", chickentext);

  Delete(f_scm);

  char buftmp[20];
  sprintf(buftmp, "%d", num_methods);
  Replaceall(f_init, "$nummethods", buftmp);
  Replaceall(f_init, "$symsize", f_sym_size);

  if (hide_primitive)
    Replaceall(f_init, "$veclength", buftmp);
  else
    Replaceall(f_init, "$veclength", "0");

  Delete(chicken_filename);
  Delete(chickentext);
  Delete(closprefix);
  Delete(overload_parameter_lists);

  Delete(clos_class_defines);
  Delete(clos_methods);
  Delete(scm_const_defs);

  /* Close all of the files */
  Delete(primitive_names);
  Delete(scmmodule);
  Dump(f_runtime, f_begin);
  Dump(f_header, f_begin);
  Dump(f_wrappers, f_begin);
  Wrapper_pretty_print(f_init, f_begin);
  Delete(f_header);
  Delete(f_wrappers);
  Delete(f_sym_size);
  Delete(f_init);
  Delete(f_runtime);
  Delete(f_begin);
  return alaqil_OK;
}

int CHICKEN::functionWrapper(Node *n) {

  String *name = Getattr(n, "name");
  String *iname = Getattr(n, "sym:name");
  alaqilType *d = Getattr(n, "type");
  ParmList *l = Getattr(n, "parms");

  Parm *p;
  int i;
  String *wname;
  Wrapper *f;
  String *mangle = NewString("");
  String *get_pointers;
  String *cleanup;
  String *argout;
  String *tm;
  String *overname = 0;
  String *declfunc = 0;
  String *scmname;
  bool any_specialized_arg = false;
  List *function_arg_types = NewList();

  int num_required;
  int num_arguments;
  int have_argout;

  Printf(mangle, "\"%s\"", alaqilType_manglestr(d));

  if (Getattr(n, "sym:overloaded")) {
    overname = Getattr(n, "sym:overname");
  } else {
    if (!addSymbol(iname, n))
      return alaqil_ERROR;
  }

  f = NewWrapper();
  wname = NewString("");
  get_pointers = NewString("");
  cleanup = NewString("");
  argout = NewString("");
  declfunc = NewString("");
  scmname = NewString(iname);
  Replaceall(scmname, "_", "-");

  /* Local vars */
  Wrapper_add_local(f, "resultobj", "C_word resultobj");

  /* Write code to extract function parameters. */
  emit_parameter_variables(l, f);

  /* Attach the standard typemaps */
  emit_attach_parmmaps(l, f);
  Setattr(n, "wrap:parms", l);

  /* Get number of required and total arguments */
  num_arguments = emit_num_arguments(l);
  num_required = emit_num_required(l);

  Append(wname, alaqil_name_wrapper(iname));
  if (overname) {
    Append(wname, overname);
  }
  // Check for interrupts
  Printv(f->code, "C_trace(\"", scmname, "\");\n", NIL);

  Printv(f->def, "static ", "void ", wname, " (C_word argc, C_word closure, C_word continuation", NIL);
  Printv(declfunc, "void ", wname, "(C_word,C_word,C_word", NIL);

  /* Generate code for argument marshalling */
  for (i = 0, p = l; i < num_arguments; i++) {

    while (checkAttribute(p, "tmap:in:numinputs", "0")) {
      p = Getattr(p, "tmap:in:next");
    }

    alaqilType *pt = Getattr(p, "type");
    String *ln = Getattr(p, "lname");

    Printf(f->def, ", C_word scm%d", i + 1);
    Printf(declfunc, ",C_word");

    /* Look for an input typemap */
    if ((tm = Getattr(p, "tmap:in"))) {
      String *parse = Getattr(p, "tmap:in:parse");
      if (!parse) {
        String *source = NewStringf("scm%d", i + 1);
	Replaceall(tm, "$source", source);
	Replaceall(tm, "$target", ln);
	Replaceall(tm, "$input", source);
	Setattr(p, "emit:input", source);	/* Save the location of
						   the object */

	if (Getattr(p, "wrap:disown") || (Getattr(p, "tmap:in:disown"))) {
	  Replaceall(tm, "$disown", "alaqil_POINTER_DISOWN");
	} else {
	  Replaceall(tm, "$disown", "0");
	}

	if (i >= num_required)
	  Printf(get_pointers, "if (argc-2>%i && (%s)) {\n", i, source);
	Printv(get_pointers, tm, "\n", NIL);
	if (i >= num_required)
	  Printv(get_pointers, "}\n", NIL);

	if (clos) {
	  if (i < num_required) {
	    if (strcmp("void", Char(pt)) != 0) {
	      Node *class_node = 0;
	      String *clos_code = Getattr(p, "tmap:in:closcode");
	      class_node = classLookup(pt);
	      if (clos_code && class_node) {
		String *class_name = NewStringf("<%s>", Getattr(class_node, "sym:name"));
		Replaceall(class_name, "_", "-");
		Append(function_arg_types, class_name);
		Append(function_arg_types, Copy(clos_code));
		any_specialized_arg = true;
		Delete(class_name);
	      } else {
		Append(function_arg_types, "<top>");
		Append(function_arg_types, "$input");
	      }
	    }
	  }
	}
        Delete(source);
      }

      p = Getattr(p, "tmap:in:next");
      continue;
    } else {
      alaqil_warning(WARN_TYPEMAP_IN_UNDEF, input_file, line_number, "Unable to use type %s as a function argument.\n", alaqilType_str(pt, 0));
      break;
    }
  }

  /* finish argument marshalling */

  Printf(f->def, ") {");
  Printf(declfunc, ")");

  if (num_required != num_arguments) {
    Append(function_arg_types, "^^##optional$$");
  }

  /* First check the number of arguments is correct */
  if (num_arguments != num_required)
    Printf(f->code, "if (argc-2<%i || argc-2>%i) C_bad_argc(argc,%i);\n", num_required, num_arguments, num_required + 2);
  else
    Printf(f->code, "if (argc!=%i) C_bad_argc(argc,%i);\n", num_arguments + 2, num_arguments + 2);

  /* Now piece together the first part of the wrapper function */
  Printv(f->code, get_pointers, NIL);

  /* Insert constraint checking code */
  for (p = l; p;) {
    if ((tm = Getattr(p, "tmap:check"))) {
      Replaceall(tm, "$target", Getattr(p, "lname"));
      Printv(f->code, tm, "\n", NIL);
      p = Getattr(p, "tmap:check:next");
    } else {
      p = nextSibling(p);
    }
  }

  /* Insert cleanup code */
  for (p = l; p;) {
    if ((tm = Getattr(p, "tmap:freearg"))) {
      Replaceall(tm, "$source", Getattr(p, "lname"));
      Printv(cleanup, tm, "\n", NIL);
      p = Getattr(p, "tmap:freearg:next");
    } else {
      p = nextSibling(p);
    }
  }

  /* Insert argument output code */
  have_argout = 0;
  for (p = l; p;) {
    if ((tm = Getattr(p, "tmap:argout"))) {

      if (!have_argout) {
	have_argout = 1;
	// Print initial argument output code
	Printf(argout, "alaqil_Chicken_SetupArgout\n");
      }

      Replaceall(tm, "$source", Getattr(p, "lname"));
      Replaceall(tm, "$target", "resultobj");
      Replaceall(tm, "$arg", Getattr(p, "emit:input"));
      Replaceall(tm, "$input", Getattr(p, "emit:input"));
      Printf(argout, "%s", tm);
      p = Getattr(p, "tmap:argout:next");
    } else {
      p = nextSibling(p);
    }
  }

  Setattr(n, "wrap:name", wname);

  /* Emit the function call */
  String *actioncode = emit_action(n);

  /* Return the function value */
  if ((tm = alaqil_typemap_lookup_out("out", n, alaqil_cresult_name(), f, actioncode))) {
    Replaceall(tm, "$source", alaqil_cresult_name());
    Replaceall(tm, "$target", "resultobj");
    Replaceall(tm, "$result", "resultobj");
    if (GetFlag(n, "feature:new")) {
      Replaceall(tm, "$owner", "1");
    } else {
      Replaceall(tm, "$owner", "0");
    }

    Printf(f->code, "%s", tm);

    if (have_argout)
      Printf(f->code, "\nalaqil_APPEND_VALUE(resultobj);\n");

  } else {
    alaqil_warning(WARN_TYPEMAP_OUT_UNDEF, input_file, line_number, "Unable to use return type %s in function %s.\n", alaqilType_str(d, 0), name);
  }
  emit_return_variable(n, d, f);

  /* Insert the argumetn output code */
  Printv(f->code, argout, NIL);

  /* Output cleanup code */
  Printv(f->code, cleanup, NIL);

  /* Look to see if there is any newfree cleanup code */
  if (GetFlag(n, "feature:new")) {
    if ((tm = alaqil_typemap_lookup("newfree", n, alaqil_cresult_name(), 0))) {
      Replaceall(tm, "$source", alaqil_cresult_name());
      Printf(f->code, "%s\n", tm);
    }
  }

  /* See if there is any return cleanup code */
  if ((tm = alaqil_typemap_lookup("ret", n, alaqil_cresult_name(), 0))) {
    Replaceall(tm, "$source", alaqil_cresult_name());
    Printf(f->code, "%s\n", tm);
  }


  if (have_argout) {
    Printf(f->code, "C_kontinue(continuation,C_SCHEME_END_OF_LIST);\n");
  } else {
    if (exporting_constructor && clos && hide_primitive) {
      /* Don't return a proxy, the wrapped CLOS class is the proxy */
      Printf(f->code, "C_kontinue(continuation,resultobj);\n");
    } else {
      // make the continuation the proxy creation function, if one exists
      Printv(f->code, "{\n",
	     "C_word func;\n",
	     "alaqil_Chicken_FindCreateProxy(func, resultobj)\n",
	     "if (C_alaqil_is_closurep(func))\n",
	     "  ((C_proc4)(void *)C_block_item(func, 0))(4,func,continuation,resultobj,C_SCHEME_FALSE);\n",
	     "else\n", "  C_kontinue(continuation, resultobj);\n", "}\n", NIL);
    }
  }

  /* Error handling code */
#ifdef USE_FAIL
  Printf(f->code, "fail:\n");
  Printv(f->code, cleanup, NIL);
  Printf(f->code, "alaqil_panic (\"failure in " "'$symname' alaqil function wrapper\");\n");
#endif
  Printf(f->code, "}\n");

  /* Substitute the cleanup code */
  Replaceall(f->code, "$cleanup", cleanup);

  /* Substitute the function name */
  Replaceall(f->code, "$symname", iname);
  Replaceall(f->code, "$result", "resultobj");

  /* Dump the function out */
  Printv(f_wrappers, "static ", declfunc, " C_noret;\n", NIL);
  Wrapper_print(f, f_wrappers);

  /* Now register the function with the interpreter.   */
  if (!Getattr(n, "sym:overloaded")) {
    if (exporting_destructor && !no_collection) {
      Printf(f_init, "((alaqil_chicken_clientdata *)(alaqilTYPE%s->clientdata))->destroy = (alaqil_chicken_destructor) %s;\n", alaqiltype_ptr, wname);
    } else {
      addMethod(scmname, wname);
    }

    /* Only export if we are not in a class, or if in a class memberfunction */
    if (!in_class || member_name) {
      String *method_def;
      String *clos_name;
      if (in_class)
	clos_name = NewString(member_name);
      else
	clos_name = chickenNameMapping(scmname, "");

      if (!any_specialized_arg) {
	method_def = NewString("");
	Printv(method_def, "(define ", clos_name, " ", chickenPrimitiveName(scmname), ")", NIL);
      } else {
	method_def = buildClosFunctionCall(function_arg_types, clos_name, chickenPrimitiveName(scmname));
      }
      Printv(clos_methods, method_def, "\n", NIL);
      Delete(clos_name);
      Delete(method_def);
    }

    if (have_constructor && !has_constructor_args && any_specialized_arg) {
      has_constructor_args = 1;
      constructor_arg_types = Copy(function_arg_types);
    }
  } else {
    /* add function_arg_types to overload hash */
    List *flist = Getattr(overload_parameter_lists, scmname);
    if (!flist) {
      flist = NewList();
      Setattr(overload_parameter_lists, scmname, flist);
    }

    Append(flist, Copy(function_arg_types));

    if (!Getattr(n, "sym:nextSibling")) {
      dispatchFunction(n);
    }
  }


  Delete(wname);
  Delete(get_pointers);
  Delete(cleanup);
  Delete(declfunc);
  Delete(mangle);
  Delete(function_arg_types);
  DelWrapper(f);
  return alaqil_OK;
}

int CHICKEN::variableWrapper(Node *n) {
  char *name = GetChar(n, "name");
  char *iname = GetChar(n, "sym:name");
  alaqilType *t = Getattr(n, "type");
  ParmList *l = Getattr(n, "parms");

  String *wname = NewString("");
  String *mangle = NewString("");
  String *tm;
  String *tm2 = NewString("");
  String *argnum = NewString("0");
  String *arg = NewString("argv[0]");
  Wrapper *f;
  String *overname = 0;
  String *scmname;

  scmname = NewString(iname);
  Replaceall(scmname, "_", "-");

  Printf(mangle, "\"%s\"", alaqilType_manglestr(t));

  if (Getattr(n, "sym:overloaded")) {
    overname = Getattr(n, "sym:overname");
  } else {
    if (!addSymbol(iname, n))
      return alaqil_ERROR;
  }

  f = NewWrapper();

  /* Attach the standard typemaps */
  emit_attach_parmmaps(l, f);
  Setattr(n, "wrap:parms", l);

  // evaluation function names
  Append(wname, alaqil_name_wrapper(iname));
  if (overname) {
    Append(wname, overname);
  }
  Setattr(n, "wrap:name", wname);

  // Check for interrupts
  Printv(f->code, "C_trace(\"", scmname, "\");\n", NIL);

  if (1 || (alaqilType_type(t) != T_USER) || (isPointer(t))) {

    Printv(f->def, "static ", "void ", wname, "(C_word, C_word, C_word, C_word) C_noret;\n", NIL);
    Printv(f->def, "static " "void ", wname, "(C_word argc, C_word closure, " "C_word continuation, C_word value) {\n", NIL);

    Wrapper_add_local(f, "resultobj", "C_word resultobj");

    Printf(f->code, "if (argc!=2 && argc!=3) C_bad_argc(argc,2);\n");

    /* Check for a setting of the variable value */
    if (!GetFlag(n, "feature:immutable")) {
      Printf(f->code, "if (argc > 2) {\n");
      if ((tm = alaqil_typemap_lookup("varin", n, name, 0))) {
	Replaceall(tm, "$source", "value");
	Replaceall(tm, "$target", name);
	Replaceall(tm, "$input", "value");
	/* Printv(f->code, tm, "\n",NIL); */
	emit_action_code(n, f->code, tm);
      } else {
	alaqil_warning(WARN_TYPEMAP_VARIN_UNDEF, input_file, line_number, "Unable to set variable of type %s.\n", alaqilType_str(t, 0));
      }
      Printf(f->code, "}\n");
    }

    String *varname;
    if (alaqilType_istemplate((char *) name)) {
      varname = alaqilType_namestr((char *) name);
    } else {
      varname = name;
    }

    // Now return the value of the variable - regardless
    // of evaluating or setting.
    if ((tm = alaqil_typemap_lookup("varout", n, name, 0))) {
      Replaceall(tm, "$source", varname);
      Replaceall(tm, "$varname", varname);
      Replaceall(tm, "$target", "resultobj");
      Replaceall(tm, "$result", "resultobj");
      /* Printf(f->code, "%s\n", tm); */
      emit_action_code(n, f->code, tm);
    } else {
      alaqil_warning(WARN_TYPEMAP_VAROUT_UNDEF, input_file, line_number, "Unable to read variable of type %s\n", alaqilType_str(t, 0));
    }

    Printv(f->code, "{\n",
	   "C_word func;\n",
	   "alaqil_Chicken_FindCreateProxy(func, resultobj)\n",
	   "if (C_alaqil_is_closurep(func))\n",
	   "  ((C_proc4)(void *)C_block_item(func, 0))(4,func,continuation,resultobj,C_SCHEME_FALSE);\n",
	   "else\n", "  C_kontinue(continuation, resultobj);\n", "}\n", NIL);

    /* Error handling code */
#ifdef USE_FAIL
    Printf(f->code, "fail:\n");
    Printf(f->code, "alaqil_panic (\"failure in " "'%s' alaqil wrapper\");\n", proc_name);
#endif
    Printf(f->code, "}\n");

    Wrapper_print(f, f_wrappers);

    /* Now register the variable with the interpreter.   */
    addMethod(scmname, wname);

    if (!in_class || member_name) {
      String *clos_name;
      if (in_class)
	clos_name = NewString(member_name);
      else
	clos_name = chickenNameMapping(scmname, "");

      Node *class_node = classLookup(t);
      String *clos_code = Getattr(n, "tmap:varin:closcode");
      if (class_node && clos_code && !GetFlag(n, "feature:immutable")) {
	Replaceall(clos_code, "$input", "(car lst)");
	Printv(clos_methods, "(define (", clos_name, " . lst) (if (null? lst) (", chickenPrimitiveName(scmname), ") (",
	       chickenPrimitiveName(scmname), " ", clos_code, ")))\n", NIL);
      } else {
	/* Simply re-export the procedure */
	if (GetFlag(n, "feature:immutable") && GetFlag(n, "feature:constasvar")) {
	  Printv(clos_methods, "(define ", clos_name, " (", chickenPrimitiveName(scmname), "))\n", NIL);
	  Printv(scm_const_defs, "(set! ", scmname, " (", scmname, "))\n", NIL);
	} else {
	  Printv(clos_methods, "(define ", clos_name, " ", chickenPrimitiveName(scmname), ")\n", NIL);
	}
      }
      Delete(clos_name);
    }
  } else {
    alaqil_warning(WARN_TYPEMAP_VAR_UNDEF, input_file, line_number, "Unsupported variable type %s (ignored).\n", alaqilType_str(t, 0));
  }

  Delete(wname);
  Delete(argnum);
  Delete(arg);
  Delete(tm2);
  Delete(mangle);
  DelWrapper(f);
  return alaqil_OK;
}

/* ------------------------------------------------------------
 * constantWrapper()
 * ------------------------------------------------------------ */

int CHICKEN::constantWrapper(Node *n) {

  char *name = GetChar(n, "name");
  char *iname = GetChar(n, "sym:name");
  alaqilType *t = Getattr(n, "type");
  ParmList *l = Getattr(n, "parms");
  String *value = Getattr(n, "value");

  String *proc_name = NewString("");
  String *wname = NewString("");
  String *mangle = NewString("");
  String *tm;
  String *tm2 = NewString("");
  String *source = NewString("");
  String *argnum = NewString("0");
  String *arg = NewString("argv[0]");
  Wrapper *f;
  String *overname = 0;
  String *scmname;
  String *rvalue;
  alaqilType *nctype;

  scmname = NewString(iname);
  Replaceall(scmname, "_", "-");

  Printf(source, "alaqil_const_%s", iname);
  Replaceall(source, "::", "__");

  Printf(mangle, "\"%s\"", alaqilType_manglestr(t));

  if (Getattr(n, "sym:overloaded")) {
    overname = Getattr(n, "sym:overname");
  } else {
    if (!addSymbol(iname, n))
      return alaqil_ERROR;
  }

  Append(wname, alaqil_name_wrapper(iname));
  if (overname) {
    Append(wname, overname);
  }

  nctype = NewString(t);
  if (alaqilType_isconst(nctype)) {
    Delete(alaqilType_pop(nctype));
  }

  bool is_enum_item = (Cmp(nodeType(n), "enumitem") == 0);
  if (alaqilType_type(nctype) == T_STRING) {
    rvalue = NewStringf("\"%s\"", value);
  } else if (alaqilType_type(nctype) == T_CHAR && !is_enum_item) {
    rvalue = NewStringf("\'%s\'", value);
  } else {
    rvalue = NewString(value);
  }

  /* Special hook for member pointer */
  if (alaqilType_type(t) == T_MPOINTER) {
    Printf(f_header, "static %s = %s;\n", alaqilType_str(t, source), rvalue);
  } else {
    if ((tm = alaqil_typemap_lookup("constcode", n, name, 0))) {
      Replaceall(tm, "$source", rvalue);
      Replaceall(tm, "$target", source);
      Replaceall(tm, "$result", source);
      Replaceall(tm, "$value", rvalue);
      Printf(f_header, "%s\n", tm);
    } else {
      alaqil_warning(WARN_TYPEMAP_CONST_UNDEF, input_file, line_number, "Unsupported constant value.\n");
      return alaqil_NOWRAP;
    }
  }

  f = NewWrapper();

  /* Attach the standard typemaps */
  emit_attach_parmmaps(l, f);
  Setattr(n, "wrap:parms", l);

  // evaluation function names

  // Check for interrupts
  Printv(f->code, "C_trace(\"", scmname, "\");\n", NIL);

  if (1 || (alaqilType_type(t) != T_USER) || (isPointer(t))) {

    Setattr(n, "wrap:name", wname);
    Printv(f->def, "static ", "void ", wname, "(C_word, C_word, C_word) C_noret;\n", NIL);

    Printv(f->def, "static ", "void ", wname, "(C_word argc, C_word closure, " "C_word continuation) {\n", NIL);

    Wrapper_add_local(f, "resultobj", "C_word resultobj");

    Printf(f->code, "if (argc!=2) C_bad_argc(argc,2);\n");

    // Return the value of the variable
    if ((tm = alaqil_typemap_lookup("varout", n, name, 0))) {

      Replaceall(tm, "$source", source);
      Replaceall(tm, "$varname", source);
      Replaceall(tm, "$target", "resultobj");
      Replaceall(tm, "$result", "resultobj");
      /* Printf(f->code, "%s\n", tm); */
      emit_action_code(n, f->code, tm);
    } else {
      alaqil_warning(WARN_TYPEMAP_VAROUT_UNDEF, input_file, line_number, "Unable to read variable of type %s\n", alaqilType_str(t, 0));
    }

    Printv(f->code, "{\n",
	   "C_word func;\n",
	   "alaqil_Chicken_FindCreateProxy(func, resultobj)\n",
	   "if (C_alaqil_is_closurep(func))\n",
	   "  ((C_proc4)(void *)C_block_item(func, 0))(4,func,continuation,resultobj,C_SCHEME_FALSE);\n",
	   "else\n", "  C_kontinue(continuation, resultobj);\n", "}\n", NIL);

    /* Error handling code */
#ifdef USE_FAIL
    Printf(f->code, "fail:\n");
    Printf(f->code, "alaqil_panic (\"failure in " "'%s' alaqil wrapper\");\n", proc_name);
#endif
    Printf(f->code, "}\n");

    Wrapper_print(f, f_wrappers);

    /* Now register the variable with the interpreter.   */
    addMethod(scmname, wname);

    if (!in_class || member_name) {
      String *clos_name;
      if (in_class)
	clos_name = NewString(member_name);
      else
	clos_name = chickenNameMapping(scmname, "");
      if (GetFlag(n, "feature:constasvar")) {
	Printv(clos_methods, "(define ", clos_name, " (", chickenPrimitiveName(scmname), "))\n", NIL);
	Printv(scm_const_defs, "(set! ", scmname, " (", scmname, "))\n", NIL);
      } else {
	Printv(clos_methods, "(define ", clos_name, " ", chickenPrimitiveName(scmname), ")\n", NIL);
      }
      Delete(clos_name);
    }

  } else {
    alaqil_warning(WARN_TYPEMAP_VAR_UNDEF, input_file, line_number, "Unsupported variable type %s (ignored).\n", alaqilType_str(t, 0));
  }

  Delete(wname);
  Delete(nctype);
  Delete(proc_name);
  Delete(argnum);
  Delete(arg);
  Delete(tm2);
  Delete(mangle);
  Delete(source);
  Delete(rvalue);
  DelWrapper(f);
  return alaqil_OK;
}

int CHICKEN::classHandler(Node *n) {
  /* Create new strings for building up a wrapper function */
  have_constructor = 0;
  constructor_dispatch = 0;
  constructor_name = 0;

  c_class_name = NewString(Getattr(n, "sym:name"));
  class_name = NewString("");
  short_class_name = NewString("");
  Printv(class_name, "<", c_class_name, ">", NIL);
  Printv(short_class_name, c_class_name, NIL);
  Replaceall(class_name, "_", "-");
  Replaceall(short_class_name, "_", "-");

  if (!addSymbol(class_name, n))
    return alaqil_ERROR;

  /* Handle inheritance */
  String *base_class = NewString("");
  List *baselist = Getattr(n, "bases");
  if (baselist && Len(baselist)) {
    Iterator base = First(baselist);
    while (base.item) {
      if (!Getattr(base.item, "feature:ignore"))
	Printv(base_class, "<", Getattr(base.item, "sym:name"), "> ", NIL);
      base = Next(base);
    }
  }

  Replaceall(base_class, "_", "-");

  String *scmmod = NewString(module);
  Replaceall(scmmod, "_", "-");

  Printv(clos_class_defines, "(define ", class_name, "\n", "  (make <alaqil-metaclass-", scmmod, "> 'name \"", short_class_name, "\"\n", NIL);
  Delete(scmmod);

  if (Len(base_class)) {
    Printv(clos_class_defines, "    'direct-supers (list ", base_class, ")\n", NIL);
  } else {
    Printv(clos_class_defines, "    'direct-supers (list <object>)\n", NIL);
  }

  Printf(clos_class_defines, "    'direct-slots (list 'alaqil-this\n");

  String *mangled_classname = alaqil_name_mangle(Getattr(n, "sym:name"));

  alaqilType *ct = NewStringf("p.%s", Getattr(n, "name"));
  alaqiltype_ptr = alaqilType_manglestr(ct);

  Printf(f_runtime, "static alaqil_chicken_clientdata _alaqil_chicken_clientdata%s = { 0 };\n", mangled_classname);
  Printv(f_init, "alaqil_TypeClientData(alaqilTYPE", alaqiltype_ptr, ", (void *) &_alaqil_chicken_clientdata", mangled_classname, ");\n", NIL);
  alaqilType_remember(ct);

  /* Emit all of the members */

  in_class = 1;
  Language::classHandler(n);
  in_class = 0;

  Printf(clos_class_defines, ")))\n\n");

  if (have_constructor) {
    Printv(clos_methods, "(define-method (initialize (obj ", class_name, ") initargs)\n", "  (alaqil-initialize obj initargs ", NIL);
    if (constructor_arg_types) {
      String *initfunc_name = NewStringf("%s@@alaqil@initmethod", class_name);
      String *func_call = buildClosFunctionCall(constructor_arg_types, initfunc_name, chickenPrimitiveName(constructor_name));
      Printf(clos_methods, "%s)\n)\n", initfunc_name);
      Printf(clos_methods, "(declare (hide %s))\n", initfunc_name);
      Printf(clos_methods, "%s\n", func_call);
      Delete(func_call);
      Delete(initfunc_name);
      Delete(constructor_arg_types);
      constructor_arg_types = 0;
    } else if (constructor_dispatch) {
      Printf(clos_methods, "%s)\n)\n", constructor_dispatch);
      Delete(constructor_dispatch);
      constructor_dispatch = 0;
    } else {
      Printf(clos_methods, "%s)\n)\n", chickenPrimitiveName(constructor_name));
    }
    Delete(constructor_name);
    constructor_name = 0;
  } else {
    Printv(clos_methods, "(define-method (initialize (obj ", class_name, ") initargs)\n", "  (alaqil-initialize obj initargs (lambda x #f)))\n", NIL);
  }

  /* export class initialization function */
  if (clos) {
    String *funcname = NewString(mangled_classname);
    Printf(funcname, "_alaqil_chicken_setclosclass");
    String *closfuncname = NewString(funcname);
    Replaceall(closfuncname, "_", "-");

    Printv(f_wrappers, "static void ", funcname, "(C_word,C_word,C_word,C_word) C_noret;\n",
	   "static void ", funcname, "(C_word argc, C_word closure, C_word continuation, C_word cl) {\n",
	   "  C_trace(\"", funcname, "\");\n",
	   "  if (argc!=3) C_bad_argc(argc,3);\n",
	   "  alaqil_chicken_clientdata *cdata = (alaqil_chicken_clientdata *) alaqilTYPE", alaqiltype_ptr, "->clientdata;\n",
	   "  cdata->gc_proxy_create = CHICKEN_new_gc_root();\n",
	   "  CHICKEN_gc_root_set(cdata->gc_proxy_create, cl);\n", "  C_kontinue(continuation, C_SCHEME_UNDEFINED);\n", "}\n", NIL);
    addMethod(closfuncname, funcname);

    Printv(clos_methods, "(", chickenPrimitiveName(closfuncname), " (lambda (x lst) (if lst ",
	   "(cons (make ", class_name, " 'alaqil-this x) lst) ", "(make ", class_name, " 'alaqil-this x))))\n\n", NIL);
    Delete(closfuncname);
    Delete(funcname);
  }

  Delete(mangled_classname);
  Delete(alaqiltype_ptr);
  alaqiltype_ptr = 0;

  Delete(class_name);
  Delete(short_class_name);
  Delete(c_class_name);
  class_name = 0;
  short_class_name = 0;
  c_class_name = 0;

  return alaqil_OK;
}

int CHICKEN::memberfunctionHandler(Node *n) {
  String *iname = Getattr(n, "sym:name");
  String *proc = NewString(iname);
  Replaceall(proc, "_", "-");

  member_name = chickenNameMapping(proc, short_class_name);
  Language::memberfunctionHandler(n);
  Delete(member_name);
  member_name = NULL;
  Delete(proc);

  return alaqil_OK;
}

int CHICKEN::staticmemberfunctionHandler(Node *n) {
  String *iname = Getattr(n, "sym:name");
  String *proc = NewString(iname);
  Replaceall(proc, "_", "-");

  member_name = NewStringf("%s-%s", short_class_name, proc);
  Language::staticmemberfunctionHandler(n);
  Delete(member_name);
  member_name = NULL;
  Delete(proc);

  return alaqil_OK;
}

int CHICKEN::membervariableHandler(Node *n) {
  String *iname = Getattr(n, "sym:name");
  //String *pb = alaqilType_typedef_resolve_all(alaqilType_base(Getattr(n, "type")));

  Language::membervariableHandler(n);

  String *proc = NewString(iname);
  Replaceall(proc, "_", "-");

  //Node *class_node = alaqil_symbol_clookup(pb, Getattr(n, "sym:symtab"));
  Node *class_node = classLookup(Getattr(n, "type"));

  //String *getfunc = NewStringf("%s-%s-get", short_class_name, proc);
  //String *setfunc = NewStringf("%s-%s-set", short_class_name, proc);
  String *getfunc = alaqil_name_get(NSPACE_TODO, alaqil_name_member(NSPACE_TODO, c_class_name, iname));
  Replaceall(getfunc, "_", "-");
  String *setfunc = alaqil_name_set(NSPACE_TODO, alaqil_name_member(NSPACE_TODO, c_class_name, iname));
  Replaceall(setfunc, "_", "-");

  Printv(clos_class_defines, "        (list '", proc, " ':alaqil-virtual ':alaqil-get ", chickenPrimitiveName(getfunc), NIL);

  if (!GetFlag(n, "feature:immutable")) {
    if (class_node) {
      Printv(clos_class_defines, " ':alaqil-set (lambda (x y) (", chickenPrimitiveName(setfunc), " x (slot-ref y 'alaqil-this))))\n", NIL);
    } else {
      Printv(clos_class_defines, " ':alaqil-set ", chickenPrimitiveName(setfunc), ")\n", NIL);
    }
  } else {
    Printf(clos_class_defines, ")\n");
  }

  Delete(proc);
  Delete(setfunc);
  Delete(getfunc);
  return alaqil_OK;
}

int CHICKEN::staticmembervariableHandler(Node *n) {
  String *iname = Getattr(n, "sym:name");
  String *proc = NewString(iname);
  Replaceall(proc, "_", "-");

  member_name = NewStringf("%s-%s", short_class_name, proc);
  Language::staticmembervariableHandler(n);
  Delete(member_name);
  member_name = NULL;
  Delete(proc);

  return alaqil_OK;
}

int CHICKEN::constructorHandler(Node *n) {
  have_constructor = 1;
  has_constructor_args = 0;


  exporting_constructor = true;
  Language::constructorHandler(n);
  exporting_constructor = false;

  has_constructor_args = 1;

  String *iname = Getattr(n, "sym:name");
  constructor_name = alaqil_name_construct(NSPACE_TODO, iname);
  Replaceall(constructor_name, "_", "-");
  return alaqil_OK;
}

int CHICKEN::destructorHandler(Node *n) {

  if (no_collection)
    member_name = NewStringf("delete-%s", short_class_name);

  exporting_destructor = true;
  Language::destructorHandler(n);
  exporting_destructor = false;

  if (no_collection) {
    Delete(member_name);
    member_name = NULL;
  }

  return alaqil_OK;
}

int CHICKEN::importDirective(Node *n) {
  String *modname = Getattr(n, "module");
  if (modname && clos_uses) {

    // Find the module node for this imported module.  It should be the
    // first child but search just in case.
    Node *mod = firstChild(n);
    while (mod && Strcmp(nodeType(mod), "module") != 0)
      mod = nextSibling(mod);

    if (mod) {
      String *name = Getattr(mod, "name");
      if (name) {
	Printf(closprefix, "(declare (uses %s))\n", name);
      }
    }
  }

  return Language::importDirective(n);
}

String *CHICKEN::buildClosFunctionCall(List *types, const_String_or_char_ptr closname, const_String_or_char_ptr funcname) {
  String *method_signature = NewString("");
  String *func_args = NewString("");
  String *func_call = NewString("");

  Iterator arg_type;
  int arg_count = 0;
  int optional_arguments = 0;

  for (arg_type = First(types); arg_type.item; arg_type = Next(arg_type)) {
    if (Strcmp(arg_type.item, "^^##optional$$") == 0) {
      optional_arguments = 1;
    } else {
      Printf(method_signature, " (arg%i %s)", arg_count, arg_type.item);
      arg_type = Next(arg_type);
      if (!arg_type.item)
	break;

      String *arg = NewStringf("arg%i", arg_count);
      String *access_arg = Copy(arg_type.item);

      Replaceall(access_arg, "$input", arg);
      Printf(func_args, " %s", access_arg);

      Delete(arg);
      Delete(access_arg);
    }
    arg_count++;
  }

  if (optional_arguments) {
    Printf(func_call, "(define-method (%s %s . args) (apply %s %s args))", closname, method_signature, funcname, func_args);
  } else {
    Printf(func_call, "(define-method (%s %s) (%s %s))", closname, method_signature, funcname, func_args);
  }

  Delete(method_signature);
  Delete(func_args);

  return func_call;
}

extern "C" {

  /* compares based on non-primitive names */
  static int compareTypeListsHelper(const DOH *a, const DOH *b, int opt_equal) {
    List *la = (List *) a;
    List *lb = (List *) b;

    Iterator ia = First(la);
    Iterator ib = First(lb);

    while (ia.item && ib.item) {
      int ret = Strcmp(ia.item, ib.item);
      if (ret)
	return ret;
      ia = Next(Next(ia));
      ib = Next(Next(ib));
    } if (opt_equal && ia.item && Strcmp(ia.item, "^^##optional$$") == 0)
      return 0;
    if (ia.item)
      return -1;
    if (opt_equal && ib.item && Strcmp(ib.item, "^^##optional$$") == 0)
      return 0;
    if (ib.item)
      return 1;

    return 0;
  }

  static int compareTypeLists(const DOH *a, const DOH *b) {
    return compareTypeListsHelper(a, b, 0);
  }
}

void CHICKEN::dispatchFunction(Node *n) {
  /* Last node in overloaded chain */

  int maxargs;
  String *tmp = NewString("");
  String *dispatch = alaqil_overload_dispatch(n, "%s (2+$numargs,closure," "continuation$commaargs);", &maxargs);

  /* Generate a dispatch wrapper for all overloaded functions */

  Wrapper *f = NewWrapper();
  String *iname = Getattr(n, "sym:name");
  String *wname = NewString("");
  String *scmname = NewString(iname);
  Replaceall(scmname, "_", "-");

  Append(wname, alaqil_name_wrapper(iname));

  Printv(f->def, "static void real_", wname, "(C_word, C_word, C_word, C_word) C_noret;\n", NIL);

  Printv(f->def, "static void real_", wname, "(C_word oldargc, C_word closure, C_word continuation, C_word args) {", NIL);

  Wrapper_add_local(f, "argc", "int argc");
  Printf(tmp, "C_word argv[%d]", maxargs + 1);
  Wrapper_add_local(f, "argv", tmp);
  Wrapper_add_local(f, "ii", "int ii");
  Wrapper_add_local(f, "t", "C_word t = args");
  Printf(f->code, "if (!C_alaqil_is_list (args)) {\n");
  Printf(f->code, "  alaqil_barf (alaqil_BARF1_BAD_ARGUMENT_TYPE, " "\"Argument #1 must be a list of overloaded arguments\");\n");
  Printf(f->code, "}\n");
  Printf(f->code, "argc = C_unfix (C_i_length (args));\n");
  Printf(f->code, "for (ii = 0; (ii < argc) && (ii < %d); ii++, t = C_block_item (t, 1)) {\n", maxargs);
  Printf(f->code, "argv[ii] = C_block_item (t, 0);\n");
  Printf(f->code, "}\n");

  Printv(f->code, dispatch, "\n", NIL);
  Printf(f->code, "alaqil_barf (alaqil_BARF1_BAD_ARGUMENT_TYPE," "\"No matching function for overloaded '%s'\");\n", iname);
  Printv(f->code, "}\n", NIL);
  Wrapper_print(f, f_wrappers);
  addMethod(scmname, wname);

  DelWrapper(f);
  f = NewWrapper();

  /* varargs */
  Printv(f->def, "void ", wname, "(C_word, C_word, C_word, ...) C_noret;\n", NIL);
  Printv(f->def, "void ", wname, "(C_word c, C_word t0, C_word t1, ...) {", NIL);
  Printv(f->code,
	 "C_word t2;\n",
	 "va_list v;\n",
	 "C_word *a, c2 = c;\n",
	 "C_save_rest (t1, c2, 2);\n", "a = C_alloc((c-2)*3);\n", "t2 = C_restore_rest (a, C_rest_count (0));\n", "real_", wname, " (3, t0, t1, t2);\n", NIL);
  Printv(f->code, "}\n", NIL);
  Wrapper_print(f, f_wrappers);

  /* Now deal with overloaded function when exporting clos */
  if (clos) {
    List *flist = Getattr(overload_parameter_lists, scmname);
    if (flist) {
      Delattr(overload_parameter_lists, scmname);

      SortList(flist, compareTypeLists);

      String *clos_name;
      if (have_constructor && !has_constructor_args) {
	has_constructor_args = 1;
	constructor_dispatch = NewStringf("%s@alaqil@new@dispatch", short_class_name);
	clos_name = Copy(constructor_dispatch);
	Printf(clos_methods, "(declare (hide %s))\n", clos_name);
      } else if (in_class)
	clos_name = NewString(member_name);
      else
	clos_name = chickenNameMapping(scmname, "");

      Iterator f;
      List *prev = 0;
      int all_primitive = 1;

      /* first check for duplicates and an empty call */
      String *newlist = NewList();
      for (f = First(flist); f.item; f = Next(f)) {
	/* check if cur is a duplicate of prev */
	if (prev && compareTypeListsHelper(f.item, prev, 1) == 0) {
	  Delete(f.item);
	} else {
	  Append(newlist, f.item);
	  prev = f.item;
	  Iterator j;
	  for (j = First(f.item); j.item; j = Next(j)) {
	    if (Strcmp(j.item, "^^##optional$$") != 0 && Strcmp(j.item, "<top>") != 0)
	      all_primitive = 0;
	  }
	}
      }
      Delete(flist);
      flist = newlist;

      if (all_primitive) {
	Printf(clos_methods, "(define %s %s)\n", clos_name, chickenPrimitiveName(scmname));
      } else {
	for (f = First(flist); f.item; f = Next(f)) {
	  /* now export clos code for argument */
	  String *func_call = buildClosFunctionCall(f.item, clos_name, chickenPrimitiveName(scmname));
	  Printf(clos_methods, "%s\n", func_call);
	  Delete(f.item);
	  Delete(func_call);
	}
      }

      Delete(clos_name);
      Delete(flist);
    }
  }

  DelWrapper(f);
  Delete(dispatch);
  Delete(tmp);
  Delete(wname);
}

int CHICKEN::isPointer(alaqilType *t) {
  return alaqilType_ispointer(alaqilType_typedef_resolve_all(t));
}

void CHICKEN::addMethod(String *scheme_name, String *function) {
  String *sym = NewString("");
  if (clos) {
    Append(sym, "primitive:");
  }
  Append(sym, scheme_name);

  /* add symbol to Chicken internal symbol table */
  if (hide_primitive) {
    Printv(f_init, "{\n",
	   "  C_word *p0 = a;\n", "  *(a++)=C_CLOSURE_TYPE|1;\n", "  *(a++)=(C_word)", function, ";\n", "  C_mutate(return_vec++, (C_word)p0);\n", "}\n", NIL);
  } else {
    Printf(f_sym_size, "+C_SIZEOF_INTERNED_SYMBOL(%d)", Len(sym));
    Printf(f_init, "sym = C_intern (&a, %d, \"%s\");\n", Len(sym), sym);
    Printv(f_init, "C_mutate ((C_word*)sym+1, (*a=C_CLOSURE_TYPE|1, a[1]=(C_word)", function, ", tmp=(C_word)a, a+=2, tmp));\n", NIL);
  }

  if (hide_primitive) {
    Setattr(primitive_names, scheme_name, NewStringf("(vector-ref alaqil-init-return %i)", num_methods));
  } else {
    Setattr(primitive_names, scheme_name, Copy(sym));
  }

  num_methods++;

  Delete(sym);
}

String *CHICKEN::chickenPrimitiveName(String *name) {
  String *value = Getattr(primitive_names, name);
  if (value)
    return value;
  else {
    alaqil_error(input_file, line_number, "Internal Error: attempting to reference non-existant primitive name %s\n", name);
    return NewString("#f");
  }
}

int CHICKEN::validIdentifier(String *s) {
  char *c = Char(s);
  /* Check whether we have an R5RS identifier. */
  /* <identifier> --> <initial> <subsequent>* | <peculiar identifier> */
  /* <initial> --> <letter> | <special initial> */
  if (!(isalpha(*c) || (*c == '!') || (*c == '$') || (*c == '%')
	|| (*c == '&') || (*c == '*') || (*c == '/') || (*c == ':')
	|| (*c == '<') || (*c == '=') || (*c == '>') || (*c == '?')
	|| (*c == '^') || (*c == '_') || (*c == '~'))) {
    /* <peculiar identifier> --> + | - | ... */
    if ((strcmp(c, "+") == 0)
	|| strcmp(c, "-") == 0 || strcmp(c, "...") == 0)
      return 1;
    else
      return 0;
  }
  /* <subsequent> --> <initial> | <digit> | <special subsequent> */
  while (*c) {
    if (!(isalnum(*c) || (*c == '!') || (*c == '$') || (*c == '%')
	  || (*c == '&') || (*c == '*') || (*c == '/') || (*c == ':')
	  || (*c == '<') || (*c == '=') || (*c == '>') || (*c == '?')
	  || (*c == '^') || (*c == '_') || (*c == '~') || (*c == '+')
	  || (*c == '-') || (*c == '.') || (*c == '@')))
      return 0;
    c++;
  }
  return 1;
}

  /* ------------------------------------------------------------
   * closNameMapping()
   * Maps the identifier from C++ to the CLOS based on command 
   * line parameters and such.
   * If class_name = "" that means the mapping is for a function or
   * variable not attached to any class.
   * ------------------------------------------------------------ */
String *CHICKEN::chickenNameMapping(String *name, const_String_or_char_ptr class_name) {
  String *n = NewString("");

  if (Strcmp(class_name, "") == 0) {
    // not part of a class, so no class name to prefix
    if (clossymnameprefix) {
      Printf(n, "%s%s", clossymnameprefix, name);
    } else {
      Printf(n, "%s", name);
    }
  } else {
    if (useclassprefix) {
      Printf(n, "%s-%s", class_name, name);
    } else {
      if (clossymnameprefix) {
	Printf(n, "%s%s", clossymnameprefix, name);
      } else {
	Printf(n, "%s", name);
      }
    }
  }
  return n;
}

String *CHICKEN::runtimeCode() {
  String *s = alaqil_include_sys("chickenrun.swg");
  if (!s) {
    Printf(stderr, "*** Unable to open 'chickenrun.swg'\n");
    s = NewString("");
  }
  return s;
}

String *CHICKEN::defaultExternalRuntimeFilename() {
  return NewString("alaqilchickenrun.h");
}
