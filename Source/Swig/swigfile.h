/* ----------------------------------------------------------------------------- 
 * This file is part of alaqil, which is licensed as a whole under version 3 
 * (or any later version) of the GNU General Public License. Some additional
 * terms also apply to certain portions of alaqil. The full details of the alaqil
 * license and copyrights can be found in the LICENSE and COPYRIGHT files
 * included with the alaqil source code as distributed by the alaqil developers
 * and at http://www.alaqil.org/legal.html.
 *
 * alaqilfile.h
 *
 * File handling functions in the alaqil core
 * ----------------------------------------------------------------------------- */

extern List   *alaqil_add_directory(const_String_or_char_ptr dirname);
extern void    alaqil_push_directory(const_String_or_char_ptr dirname);
extern void    alaqil_pop_directory(void);
extern String *alaqil_last_file(void);
extern List   *alaqil_search_path(void);
extern FILE   *alaqil_include_open(const_String_or_char_ptr name);
extern FILE   *alaqil_open(const_String_or_char_ptr name);
extern String *alaqil_read_file(FILE *f); 
extern String *alaqil_include(const_String_or_char_ptr name);
extern String *alaqil_include_sys(const_String_or_char_ptr name);
extern int     alaqil_insert_file(const_String_or_char_ptr name, File *outfile);
extern void    alaqil_set_push_dir(int dopush);
extern int     alaqil_get_push_dir(void);
extern void    alaqil_register_filebyname(const_String_or_char_ptr filename, File *outfile);
extern File   *alaqil_filebyname(const_String_or_char_ptr filename);
extern String *alaqil_file_extension(const_String_or_char_ptr filename);
extern String *alaqil_file_basename(const_String_or_char_ptr filename);
extern String *alaqil_file_filename(const_String_or_char_ptr filename);
extern String *alaqil_file_dirname(const_String_or_char_ptr filename);
extern void   alaqil_file_debug_set();

/* Delimiter used in accessing files and directories */

#if defined(MACalaqil)
#  define alaqil_FILE_DELIMITER ":"
#elif defined(_WIN32)
#  define alaqil_FILE_DELIMITER "\\"
#else
#  define alaqil_FILE_DELIMITER "/"
#endif
