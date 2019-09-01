/* ----------------------------------------------------------------------------- 
 * This file is part of alaqil, which is licensed as a whole under version 3 
 * (or any later version) of the GNU General Public License. Some additional
 * terms also apply to certain portions of alaqil. The full details of the alaqil
 * license and copyrights can be found in the LICENSE and COPYRIGHT files
 * included with the alaqil source code as distributed by the alaqil developers
 * and at http://www.alaqil.org/legal.html.
 *
 * alaqilopt.h
 *
 * Header file for the alaqil command line processing functions
 * ----------------------------------------------------------------------------- */

 extern void  alaqil_init_args(int argc, char **argv);
 extern void  alaqil_mark_arg(int n);
 extern int   alaqil_check_marked(int n);
 extern void  alaqil_check_options(int check_input);
 extern void  alaqil_arg_error(void);
