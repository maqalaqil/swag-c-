/* ----------------------------------------------------------------------------- 
 * This file is part of alaqil, which is licensed as a whole under version 3 
 * (or any later version) of the GNU General Public License. Some additional
 * terms also apply to certain portions of alaqil. The full details of the alaqil
 * license and copyrights can be found in the LICENSE and COPYRIGHT files
 * included with the alaqil source code as distributed by the alaqil developers
 * and at http://www.alaqil.org/legal.html.
 *
 * mzscheme.cxx
 *
 * Mzscheme language module for alaqil.
 * ----------------------------------------------------------------------------- */

#include "alaqilmod.h"

#include <ctype.h>

static const char *usage = "\
Mzscheme Options (available with -mzscheme)\n\
     -declaremodule                - Create extension that declares a module\n\
     -dynamic-load <lib>,[lib,...] - Do not link with these libraries, dynamic load them\n\
     -noinit                       - Do not emit module initialization code\n\
     -prefix <name>                - Set a prefix <name> to be prepended to all names\n\
";

static String *fieldnames_tab = 0;
static String *convert_tab = 0;
static String *convert_proto_tab = 0;
static String *struct_name = 0;
static String *mangled_struct_name = 0;

static String *prefix = 0;
static bool declaremodule = false;
static bool noinit = false;
static String *load_libraries = NULL;
static String *module = 0;
static const char *mzscheme_path = "mzscheme";
static String *init_func_def = 0;

static File *f_begin = 0;
static File *f_runtime = 0;
static File *f_header = 0;
static File *f_wrappers = 0;
static File *f_init = 0;

// Used for garbage collection
static int exporting_destructor = 0;
static String *alaqiltype_ptr = 0;
static String *cls_alaqiltype = 0;

class MZSCHEME:public Language {
public:

  /* ------------------------------------------------------------
   * main()
   * ------------------------------------------------------------ */

  virtual void main(int argc, char *argv[]) {

    int i;

     alaqil_library_directory(mzscheme_path);

    // Look for certain command line options
    for (i = 1; i < argc; i++) {
      if (argv[i]) {
	if (strcmp(argv[i], "-help") == 0) {
	  fputs(usage, stdout);
	  alaqil_exit(0);
	} else if (strcmp(argv[i], "-prefix") == 0) {
	  if (argv[i + 1]) {
	    prefix = NewString(argv[i + 1]);
	    alaqil_mark_arg(i);
	    alaqil_mark_arg(i + 1);
	    i++;
	  } else {
	    alaqil_arg_error();
	  }
	} else if (strcmp(argv[i], "-declaremodule") == 0) {
	  declaremodule = true;
	  alaqil_mark_arg(i);
	} else if (strcmp(argv[i], "-noinit") == 0) {
	  noinit = true;
	  alaqil_mark_arg(i);
	}
	else if (strcmp(argv[i], "-dynamic-load") == 0) {
	  if (argv[i + 1]) {
	    Delete(load_libraries);
	    load_libraries = NewString(argv[i + 1]);
	    alaqil_mark_arg(i++);
	    alaqil_mark_arg(i);
	  } else {
	    alaqil_arg_error();
	  }
	}
      }
    }

    // If a prefix has been specified make sure it ends in a '_' (not actually used!)
    if (prefix) {
      const char *px = Char(prefix);
      if (px[Len(prefix) - 1] != '_')
	Printf(prefix, "_");
    } else
      prefix = NewString("alaqil_");

    // Add a symbol for this module

    Preprocessor_define("alaqilMZSCHEME 1", 0);

    // Set name of typemaps

    alaqil_typemap_lang("mzscheme");

    // Read in default typemaps */
    alaqil_config_file("mzscheme.swg");
    allow_overloading();

  }

  /* ------------------------------------------------------------
   * top()
   * ------------------------------------------------------------ */

  virtual int top(Node *n) {

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

    /* Register file targets with the alaqil file handler */
    alaqil_register_filebyname("header", f_header);
    alaqil_register_filebyname("wrapper", f_wrappers);
    alaqil_register_filebyname("begin", f_begin);
    alaqil_register_filebyname("runtime", f_runtime);

    init_func_def = NewString("");
    alaqil_register_filebyname("init", init_func_def);

    alaqil_banner(f_begin);

    Printf(f_runtime, "\n\n#ifndef alaqilMZSCHEME\n#define alaqilMZSCHEME\n#endif\n\n");

    module = Getattr(n, "name");

    Language::top(n);

    alaqilType_emit_type_table(f_runtime, f_wrappers);
    if (!noinit) {
      if (declaremodule) {
	Printf(f_init, "#define alaqil_MZSCHEME_CREATE_MENV(env) scheme_primitive_module(scheme_intern_symbol(\"%s\"), env)\n", module);
      } else {
	Printf(f_init, "#define alaqil_MZSCHEME_CREATE_MENV(env) (env)\n");
      }
      Printf(f_init, "%s\n", Char(init_func_def));
      if (declaremodule) {
	Printf(f_init, "\tscheme_finish_primitive_module(menv);\n");
      }
      Printf(f_init, "\treturn scheme_void;\n}\n");
      Printf(f_init, "Scheme_Object *scheme_initialize(Scheme_Env *env) {\n");

      if (load_libraries) {
	Printf(f_init, "mz_set_dlopen_libraries(\"%s\");\n", load_libraries);
      }

      Printf(f_init, "\treturn scheme_reload(env);\n");
      Printf(f_init, "}\n");

      Printf(f_init, "Scheme_Object *scheme_module_name(void) {\n");
      if (declaremodule) {
	Printf(f_init, "   return scheme_intern_symbol((char*)\"%s\");\n", module);
      } else {
	Printf(f_init, "   return scheme_make_symbol((char*)\"%s\");\n", module);
      }
      Printf(f_init, "}\n");
    }

    /* Close all of the files */
    Dump(f_runtime, f_begin);
    Dump(f_header, f_begin);
    Dump(f_wrappers, f_begin);
    Wrapper_pretty_print(f_init, f_begin);
    Delete(f_header);
    Delete(f_wrappers);
    Delete(f_init);
    Delete(f_runtime);
    Delete(f_begin);
    return alaqil_OK;
  }

  /* ------------------------------------------------------------
   * functionWrapper()
   * Create a function declaration and register it with the interpreter.
   * ------------------------------------------------------------ */

  void throw_unhandled_mzscheme_type_error(alaqilType *d) {
    alaqil_warning(WARN_TYPEMAP_UNDEF, input_file, line_number, "Unable to handle type %s.\n", alaqilType_str(d, 0));
  }

  /* Return true iff T is a pointer type */

  int
   is_a_pointer(alaqilType *t) {
    return alaqilType_ispointer(alaqilType_typedef_resolve_all(t));
  }

  virtual int functionWrapper(Node *n) {
    char *iname = GetChar(n, "sym:name");
    alaqilType *d = Getattr(n, "type");
    ParmList *l = Getattr(n, "parms");
    Parm *p;

    Wrapper *f = NewWrapper();
    String *proc_name = NewString("");
    String *source = NewString("");
    String *target = NewString("");
    String *arg = NewString("");
    String *cleanup = NewString("");
    String *outarg = NewString("");
    String *build = NewString("");
    String *tm;
    int i = 0;
    int numargs;
    int numreq;
    String *overname = 0;

    if (load_libraries) {
      ParmList *parms = Getattr(n, "parms");
      alaqilType *type = Getattr(n, "type");
      String *name = NewString("caller");
      Setattr(n, "wrap:action", alaqil_cresult(type, alaqil_cresult_name(), alaqil_cfunction_call(name, parms)));
    }

    // Make a wrapper name for this
    String *wname = alaqil_name_wrapper(iname);
    if (Getattr(n, "sym:overloaded")) {
      overname = Getattr(n, "sym:overname");
    } else {
      if (!addSymbol(iname, n)) {
        DelWrapper(f);
	return alaqil_ERROR;
      }
    }
    if (overname) {
      Append(wname, overname);
    }
    Setattr(n, "wrap:name", wname);

    // Build the name for Scheme.
    Printv(proc_name, iname, NIL);
    Replaceall(proc_name, "_", "-");

    // writing the function wrapper function
    Printv(f->def, "static Scheme_Object *", wname, " (", NIL);
    Printv(f->def, "int argc, Scheme_Object **argv", NIL);
    Printv(f->def, ")\n{", NIL);

    /* Define the scheme name in C. This define is used by several
       macros. */
    Printv(f->def, "#define FUNC_NAME \"", proc_name, "\"", NIL);

    // Emit all of the local variables for holding arguments.
    emit_parameter_variables(l, f);

    /* Attach the standard typemaps */
    emit_attach_parmmaps(l, f);
    Setattr(n, "wrap:parms", l);

    numargs = emit_num_arguments(l);
    numreq = emit_num_required(l);

    /* Add the holder for the pointer to the function to be opened */
    if (load_libraries) {
      Wrapper_add_local(f, "_function_loaded", "static int _function_loaded=(1==0)");
      Wrapper_add_local(f, "_the_function", "static void *_the_function=NULL");
      {
	String *parms = ParmList_protostr(l);
	String *func = NewStringf("(*caller)(%s)", parms);
	Wrapper_add_local(f, "caller", alaqilType_lstr(d, func));	/*"(*caller)()")); */
      }
    }

    // adds local variables
    Wrapper_add_local(f, "lenv", "int lenv = 1");
    Wrapper_add_local(f, "values", "Scheme_Object *values[MAXVALUES]");

    if (load_libraries) {
      Printf(f->code, "if (!_function_loaded) { _the_function=mz_load_function(\"%s\");_function_loaded=(1==1); }\n", iname);
      Printf(f->code, "if (!_the_function) { scheme_signal_error(\"Cannot load C function '%s'\"); }\n", iname);
      Printf(f->code, "caller=_the_function;\n");
    }

    // Now write code to extract the parameters (this is super ugly)

    for (i = 0, p = l; i < numargs; i++) {
      /* Skip ignored arguments */

      while (checkAttribute(p, "tmap:in:numinputs", "0")) {
	p = Getattr(p, "tmap:in:next");
      }

      alaqilType *pt = Getattr(p, "type");
      String *ln = Getattr(p, "lname");

      // Produce names of source and target
      Clear(source);
      Clear(target);
      Clear(arg);
      Printf(source, "argv[%d]", i);
      Printf(target, "%s", ln);
      Printv(arg, Getattr(p, "name"), NIL);

      if (i >= numreq) {
	Printf(f->code, "if (argc > %d) {\n", i);
      }
      // Handle parameter types.
      if ((tm = Getattr(p, "tmap:in"))) {
	Replaceall(tm, "$source", source);
	Replaceall(tm, "$target", target);
	Replaceall(tm, "$input", source);
	Setattr(p, "emit:input", source);
	Printv(f->code, tm, "\n", NIL);
	p = Getattr(p, "tmap:in:next");
      } else {
	// no typemap found
	// check if typedef and resolve
	throw_unhandled_mzscheme_type_error(pt);
	p = nextSibling(p);
      }
      if (i >= numreq) {
	Printf(f->code, "}\n");
      }
    }

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

    // Pass output arguments back to the caller.

    for (p = l; p;) {
      if ((tm = Getattr(p, "tmap:argout"))) {
	Replaceall(tm, "$source", Getattr(p, "emit:input"));	/* Deprecated */
	Replaceall(tm, "$target", Getattr(p, "lname"));	/* Deprecated */
	Replaceall(tm, "$arg", Getattr(p, "emit:input"));
	Replaceall(tm, "$input", Getattr(p, "emit:input"));
	Printv(outarg, tm, "\n", NIL);
	p = Getattr(p, "tmap:argout:next");
      } else {
	p = nextSibling(p);
      }
    }

    // Free up any memory allocated for the arguments.

    /* Insert cleanup code */
    for (p = l; p;) {
      if ((tm = Getattr(p, "tmap:freearg"))) {
	Replaceall(tm, "$target", Getattr(p, "lname"));
	Printv(cleanup, tm, "\n", NIL);
	p = Getattr(p, "tmap:freearg:next");
      } else {
	p = nextSibling(p);
      }
    }

    // Now write code to make the function call

    String *actioncode = emit_action(n);

    // Now have return value, figure out what to do with it.
    if ((tm = alaqil_typemap_lookup_out("out", n, alaqil_cresult_name(), f, actioncode))) {
      Replaceall(tm, "$source", alaqil_cresult_name());
      Replaceall(tm, "$target", "values[0]");
      Replaceall(tm, "$result", "values[0]");
      if (GetFlag(n, "feature:new"))
	Replaceall(tm, "$owner", "1");
      else
	Replaceall(tm, "$owner", "0");
      Printv(f->code, tm, "\n", NIL);
    } else {
      throw_unhandled_mzscheme_type_error(d);
    }
    emit_return_variable(n, d, f);

    // Dump the argument output code
    Printv(f->code, Char(outarg), NIL);

    // Dump the argument cleanup code
    Printv(f->code, Char(cleanup), NIL);

    // Look for any remaining cleanup

    if (GetFlag(n, "feature:new")) {
      if ((tm = alaqil_typemap_lookup("newfree", n, alaqil_cresult_name(), 0))) {
	Replaceall(tm, "$source", alaqil_cresult_name());
	Printv(f->code, tm, "\n", NIL);
      }
    }
    // Free any memory allocated by the function being wrapped..

    if ((tm = alaqil_typemap_lookup("ret", n, alaqil_cresult_name(), 0))) {
      Replaceall(tm, "$source", alaqil_cresult_name());
      Printv(f->code, tm, "\n", NIL);
    }
    // Wrap things up (in a manner of speaking)

    Printv(f->code, tab4, "return alaqil_MzScheme_PackageValues(lenv, values);\n", NIL);
    Printf(f->code, "#undef FUNC_NAME\n");
    Printv(f->code, "}\n", NIL);

    /* Substitute the function name */
    Replaceall(f->code, "$symname", iname);

    Wrapper_print(f, f_wrappers);

    if (!Getattr(n, "sym:overloaded")) {

      // Now register the function
      char temp[256];
      sprintf(temp, "%d", numargs);
      if (exporting_destructor) {
	Printf(init_func_def, "alaqil_TypeClientData(alaqilTYPE%s, (void *) %s);\n", alaqiltype_ptr, wname);
      }
      Printf(init_func_def, "scheme_add_global(\"%s\", scheme_make_prim_w_arity(%s,\"%s\",%d,%d),menv);\n", proc_name, wname, proc_name, numreq, numargs);
    } else {
      if (!Getattr(n, "sym:nextSibling")) {
	/* Emit overloading dispatch function */

	int maxargs;
	String *dispatch = alaqil_overload_dispatch(n, "return %s(argc,argv);", &maxargs);

	/* Generate a dispatch wrapper for all overloaded functions */

	Wrapper *df = NewWrapper();
	String *dname = alaqil_name_wrapper(iname);

	Printv(df->def, "static Scheme_Object *\n", dname, "(int argc, Scheme_Object **argv) {", NIL);
	Printv(df->code, dispatch, "\n", NIL);
	Printf(df->code, "scheme_signal_error(\"No matching function for overloaded '%s'\");\n", iname);
	Printf(df->code, "return NULL;\n", iname);
	Printv(df->code, "}\n", NIL);
	Wrapper_print(df, f_wrappers);
	Printf(init_func_def, "scheme_add_global(\"%s\", scheme_make_prim_w_arity(%s,\"%s\",%d,%d),menv);\n", proc_name, dname, proc_name, 0, maxargs);
	DelWrapper(df);
	Delete(dispatch);
	Delete(dname);
      }
    }

    Delete(proc_name);
    Delete(source);
    Delete(target);
    Delete(arg);
    Delete(outarg);
    Delete(cleanup);
    Delete(build);
    DelWrapper(f);
    return alaqil_OK;
  }

  /* ------------------------------------------------------------
   * variableWrapper()
   *
   * Create a link to a C variable.
   * This creates a single function _wrap_alaqil_var_varname().
   * This function takes a single optional argument.   If supplied, it means
   * we are setting this variable to some value.  If omitted, it means we are
   * simply evaluating this variable.  Either way, we return the variables
   * value.
   * ------------------------------------------------------------ */

  virtual int variableWrapper(Node *n) {

    char *name = GetChar(n, "name");
    char *iname = GetChar(n, "sym:name");
    alaqilType *t = Getattr(n, "type");

    String *proc_name = NewString("");
    String *tm;
    String *tm2 = NewString("");
    String *argnum = NewString("0");
    String *arg = NewString("argv[0]");
    Wrapper *f;

    if (!addSymbol(iname, n))
      return alaqil_ERROR;

    f = NewWrapper();

    // evaluation function names
    String *var_name = alaqil_name_wrapper(iname);

    // Build the name for scheme.
    Printv(proc_name, iname, NIL);
    Replaceall(proc_name, "_", "-");
    Setattr(n, "wrap:name", proc_name);

    if ((alaqilType_type(t) != T_USER) || (is_a_pointer(t))) {

      Printf(f->def, "static Scheme_Object *%s(int argc, Scheme_Object** argv) {\n", var_name);
      Printv(f->def, "#define FUNC_NAME \"", proc_name, "\"", NIL);

      Wrapper_add_local(f, "alaqil_result", "Scheme_Object *alaqil_result");

      if (!GetFlag(n, "feature:immutable")) {
	/* Check for a setting of the variable value */
	Printf(f->code, "if (argc) {\n");
	if ((tm = alaqil_typemap_lookup("varin", n, name, 0))) {
	  Replaceall(tm, "$source", "argv[0]");
	  Replaceall(tm, "$target", name);
	  Replaceall(tm, "$input", "argv[0]");
	  Replaceall(tm, "$argnum", "1");
	  emit_action_code(n, f->code, tm);
	} else {
	  throw_unhandled_mzscheme_type_error(t);
	}
	Printf(f->code, "}\n");
      }
      // Now return the value of the variable (regardless
      // of evaluating or setting)

      if ((tm = alaqil_typemap_lookup("varout", n, name, 0))) {
	Replaceall(tm, "$source", name);
	Replaceall(tm, "$target", "alaqil_result");
	Replaceall(tm, "$result", "alaqil_result");
	/* Printf (f->code, "%s\n", tm); */
	emit_action_code(n, f->code, tm);
      } else {
	throw_unhandled_mzscheme_type_error(t);
      }
      Printf(f->code, "\nreturn alaqil_result;\n");
      Printf(f->code, "#undef FUNC_NAME\n");
      Printf(f->code, "}\n");

      Wrapper_print(f, f_wrappers);

      // Now add symbol to the MzScheme interpreter

      Printv(init_func_def,
	     "scheme_add_global(\"", proc_name, "\", scheme_make_prim_w_arity(", var_name, ", \"", proc_name, "\", ", "0", ", ", "1", "), menv);\n", NIL);

    } else {
      alaqil_warning(WARN_TYPEMAP_VAR_UNDEF, input_file, line_number, "Unsupported variable type %s (ignored).\n", alaqilType_str(t, 0));
    }
    Delete(var_name);
    Delete(proc_name);
    Delete(argnum);
    Delete(arg);
    Delete(tm2);
    DelWrapper(f);
    return alaqil_OK;
  }

  /* ------------------------------------------------------------
   * constantWrapper()
   * ------------------------------------------------------------ */

  virtual int constantWrapper(Node *n) {
    char *name = GetChar(n, "name");
    char *iname = GetChar(n, "sym:name");
    alaqilType *type = Getattr(n, "type");
    String *value = Getattr(n, "value");

    String *var_name = NewString("");
    String *proc_name = NewString("");
    String *rvalue = NewString("");
    String *temp = NewString("");
    String *tm;

    // Make a static variable;

    Printf(var_name, "_wrap_const_%s", alaqil_name_mangle(Getattr(n, "sym:name")));

    // Build the name for scheme.
    Printv(proc_name, iname, NIL);
    Replaceall(proc_name, "_", "-");

    if ((alaqilType_type(type) == T_USER) && (!is_a_pointer(type))) {
      alaqil_warning(WARN_TYPEMAP_CONST_UNDEF, input_file, line_number, "Unsupported constant value.\n");
      return alaqil_NOWRAP;
    }
    // See if there's a typemap

    Printv(rvalue, value, NIL);
    if ((alaqilType_type(type) == T_CHAR) && (is_a_pointer(type) == 1)) {
      temp = Copy(rvalue);
      Clear(rvalue);
      Printv(rvalue, "\"", temp, "\"", NIL);
    }
    if ((alaqilType_type(type) == T_CHAR) && (is_a_pointer(type) == 0)) {
      Delete(temp);
      temp = Copy(rvalue);
      Clear(rvalue);
      Printv(rvalue, "'", temp, "'", NIL);
    }
    if ((tm = alaqil_typemap_lookup("constant", n, name, 0))) {
      Replaceall(tm, "$source", rvalue);
      Replaceall(tm, "$value", rvalue);
      Replaceall(tm, "$target", name);
      Printf(f_init, "%s\n", tm);
    } else {
      // Create variable and assign it a value

      Printf(f_header, "static %s = ", alaqilType_lstr(type, var_name));
      bool is_enum_item = (Cmp(nodeType(n), "enumitem") == 0);
      if ((alaqilType_type(type) == T_STRING)) {
	Printf(f_header, "\"%s\";\n", value);
      } else if (alaqilType_type(type) == T_CHAR && !is_enum_item) {
	Printf(f_header, "\'%s\';\n", value);
      } else {
	Printf(f_header, "%s;\n", value);
      }

      // Now create a variable declaration

      {
	/* Hack alert: will cleanup later -- Dave */
	Node *nn = NewHash();
	Setfile(nn, Getfile(n));
	Setline(nn, Getline(n));
	Setattr(nn, "name", var_name);
	Setattr(nn, "sym:name", iname);
	Setattr(nn, "type", type);
	SetFlag(nn, "feature:immutable");
	variableWrapper(nn);
	Delete(nn);
      }
    }
    Delete(proc_name);
    Delete(rvalue);
    Delete(temp);
    return alaqil_OK;
  }

  virtual int destructorHandler(Node *n) {
    exporting_destructor = true;
    Language::destructorHandler(n);
    exporting_destructor = false;
    return alaqil_OK;
  }

  /* ------------------------------------------------------------
   * classHandler()
   * ------------------------------------------------------------ */
  virtual int classHandler(Node *n) {
    String *mangled_classname = 0;
    String *real_classname = 0;
    String *scm_structname = NewString("");
    alaqilType *ctype_ptr = NewStringf("p.%s", getClassType());

    alaqilType *t = NewStringf("p.%s", Getattr(n, "name"));
    alaqiltype_ptr = alaqilType_manglestr(t);
    Delete(t);

    cls_alaqiltype = alaqilType_manglestr(Getattr(n, "name"));


    fieldnames_tab = NewString("");
    convert_tab = NewString("");
    convert_proto_tab = NewString("");

    struct_name = Getattr(n, "sym:name");
    mangled_struct_name = alaqil_name_mangle(Getattr(n, "sym:name"));

    Printv(scm_structname, struct_name, NIL);
    Replaceall(scm_structname, "_", "-");

    real_classname = Getattr(n, "name");
    mangled_classname = alaqil_name_mangle(real_classname);

    Printv(fieldnames_tab, "static const char *_alaqil_struct_", cls_alaqiltype, "_field_names[] = { \n", NIL);

    Printv(convert_proto_tab, "static Scheme_Object *_alaqil_convert_struct_", cls_alaqiltype, "(", alaqilType_str(ctype_ptr, "ptr"), ");\n", NIL);

    Printv(convert_tab, "static Scheme_Object *_alaqil_convert_struct_", cls_alaqiltype, "(", alaqilType_str(ctype_ptr, "ptr"), ")\n {\n", NIL);

    Printv(convert_tab,
	   tab4, "Scheme_Object *obj;\n", tab4, "Scheme_Object *fields[_alaqil_struct_", cls_alaqiltype, "_field_names_cnt];\n", tab4, "int i = 0;\n\n", NIL);

    /* Generate normal wrappers */
    Language::classHandler(n);

    Printv(convert_tab, tab4, "obj = scheme_make_struct_instance(", "_alaqil_struct_type_", cls_alaqiltype, ", i, fields);\n", NIL);
    Printv(convert_tab, tab4, "return obj;\n}\n\n", NIL);

    Printv(fieldnames_tab, "};\n", NIL);

    Printv(f_header, "static Scheme_Object *_alaqil_struct_type_", cls_alaqiltype, ";\n", NIL);

    Printv(f_header, fieldnames_tab, NIL);
    Printv(f_header, "#define  _alaqil_struct_", cls_alaqiltype, "_field_names_cnt (sizeof(_alaqil_struct_", cls_alaqiltype, "_field_names)/sizeof(char*))\n", NIL);

    Printv(f_header, convert_proto_tab, NIL);
    Printv(f_wrappers, convert_tab, NIL);

    Printv(init_func_def, "_alaqil_struct_type_", cls_alaqiltype,
	   " = alaqil_MzScheme_new_scheme_struct(menv, \"", scm_structname, "\", ",
	   "_alaqil_struct_", cls_alaqiltype, "_field_names_cnt,", "(char**) _alaqil_struct_", cls_alaqiltype, "_field_names);\n", NIL);

    Delete(mangled_classname);
    Delete(alaqiltype_ptr);
    alaqiltype_ptr = 0;
    Delete(fieldnames_tab);
    Delete(convert_tab);
    Delete(ctype_ptr);
    Delete(convert_proto_tab);
    struct_name = 0;
    mangled_struct_name = 0;
    Delete(cls_alaqiltype);
    cls_alaqiltype = 0;

    return alaqil_OK;
  }

  /* ------------------------------------------------------------
   * membervariableHandler()
   * ------------------------------------------------------------ */

  virtual int membervariableHandler(Node *n) {
    Language::membervariableHandler(n);

    if (!is_smart_pointer()) {
      String *symname = Getattr(n, "sym:name");
      String *name = Getattr(n, "name");
      alaqilType *type = Getattr(n, "type");
      String *alaqiltype = alaqilType_manglestr(Getattr(n, "type"));
      String *tm = 0;
      String *access_mem = NewString("");
      alaqilType *ctype_ptr = NewStringf("p.%s", Getattr(n, "type"));

      Printv(fieldnames_tab, tab4, "\"", symname, "\",\n", NIL);
      Printv(access_mem, "(ptr)->", name, NIL);
      if ((alaqilType_type(type) == T_USER) && (!is_a_pointer(type))) {
	Printv(convert_tab, tab4, "fields[i++] = ", NIL);
	Printv(convert_tab, "_alaqil_convert_struct_", alaqiltype, "((", alaqilType_str(ctype_ptr, 0), ")&((ptr)->", name, "));\n", NIL);
      } else if ((tm = alaqil_typemap_lookup("varout", n, access_mem, 0))) {
	Replaceall(tm, "$result", "fields[i++]");
	Printv(convert_tab, tm, "\n", NIL);
      } else
	alaqil_warning(WARN_TYPEMAP_VAR_UNDEF, input_file, line_number, "Unsupported member variable type %s (ignored).\n", alaqilType_str(type, 0));

      Delete(access_mem);
    }
    return alaqil_OK;
  }


  /* ------------------------------------------------------------
   * validIdentifier()
   * ------------------------------------------------------------ */

  virtual int validIdentifier(String *s) {
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

  String *runtimeCode() {
    String *s = alaqil_include_sys("mzrun.swg");
    if (!s) {
      Printf(stderr, "*** Unable to open 'mzrun.swg'\n");
      s = NewString("");
    }
    return s;
  }

  String *defaultExternalRuntimeFilename() {
    return NewString("alaqilmzrun.h");
  }
};

/* -----------------------------------------------------------------------------
 * alaqil_mzscheme()    - Instantiate module
 * ----------------------------------------------------------------------------- */

static Language *new_alaqil_mzscheme() {
  return new MZSCHEME();
}
extern "C" Language *alaqil_mzscheme(void) {
  return new_alaqil_mzscheme();
}
