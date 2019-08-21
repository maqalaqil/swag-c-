/* ------------------------------------------------------------
 * --- Argc & Argv ---
 * ------------------------------------------------------------ */

%fragment("alaqil_AsArgcArgv","header",fragment="alaqil_AsCharPtrAndSize") {
alaqilINTERN int
alaqil_AsArgcArgv(PyObject *input,
		alaqil_type_info *ppchar_info,
		size_t *argc, char ***argv, int *owner)
{  
  void *vptr;
  int res = alaqil_ConvertPtr(input, &vptr, ppchar_info, 0);
  if (!alaqil_IsOK(res)) {
    int list = 0;
    PyErr_Clear();
    list = PyList_Check(input);
    if (list || PyTuple_Check(input)) {
      size_t i = 0;
      size_t size = list ? PyList_Size(input) : PyTuple_Size(input);
      if (argc) *argc = size;
      if (argv) {
	*argv = %new_array(size + 1, char*);
	for (; i < size; ++i) {
	  PyObject *obj = list ? PyList_GetItem(input,i) : PyTuple_GetItem(input,i);
	  char *cptr = 0; size_t sz = 0; int alloc = 0;
	  res = alaqil_AsCharPtrAndSize(obj, &cptr, &sz, &alloc);
	  if (alaqil_IsOK(res)) {
	    if (cptr && sz) {
	      (*argv)[i] = (alloc == alaqil_NEWOBJ) ? cptr : %new_copy_array(cptr, sz, char);
	    } else {
	      (*argv)[i] = 0;
	    }
	  } else {
	    return alaqil_TypeError;
	  }
	}
	(*argv)[i] = 0;
	if (owner) *owner = 1;
      } else {
	for (; i < size; ++i) {
	  PyObject *obj = list ? PyList_GetItem(input,i) : PyTuple_GetItem(input,i);
	  res = alaqil_AsCharPtrAndSize(obj, 0, 0, 0);
	  if (!alaqil_IsOK(res)) return alaqil_TypeError;
	}
	if (owner) *owner = 0;
      }
      return alaqil_OK;
    } else {
      return alaqil_TypeError;
    }
  } else {
    /* seems dangerous, but the user asked for it... */
    size_t i = 0;
    if (argv) { while (*argv[i] != 0) ++i;}    
    if (argc) *argc = i;
    if (owner) *owner = 0;
    return alaqil_OK;
  }
}
}

/*
  This typemap works with either a char **, a python list or a python
  tuple
 */

%typemap(in,noblock=0,fragment="alaqil_AsArgcArgv") (int ARGC, char **ARGV) (int res,char **argv = 0, size_t argc = 0, int owner= 0) {
  res = alaqil_AsArgcArgv($input, $descriptor(char**), &argc, &argv, &owner);
  if (!alaqil_IsOK(res)) { 
    $1 = 0; $2 = 0;
    %argument_fail(alaqil_TypeError, "int ARGC, char **ARGV", $symname, $argnum);
  } else {  
    $1 = %static_cast(argc,$1_ltype);
    $2 = %static_cast(argv, $2_ltype);
  }
}

%typemap(typecheck, precedence=alaqil_TYPECHECK_STRING_ARRAY) (int ARGC, char **ARGV) {
  int res = alaqil_AsArgcArgv($input, $descriptor(char**), 0, 0, 0);
  $1 = alaqil_IsOK(res);
}

%typemap(freearg,noblock=1) (int ARGC, char **ARGV)  {
  if (owner$argnum) {
    size_t i = argc$argnum;
    while (i) {
      %delete_array(argv$argnum[--i]);
    }
    %delete_array(argv$argnum);
  }
}

