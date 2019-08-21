//
// embed.i
// alaqil file embedding the Python interpreter in something else.
// This file is deprecated and no longer actively maintained, but it still
// seems to work with Python 2.7.  Status with Python 3 is unknown.
//
// This file makes it possible to extend Python and all of its
// built-in functions without having to hack its setup script.
//


#ifdef AUTODOC
%subsection "embed.i"
%text %{
This module provides support for building a new version of the
Python executable.  This will be necessary on systems that do
not support shared libraries and may be necessary with C++
extensions.  This file contains everything you need to build
a new version of Python from include files and libraries normally
installed with the Python language.

This module will automatically grab all of the Python modules
present in your current Python executable (including any special
purpose modules you have enabled such as Tkinter).   Thus, you
may need to provide additional link libraries when compiling.

As far as I know, this module is C++ safe.
%}
#endif

%wrapper %{

#include <Python.h>

#ifdef __cplusplus
extern "C"
#endif
void alaqil_init();  /* Forward reference */

#define _PyImport_Inittab alaqil_inittab

/* Grab Python's inittab[] structure */

#ifdef __cplusplus
extern "C" {
#endif
#include <config.c>

#undef _PyImport_Inittab

/* Now define our own version of it.
   Hopefully someone does not have more than 1000 built-in modules */

struct _inittab alaqil_Import_Inittab[1000];

static int  alaqil_num_modules = 0;

/* Function for adding modules to Python */

static void alaqil_add_module(char *name, void (*initfunc)()) {
	alaqil_Import_Inittab[alaqil_num_modules].name = name;
	alaqil_Import_Inittab[alaqil_num_modules].initfunc = initfunc;
	alaqil_num_modules++;
	alaqil_Import_Inittab[alaqil_num_modules].name = (char *) 0;
	alaqil_Import_Inittab[alaqil_num_modules].initfunc = 0;
}

/* Function to add all of Python's built-in modules to our interpreter */

static void alaqil_add_builtin() {
	int i = 0;
	while (alaqil_inittab[i].name) {
		alaqil_add_module(alaqil_inittab[i].name, alaqil_inittab[i].initfunc);
		i++;
	}
#ifdef alaqilMODINIT
	alaqilMODINIT
#endif
	/* Add alaqil builtin function */
	alaqil_add_module(alaqil_name, alaqil_init);
}

#ifdef __cplusplus
}
#endif

#ifdef __cplusplus
extern "C" {
#endif

extern int Py_Main(int, char **);

#ifdef __cplusplus
}
#endif

extern struct _inittab *PyImport_Inittab;

int
main(int argc, char **argv) {
	alaqil_add_builtin();
	PyImport_Inittab = alaqil_Import_Inittab;
	return Py_Main(argc,argv);
}

%}
