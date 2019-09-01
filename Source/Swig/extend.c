/* -----------------------------------------------------------------------------
 * This file is part of alaqil, which is licensed as a whole under version 3 
 * (or any later version) of the GNU General Public License. Some additional
 * terms also apply to certain portions of alaqil. The full details of the alaqil
 * license and copyrights can be found in the LICENSE and COPYRIGHT files
 * included with the alaqil source code as distributed by the alaqil developers
 * and at http://www.alaqil.org/legal.html.
 *
 * extend.c
 *
 * Extensions support (%extend)
 * ----------------------------------------------------------------------------- */

#include "alaqil.h"
#include "cparse.h"

static Hash *extendhash = 0;     /* Hash table of added methods */

/* -----------------------------------------------------------------------------
 * alaqil_extend_hash()
 *
 * Access the extend hash
 * ----------------------------------------------------------------------------- */
Hash *alaqil_extend_hash(void) {
  if (!extendhash)
    extendhash = NewHash();
  return extendhash;
}

/* -----------------------------------------------------------------------------
 * alaqil_extend_merge()
 *
 * Extension merge.  This function is used to handle the %extend directive
 * when it appears before a class definition.   To handle this, the %extend
 * actually needs to take precedence.  Therefore, we will selectively nuke symbols
 * from the current symbol table, replacing them with the added methods.
 * ----------------------------------------------------------------------------- */

void alaqil_extend_merge(Node *cls, Node *am) {
  Node *n;
  Node *csym;

  n = firstChild(am);
  while (n) {
    String *symname;
    if (Strcmp(nodeType(n),"constructor") == 0) {
      symname = Getattr(n,"sym:name");
      if (symname) {
	if (Strcmp(symname,Getattr(n,"name")) == 0) {
	  /* If the name and the sym:name of a constructor are the same,
             then it hasn't been renamed.  However---the name of the class
             itself might have been renamed so we need to do a consistency
             check here */
	  if (Getattr(cls,"sym:name")) {
	    Setattr(n,"sym:name", Getattr(cls,"sym:name"));
	  }
	}
      } 
    }

    symname = Getattr(n,"sym:name");
    DohIncref(symname);
    if ((symname) && (!Getattr(n,"error"))) {
      /* Remove node from its symbol table */
      alaqil_symbol_remove(n);
      csym = alaqil_symbol_add(symname,n);
      if (csym != n) {
	/* Conflict with previous definition.  Nuke previous definition */
	String *e = NewStringEmpty();
	String *en = NewStringEmpty();
	String *ec = NewStringEmpty();
	Printf(ec,"Identifier '%s' redefined by %%extend (ignored),",symname);
	Printf(en,"%%extend definition of '%s'.",symname);
	alaqil_WARN_NODE_BEGIN(n);
	alaqil_warning(WARN_PARSE_REDEFINED,Getfile(csym),Getline(csym),"%s\n",ec);
	alaqil_warning(WARN_PARSE_REDEFINED,Getfile(n),Getline(n),"%s\n",en);
	alaqil_WARN_NODE_END(n);
	Printf(e,"%s:%d:%s\n%s:%d:%s\n",Getfile(csym),Getline(csym),ec, 
	       Getfile(n),Getline(n),en);
	Setattr(csym,"error",e);
	Delete(e);
	Delete(en);
	Delete(ec);
	alaqil_symbol_remove(csym);              /* Remove class definition */
	alaqil_symbol_add(symname,n);            /* Insert extend definition */
      }
    }
    n = nextSibling(n);
  }
}

/* -----------------------------------------------------------------------------
 * alaqil_extend_append_previous()
 * ----------------------------------------------------------------------------- */

void alaqil_extend_append_previous(Node *cls, Node *am) {
  Node *n, *ne;
  Node *pe = 0;
  Node *ae = 0;

  if (!am) return;
  
  n = firstChild(am);
  while (n) {
    ne = nextSibling(n);
    set_nextSibling(n,0);
    /* typemaps and fragments need to be prepended */
    if (((Cmp(nodeType(n),"typemap") == 0) || (Cmp(nodeType(n),"fragment") == 0)))  {
      if (!pe) pe = alaqil_cparse_new_node("extend");
      appendChild(pe, n);
    } else {
      if (!ae) ae = alaqil_cparse_new_node("extend");
      appendChild(ae, n);
    }    
    n = ne;
  }
  if (pe) prependChild(cls,pe);
  if (ae) appendChild(cls,ae);
}
 

/* -----------------------------------------------------------------------------
 * alaqil_extend_unused_check()
 *
 * Check for unused %extend.  Special case, don't report unused
 * extensions for templates
 * ----------------------------------------------------------------------------- */
 
void alaqil_extend_unused_check(void) {
  Iterator ki;

  if (!extendhash) return;
  for (ki = First(extendhash); ki.key; ki = Next(ki)) {
    if (!Strchr(ki.key,'<')) {
      alaqil_WARN_NODE_BEGIN(ki.item);
      alaqil_warning(WARN_PARSE_EXTEND_UNDEF,Getfile(ki.item), Getline(ki.item), "%%extend defined for an undeclared class %s.\n", alaqilType_namestr(ki.key));
      alaqil_WARN_NODE_END(ki.item);
    }
  }
}

