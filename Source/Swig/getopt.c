/* ----------------------------------------------------------------------------- 
 * This file is part of alaqil, which is licensed as a whole under version 3 
 * (or any later version) of the GNU General Public License. Some additional
 * terms also apply to certain portions of alaqil. The full details of the alaqil
 * license and copyrights can be found in the LICENSE and COPYRIGHT files
 * included with the alaqil source code as distributed by the alaqil developers
 * and at http://www.alaqil.org/legal.html.
 *
 * getopt.c
 *
 * Handles the parsing of command line options.  This is particularly nasty
 * compared to other utilities given that command line options can potentially
 * be read by many different modules within alaqil.  Thus, in order to make sure
 * there are no unrecognized options, each module is required to "mark"
 * the options that it uses.  Afterwards, we can make a quick scan to make
 * sure there are no unmarked options.
 * 
 * TODO: 
 *     - This module needs to be modified so that it doesn't call exit().
 *       Should have cleaner error handling in general.
 * ----------------------------------------------------------------------------- */

#include "alaqil.h"

static char **args;
static int numargs;
static int *marked;

/* -----------------------------------------------------------------------------
 * alaqil_init_args()
 * 
 * Initialize the argument list handler.
 * ----------------------------------------------------------------------------- */

void alaqil_init_args(int argc, char **argv) {
  int i;
  assert(argc > 0);
  assert(argv);

  numargs = argc;
  args = argv;
  marked = (int *) malloc(numargs * sizeof(int));
  for (i = 0; i < argc; i++) {
    marked[i] = 0;
  }
  marked[0] = 1;
}

/* -----------------------------------------------------------------------------
 * alaqil_mark_arg()
 * 
 * Marks an argument as being parsed.
 * ----------------------------------------------------------------------------- */

void alaqil_mark_arg(int n) {
  assert(marked);
  assert((n >= 0) && (n < numargs));
  marked[n] = 1;
}

/* -----------------------------------------------------------------------------
 * alaqil_check_marked()
 *
 * Checks to see if argument has been picked up.
 * ----------------------------------------------------------------------------- */

int alaqil_check_marked(int n) {
  assert((n >= 0) && (n < numargs));
  return marked[n];
}

/* -----------------------------------------------------------------------------
 * alaqil_check_options()
 * 
 * Checkers for unprocessed command line options and errors.
 * ----------------------------------------------------------------------------- */

void alaqil_check_options(int check_input) {
  int error = 0;
  int i;
  int max = check_input ? numargs - 1 : numargs;
  assert(marked);
  for (i = 1; i < max; i++) {
    if (!marked[i]) {
      Printf(stderr, "alaqil error : Unrecognized option %s\n", args[i]);
      error = 1;
    }
  }
  if (error) {
    Printf(stderr, "Use 'alaqil -help' for available options.\n");
    exit(1);
  }
  if (check_input && marked[numargs - 1]) {
    Printf(stderr, "Must specify an input file. Use -help for available options.\n");
    exit(1);
  }
}

/* -----------------------------------------------------------------------------
 * alaqil_arg_error()
 * 
 * Generates a generic error message and exits.
 * ----------------------------------------------------------------------------- */

void alaqil_arg_error(void) {
  Printf(stderr, "alaqil : Unable to parse command line options.\n");
  Printf(stderr, "Use 'alaqil -help' for available options.\n");
  exit(1);
}
