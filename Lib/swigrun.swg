/* -----------------------------------------------------------------------------
 * alaqilrun.swg
 *
 * This file contains generic C API alaqil runtime support for pointer
 * type checking.
 * ----------------------------------------------------------------------------- */

/* This should only be incremented when either the layout of alaqil_type_info changes,
   or for whatever reason, the runtime changes incompatibly */
#define alaqil_RUNTIME_VERSION "4"

/* define alaqil_TYPE_TABLE_NAME as "alaqil_TYPE_TABLE" */
#ifdef alaqil_TYPE_TABLE
# define alaqil_QUOTE_STRING(x) #x
# define alaqil_EXPAND_AND_QUOTE_STRING(x) alaqil_QUOTE_STRING(x)
# define alaqil_TYPE_TABLE_NAME alaqil_EXPAND_AND_QUOTE_STRING(alaqil_TYPE_TABLE)
#else
# define alaqil_TYPE_TABLE_NAME
#endif

/*
  You can use the alaqilRUNTIME and alaqilRUNTIMEINLINE macros for
  creating a static or dynamic library from the alaqil runtime code.
  In 99.9% of the cases, alaqil just needs to declare them as 'static'.

  But only do this if strictly necessary, ie, if you have problems
  with your compiler or suchlike.
*/

#ifndef alaqilRUNTIME
# define alaqilRUNTIME alaqilINTERN
#endif

#ifndef alaqilRUNTIMEINLINE
# define alaqilRUNTIMEINLINE alaqilRUNTIME alaqilINLINE
#endif

/*  Generic buffer size */
#ifndef alaqil_BUFFER_SIZE
# define alaqil_BUFFER_SIZE 1024
#endif

/* Flags for pointer conversions */
#define alaqil_POINTER_DISOWN        0x1
#define alaqil_CAST_NEW_MEMORY       0x2
#define alaqil_POINTER_NO_NULL       0x4

/* Flags for new pointer objects */
#define alaqil_POINTER_OWN           0x1


/*
   Flags/methods for returning states.

   The alaqil conversion methods, as ConvertPtr, return an integer
   that tells if the conversion was successful or not. And if not,
   an error code can be returned (see alaqilerrors.swg for the codes).

   Use the following macros/flags to set or process the returning
   states.

   In old versions of alaqil, code such as the following was usually written:

     if (alaqil_ConvertPtr(obj,vptr,ty.flags) != -1) {
       // success code
     } else {
       //fail code
     }

   Now you can be more explicit:

    int res = alaqil_ConvertPtr(obj,vptr,ty.flags);
    if (alaqil_IsOK(res)) {
      // success code
    } else {
      // fail code
    }

   which is the same really, but now you can also do

    Type *ptr;
    int res = alaqil_ConvertPtr(obj,(void **)(&ptr),ty.flags);
    if (alaqil_IsOK(res)) {
      // success code
      if (alaqil_IsNewObj(res) {
        ...
	delete *ptr;
      } else {
        ...
      }
    } else {
      // fail code
    }

   I.e., now alaqil_ConvertPtr can return new objects and you can
   identify the case and take care of the deallocation. Of course that
   also requires alaqil_ConvertPtr to return new result values, such as

      int alaqil_ConvertPtr(obj, ptr,...) {
        if (<obj is ok>) {
          if (<need new object>) {
            *ptr = <ptr to new allocated object>;
            return alaqil_NEWOBJ;
          } else {
            *ptr = <ptr to old object>;
            return alaqil_OLDOBJ;
          }
        } else {
          return alaqil_BADOBJ;
        }
      }

   Of course, returning the plain '0(success)/-1(fail)' still works, but you can be
   more explicit by returning alaqil_BADOBJ, alaqil_ERROR or any of the
   alaqil errors code.

   Finally, if the alaqil_CASTRANK_MODE is enabled, the result code
   allows to return the 'cast rank', for example, if you have this

       int food(double)
       int fooi(int);

   and you call

      food(1)   // cast rank '1'  (1 -> 1.0)
      fooi(1)   // cast rank '0'

   just use the alaqil_AddCast()/alaqil_CheckState()
*/

#define alaqil_OK                    (0)
#define alaqil_ERROR                 (-1)
#define alaqil_IsOK(r)               (r >= 0)
#define alaqil_ArgError(r)           ((r != alaqil_ERROR) ? r : alaqil_TypeError)

/* The CastRankLimit says how many bits are used for the cast rank */
#define alaqil_CASTRANKLIMIT         (1 << 8)
/* The NewMask denotes the object was created (using new/malloc) */
#define alaqil_NEWOBJMASK            (alaqil_CASTRANKLIMIT  << 1)
/* The TmpMask is for in/out typemaps that use temporal objects */
#define alaqil_TMPOBJMASK            (alaqil_NEWOBJMASK << 1)
/* Simple returning values */
#define alaqil_BADOBJ                (alaqil_ERROR)
#define alaqil_OLDOBJ                (alaqil_OK)
#define alaqil_NEWOBJ                (alaqil_OK | alaqil_NEWOBJMASK)
#define alaqil_TMPOBJ                (alaqil_OK | alaqil_TMPOBJMASK)
/* Check, add and del mask methods */
#define alaqil_AddNewMask(r)         (alaqil_IsOK(r) ? (r | alaqil_NEWOBJMASK) : r)
#define alaqil_DelNewMask(r)         (alaqil_IsOK(r) ? (r & ~alaqil_NEWOBJMASK) : r)
#define alaqil_IsNewObj(r)           (alaqil_IsOK(r) && (r & alaqil_NEWOBJMASK))
#define alaqil_AddTmpMask(r)         (alaqil_IsOK(r) ? (r | alaqil_TMPOBJMASK) : r)
#define alaqil_DelTmpMask(r)         (alaqil_IsOK(r) ? (r & ~alaqil_TMPOBJMASK) : r)
#define alaqil_IsTmpObj(r)           (alaqil_IsOK(r) && (r & alaqil_TMPOBJMASK))

/* Cast-Rank Mode */
#if defined(alaqil_CASTRANK_MODE)
#  ifndef alaqil_TypeRank
#    define alaqil_TypeRank             unsigned long
#  endif
#  ifndef alaqil_MAXCASTRANK            /* Default cast allowed */
#    define alaqil_MAXCASTRANK          (2)
#  endif
#  define alaqil_CASTRANKMASK          ((alaqil_CASTRANKLIMIT) -1)
#  define alaqil_CastRank(r)           (r & alaqil_CASTRANKMASK)
alaqilINTERNINLINE int alaqil_AddCast(int r) {
  return alaqil_IsOK(r) ? ((alaqil_CastRank(r) < alaqil_MAXCASTRANK) ? (r + 1) : alaqil_ERROR) : r;
}
alaqilINTERNINLINE int alaqil_CheckState(int r) {
  return alaqil_IsOK(r) ? alaqil_CastRank(r) + 1 : 0;
}
#else /* no cast-rank mode */
#  define alaqil_AddCast(r) (r)
#  define alaqil_CheckState(r) (alaqil_IsOK(r) ? 1 : 0)
#endif


#include <string.h>

#ifdef __cplusplus
extern "C" {
#endif

typedef void *(*alaqil_converter_func)(void *, int *);
typedef struct alaqil_type_info *(*alaqil_dycast_func)(void **);

/* Structure to store information on one type */
typedef struct alaqil_type_info {
  const char             *name;			/* mangled name of this type */
  const char             *str;			/* human readable name of this type */
  alaqil_dycast_func        dcast;		/* dynamic cast function down a hierarchy */
  struct alaqil_cast_info  *cast;			/* linked list of types that can cast into this type */
  void                   *clientdata;		/* language specific type data */
  int                    owndata;		/* flag if the structure owns the clientdata */
} alaqil_type_info;

/* Structure to store a type and conversion function used for casting */
typedef struct alaqil_cast_info {
  alaqil_type_info         *type;			/* pointer to type that is equivalent to this type */
  alaqil_converter_func     converter;		/* function to cast the void pointers */
  struct alaqil_cast_info  *next;			/* pointer to next cast in linked list */
  struct alaqil_cast_info  *prev;			/* pointer to the previous cast */
} alaqil_cast_info;

/* Structure used to store module information
 * Each module generates one structure like this, and the runtime collects
 * all of these structures and stores them in a circularly linked list.*/
typedef struct alaqil_module_info {
  alaqil_type_info         **types;		/* Array of pointers to alaqil_type_info structures that are in this module */
  size_t                 size;		        /* Number of types in this module */
  struct alaqil_module_info *next;		/* Pointer to next element in circularly linked list */
  alaqil_type_info         **type_initial;	/* Array of initially generated type structures */
  alaqil_cast_info         **cast_initial;	/* Array of initially generated casting structures */
  void                    *clientdata;		/* Language specific module data */
} alaqil_module_info;

/*
  Compare two type names skipping the space characters, therefore
  "char*" == "char *" and "Class<int>" == "Class<int >", etc.

  Return 0 when the two name types are equivalent, as in
  strncmp, but skipping ' '.
*/
alaqilRUNTIME int
alaqil_TypeNameComp(const char *f1, const char *l1,
		  const char *f2, const char *l2) {
  for (;(f1 != l1) && (f2 != l2); ++f1, ++f2) {
    while ((*f1 == ' ') && (f1 != l1)) ++f1;
    while ((*f2 == ' ') && (f2 != l2)) ++f2;
    if (*f1 != *f2) return (*f1 > *f2) ? 1 : -1;
  }
  return (int)((l1 - f1) - (l2 - f2));
}

/*
  Check type equivalence in a name list like <name1>|<name2>|...
  Return 0 if equal, -1 if nb < tb, 1 if nb > tb
*/
alaqilRUNTIME int
alaqil_TypeCmp(const char *nb, const char *tb) {
  int equiv = 1;
  const char* te = tb + strlen(tb);
  const char* ne = nb;
  while (equiv != 0 && *ne) {
    for (nb = ne; *ne; ++ne) {
      if (*ne == '|') break;
    }
    equiv = alaqil_TypeNameComp(nb, ne, tb, te);
    if (*ne) ++ne;
  }
  return equiv;
}

/*
  Check type equivalence in a name list like <name1>|<name2>|...
  Return 0 if not equal, 1 if equal
*/
alaqilRUNTIME int
alaqil_TypeEquiv(const char *nb, const char *tb) {
  return alaqil_TypeCmp(nb, tb) == 0 ? 1 : 0;
}

/*
  Check the typename
*/
alaqilRUNTIME alaqil_cast_info *
alaqil_TypeCheck(const char *c, alaqil_type_info *ty) {
  if (ty) {
    alaqil_cast_info *iter = ty->cast;
    while (iter) {
      if (strcmp(iter->type->name, c) == 0) {
        if (iter == ty->cast)
          return iter;
        /* Move iter to the top of the linked list */
        iter->prev->next = iter->next;
        if (iter->next)
          iter->next->prev = iter->prev;
        iter->next = ty->cast;
        iter->prev = 0;
        if (ty->cast) ty->cast->prev = iter;
        ty->cast = iter;
        return iter;
      }
      iter = iter->next;
    }
  }
  return 0;
}

/*
  Identical to alaqil_TypeCheck, except strcmp is replaced with a pointer comparison
*/
alaqilRUNTIME alaqil_cast_info *
alaqil_TypeCheckStruct(alaqil_type_info *from, alaqil_type_info *ty) {
  if (ty) {
    alaqil_cast_info *iter = ty->cast;
    while (iter) {
      if (iter->type == from) {
        if (iter == ty->cast)
          return iter;
        /* Move iter to the top of the linked list */
        iter->prev->next = iter->next;
        if (iter->next)
          iter->next->prev = iter->prev;
        iter->next = ty->cast;
        iter->prev = 0;
        if (ty->cast) ty->cast->prev = iter;
        ty->cast = iter;
        return iter;
      }
      iter = iter->next;
    }
  }
  return 0;
}

/*
  Cast a pointer up an inheritance hierarchy
*/
alaqilRUNTIMEINLINE void *
alaqil_TypeCast(alaqil_cast_info *ty, void *ptr, int *newmemory) {
  return ((!ty) || (!ty->converter)) ? ptr : (*ty->converter)(ptr, newmemory);
}

/*
   Dynamic pointer casting. Down an inheritance hierarchy
*/
alaqilRUNTIME alaqil_type_info *
alaqil_TypeDynamicCast(alaqil_type_info *ty, void **ptr) {
  alaqil_type_info *lastty = ty;
  if (!ty || !ty->dcast) return ty;
  while (ty && (ty->dcast)) {
    ty = (*ty->dcast)(ptr);
    if (ty) lastty = ty;
  }
  return lastty;
}

/*
  Return the name associated with this type
*/
alaqilRUNTIMEINLINE const char *
alaqil_TypeName(const alaqil_type_info *ty) {
  return ty->name;
}

/*
  Return the pretty name associated with this type,
  that is an unmangled type name in a form presentable to the user.
*/
alaqilRUNTIME const char *
alaqil_TypePrettyName(const alaqil_type_info *type) {
  /* The "str" field contains the equivalent pretty names of the
     type, separated by vertical-bar characters.  We choose
     to print the last name, as it is often (?) the most
     specific. */
  if (!type) return NULL;
  if (type->str != NULL) {
    const char *last_name = type->str;
    const char *s;
    for (s = type->str; *s; s++)
      if (*s == '|') last_name = s+1;
    return last_name;
  }
  else
    return type->name;
}

/*
   Set the clientdata field for a type
*/
alaqilRUNTIME void
alaqil_TypeClientData(alaqil_type_info *ti, void *clientdata) {
  alaqil_cast_info *cast = ti->cast;
  /* if (ti->clientdata == clientdata) return; */
  ti->clientdata = clientdata;

  while (cast) {
    if (!cast->converter) {
      alaqil_type_info *tc = cast->type;
      if (!tc->clientdata) {
	alaqil_TypeClientData(tc, clientdata);
      }
    }
    cast = cast->next;
  }
}
alaqilRUNTIME void
alaqil_TypeNewClientData(alaqil_type_info *ti, void *clientdata) {
  alaqil_TypeClientData(ti, clientdata);
  ti->owndata = 1;
}

/*
  Search for a alaqil_type_info structure only by mangled name
  Search is a O(log #types)

  We start searching at module start, and finish searching when start == end.
  Note: if start == end at the beginning of the function, we go all the way around
  the circular list.
*/
alaqilRUNTIME alaqil_type_info *
alaqil_MangledTypeQueryModule(alaqil_module_info *start,
                            alaqil_module_info *end,
		            const char *name) {
  alaqil_module_info *iter = start;
  do {
    if (iter->size) {
      size_t l = 0;
      size_t r = iter->size - 1;
      do {
	/* since l+r >= 0, we can (>> 1) instead (/ 2) */
	size_t i = (l + r) >> 1;
	const char *iname = iter->types[i]->name;
	if (iname) {
	  int compare = strcmp(name, iname);
	  if (compare == 0) {
	    return iter->types[i];
	  } else if (compare < 0) {
	    if (i) {
	      r = i - 1;
	    } else {
	      break;
	    }
	  } else if (compare > 0) {
	    l = i + 1;
	  }
	} else {
	  break; /* should never happen */
	}
      } while (l <= r);
    }
    iter = iter->next;
  } while (iter != end);
  return 0;
}

/*
  Search for a alaqil_type_info structure for either a mangled name or a human readable name.
  It first searches the mangled names of the types, which is a O(log #types)
  If a type is not found it then searches the human readable names, which is O(#types).

  We start searching at module start, and finish searching when start == end.
  Note: if start == end at the beginning of the function, we go all the way around
  the circular list.
*/
alaqilRUNTIME alaqil_type_info *
alaqil_TypeQueryModule(alaqil_module_info *start,
                     alaqil_module_info *end,
		     const char *name) {
  /* STEP 1: Search the name field using binary search */
  alaqil_type_info *ret = alaqil_MangledTypeQueryModule(start, end, name);
  if (ret) {
    return ret;
  } else {
    /* STEP 2: If the type hasn't been found, do a complete search
       of the str field (the human readable name) */
    alaqil_module_info *iter = start;
    do {
      size_t i = 0;
      for (; i < iter->size; ++i) {
	if (iter->types[i]->str && (alaqil_TypeEquiv(iter->types[i]->str, name)))
	  return iter->types[i];
      }
      iter = iter->next;
    } while (iter != end);
  }

  /* neither found a match */
  return 0;
}

/*
   Pack binary data into a string
*/
alaqilRUNTIME char *
alaqil_PackData(char *c, void *ptr, size_t sz) {
  static const char hex[17] = "0123456789abcdef";
  const unsigned char *u = (unsigned char *) ptr;
  const unsigned char *eu =  u + sz;
  for (; u != eu; ++u) {
    unsigned char uu = *u;
    *(c++) = hex[(uu & 0xf0) >> 4];
    *(c++) = hex[uu & 0xf];
  }
  return c;
}

/*
   Unpack binary data from a string
*/
alaqilRUNTIME const char *
alaqil_UnpackData(const char *c, void *ptr, size_t sz) {
  unsigned char *u = (unsigned char *) ptr;
  const unsigned char *eu = u + sz;
  for (; u != eu; ++u) {
    char d = *(c++);
    unsigned char uu;
    if ((d >= '0') && (d <= '9'))
      uu = (unsigned char)((d - '0') << 4);
    else if ((d >= 'a') && (d <= 'f'))
      uu = (unsigned char)((d - ('a'-10)) << 4);
    else
      return (char *) 0;
    d = *(c++);
    if ((d >= '0') && (d <= '9'))
      uu |= (unsigned char)(d - '0');
    else if ((d >= 'a') && (d <= 'f'))
      uu |= (unsigned char)(d - ('a'-10));
    else
      return (char *) 0;
    *u = uu;
  }
  return c;
}

/*
   Pack 'void *' into a string buffer.
*/
alaqilRUNTIME char *
alaqil_PackVoidPtr(char *buff, void *ptr, const char *name, size_t bsz) {
  char *r = buff;
  if ((2*sizeof(void *) + 2) > bsz) return 0;
  *(r++) = '_';
  r = alaqil_PackData(r,&ptr,sizeof(void *));
  if (strlen(name) + 1 > (bsz - (r - buff))) return 0;
  strcpy(r,name);
  return buff;
}

alaqilRUNTIME const char *
alaqil_UnpackVoidPtr(const char *c, void **ptr, const char *name) {
  if (*c != '_') {
    if (strcmp(c,"NULL") == 0) {
      *ptr = (void *) 0;
      return name;
    } else {
      return 0;
    }
  }
  return alaqil_UnpackData(++c,ptr,sizeof(void *));
}

alaqilRUNTIME char *
alaqil_PackDataName(char *buff, void *ptr, size_t sz, const char *name, size_t bsz) {
  char *r = buff;
  size_t lname = (name ? strlen(name) : 0);
  if ((2*sz + 2 + lname) > bsz) return 0;
  *(r++) = '_';
  r = alaqil_PackData(r,ptr,sz);
  if (lname) {
    strncpy(r,name,lname+1);
  } else {
    *r = 0;
  }
  return buff;
}

alaqilRUNTIME const char *
alaqil_UnpackDataName(const char *c, void *ptr, size_t sz, const char *name) {
  if (*c != '_') {
    if (strcmp(c,"NULL") == 0) {
      memset(ptr,0,sz);
      return name;
    } else {
      return 0;
    }
  }
  return alaqil_UnpackData(++c,ptr,sz);
}

#ifdef __cplusplus
}
#endif
