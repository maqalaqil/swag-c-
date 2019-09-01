/* -----------------------------------------------------------------------------
 * This file is part of alaqil, which is licensed as a whole under version 3 
 * (or any later version) of the GNU General Public License. Some additional
 * terms also apply to certain portions of alaqil. The full details of the alaqil
 * license and copyrights can be found in the LICENSE and COPYRIGHT files
 * included with the alaqil source code as distributed by the alaqil developers
 * and at http://www.alaqil.org/legal.html.
 *
 * typeobj.c
 *
 * This file provides functions for constructing, manipulating, and testing
 * type objects.   Type objects are merely the raw low-level representation
 * of C++ types.   They do not incorporate high-level type system features
 * like typedef, namespaces, etc.
 * ----------------------------------------------------------------------------- */

#include "alaqil.h"
#include <ctype.h>
#include <limits.h>

/* -----------------------------------------------------------------------------
 * Synopsis
 *
 * This file provides a collection of low-level functions for constructing and
 * manipulating C++ data types.   In alaqil, C++ datatypes are encoded as simple
 * text strings.  This representation is compact, easy to debug, and easy to read.
 *
 * General idea:
 *
 * Types are represented by a base type (e.g., "int") and a collection of
 * type operators applied to the base (e.g., pointers, arrays, etc...).
 *
 * Encoding:
 *
 * Types are encoded as strings of type constructors such as follows:
 *
 *        String Encoding                 C Example
 *        ---------------                 ---------
 *        p.p.int                         int **
 *        a(300).a(400).int               int [300][400]
 *        p.q(const).char                 char const *
 *
 * All type constructors are denoted by a trailing '.':
 * 
 *  'p.'                = Pointer (*)
 *  'r.'                = Reference or ref-qualifier (&)
 *  'z.'                = Rvalue reference or ref-qualifier (&&)
 *  'a(n).'             = Array of size n  [n]
 *  'f(..,..).'         = Function with arguments  (args)
 *  'q(str).'           = Qualifier, such as const or volatile (cv-qualifier)
 *  'm(cls).'           = Pointer to member (cls::*)
 *
 *  The complete type representation for varargs is:
 *  'v(...)'
 *
 * The encoding follows the order that you might describe a type in words.
 * For example "p.a(200).int" is "A pointer to array of int's" and
 * "p.q(const).char" is "a pointer to a const char".
 *
 * This representation of types is fairly convenient because ordinary string
 * operations can be used for type manipulation. For example, a type could be
 * formed by combining two strings such as the following:
 *
 *        "p.p." + "a(400).int" = "p.p.a(400).int"
 *
 * For C++, typenames may be parameterized using <(...)>.  Here are some
 * examples:
 *
 *       String Encoding                  C++ Example
 *       ---------------                  ------------
 *       p.vector<(int)>                  vector<int> *
 *       r.foo<(int,p.double)>            foo<int,double *> &
 *
 * Contents of this file:
 *
 * Most of this functions in this file pertain to the low-level manipulation
 * of type objects.   There are constructor functions like this:
 *
 *       alaqilType_add_pointer()
 *       alaqilType_add_reference()
 *       alaqilType_add_rvalue_reference()
 *       alaqilType_add_array()
 *
 * These are used to build new types.  There are also functions to undo these
 * operations.  For example:
 *
 *       alaqilType_del_pointer()
 *       alaqilType_del_reference()
 *       alaqilType_del_rvalue_reference()
 *       alaqilType_del_array()
 *
 * In addition, there are query functions
 *
 *       alaqilType_ispointer()
 *       alaqilType_isreference()
 *       alaqilType_isrvalue_reference()
 *       alaqilType_isarray()
 *
 * Finally, there are some data extraction functions that can be used to
 * extract array dimensions, template arguments, and so forth.
 * 
 * It is very important for developers to realize that the functions in this
 * module do *NOT* incorporate higher-level type system features like typedef.
 * For example, you could have C code like this:
 *
 *        typedef  int  *intptr;
 *       
 * In this case, a alaqilType of type 'intptr' will be treated as a simple type and
 * functions like alaqilType_ispointer() will evaluate as false.  It is strongly
 * advised that developers use the TypeSys_* interface to check types in a more
 * reliable manner.
 * ----------------------------------------------------------------------------- */


/* -----------------------------------------------------------------------------
 * NewalaqilType()
 *
 * Constructs a new type object.   Eventually, it would be nice for this function
 * to accept an initial value in the form a C/C++ abstract type (currently unimplemented).
 * ----------------------------------------------------------------------------- */

#ifdef NEW
alaqilType *NewalaqilType(const_String_or_char_ptr initial) {
  return NewString(initial);
}

#endif

/* The next few functions are utility functions used in the construction and 
   management of types */

/* -----------------------------------------------------------------------------
 * static element_size()
 *
 * This utility function finds the size of a single type element in a type string.
 * Type elements are always delimited by periods, but may be nested with
 * parentheses.  A nested element is always handled as a single item.
 *
 * Returns the integer size of the element (which can be used to extract a 
 * substring, to chop the element off, or for other purposes).
 * ----------------------------------------------------------------------------- */

static int element_size(char *c) {
  int nparen;
  char *s = c;
  while (*c) {
    if (*c == '.') {
      c++;
      return (int) (c - s);
    } else if (*c == '(') {
      nparen = 1;
      c++;
      while (*c) {
	if (*c == '(')
	  nparen++;
	if (*c == ')') {
	  nparen--;
	  if (nparen == 0)
	    break;
	}
	c++;
      }
    }
    if (*c)
      c++;
  }
  return (int) (c - s);
}

/* -----------------------------------------------------------------------------
 * alaqilType_del_element()
 *
 * Deletes one type element from the type.  
 * ----------------------------------------------------------------------------- */

alaqilType *alaqilType_del_element(alaqilType *t) {
  int sz = element_size(Char(t));
  Delslice(t, 0, sz);
  return t;
}

/* -----------------------------------------------------------------------------
 * alaqilType_pop()
 * 
 * Pop one type element off the type.
 * For example:
 *   t in:   q(const).p.Integer
 *   t out:  p.Integer
 *   result: q(const).
 * ----------------------------------------------------------------------------- */

alaqilType *alaqilType_pop(alaqilType *t) {
  alaqilType *result;
  char *c;
  int sz;

  c = Char(t);
  if (!*c)
    return 0;

  sz = element_size(c);
  result = NewStringWithSize(c, sz);
  Delslice(t, 0, sz);
  c = Char(t);
  if (*c == '.') {
    Delitem(t, 0);
  }
  return result;
}

/* -----------------------------------------------------------------------------
 * alaqilType_parm()
 *
 * Returns the parameter of an operator as a string
 * ----------------------------------------------------------------------------- */

String *alaqilType_parm(const alaqilType *t) {
  char *start, *c;
  int nparens = 0;

  c = Char(t);
  while (*c && (*c != '(') && (*c != '.'))
    c++;
  if (!*c || (*c == '.'))
    return 0;
  c++;
  start = c;
  while (*c) {
    if (*c == ')') {
      if (nparens == 0)
	break;
      nparens--;
    } else if (*c == '(') {
      nparens++;
    }
    c++;
  }
  return NewStringWithSize(start, (int) (c - start));
}

/* -----------------------------------------------------------------------------
 * alaqilType_split()
 *
 * Splits a type into its component parts and returns a list of string.
 * ----------------------------------------------------------------------------- */

List *alaqilType_split(const alaqilType *t) {
  String *item;
  List *list;
  char *c;
  int len;

  c = Char(t);
  list = NewList();
  while (*c) {
    len = element_size(c);
    item = NewStringWithSize(c, len);
    Append(list, item);
    Delete(item);
    c = c + len;
    if (*c == '.')
      c++;
  }
  return list;
}

/* -----------------------------------------------------------------------------
 * alaqilType_parmlist()
 *
 * Splits a comma separated list of parameters into its component parts
 * The input is expected to contain the parameter list within () brackets
 * Returns 0 if no argument list in the input, ie there are no round brackets ()
 * Returns an empty List if there are no parameters in the () brackets
 * For example:
 *
 *     Foo(std::string,p.f().Bar<(int,double)>)
 *
 * returns 2 elements in the list:
 *    std::string
 *    p.f().Bar<(int,double)>
 * ----------------------------------------------------------------------------- */
 
List *alaqilType_parmlist(const String *p) {
  String *item = 0;
  List *list;
  char *c;
  char *itemstart;
  int size;

  assert(p);
  c = Char(p);
  while (*c && (*c != '(') && (*c != '.'))
    c++;
  if (!*c)
    return 0;
  assert(*c != '.'); /* p is expected to contain sub elements of a type */
  c++;
  list = NewList();
  itemstart = c;
  while (*c) {
    if (*c == ',') {
      size = (int) (c - itemstart);
      item = NewStringWithSize(itemstart, size);
      Append(list, item);
      Delete(item);
      itemstart = c + 1;
    } else if (*c == '(') {
      int nparens = 1;
      c++;
      while (*c) {
	if (*c == '(')
	  nparens++;
	if (*c == ')') {
	  nparens--;
	  if (nparens == 0)
	    break;
	}
	c++;
      }
    } else if (*c == ')') {
      break;
    }
    if (*c)
      c++;
  }
  size = (int) (c - itemstart);
  if (size > 0) {
    item = NewStringWithSize(itemstart, size);
    Append(list, item);
  }
  Delete(item);
  return list;
}

/* -----------------------------------------------------------------------------
 *                                 Pointers
 *
 * alaqilType_add_pointer()
 * alaqilType_del_pointer()
 * alaqilType_ispointer()
 *
 * Add, remove, and test if a type is a pointer.  The deletion and query
 * functions take into account qualifiers (if any).
 * ----------------------------------------------------------------------------- */

alaqilType *alaqilType_add_pointer(alaqilType *t) {
  Insert(t, 0, "p.");
  return t;
}

alaqilType *alaqilType_del_pointer(alaqilType *t) {
  char *c, *s;
  c = Char(t);
  s = c;
  /* Skip qualifiers, if any */
  if (strncmp(c, "q(", 2) == 0) {
    c = strchr(c, '.');
    assert(c);
    c++;
  }
  if (strncmp(c, "p.", 2)) {
    printf("Fatal error. alaqilType_del_pointer applied to non-pointer.\n");
    abort();
  }
  Delslice(t, 0, (int)((c - s) + 2));
  return t;
}

int alaqilType_ispointer(const alaqilType *t) {
  char *c;
  if (!t)
    return 0;
  c = Char(t);
  /* Skip qualifiers, if any */
  if (strncmp(c, "q(", 2) == 0) {
    c = strchr(c, '.');
    if (!c)
      return 0;
    c++;
  }
  if (strncmp(c, "p.", 2) == 0) {
    return 1;
  }
  return 0;
}

/* -----------------------------------------------------------------------------
 *                                 References
 *
 * alaqilType_add_reference()
 * alaqilType_del_reference()
 * alaqilType_isreference()
 *
 * Add, remove, and test if a type is a reference.  The deletion and query
 * functions take into account qualifiers (if any).
 * ----------------------------------------------------------------------------- */

alaqilType *alaqilType_add_reference(alaqilType *t) {
  Insert(t, 0, "r.");
  return t;
}

alaqilType *alaqilType_del_reference(alaqilType *t) {
  char *c = Char(t);
  int check = strncmp(c, "r.", 2);
  assert(check == 0);
  Delslice(t, 0, 2);
  return t;
}

int alaqilType_isreference(const alaqilType *t) {
  char *c;
  if (!t)
    return 0;
  c = Char(t);
  if (strncmp(c, "r.", 2) == 0) {
    return 1;
  }
  return 0;
}

/* -----------------------------------------------------------------------------
 *                                 Rvalue References
 *
 * alaqilType_add_rvalue_reference()
 * alaqilType_del_rvalue_reference()
 * alaqilType_isrvalue_reference()
 *
 * Add, remove, and test if a type is a rvalue reference.  The deletion and query
 * functions take into account qualifiers (if any).
 * ----------------------------------------------------------------------------- */

alaqilType *alaqilType_add_rvalue_reference(alaqilType *t) {
  Insert(t, 0, "z.");
  return t;
}

alaqilType *alaqilType_del_rvalue_reference(alaqilType *t) {
  char *c = Char(t);
  int check = strncmp(c, "z.", 2);
  assert(check == 0);
  Delslice(t, 0, 2);
  return t;
}

int alaqilType_isrvalue_reference(const alaqilType *t) {
  char *c;
  if (!t)
    return 0;
  c = Char(t);
  if (strncmp(c, "z.", 2) == 0) {
    return 1;
  }
  return 0;
}

/* -----------------------------------------------------------------------------
 *                                  Qualifiers
 *
 * alaqilType_add_qualifier()
 * alaqilType_del_qualifier()
 * alaqilType_is_qualifier()
 *
 * Adds type qualifiers like "const" and "volatile".   When multiple qualifiers
 * are added to a type, they are combined together into a single qualifier.
 * Repeated qualifications have no effect.  Moreover, the order of qualifications
 * is alphabetical---meaning that "const volatile" and "volatile const" are
 * stored in exactly the same way as "q(const volatile)".
 * 'qual' can be a list of multiple qualifiers in any order, separated by spaces.
 * ----------------------------------------------------------------------------- */

alaqilType *alaqilType_add_qualifier(alaqilType *t, const_String_or_char_ptr qual) {
  List *qlist;
  String *allq, *newq;
  int i, sz;
  const char *cqprev = 0;
  const char *c = Char(t);
  const char *cqual = Char(qual);

  /* if 't' has no qualifiers and 'qual' is a single qualifier, simply add it */
  if ((strncmp(c, "q(", 2) != 0) && (strstr(cqual, " ") == 0)) {
    String *temp = NewStringf("q(%s).", cqual);
    Insert(t, 0, temp);
    Delete(temp);
    return t;
  }

  /* create string of all qualifiers */
  if (strncmp(c, "q(", 2) == 0) {
    allq = alaqilType_parm(t);
    Append(allq, " ");
    alaqilType_del_element(t);     /* delete old qualifier list from 't' */
  } else {
    allq = NewStringEmpty();
  }
  Append(allq, qual);

  /* create list of all qualifiers from string */
  qlist = Split(allq, ' ', INT_MAX);
  Delete(allq);

  /* sort in alphabetical order */
  SortList(qlist, Strcmp);

  /* create new qualifier string from unique elements of list */
  sz = Len(qlist);
  newq = NewString("q(");
  for (i = 0; i < sz; ++i) {
    String *q = Getitem(qlist, i);
    const char *cq = Char(q);
    if (cqprev == 0 || strcmp(cqprev, cq) != 0) {
      if (i > 0) {
        Append(newq, " ");
      }
      Append(newq, q);
      cqprev = cq;
    }
  }
  Append(newq, ").");
  Delete(qlist);

  /* replace qualifier string with new one */
  Insert(t, 0, newq);
  Delete(newq);
  return t;
}

alaqilType *alaqilType_del_qualifier(alaqilType *t) {
  char *c = Char(t);
  int check = strncmp(c, "q(", 2);
  assert(check == 0);
  Delslice(t, 0, element_size(c));
  return t;
}

int alaqilType_isqualifier(const alaqilType *t) {
  char *c;
  if (!t)
    return 0;
  c = Char(t);
  if (strncmp(c, "q(", 2) == 0) {
    return 1;
  }
  return 0;
}

/* -----------------------------------------------------------------------------
 *                                Function Pointers
 * ----------------------------------------------------------------------------- */

int alaqilType_isfunctionpointer(const alaqilType *t) {
  char *c;
  if (!t)
    return 0;
  c = Char(t);
  if (strncmp(c, "p.f(", 4) == 0) {
    return 1;
  }
  return 0;
}

/* -----------------------------------------------------------------------------
 * alaqilType_functionpointer_decompose
 *
 * Decompose the function pointer into the parameter list and the return type
 * t - input and on completion contains the return type
 * returns the function's parameters
 * ----------------------------------------------------------------------------- */

alaqilType *alaqilType_functionpointer_decompose(alaqilType *t) {
  String *p;
  assert(alaqilType_isfunctionpointer(t));
  p = alaqilType_pop(t);
  Delete(p);
  p = alaqilType_pop(t);
  return p;
}

/* -----------------------------------------------------------------------------
 *                                Member Pointers
 *
 * alaqilType_add_memberpointer()
 * alaqilType_del_memberpointer()
 * alaqilType_ismemberpointer()
 *
 * Add, remove, and test for C++ pointer to members.
 * ----------------------------------------------------------------------------- */

alaqilType *alaqilType_add_memberpointer(alaqilType *t, const_String_or_char_ptr name) {
  String *temp = NewStringf("m(%s).", name);
  Insert(t, 0, temp);
  Delete(temp);
  return t;
}

alaqilType *alaqilType_del_memberpointer(alaqilType *t) {
  char *c = Char(t);
  int check = strncmp(c, "m(", 2);
  assert(check == 0);
  Delslice(t, 0, element_size(c));
  return t;
}

int alaqilType_ismemberpointer(const alaqilType *t) {
  char *c;
  if (!t)
    return 0;
  c = Char(t);
  if (strncmp(c, "m(", 2) == 0) {
    return 1;
  }
  return 0;
}

/* -----------------------------------------------------------------------------
 *                                    Arrays
 *
 * alaqilType_add_array()
 * alaqilType_del_array()
 * alaqilType_isarray()
 *
 * Utility functions:
 *
 * alaqilType_array_ndim()        - Calculate number of array dimensions.
 * alaqilType_array_getdim()      - Get array dimension
 * alaqilType_array_setdim()      - Set array dimension
 * alaqilType_array_type()        - Return array type
 * alaqilType_pop_arrays()        - Remove all arrays
 * ----------------------------------------------------------------------------- */

alaqilType *alaqilType_add_array(alaqilType *t, const_String_or_char_ptr size) {
  String *temp = NewString("a(");
  Append(temp, size);
  Append(temp, ").");
  Insert(t, 0, temp);
  Delete(temp);
  return t;
}

alaqilType *alaqilType_del_array(alaqilType *t) {
  char *c = Char(t);
  int check = strncmp(c, "a(", 2);
  assert(check == 0);
  Delslice(t, 0, element_size(c));
  return t;
}

int alaqilType_isarray(const alaqilType *t) {
  char *c;
  if (!t)
    return 0;
  c = Char(t);
  if (strncmp(c, "a(", 2) == 0) {
    return 1;
  }
  return 0;
}
/*
 * alaqilType_prefix_is_simple_1D_array
 *
 * Determine if the type is a 1D array type that is treated as a pointer within alaqil
 * eg Foo[], Foo[3] return true, but Foo[3][3], Foo*[], Foo*[3], Foo**[] return false
 */
int alaqilType_prefix_is_simple_1D_array(const alaqilType *t) {
  char *c = Char(t);

  if (c && (strncmp(c, "a(", 2) == 0)) {
    c = strchr(c, '.');
    if (c)
      return (*(++c) == 0);
  }
  return 0;
}


/* Remove all arrays */
alaqilType *alaqilType_pop_arrays(alaqilType *t) {
  String *ta;
  assert(alaqilType_isarray(t));
  ta = NewStringEmpty();
  while (alaqilType_isarray(t)) {
    alaqilType *td = alaqilType_pop(t);
    Append(ta, td);
    Delete(td);
  }
  return ta;
}

/* Return number of array dimensions */
int alaqilType_array_ndim(const alaqilType *t) {
  int ndim = 0;
  char *c = Char(t);

  while (c && (strncmp(c, "a(", 2) == 0)) {
    c = strchr(c, '.');
    if (c) {
      c++;
      ndim++;
    }
  }
  return ndim;
}

/* Get nth array dimension */
String *alaqilType_array_getdim(const alaqilType *t, int n) {
  char *c = Char(t);
  while (c && (strncmp(c, "a(", 2) == 0) && (n > 0)) {
    c = strchr(c, '.');
    if (c) {
      c++;
      n--;
    }
  }
  if (n == 0) {
    String *dim = alaqilType_parm(c);
    if (alaqilType_istemplate(dim)) {
      String *ndim = alaqilType_namestr(dim);
      Delete(dim);
      dim = ndim;
    }

    return dim;
  }

  return 0;
}

/* Replace nth array dimension */
void alaqilType_array_setdim(alaqilType *t, int n, const_String_or_char_ptr rep) {
  String *result = 0;
  char temp;
  char *start;
  char *c = Char(t);

  start = c;
  if (strncmp(c, "a(", 2))
    abort();

  while (c && (strncmp(c, "a(", 2) == 0) && (n > 0)) {
    c = strchr(c, '.');
    if (c) {
      c++;
      n--;
    }
  }
  if (n == 0) {
    temp = *c;
    *c = 0;
    result = NewString(start);
    Printf(result, "a(%s)", rep);
    *c = temp;
    c = strchr(c, '.');
    Append(result, c);
  }
  Clear(t);
  Append(t, result);
  Delete(result);
}

/* Return base type of an array */
alaqilType *alaqilType_array_type(const alaqilType *ty) {
  alaqilType *t;
  t = Copy(ty);
  while (alaqilType_isarray(t)) {
    Delete(alaqilType_pop(t));
  }
  return t;
}


/* -----------------------------------------------------------------------------
 *                                    Functions
 *
 * alaqilType_add_function()
 * alaqilType_isfunction()
 * alaqilType_pop_function()
 *
 * Add, remove, and test for function types.
 * ----------------------------------------------------------------------------- */

/* Returns the function type, t, constructed from the parameters, parms */
alaqilType *alaqilType_add_function(alaqilType *t, ParmList *parms) {
  String *pstr;
  Parm *p;

  Insert(t, 0, ").");
  pstr = NewString("f(");
  for (p = parms; p; p = nextSibling(p)) {
    if (p != parms)
      Putc(',', pstr);
    Append(pstr, Getattr(p, "type"));
  }
  Insert(t, 0, pstr);
  Delete(pstr);
  return t;
}

/* -----------------------------------------------------------------------------
 * alaqilType_pop_function()
 *
 * Pop and return the function from the input type leaving the function's return
 * type, if any.
 * For example:
 *   t in:   q(const).f().p.
 *   t out:  p.
 *   result: q(const).f().
 * ----------------------------------------------------------------------------- */

alaqilType *alaqilType_pop_function(alaqilType *t) {
  alaqilType *f = 0;
  alaqilType *g = 0;
  char *c = Char(t);
  if (strncmp(c, "r.", 2) == 0 || strncmp(c, "z.", 2) == 0) {
    /* Remove ref-qualifier */
    f = alaqilType_pop(t);
    c = Char(t);
  }
  if (strncmp(c, "q(", 2) == 0) {
    /* Remove cv-qualifier */
    String *qual = alaqilType_pop(t);
    if (f) {
      alaqilType_push(qual, f);
      Delete(f);
    }
    f = qual;
    c = Char(t);
  }
  if (strncmp(c, "f(", 2)) {
    printf("Fatal error. alaqilType_pop_function applied to non-function.\n");
    abort();
  }
  g = alaqilType_pop(t);
  if (f)
    alaqilType_push(g, f);
  Delete(f);
  return g;
}

/* -----------------------------------------------------------------------------
 * alaqilType_pop_function_qualifiers()
 *
 * Pop and return the function qualifiers from the input type leaving the rest of
 * function declaration. Returns NULL if no qualifiers.
 * For example:
 *   t in:   r.q(const).f().p.
 *   t out:  f().p.
 *   result: r.q(const)
 * ----------------------------------------------------------------------------- */

alaqilType *alaqilType_pop_function_qualifiers(alaqilType *t) {
  alaqilType *qualifiers = 0;
  char *c = Char(t);
  if (strncmp(c, "r.", 2) == 0 || strncmp(c, "z.", 2) == 0) {
    /* Remove ref-qualifier */
    String *qual = alaqilType_pop(t);
    qualifiers = qual;
    c = Char(t);
  }
  if (strncmp(c, "q(", 2) == 0) {
    /* Remove cv-qualifier */
    String *qual = alaqilType_pop(t);
    if (qualifiers) {
      alaqilType_push(qual, qualifiers);
      Delete(qualifiers);
    }
    qualifiers = qual;
  }
  assert(Strncmp(t, "f(", 2) == 0);

  return qualifiers;
}

int alaqilType_isfunction(const alaqilType *t) {
  char *c;
  if (!t) {
    return 0;
  }
  c = Char(t);
  if (strncmp(c, "r.", 2) == 0 || strncmp(c, "z.", 2) == 0) {
    /* Might be a function with a ref-qualifier, skip over */
    c += 2;
    if (!*c)
      return 0;
  }
  if (strncmp(c, "q(", 2) == 0) {
    /* Might be a function with a cv-qualifier, skip over */
    c = strchr(c, '.');
    if (c)
      c++;
    else
      return 0;
  }
  if (strncmp(c, "f(", 2) == 0) {
    return 1;
  }
  return 0;
}

/* Create a list of parameters from the type t, using the file_line_node Node for 
 * file and line numbering for the parameters */
ParmList *alaqilType_function_parms(const alaqilType *t, Node *file_line_node) {
  List *l = alaqilType_parmlist(t);
  Hash *p, *pp = 0, *firstp = 0;
  Iterator o;

  for (o = First(l); o.item; o = Next(o)) {
    p = file_line_node ? NewParm(o.item, 0, file_line_node) : NewParmWithoutFileLineInfo(o.item, 0);
    if (!firstp)
      firstp = p;
    if (pp) {
      set_nextSibling(pp, p);
      Delete(p);
    }
    pp = p;
  }
  Delete(l);
  return firstp;
}

int alaqilType_isvarargs(const alaqilType *t) {
  if (Strcmp(t, "v(...)") == 0)
    return 1;
  return 0;
}

/* -----------------------------------------------------------------------------
 *                                    Templates
 *
 * alaqilType_add_template()
 *
 * Template handling.
 * ----------------------------------------------------------------------------- */

/* -----------------------------------------------------------------------------
 * alaqilType_add_template()
 *
 * Adds a template to a type.   This template is encoded in the alaqil type
 * mechanism and produces a string like this:
 *
 *  vector<int *> ----> "vector<(p.int)>"
 * ----------------------------------------------------------------------------- */

alaqilType *alaqilType_add_template(alaqilType *t, ParmList *parms) {
  Parm *p;

  Append(t, "<(");
  for (p = parms; p; p = nextSibling(p)) {
    String *v;
    if (Getattr(p, "default"))
      continue;
    if (p != parms)
      Append(t, ",");
    v = Getattr(p, "value");
    if (v) {
      Append(t, v);
    } else {
      Append(t, Getattr(p, "type"));
    }
  }
  Append(t, ")>");
  return t;
}


/* -----------------------------------------------------------------------------
 * alaqilType_templateprefix()
 *
 * Returns the prefix before the first template definition.
 * Returns the type unmodified if not a template.
 * For example:
 *
 *     Foo<(p.int)>::bar  =>  Foo
 *     r.q(const).Foo<(p.int)>::bar => r.q(const).Foo
 *     Foo => Foo
 * ----------------------------------------------------------------------------- */

String *alaqilType_templateprefix(const alaqilType *t) {
  const char *s = Char(t);
  const char *c = strstr(s, "<(");
  return c ? NewStringWithSize(s, (int)(c - s)) : NewString(s);
}

/* -----------------------------------------------------------------------------
 * alaqilType_templatesuffix()
 *
 * Returns text after a template substitution.  Used to handle scope names
 * for example:
 *
 *        Foo<(p.int)>::bar
 *
 * returns "::bar"
 * ----------------------------------------------------------------------------- */

String *alaqilType_templatesuffix(const alaqilType *t) {
  const char *c;
  c = Char(t);
  while (*c) {
    if ((*c == '<') && (*(c + 1) == '(')) {
      int nest = 1;
      c++;
      while (*c && nest) {
	if (*c == '<')
	  nest++;
	if (*c == '>')
	  nest--;
	c++;
      }
      return NewString(c);
    }
    c++;
  }
  return NewStringEmpty();
}

/* -----------------------------------------------------------------------------
 * alaqilType_istemplate_templateprefix()
 *
 * Combines alaqilType_istemplate and alaqilType_templateprefix efficiently into one function.
 * Returns the prefix before the first template definition.
 * Returns NULL if not a template.
 * For example:
 *
 *     Foo<(p.int)>::bar  =>  Foo
 *     r.q(const).Foo<(p.int)>::bar => r.q(const).Foo
 *     Foo => NULL
 * ----------------------------------------------------------------------------- */

String *alaqilType_istemplate_templateprefix(const alaqilType *t) {
  const char *s = Char(t);
  const char *c = strstr(s, "<(");
  return c ? NewStringWithSize(s, (int)(c - s)) : 0;
}

/* -----------------------------------------------------------------------------
 * alaqilType_istemplate_only_templateprefix()
 *
 * Similar to alaqilType_istemplate_templateprefix() but only returns the template
 * prefix if the type is just the template and not a subtype/symbol within the template.
 * Returns NULL if not a template or is a template with a symbol within the template.
 * For example:
 *
 *     Foo<(p.int)>  =>  Foo
 *     Foo<(p.int)>::bar  =>  NULL
 *     r.q(const).Foo<(p.int)> => r.q(const).Foo
 *     r.q(const).Foo<(p.int)>::bar => NULL
 *     Foo => NULL
 * ----------------------------------------------------------------------------- */

String *alaqilType_istemplate_only_templateprefix(const alaqilType *t) {
  int len = Len(t);
  const char *s = Char(t);
  if (len >= 4 && strcmp(s + len - 2, ")>") == 0) {
    const char *c = strstr(s, "<(");
    return c ? NewStringWithSize(s, (int)(c - s)) : 0;
  } else {
    return 0;
  }
}

/* -----------------------------------------------------------------------------
 * alaqilType_templateargs()
 *
 * Returns the template arguments
 * For example:
 *
 *     Foo<(p.int)>::bar
 *
 * returns "<(p.int)>"
 * ----------------------------------------------------------------------------- */

String *alaqilType_templateargs(const alaqilType *t) {
  const char *c;
  const char *start;
  c = Char(t);
  while (*c) {
    if ((*c == '<') && (*(c + 1) == '(')) {
      int nest = 1;
      start = c;
      c++;
      while (*c && nest) {
	if (*c == '<')
	  nest++;
	if (*c == '>')
	  nest--;
	c++;
      }
      return NewStringWithSize(start, (int)(c - start));
    }
    c++;
  }
  return 0;
}

/* -----------------------------------------------------------------------------
 * alaqilType_istemplate()
 *
 * Tests a type to see if it includes template parameters
 * ----------------------------------------------------------------------------- */

int alaqilType_istemplate(const alaqilType *t) {
  char *ct = Char(t);
  ct = strstr(ct, "<(");
  if (ct && (strstr(ct + 2, ")>")))
    return 1;
  return 0;
}

/* -----------------------------------------------------------------------------
 * alaqilType_base()
 *
 * This function returns the base of a type.  For example, if you have a
 * type "p.p.int", the function would return "int".
 * ----------------------------------------------------------------------------- */

alaqilType *alaqilType_base(const alaqilType *t) {
  char *c;
  char *lastop = 0;
  c = Char(t);

  lastop = c;

  /* Search for the last type constructor separator '.' */
  while (*c) {
    if (*c == '.') {
      if (*(c + 1)) {
	lastop = c + 1;
      }
      c++;
      continue;
    }
    if (*c == '<') {
      /* Skip over template---it's part of the base name */
      int ntemp = 1;
      c++;
      while ((*c) && (ntemp > 0)) {
	if (*c == '>')
	  ntemp--;
	else if (*c == '<')
	  ntemp++;
	c++;
      }
      if (ntemp)
	break;
      continue;
    }
    if (*c == '(') {
      /* Skip over params */
      int nparen = 1;
      c++;
      while ((*c) && (nparen > 0)) {
	if (*c == '(')
	  nparen++;
	else if (*c == ')')
	  nparen--;
	c++;
      }
      if (nparen)
	break;
      continue;
    }
    c++;
  }
  return NewString(lastop);
}

/* -----------------------------------------------------------------------------
 * alaqilType_prefix()
 *
 * Returns the prefix of a datatype.  For example, the prefix of the
 * type "p.p.int" is "p.p.".
 * ----------------------------------------------------------------------------- */

String *alaqilType_prefix(const alaqilType *t) {
  char *c, *d;
  String *r = 0;

  c = Char(t);
  d = c + strlen(c);

  /* Check for a type constructor */
  if ((d > c) && (*(d - 1) == '.'))
    d--;

  while (d > c) {
    d--;
    if (*d == '>') {
      int nest = 1;
      d--;
      while ((d > c) && (nest)) {
	if (*d == '>')
	  nest++;
	if (*d == '<')
	  nest--;
	d--;
      }
    }
    if (*d == ')') {
      /* Skip over params */
      int nparen = 1;
      d--;
      while ((d > c) && (nparen)) {
	if (*d == ')')
	  nparen++;
	if (*d == '(')
	  nparen--;
	d--;
      }
    }

    if (*d == '.') {
      char t = *(d + 1);
      *(d + 1) = 0;
      r = NewString(c);
      *(d + 1) = t;
      return r;
    }
  }
  return NewStringEmpty();
}

/* -----------------------------------------------------------------------------
 * alaqilType_strip_qualifiers()
 * 
 * Strip all qualifiers from a type and return a new type
 * ----------------------------------------------------------------------------- */

alaqilType *alaqilType_strip_qualifiers(const alaqilType *t) {
  static Hash *memoize_stripped = 0;
  alaqilType *r;
  List *l;
  Iterator ei;

  if (!memoize_stripped)
    memoize_stripped = NewHash();
  r = Getattr(memoize_stripped, t);
  if (r)
    return Copy(r);

  l = alaqilType_split(t);
  r = NewStringEmpty();

  for (ei = First(l); ei.item; ei = Next(ei)) {
    if (alaqilType_isqualifier(ei.item))
      continue;
    Append(r, ei.item);
  }
  Delete(l);
  {
    String *key, *value;
    key = Copy(t);
    value = Copy(r);
    Setattr(memoize_stripped, key, value);
    Delete(key);
    Delete(value);
  }
  return r;
}

/* -----------------------------------------------------------------------------
 * alaqilType_strip_single_qualifier()
 * 
 * If the type contains a qualifier, strip one qualifier and return a new type.
 * The left most qualifier is stripped first (when viewed as C source code) but
 * this is the equivalent to the right most qualifier using alaqilType notation.
 * Example: 
 *    r.q(const).p.q(const).int => r.q(const).p.int
 *    r.q(const).p.int          => r.p.int
 *    r.p.int                   => r.p.int
 * ----------------------------------------------------------------------------- */

alaqilType *alaqilType_strip_single_qualifier(const alaqilType *t) {
  static Hash *memoize_stripped = 0;
  alaqilType *r = 0;
  List *l;
  int numitems;

  if (!memoize_stripped)
    memoize_stripped = NewHash();
  r = Getattr(memoize_stripped, t);
  if (r)
    return Copy(r);

  l = alaqilType_split(t);

  numitems = Len(l);
  if (numitems >= 2) {
    int item;
    /* iterate backwards from last but one item */
    for (item = numitems - 2; item >= 0; --item) {
      String *subtype = Getitem(l, item);
      if (alaqilType_isqualifier(subtype)) {
	Iterator it;
	Delitem(l, item);
	r = NewStringEmpty();
	for (it = First(l); it.item; it = Next(it)) {
	  Append(r, it.item);
	}
	break;
      }
    }
  }
  if (!r)
    r = Copy(t);

  Delete(l);
  {
    String *key, *value;
    key = Copy(t);
    value = Copy(r);
    Setattr(memoize_stripped, key, value);
    Delete(key);
    Delete(value);
  }
  return r;
}

