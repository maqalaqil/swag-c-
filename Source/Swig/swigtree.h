/* ----------------------------------------------------------------------------- 
 * This file is part of alaqil, which is licensed as a whole under version 3 
 * (or any later version) of the GNU General Public License. Some additional
 * terms also apply to certain portions of alaqil. The full details of the alaqil
 * license and copyrights can be found in the LICENSE and COPYRIGHT files
 * included with the alaqil source code as distributed by the alaqil developers
 * and at http://www.alaqil.org/legal.html.
 *
 * alaqiltree.h
 *
 * These functions are used to access and manipulate the alaqil parse tree.
 * The structure of this tree is modeled directly after XML-DOM.  The attribute 
 * and function names are meant to be similar.
 * ----------------------------------------------------------------------------- */

/* Macros to traverse the DOM tree */

#define  nodeType(x)               Getattr(x,"nodeType")
#define  parentNode(x)             Getattr(x,"parentNode")
#define  previousSibling(x)        Getattr(x,"previousSibling")
#define  nextSibling(x)            Getattr(x,"nextSibling")
#define  firstChild(x)             Getattr(x,"firstChild")
#define  lastChild(x)              Getattr(x,"lastChild")

/* Macros to set up the DOM tree (mostly used by the parser) */

#define  set_nodeType(x,v)         Setattr(x,"nodeType",v)
#define  set_parentNode(x,v)       Setattr(x,"parentNode",v)
#define  set_previousSibling(x,v)  Setattr(x,"previousSibling",v)
#define  set_nextSibling(x,v)      Setattr(x,"nextSibling",v)
#define  set_firstChild(x,v)       Setattr(x,"firstChild",v)
#define  set_lastChild(x,v)        Setattr(x,"lastChild",v)

/* Utility functions */

extern int    checkAttribute(Node *obj, const_String_or_char_ptr name, const_String_or_char_ptr value);
extern void   appendChild(Node *node, Node *child);
extern void   prependChild(Node *node, Node *child);
extern void   removeNode(Node *node);
extern Node  *copyNode(Node *node);
extern void   appendSibling(Node *node, Node *child);

/* Node restoration/restore functions */

extern void  alaqil_require(const char *ns, Node *node, ...);
extern void  alaqil_save(const char *ns, Node *node, ...);
extern void  alaqil_restore(Node *node);

/* Debugging of parse trees */

extern void alaqil_print_tags(File *obj, Node *root);
extern void alaqil_print_tree(Node *obj);
extern void alaqil_print_node(Node *obj);
