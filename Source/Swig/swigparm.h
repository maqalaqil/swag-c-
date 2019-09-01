/* ----------------------------------------------------------------------------- 
 * This file is part of alaqil, which is licensed as a whole under version 3 
 * (or any later version) of the GNU General Public License. Some additional
 * terms also apply to certain portions of alaqil. The full details of the alaqil
 * license and copyrights can be found in the LICENSE and COPYRIGHT files
 * included with the alaqil source code as distributed by the alaqil developers
 * and at http://www.alaqil.org/legal.html.
 *
 * alaqilparm.h
 *
 * Functions related to the handling of function/method parameters and
 * parameter lists.  
 * ----------------------------------------------------------------------------- */

/* Individual parameters */
extern Parm      *NewParm(alaqilType *type, const_String_or_char_ptr name, Node *from_node);
extern Parm      *NewParmWithoutFileLineInfo(alaqilType *type, const_String_or_char_ptr name);
extern Parm      *NewParmNode(alaqilType *type, Node *from_node);
extern Parm      *CopyParm(Parm *p);

/* Parameter lists */
extern ParmList  *CopyParmList(ParmList *);
extern ParmList  *CopyParmListMax(ParmList *, int count);
extern int        ParmList_len(ParmList *);
extern int        ParmList_numrequired(ParmList *);
extern int        ParmList_has_defaultargs(ParmList *p);
extern int        ParmList_has_varargs(ParmList *p);

/* Output functions */
extern String    *ParmList_str(ParmList *);
extern String    *ParmList_str_defaultargs(ParmList *);
extern String    *ParmList_str_multibrackets(ParmList *);
extern String    *ParmList_protostr(ParmList *);


