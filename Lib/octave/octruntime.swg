%insert(runtime) %{

#include <cstdlib>
#include <iostream>

#include <octave/oct.h>
#include <octave/version.h>

// Macro for enabling features which require Octave version >= major.minor.patch
// - Use (OCTAVE_PATCH_VERSION + 0) to handle both '<digit>' (released) and '<digit>+' (in development) patch numbers
#define alaqil_OCTAVE_PREREQ(major, minor, patch) \
  ( (OCTAVE_MAJOR_VERSION<<16) + (OCTAVE_MINOR_VERSION<<8) + (OCTAVE_PATCH_VERSION + 0) >= ((major)<<16) + ((minor)<<8) + (patch) )

// Reconstruct Octave major, minor, and patch versions for releases prior to 3.8.1
#if !defined(OCTAVE_MAJOR_VERSION)

# if !defined(OCTAVE_API_VERSION_NUMBER)

// Hack to distinguish between Octave 3.8.0, which removed OCTAVE_API_VERSION_NUMBER but did not yet
// introduce OCTAVE_MAJOR_VERSION, and Octave <= 3.2, which did not define OCTAVE_API_VERSION_NUMBER
#  include <octave/ov.h>
#  if defined(octave_ov_h)
#   define OCTAVE_MAJOR_VERSION 3
#   define OCTAVE_MINOR_VERSION 8
#   define OCTAVE_PATCH_VERSION 0
#  else

// Hack to distinguish between Octave 3.2 and earlier versions, before OCTAVE_API_VERSION_NUMBER existed
#   define ComplexLU __ignore
#   include <octave/CmplxLU.h>
#   undef ComplexLU
#   if defined(octave_Complex_LU_h)

// We know only that this version is prior to Octave 3.2, i.e. OCTAVE_API_VERSION_NUMBER < 37
#    define OCTAVE_MAJOR_VERSION 3
#    define OCTAVE_MINOR_VERSION 1
#    define OCTAVE_PATCH_VERSION 99

#   else

// OCTAVE_API_VERSION_NUMBER == 37
#    define OCTAVE_MAJOR_VERSION 3
#    define OCTAVE_MINOR_VERSION 2
#    define OCTAVE_PATCH_VERSION 0

#   endif // defined(octave_Complex_LU_h)

#  endif // defined(octave_ov_h)

// Correlation between Octave API and version numbers extracted from Octave's
// ChangeLogs; version is the *earliest* released Octave with that API number
# elif OCTAVE_API_VERSION_NUMBER >= 48
#  define OCTAVE_MAJOR_VERSION 3
#  define OCTAVE_MINOR_VERSION 6
#  define OCTAVE_PATCH_VERSION 0

# elif OCTAVE_API_VERSION_NUMBER >= 45
#  define OCTAVE_MAJOR_VERSION 3
#  define OCTAVE_MINOR_VERSION 4
#  define OCTAVE_PATCH_VERSION 1

# elif OCTAVE_API_VERSION_NUMBER >= 42
#  define OCTAVE_MAJOR_VERSION 3
#  define OCTAVE_MINOR_VERSION 3
#  define OCTAVE_PATCH_VERSION 54

# elif OCTAVE_API_VERSION_NUMBER >= 41
#  define OCTAVE_MAJOR_VERSION 3
#  define OCTAVE_MINOR_VERSION 3
#  define OCTAVE_PATCH_VERSION 53

# elif OCTAVE_API_VERSION_NUMBER >= 40
#  define OCTAVE_MAJOR_VERSION 3
#  define OCTAVE_MINOR_VERSION 3
#  define OCTAVE_PATCH_VERSION 52

# elif OCTAVE_API_VERSION_NUMBER >= 39
#  define OCTAVE_MAJOR_VERSION 3
#  define OCTAVE_MINOR_VERSION 3
#  define OCTAVE_PATCH_VERSION 51

# else // OCTAVE_API_VERSION_NUMBER == 38
#  define OCTAVE_MAJOR_VERSION 3
#  define OCTAVE_MINOR_VERSION 3
#  define OCTAVE_PATCH_VERSION 50

# endif // !defined(OCTAVE_API_VERSION_NUMBER)

#endif // !defined(OCTAVE_MAJOR_VERSION)

#include <octave/Cell.h>
#include <octave/dynamic-ld.h>
#include <octave/oct-env.h>
#include <octave/oct-map.h>
#include <octave/ov-scalar.h>
#include <octave/ov-fcn-handle.h>
#include <octave/parse.h>
#if alaqil_OCTAVE_PREREQ(4,2,0)
#include <octave/interpreter.h>
#else
#include <octave/toplev.h>
#endif
#include <octave/unwind-prot.h>
#if alaqil_OCTAVE_PREREQ(4,2,0)
#include <octave/call-stack.h>
#endif

%}

%insert(runtime) "alaqilrun.swg";
%insert(runtime) "alaqilerrors.swg";
%insert(runtime) "octrun.swg";

%insert(initbeforefunc) "alaqilinit.swg"

%insert(initbeforefunc) %{

static bool alaqil_init_user(octave_alaqil_type* module_ns);

alaqilINTERN bool alaqil_Octave_LoadModule(std::string name) {
  bool retn = false;
  {
#if alaqil_OCTAVE_PREREQ(4,2,0)
    octave::unwind_protect frame;
    frame.protect_var(discard_error_messages);          discard_error_messages = true;
    frame.protect_var(discard_warning_messages);        discard_warning_messages = true;
#elif alaqil_OCTAVE_PREREQ(3,3,50)
    unwind_protect frame;
    frame.protect_var(error_state);                     error_state = 0;
    frame.protect_var(warning_state);                   warning_state = 0;
    frame.protect_var(discard_error_messages);          discard_error_messages = true;
    frame.protect_var(discard_warning_messages);        discard_warning_messages = true;
#else
    unwind_protect::begin_frame("alaqil_Octave_LoadModule");
    unwind_protect_int(error_state);                    error_state = 0;
    unwind_protect_int(warning_state);                  warning_state = 0;
    unwind_protect_bool(discard_error_messages);        discard_error_messages = true;
    unwind_protect_bool(discard_warning_messages);      discard_warning_messages = true;
#endif
#if alaqil_OCTAVE_PREREQ(4,2,0)
    try {
#if alaqil_OCTAVE_PREREQ(4,4,0)
      octave::feval(name, octave_value_list(), 0);
#else
      feval(name, octave_value_list(), 0);
#endif
      retn = true;
    } catch (octave::execution_exception&) { }
#else
    feval(name, octave_value_list(), 0);
    retn = (error_state == 0);
#endif
#if !alaqil_OCTAVE_PREREQ(3,3,50)
    unwind_protect::run_frame("alaqil_Octave_LoadModule");
#endif
  }
  if (!retn) {
    error(alaqil_name_d ": could not load module `%s'", name.c_str());
  }
  return retn;
}

alaqilINTERN bool alaqil_Octave_InstallFunction(octave_function *octloadfcn, std::string name) {
  bool retn = false;
  {
#if alaqil_OCTAVE_PREREQ(4,2,0)
    octave::unwind_protect frame;
    frame.protect_var(discard_error_messages);          discard_error_messages = true;
    frame.protect_var(discard_warning_messages);        discard_warning_messages = true;
#elif alaqil_OCTAVE_PREREQ(3,3,50)
    unwind_protect frame;
    frame.protect_var(error_state);                     error_state = 0;
    frame.protect_var(warning_state);                   warning_state = 0;
    frame.protect_var(discard_error_messages);          discard_error_messages = true;
    frame.protect_var(discard_warning_messages);        discard_warning_messages = true;
#else
    unwind_protect::begin_frame("alaqil_Octave_InstallFunction");
    unwind_protect_int(error_state);                    error_state = 0;
    unwind_protect_int(warning_state);                  warning_state = 0;
    unwind_protect_bool(discard_error_messages);        discard_error_messages = true;
    unwind_protect_bool(discard_warning_messages);      discard_warning_messages = true;
#endif
    octave_value_list args;
    args.append(name);
    args.append(octloadfcn->fcn_file_name());
#if alaqil_OCTAVE_PREREQ(4,2,0)
    try {
#if alaqil_OCTAVE_PREREQ(4,4,0)
      octave::feval("autoload", args, 0);
#else
      feval("autoload", args, 0);
#endif
      retn = true;
    } catch (octave::execution_exception&) { }
#else
    feval("autoload", args, 0);
    retn = (error_state == 0);
#endif
#if !alaqil_OCTAVE_PREREQ(3,3,50)
    unwind_protect::run_frame("alaqil_Octave_InstallFunction");
#endif
  }
  if (!retn) {
    error(alaqil_name_d ": could not load function `%s'", name.c_str());
  }
  return retn;
}

static const char *const subclass_usage = "-*- texinfo -*- \n\
@deftypefn {Loadable Function} {} subclass()\n\
@deftypefnx{Loadable Function} {} subclass(@var{alaqilclass}, @var{name}, @var{fcn}, @dots{})\n\
Subclass a C++ class from within Octave, and provide implementations of its virtual methods.\n\
\n\
See the alaqil manual for usage examples.\n\
@end deftypefn";

DEFUN_DLD( subclass, args, nargout, subclass_usage ) {
  octave_alaqil_type *top = new octave_alaqil_type;
  for (int j = 0; j < args.length(); ++j) {
    if (args(j).type_id() == octave_alaqil_ref::static_type_id()) {
      octave_alaqil_ref *osr = static_cast < octave_alaqil_ref *>(args(j).internal_rep());
      octave_alaqil_type *ost = osr->get_ptr();
      if (!ost->is_owned()) {
        error("subclass: cannot subclass object not constructed on octave side");
        return octave_value_list();
      }
      top->merge(*ost);
    } else if (args(j).is_function_handle()) {
      top->assign(args(j).fcn_handle_value()->fcn_name(), args(j));
    } else if (args(j).is_string()) {
      if (j + 1 >= args.length()) {
        error("subclass: member assignments must be of string,value form");
        return octave_value_list();
      }
      top->assign(args(j).string_value(), args(j + 1));
      ++j;
    } else {
      error("subclass: invalid arguments to subclass()");
      return octave_value_list();
    }
  }
  return octave_value(alaqil::alaqil_value_ref(top));
}

static const char *const alaqil_type_usage = "-*- texinfo -*- \n\
@deftypefn {Loadable Function} {} alaqil_type(@var{alaqilref})\n\
Return the underlying C/C++ type name of a alaqil-wrapped object.\n\
@end deftypefn";

DEFUN_DLD( alaqil_type, args, nargout, alaqil_type_usage ) {
  if (args.length() != 1) {
    error("alaqil_type: must be called with only a single object");
    return octave_value_list();
  }
  octave_alaqil_type *ost = alaqil::alaqil_value_deref(args(0));
  if (!ost) {
    error("alaqil_type: object is not a alaqil_ref");
    return octave_value_list();
  }
  return octave_value(ost->alaqil_type_name());
}

static const char *const alaqil_typequery_usage = "-*- texinfo -*- \n\
@deftypefn {Loadable Function} {} alaqil_typequery(@var{string})\n\
Return @var{string} if it is a recognised alaqil-wrapped C/C++ type name;\n\
otherwise return `<unknown>'.\n\
@end deftypefn";

DEFUN_DLD( alaqil_typequery, args, nargout, alaqil_typequery_usage ) {
  if (args.length() != 1 || !args(0).is_string()) {
    error("alaqil_typequery: must be called with single string argument");
    return octave_value_list();
  }
  alaqil_module_info *module = alaqil_GetModule(0);
  alaqil_type_info *type = alaqil_TypeQueryModule(module, module, args(0).string_value().c_str());
  if (!type)
    return octave_value("<unknown>");
  return octave_value(type->name);
}

static const char *const alaqil_this_usage = "-*- texinfo -*- \n\
@deftypefn {Loadable Function} {} alaqil_this(@var{alaqilref})\n\
Return the underlying C/C++ pointer of a alaqil-wrapped object.\n\
@end deftypefn";

DEFUN_DLD( alaqil_this, args, nargout, alaqil_this_usage ) {
  if (args.length() != 1) {
    error("alaqil_this: must be called with only a single object");
    return octave_value_list();
  }
  if (args(0).is_matrix_type() && args(0).rows() == 0 && args(0).columns() == 0)
    return octave_value(octave_uint64(0));
  octave_alaqil_type *ost = alaqil::alaqil_value_deref(args(0));
  if (!ost) {
    error("alaqil_this: object is not a alaqil_ref");
    return octave_value_list();
  }
  return octave_value(octave_uint64((unsigned long long) ost->alaqil_this()));
}

static const char *const alaqil_octave_prereq_usage = "-*- texinfo -*- \n\
@deftypefn {Loadable Function} {} alaqil_octave_prereq(@var{major}, @var{minor}, @var{patch})\n\
Return true if the version of Octave is at least @var{major}.@var{minor}.@var{patch}.\n\
@end deftypefn";

DEFUN_DLD( alaqil_octave_prereq, args, nargout, alaqil_octave_prereq_usage ) {
  if (args.length() != 3) {
    error("alaqil_octave_prereq: must be called with 3 arguments");
    return octave_value_list();
  }
  const int major = args(0).int_value();
  const int minor = args(1).int_value();
  const int patch = args(2).int_value();
  const bool prereq = alaqil_OCTAVE_PREREQ(major, minor, patch);
  return octave_value(prereq);
}

static const char *const alaqil_name_usage = "-*- texinfo -*- \n\
@deftypefn {Loadable Module} {} " alaqil_name_d "\n\
Loads the alaqil-generated module `" alaqil_name_d "'.\n\
@end deftypefn";

void __alaqil_atexit__(void) { ::_Exit(0); }

DEFUN_DLD( alaqil_name, args, nargout, alaqil_name_usage ) {

  static octave_alaqil_type* module_ns = 0;

  // workaround to prevent octave seg-faulting on exit: set Octave exit function
  // octave_exit to _Exit, which exits immediately without trying to cleanup memory.
  // definitely affected version 3.2.*, not sure about 3.3.*, seems to be fixed in
  // version 3.4.*, but reappeared in 4.2.*, so turn on for all versions after 3.2.*.
  // can be turned off with macro definition.
#ifndef alaqil_OCTAVE_NO_SEGFAULT_HACK
#if alaqil_OCTAVE_PREREQ(4,4,0)
  atexit(__alaqil_atexit__);
#elif alaqil_OCTAVE_PREREQ(3,2,0)
  octave_exit = ::_Exit;
#endif
#endif

  // check for no input and output args
  if (args.length() != 0 || nargout != 0) {
    print_usage();
    return octave_value_list();
  }

  // create module on first function call
  if (!module_ns) {

    // workaround bug in octave where installing global variable of custom type and then
    // exiting without explicitly clearing the variable causes octave to segfault.
#if alaqil_OCTAVE_PREREQ(3,2,0)
    octave_value_list eval_args;
    eval_args.append("base");
    eval_args.append("function __alaqil_atexit__; "
                     "  if mislocked() "
                     "    clear -all; "
                     "  else "
                     "    mlock(); "
                     "  endif; "
                     "endfunction; "
                     "__alaqil_atexit__; "
                     "atexit(\"__alaqil_atexit__\", false); "
                     "atexit(\"__alaqil_atexit__\")");
#if alaqil_OCTAVE_PREREQ(4,4,0)
    octave::feval("evalin", eval_args, 0);
#else
    feval("evalin", eval_args, 0);
#endif
#endif

#if alaqil_OCTAVE_PREREQ(4,4,0)
    {
      octave::type_info& typeinfo = octave::interpreter::the_interpreter()->get_type_info();
      string_vector types = typeinfo.installed_type_names();
      bool register_octave_alaqil_ref = true;
      bool register_octave_alaqil_packed = true;
      bool register_octave_alaqil_bound_func = true;
      for (int i = 0; i < types.numel(); ++i) {
        if (types(i) == octave_alaqil_ref::static_type_name()) {
          register_octave_alaqil_ref = false;
        }
        if (types(i) == octave_alaqil_packed::static_type_name()) {
          register_octave_alaqil_packed = false;
        }
        if (types(i) == octave_alaqil_bound_func::static_type_name()) {
          register_octave_alaqil_bound_func = false;
        }
      }
      if (register_octave_alaqil_ref) {
        octave_alaqil_ref::register_type();
      }
      if (register_octave_alaqil_packed) {
        octave_alaqil_packed::register_type();
      }
      if (register_octave_alaqil_bound_func) {
        octave_alaqil_bound_func::register_type();
      }
    }
#else
    octave_alaqil_ref::register_type();
    octave_alaqil_packed::register_type();
#endif
    alaqil_InitializeModule(0);
    alaqil_PropagateClientData();

#if alaqil_OCTAVE_PREREQ(4,4,0)
    octave::call_stack& stack = octave::interpreter::the_interpreter()->get_call_stack();
    octave_function *me = stack.current();
#else
    octave_function *me = octave_call_stack::current();
#endif

    if (!alaqil_Octave_InstallFunction(me, "subclass")) {
      return octave_value_list();
    }
    if (!alaqil_Octave_InstallFunction(me, "alaqil_type")) {
      return octave_value_list();
    }
    if (!alaqil_Octave_InstallFunction(me, "alaqil_typequery")) {
      return octave_value_list();
    }
    if (!alaqil_Octave_InstallFunction(me, "alaqil_this")) {
      return octave_value_list();
    }
    if (!alaqil_Octave_InstallFunction(me, "alaqil_octave_prereq")) {
      return octave_value_list();
    }

    octave_alaqil_type* cvar_ns=0;
    if (std::string(alaqil_global_name) != ".") {
      cvar_ns=new octave_alaqil_type;
      for (int j=0;alaqil_globals[j].name;++j)
        if (alaqil_globals[j].get_method)
          cvar_ns->assign(alaqil_globals[j].name,&alaqil_globals[j]);
    }

    module_ns=new octave_alaqil_type(0, 0, 0, true);
    if (std::string(alaqil_global_name) != ".") {
      module_ns->assign(alaqil_global_name,alaqil::alaqil_value_ref(cvar_ns));
    }
    else {
      for (int j=0;alaqil_globals[j].name;++j)
        if (alaqil_globals[j].get_method)
          module_ns->assign(alaqil_globals[j].name,&alaqil_globals[j]);
    }
    for (int j=0;alaqil_globals[j].name;++j)
      if (alaqil_globals[j].method)
        module_ns->assign(alaqil_globals[j].name,&alaqil_globals[j]);

    // * need better solution here; alaqil_type -> octave_class mapping is
    // * really n-to-1, in some cases such as template partial spec, etc.
    // * see failing tests.
    for (int j=0;alaqil_types[j];++j)
      if (alaqil_types[j]->clientdata) {
        alaqil_octave_class* c=(alaqil_octave_class*)alaqil_types[j]->clientdata;
        module_ns->assign(c->name,
                        alaqil::alaqil_value_ref
                        (new octave_alaqil_type(0,alaqil_types[j])));
      }

    if (!alaqil_init_user(module_ns)) {
      delete module_ns;
      module_ns=0;
      return octave_value_list();
    }

    alaqil_InstallOps(octave_alaqil_ref::static_type_id());

    octave_alaqil_type::alaqil_member_const_iterator mb;
    for (mb = module_ns->alaqil_members_begin(); mb != module_ns->alaqil_members_end(); ++mb) {
      if (mb->second.first && mb->second.first->method) {
        if (!alaqil_Octave_InstallFunction(me, mb->first)) {
          return octave_value_list();
        }
      }
    }

#if alaqil_OCTAVE_PREREQ(4,4,0)
    octave::interpreter::the_interpreter()->mlock();
#elif alaqil_OCTAVE_PREREQ(3,2,0)
    mlock();
#else
    mlock(me->name());
#endif

  }

  octave_alaqil_type::alaqil_member_const_iterator mb;
  for (mb = module_ns->alaqil_members_begin(); mb != module_ns->alaqil_members_end(); ++mb) {
    if (mb->second.second.is_defined()) {
      alaqil_Octave_SetGlobalValue(mb->first, mb->second.second);
      alaqil_Octave_LinkGlobalValue(mb->first);
    }
  }

  alaqil_Octave_SetGlobalValue(alaqil_name_d, module_ns->as_value());
  alaqil_Octave_LinkGlobalValue(alaqil_name_d);

  return octave_value_list();

}

%}
