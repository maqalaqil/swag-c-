/* ----------------------------------------------------------------------------- 
 * This file is part of alaqil, which is licensed as a whole under version 3 
 * (or any later version) of the GNU General Public License. Some additional
 * terms also apply to certain portions of alaqil. The full details of the alaqil
 * license and copyrights can be found in the LICENSE and COPYRIGHT files
 * included with the alaqil source code as distributed by the alaqil developers
 * and at http://www.alaqil.org/legal.html.
 *
 * alaqilmain.cxx
 *
 * Simplified Wrapper and Interface Generator  (alaqil)
 *
 * This file is the main entry point to alaqil.  It collects the command
 * line options, registers built-in language modules, and instantiates
 * a module for code generation.   If adding new language modules
 * to alaqil, you would modify this file.
 * ----------------------------------------------------------------------------- */

#include "alaqilmod.h"
#include <ctype.h>

/* Module factories.  These functions are used to instantiate
   the built-in language modules.    If adding a new language
   module to alaqil, place a similar function here. Make sure
   the function has "C" linkage.  This is required so that modules
   can be dynamically loaded in future versions. */

extern "C" {
  Language *alaqil_csharp(void);
  Language *alaqil_d(void);
  Language *alaqil_go(void);
  Language *alaqil_guile(void);
  Language *alaqil_java(void);
  Language *alaqil_javascript(void);
  Language *alaqil_lua(void);
  Language *alaqil_mzscheme(void);
  Language *alaqil_ocaml(void);
  Language *alaqil_octave(void);
  Language *alaqil_perl5(void);
  Language *alaqil_php(void);
  Language *alaqil_python(void);
  Language *alaqil_r(void);
  Language *alaqil_ruby(void);
  Language *alaqil_scilab(void);
  Language *alaqil_tcl(void);
  Language *alaqil_xml(void);
}

/* Association of command line options to language modules.
   Place an entry for new language modules here, keeping the
   list sorted alphabetically. */

static TargetLanguageModule modules[] = {
  {"-allegrocl", NULL, "ALLEGROCL", Disabled},
  {"-chicken", NULL, "CHICKEN", Disabled},
  {"-clisp", NULL, "CLISP", Disabled},
  {"-cffi", NULL, "CFFI", Disabled},
  {"-csharp", alaqil_csharp, "C#", Supported},
  {"-d", alaqil_d, "D", Supported},
  {"-go", alaqil_go, "Go", Supported},
  {"-guile", alaqil_guile, "Guile", Supported},
  {"-java", alaqil_java, "Java", Supported},
  {"-javascript", alaqil_javascript, "Javascript", Supported},
  {"-lua", alaqil_lua, "Lua", Supported},
  {"-modula3", NULL, "Modula 3", Disabled},
  {"-mzscheme", alaqil_mzscheme, "MzScheme/Racket", Experimental},
  {"-ocaml", alaqil_ocaml, "OCaml", Experimental},
  {"-octave", alaqil_octave, "Octave", Supported},
  {"-perl", alaqil_perl5, NULL, Supported},
  {"-perl5", alaqil_perl5, "Perl 5", Supported},
  {"-php", alaqil_php, NULL, Supported},
  {"-php5", NULL, "PHP 5", Disabled},
  {"-php7", alaqil_php, "PHP 7", Supported},
  {"-pike", NULL, "Pike", Disabled},
  {"-python", alaqil_python, "Python", Supported},
  {"-r", alaqil_r, "R (aka GNU S)", Supported},
  {"-ruby", alaqil_ruby, "Ruby", Supported},
  {"-scilab", alaqil_scilab, "Scilab", Supported},
  {"-sexp", NULL, "Lisp S-Expressions", Disabled},
  {"-tcl", alaqil_tcl, NULL, Supported},
  {"-tcl8", alaqil_tcl, "Tcl 8", Supported},
  {"-uffi", NULL, "Common Lisp / UFFI", Disabled},
  {"-xml", alaqil_xml, "XML", Supported},
  {NULL, NULL, NULL, Disabled}
};

#ifdef MACalaqil
#include <console.h>
#include <SIOUX.h>
#endif

//-----------------------------------------------------------------
// main()
//
// Main program.    Initializes the files and starts the parser.
//-----------------------------------------------------------------

void alaqil_merge_envopt(const char *env, int oargc, char *oargv[], int *nargc, char ***nargv) {
  if (!env) {
    *nargc = oargc;
    *nargv = (char **)malloc(sizeof(char *) * (oargc + 1));
    memcpy(*nargv, oargv, sizeof(char *) * (oargc + 1));
    return;
  }

  int argc = 1;
  int arge = oargc + 1024;
  char **argv = (char **) malloc(sizeof(char *) * (arge + 1));
  char *buffer = (char *) malloc(2048);
  char *b = buffer;
  char *be = b + 1023;
  const char *c = env;
  while ((b != be) && *c && (argc < arge)) {
    while (isspace(*c) && *c)
      ++c;
    if (*c) {
      argv[argc] = b;
      ++argc;
    }
    while ((b != be) && *c && !isspace(*c)) {
      *(b++) = *(c++);
    }
    *b++ = 0;
  }

  argv[0] = oargv[0];
  for (int i = 1; (i < oargc) && (argc < arge); ++i, ++argc) {
    argv[argc] = oargv[i];
  }
  argv[argc] = NULL;

  *nargc = argc;
  *nargv = argv;
}

static void insert_option(int *argc, char ***argv, int index, char const *start, char const *end) {
  int new_argc = *argc;
  char **new_argv = *argv;
  size_t option_len = end - start;

  // Preserve the NULL pointer at argv[argc]
  new_argv = (char **)realloc(new_argv, (new_argc + 2) * sizeof(char *));
  memmove(&new_argv[index + 1], &new_argv[index], sizeof(char *) * (new_argc + 1 - index));
  new_argc++;

  new_argv[index] = (char *)malloc(option_len + 1);
  memcpy(new_argv[index], start, option_len);
  new_argv[index][option_len] = '\0';

  *argc = new_argc;
  *argv = new_argv;
}

static void merge_options_files(int *argc, char ***argv) {
  static const int BUFFER_SIZE = 4096;
  char buffer[BUFFER_SIZE];
  int i;
  int insert;
  char **new_argv = *argv;
  int new_argc = *argc;
  FILE *f;

  i = 1;
  while (i < new_argc) {
    if (new_argv[i] && new_argv[i][0] == '@' && (f = fopen(&new_argv[i][1], "r"))) {
      char c;
      char *b;
      char *be = &buffer[BUFFER_SIZE];
      int quote = 0;
      bool escape = false;

      new_argc--;
      memmove(&new_argv[i], &new_argv[i + 1], sizeof(char *) * (new_argc - i));
      insert = i;
      b = buffer;

      while ((c = fgetc(f)) != EOF) {
        if (escape) {
          if (b != be) {
            *b = c;
            ++b;
          }
          escape = false;
        } else if (c == '\\') {
          escape = true;
        } else if (!quote && (c == '\'' || c == '"')) {
          quote = c;
        } else if (quote && c == quote) {
          quote = 0;
        } else if (isspace(c) && !quote) {
          if (b != buffer) {
            insert_option(&new_argc, &new_argv, insert, buffer, b);
            insert++;

            b = buffer;
          }
        } else if (b != be) {
          *b = c;
          ++b;
        }
      }
      if (b != buffer)
        insert_option(&new_argc, &new_argv, insert, buffer, b);
      fclose(f);
    } else {
      ++i;
    }
  }

  *argv = new_argv;
  *argc = new_argc;
}

int main(int margc, char **margv) {
  int i;
  const TargetLanguageModule *language_module = 0;

  int argc;
  char **argv;

  alaqil_merge_envopt(getenv("alaqil_FEATURES"), margc, margv, &argc, &argv);
  merge_options_files(&argc, &argv);

#ifdef MACalaqil
  SIOUXSettings.asktosaveonclose = false;
  argc = ccommand(&argv);
#endif

  alaqil_init_args(argc, argv);

  /* Get options */
  for (i = 1; i < argc; i++) {
    if (argv[i]) {
      bool is_target_language_module = false;
      for (int j = 0; modules[j].name; j++) {
	if (strcmp(modules[j].name, argv[i]) == 0) {
	  language_module = &modules[j];
	  is_target_language_module = true;
	  break;
	}
      }
      if (is_target_language_module) {
	alaqil_mark_arg(i);
	if (language_module->status == Disabled) {
	  if (language_module->help)
	    Printf(stderr, "Target language option %s (%s) is no longer supported.\n", language_module->name, language_module->help);
	  else
	    Printf(stderr, "Target language option %s is no longer supported.\n", language_module->name);
	  alaqil_exit(EXIT_FAILURE);
	}
      } else if ((strcmp(argv[i], "-help") == 0) || (strcmp(argv[i], "--help") == 0)) {
	if (strcmp(argv[i], "--help") == 0)
	  strcpy(argv[i], "-help");
	Printf(stdout, "Supported Target Language Options\n");
	for (int j = 0; modules[j].name; j++) {
	  if (modules[j].help && modules[j].status == Supported) {
	    Printf(stdout, "     %-15s - Generate %s wrappers\n", modules[j].name, modules[j].help);
	  }
	}
	Printf(stdout, "\nExperimental Target Language Options\n");
	for (int j = 0; modules[j].name; j++) {
	  if (modules[j].help && modules[j].status == Experimental) {
	    Printf(stdout, "     %-15s - Generate %s wrappers\n", modules[j].name, modules[j].help);
	  }
	}
	// alaqil_mark_arg not called as the general -help options also need to be displayed later on
      }
    }
  }

  int res = alaqil_main(argc, argv, language_module);

  return res;
}
