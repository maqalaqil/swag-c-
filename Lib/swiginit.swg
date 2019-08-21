/* -----------------------------------------------------------------------------
 * Type initialization:
 * This problem is tough by the requirement that no dynamic
 * memory is used. Also, since alaqil_type_info structures store pointers to
 * alaqil_cast_info structures and alaqil_cast_info structures store pointers back
 * to alaqil_type_info structures, we need some lookup code at initialization.
 * The idea is that alaqil generates all the structures that are needed.
 * The runtime then collects these partially filled structures.
 * The alaqil_InitializeModule function takes these initial arrays out of
 * alaqil_module, and does all the lookup, filling in the alaqil_module.types
 * array with the correct data and linking the correct alaqil_cast_info
 * structures together.
 *
 * The generated alaqil_type_info structures are assigned statically to an initial
 * array. We just loop through that array, and handle each type individually.
 * First we lookup if this type has been already loaded, and if so, use the
 * loaded structure instead of the generated one. Then we have to fill in the
 * cast linked list. The cast data is initially stored in something like a
 * two-dimensional array. Each row corresponds to a type (there are the same
 * number of rows as there are in the alaqil_type_initial array). Each entry in
 * a column is one of the alaqil_cast_info structures for that type.
 * The cast_initial array is actually an array of arrays, because each row has
 * a variable number of columns. So to actually build the cast linked list,
 * we find the array of casts associated with the type, and loop through it
 * adding the casts to the list. The one last trick we need to do is making
 * sure the type pointer in the alaqil_cast_info struct is correct.
 *
 * First off, we lookup the cast->type name to see if it is already loaded.
 * There are three cases to handle:
 *  1) If the cast->type has already been loaded AND the type we are adding
 *     casting info to has not been loaded (it is in this module), THEN we
 *     replace the cast->type pointer with the type pointer that has already
 *     been loaded.
 *  2) If BOTH types (the one we are adding casting info to, and the
 *     cast->type) are loaded, THEN the cast info has already been loaded by
 *     the previous module so we just ignore it.
 *  3) Finally, if cast->type has not already been loaded, then we add that
 *     alaqil_cast_info to the linked list (because the cast->type) pointer will
 *     be correct.
 * ----------------------------------------------------------------------------- */

#ifdef __cplusplus
extern "C" {
#if 0
} /* c-mode */
#endif
#endif

#if 0
#define alaqilRUNTIME_DEBUG
#endif


alaqilRUNTIME void
alaqil_InitializeModule(void *clientdata) {
  size_t i;
  alaqil_module_info *module_head, *iter;
  int init;

  /* check to see if the circular list has been setup, if not, set it up */
  if (alaqil_module.next==0) {
    /* Initialize the alaqil_module */
    alaqil_module.type_initial = alaqil_type_initial;
    alaqil_module.cast_initial = alaqil_cast_initial;
    alaqil_module.next = &alaqil_module;
    init = 1;
  } else {
    init = 0;
  }

  /* Try and load any already created modules */
  module_head = alaqil_GetModule(clientdata);
  if (!module_head) {
    /* This is the first module loaded for this interpreter */
    /* so set the alaqil module into the interpreter */
    alaqil_SetModule(clientdata, &alaqil_module);
  } else {
    /* the interpreter has loaded a alaqil module, but has it loaded this one? */
    iter=module_head;
    do {
      if (iter==&alaqil_module) {
        /* Our module is already in the list, so there's nothing more to do. */
        return;
      }
      iter=iter->next;
    } while (iter!= module_head);

    /* otherwise we must add our module into the list */
    alaqil_module.next = module_head->next;
    module_head->next = &alaqil_module;
  }

  /* When multiple interpreters are used, a module could have already been initialized in
     a different interpreter, but not yet have a pointer in this interpreter.
     In this case, we do not want to continue adding types... everything should be
     set up already */
  if (init == 0) return;

  /* Now work on filling in alaqil_module.types */
#ifdef alaqilRUNTIME_DEBUG
  printf("alaqil_InitializeModule: size %lu\n", (unsigned long)alaqil_module.size);
#endif
  for (i = 0; i < alaqil_module.size; ++i) {
    alaqil_type_info *type = 0;
    alaqil_type_info *ret;
    alaqil_cast_info *cast;

#ifdef alaqilRUNTIME_DEBUG
    printf("alaqil_InitializeModule: type %lu %s\n", (unsigned long)i, alaqil_module.type_initial[i]->name);
#endif

    /* if there is another module already loaded */
    if (alaqil_module.next != &alaqil_module) {
      type = alaqil_MangledTypeQueryModule(alaqil_module.next, &alaqil_module, alaqil_module.type_initial[i]->name);
    }
    if (type) {
      /* Overwrite clientdata field */
#ifdef alaqilRUNTIME_DEBUG
      printf("alaqil_InitializeModule: found type %s\n", type->name);
#endif
      if (alaqil_module.type_initial[i]->clientdata) {
	type->clientdata = alaqil_module.type_initial[i]->clientdata;
#ifdef alaqilRUNTIME_DEBUG
      printf("alaqil_InitializeModule: found and overwrite type %s \n", type->name);
#endif
      }
    } else {
      type = alaqil_module.type_initial[i];
    }

    /* Insert casting types */
    cast = alaqil_module.cast_initial[i];
    while (cast->type) {

      /* Don't need to add information already in the list */
      ret = 0;
#ifdef alaqilRUNTIME_DEBUG
      printf("alaqil_InitializeModule: look cast %s\n", cast->type->name);
#endif
      if (alaqil_module.next != &alaqil_module) {
        ret = alaqil_MangledTypeQueryModule(alaqil_module.next, &alaqil_module, cast->type->name);
#ifdef alaqilRUNTIME_DEBUG
	if (ret) printf("alaqil_InitializeModule: found cast %s\n", ret->name);
#endif
      }
      if (ret) {
	if (type == alaqil_module.type_initial[i]) {
#ifdef alaqilRUNTIME_DEBUG
	  printf("alaqil_InitializeModule: skip old type %s\n", ret->name);
#endif
	  cast->type = ret;
	  ret = 0;
	} else {
	  /* Check for casting already in the list */
	  alaqil_cast_info *ocast = alaqil_TypeCheck(ret->name, type);
#ifdef alaqilRUNTIME_DEBUG
	  if (ocast) printf("alaqil_InitializeModule: skip old cast %s\n", ret->name);
#endif
	  if (!ocast) ret = 0;
	}
      }

      if (!ret) {
#ifdef alaqilRUNTIME_DEBUG
	printf("alaqil_InitializeModule: adding cast %s\n", cast->type->name);
#endif
        if (type->cast) {
          type->cast->prev = cast;
          cast->next = type->cast;
        }
        type->cast = cast;
      }
      cast++;
    }
    /* Set entry in modules->types array equal to the type */
    alaqil_module.types[i] = type;
  }
  alaqil_module.types[i] = 0;

#ifdef alaqilRUNTIME_DEBUG
  printf("**** alaqil_InitializeModule: Cast List ******\n");
  for (i = 0; i < alaqil_module.size; ++i) {
    int j = 0;
    alaqil_cast_info *cast = alaqil_module.cast_initial[i];
    printf("alaqil_InitializeModule: type %lu %s\n", (unsigned long)i, alaqil_module.type_initial[i]->name);
    while (cast->type) {
      printf("alaqil_InitializeModule: cast type %s\n", cast->type->name);
      cast++;
      ++j;
    }
  printf("---- Total casts: %d\n",j);
  }
  printf("**** alaqil_InitializeModule: Cast List ******\n");
#endif
}

/* This function will propagate the clientdata field of type to
* any new alaqil_type_info structures that have been added into the list
* of equivalent types.  It is like calling
* alaqil_TypeClientData(type, clientdata) a second time.
*/
alaqilRUNTIME void
alaqil_PropagateClientData(void) {
  size_t i;
  alaqil_cast_info *equiv;
  static int init_run = 0;

  if (init_run) return;
  init_run = 1;

  for (i = 0; i < alaqil_module.size; i++) {
    if (alaqil_module.types[i]->clientdata) {
      equiv = alaqil_module.types[i]->cast;
      while (equiv) {
        if (!equiv->converter) {
          if (equiv->type && !equiv->type->clientdata)
            alaqil_TypeClientData(equiv->type, alaqil_module.types[i]->clientdata);
        }
        equiv = equiv->next;
      }
    }
  }
}

#ifdef __cplusplus
#if 0
{ /* c-mode */
#endif
}
#endif
