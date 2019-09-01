/* ----------------------------------------------------------------------------- 
 * This file is part of alaqil, which is licensed as a whole under version 3 
 * (or any later version) of the GNU General Public License. Some additional
 * terms also apply to certain portions of alaqil. The full details of the alaqil
 * license and copyrights can be found in the LICENSE and COPYRIGHT files
 * included with the alaqil source code as distributed by the alaqil developers
 * and at http://www.alaqil.org/legal.html.
 *
 * include.c
 *
 * The functions in this file are used to manage files in the alaqil library.
 * General purpose functions for opening, including, and retrieving pathnames
 * are provided.
 * ----------------------------------------------------------------------------- */

#include "alaqil.h"

static List   *directories = 0;	        /* List of include directories */
static String *lastpath = 0;	        /* Last file that was included */
static List   *pdirectories = 0;        /* List of pushed directories  */
static int     dopush = 1;		/* Whether to push directories */
static int file_debug = 0;

/* This functions determine whether to push/pop dirs in the preprocessor */
void alaqil_set_push_dir(int push) {
  dopush = push;
}

int alaqil_get_push_dir(void) {
  return dopush;
}

/* -----------------------------------------------------------------------------
 * alaqil_add_directory()
 *
 * Adds a directory to the alaqil search path.
 * ----------------------------------------------------------------------------- */

List *alaqil_add_directory(const_String_or_char_ptr dirname) {
  String *adirname;
  if (!directories)
    directories = NewList();
  assert(directories);
  if (dirname) {
    adirname = NewString(dirname);
    Append(directories,adirname);
    Delete(adirname);
  }
  return directories;
}

/* -----------------------------------------------------------------------------
 * alaqil_push_directory()
 *
 * Inserts a directory at the front of the alaqil search path.  This is used by
 * the preprocessor to grab files in the same directory as other included files.
 * ----------------------------------------------------------------------------- */

void alaqil_push_directory(const_String_or_char_ptr dirname) {
  String *pdirname;
  if (!alaqil_get_push_dir())
    return;
  if (!pdirectories)
    pdirectories = NewList();
  assert(pdirectories);
  pdirname = NewString(dirname);
  assert(pdirname);
  Insert(pdirectories,0,pdirname);
  Delete(pdirname);
}

/* -----------------------------------------------------------------------------
 * alaqil_pop_directory()
 *
 * Pops a directory off the front of the alaqil search path.  This is used by
 * the preprocessor.
 * ----------------------------------------------------------------------------- */

void alaqil_pop_directory(void) {
  if (!alaqil_get_push_dir())
    return;
  if (!pdirectories)
    return;
  Delitem(pdirectories, 0);
}

/* -----------------------------------------------------------------------------
 * alaqil_last_file()
 * 
 * Returns the full pathname of the last file opened. 
 * ----------------------------------------------------------------------------- */

String *alaqil_last_file(void) {
  assert(lastpath);
  return lastpath;
}

/* -----------------------------------------------------------------------------
 * alaqil_search_path_any() 
 * 
 * Returns a list of the current search paths.
 * ----------------------------------------------------------------------------- */

static List *alaqil_search_path_any(int syspath) {
  String *filename;
  List   *slist;
  int     i, ilen;

  slist = NewList();
  assert(slist);
  filename = NewStringEmpty();
  assert(filename);
#ifdef MACalaqil
  Printf(filename, "%s", alaqil_FILE_DELIMITER);
#else
  Printf(filename, ".%s", alaqil_FILE_DELIMITER);
#endif
  Append(slist, filename);
  Delete(filename);
  
  /* If there are any pushed directories.  Add them first */
  if (pdirectories) {
    ilen = Len(pdirectories);
    for (i = 0; i < ilen; i++) {
      filename = NewString(Getitem(pdirectories,i));
      Append(filename,alaqil_FILE_DELIMITER);
      Append(slist,filename);
      Delete(filename);
    }
  }
  /* Add system directories next */
  ilen = Len(directories);
  for (i = 0; i < ilen; i++) {
    filename = NewString(Getitem(directories,i));
    Append(filename,alaqil_FILE_DELIMITER);
    if (syspath) {
      /* If doing a system include, put the system directories first */
      Insert(slist,i,filename);
    } else {
      /* Otherwise, just put the system directories after the pushed directories (if any) */
      Append(slist,filename);
    }
    Delete(filename);
  }
  return slist;
}

List *alaqil_search_path() {
  return alaqil_search_path_any(0);
}



/* -----------------------------------------------------------------------------
 * alaqil_open()
 *
 * open a file, optionally looking for it in the include path.  Returns an open  
 * FILE * on success.
 * ----------------------------------------------------------------------------- */

static FILE *alaqil_open_file(const_String_or_char_ptr name, int sysfile, int use_include_path) {
  FILE *f;
  String *filename;
  List *spath = 0;
  char *cname;
  int i, ilen, nbytes;
  char bom[3];

  if (!directories)
    directories = NewList();
  assert(directories);

  cname = Char(name);
  filename = NewString(cname);
  assert(filename);
  if (file_debug) {
    Printf(stdout, "  Open: %s\n", filename);
  }
  f = fopen(Char(filename), "r");
  if (!f && use_include_path) {
    spath = alaqil_search_path_any(sysfile);
    ilen = Len(spath);
    for (i = 0; i < ilen; i++) {
      Clear(filename);
      Printf(filename, "%s%s", Getitem(spath, i), cname);
      f = fopen(Char(filename), "r");
      if (f)
	break;
    }
    Delete(spath);
  }
  if (f) {
    Delete(lastpath);
    lastpath = filename;

    /* Skip the UTF-8 BOM if it's present */
    nbytes = (int)fread(bom, 1, 3, f);
    if (nbytes == 3 && bom[0] == (char)0xEF && bom[1] == (char)0xBB && bom[2] == (char)0xBF) {
      /* skip */
    } else {
      fseek(f, 0, SEEK_SET);
    }
  }
  return f;
}

/* Open a file - searching the include paths to find it */
FILE *alaqil_include_open(const_String_or_char_ptr name) {
  return alaqil_open_file(name, 0, 1);
}

/* Open a file - does not use include paths to find it */
FILE *alaqil_open(const_String_or_char_ptr name) {
  return alaqil_open_file(name, 0, 0);
}



/* -----------------------------------------------------------------------------
 * alaqil_read_file()
 * 
 * Reads data from an open FILE * and returns it as a string.
 * ----------------------------------------------------------------------------- */

String *alaqil_read_file(FILE *f) {
  int len;
  char buffer[4096];
  String *str = NewStringEmpty();

  assert(str);
  while (fgets(buffer, 4095, f)) {
    Append(str, buffer);
  }
  len = Len(str);
  /* Add a newline if not present on last line -- the preprocessor seems to 
   * rely on \n and not EOF terminating lines */
  if (len) {
    char *cstr = Char(str);
    if (cstr[len - 1] != '\n') {
      Append(str, "\n");
    }
  }
  return str;
}

/* -----------------------------------------------------------------------------
 * alaqil_include()
 *
 * Opens a file and returns it as a string.
 * ----------------------------------------------------------------------------- */

static String *alaqil_include_any(const_String_or_char_ptr name, int sysfile) {
  FILE *f;
  String *str;
  String *file;

  f = alaqil_open_file(name, sysfile, 1);
  if (!f)
    return 0;
  str = alaqil_read_file(f);
  fclose(f);
  Seek(str, 0, SEEK_SET);
  file = Copy(alaqil_last_file());
  Setfile(str, file);
  Delete(file);
  Setline(str, 1);
  return str;
}

String *alaqil_include(const_String_or_char_ptr name) {
  return alaqil_include_any(name, 0);
}

String *alaqil_include_sys(const_String_or_char_ptr name) {
  return alaqil_include_any(name, 1);
}

/* -----------------------------------------------------------------------------
 * alaqil_insert_file()
 *
 * Copies the contents of a file into another file
 * ----------------------------------------------------------------------------- */

int alaqil_insert_file(const_String_or_char_ptr filename, File *outfile) {
  char buffer[4096];
  int nbytes;
  FILE *f = alaqil_include_open(filename);

  if (!f)
    return -1;
  while ((nbytes = Read(f, buffer, 4096)) > 0) {
    Write(outfile, buffer, nbytes);
  }
  fclose(f);
  return 0;
}

/* -----------------------------------------------------------------------------
 * alaqil_register_filebyname()
 *
 * Register a "named" file with the core.  Named files can become targets
 * for %insert directives and other alaqil operations.  This function takes
 * the place of the f_header, f_wrapper, f_init, and other global variables
 * in alaqil1.1
 * ----------------------------------------------------------------------------- */

static Hash *named_files = 0;

void alaqil_register_filebyname(const_String_or_char_ptr filename, File *outfile) {
  if (!named_files)
    named_files = NewHash();
  Setattr(named_files, filename, outfile);
}

/* -----------------------------------------------------------------------------
 * alaqil_filebyname()
 *
 * Get a named file
 * ----------------------------------------------------------------------------- */

File *alaqil_filebyname(const_String_or_char_ptr filename) {
  if (!named_files)
    return 0;
  return Getattr(named_files, filename);
}

/* -----------------------------------------------------------------------------
 * alaqil_file_extension()
 *
 * Returns the extension of a file
 * ----------------------------------------------------------------------------- */

String *alaqil_file_extension(const_String_or_char_ptr filename) {
  String *name = alaqil_file_filename(filename);
  const char *c = strrchr(Char(name), '.');
  String *extension = c ? NewString(c) : NewString("");
  Delete(name);
  return extension;
}

/* -----------------------------------------------------------------------------
 * alaqil_file_basename()
 *
 * Returns the filename with the extension removed.
 * ----------------------------------------------------------------------------- */

String *alaqil_file_basename(const_String_or_char_ptr filename) {
  String *extension = alaqil_file_extension(filename);
  String *basename = NewStringWithSize(filename, Len(filename) - Len(extension));
  Delete(extension);
  return basename;
}

/* -----------------------------------------------------------------------------
 * alaqil_file_filename()
 *
 * Return the file name with any leading path stripped off
 * ----------------------------------------------------------------------------- */
String *alaqil_file_filename(const_String_or_char_ptr filename) {
  const char *delim = alaqil_FILE_DELIMITER;
  const char *c = strrchr(Char(filename), *delim);
  return c ? NewString(c + 1) : NewString(filename);
}

/* -----------------------------------------------------------------------------
 * alaqil_file_dirname()
 *
 * Return the name of the directory associated with a file
 * ----------------------------------------------------------------------------- */
String *alaqil_file_dirname(const_String_or_char_ptr filename) {
  const char *delim = alaqil_FILE_DELIMITER;
  const char *c = strrchr(Char(filename), *delim);
  return c ? NewStringWithSize(filename, (int)(c - Char(filename) + 1)) : NewString("");
}

/*
 * alaqil_file_debug()
 */
void alaqil_file_debug_set() {
  file_debug = 1;
}
