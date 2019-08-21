/* 
* From alaqil 1.3.37 we deprecated all alaqil symbols that start with Py,
* since they are inappropriate and discouraged in Python documentation
* (from http://www.python.org/doc/2.5.2/api/includes.html):
*
* "All user visible names defined by Python.h (except those defined by the included
* standard headers) have one of the prefixes "Py" or "_Py". Names beginning with
* "_Py" are for internal use by the Python implementation and should not be used
* by extension writers. Structure member names do not have a reserved prefix.
*
* Important: user code should never define names that begin with "Py" or "_Py".
* This confuses the reader, and jeopardizes the portability of the user code to
* future Python versions, which may define additional names beginning with one
* of these prefixes."
*
* This file defined macros to provide backward compatibility for these deprecated
* symbols. In the case you have these symbols in your interface file, you can simply
* include this file at beginning of it.
*
* However, this file may be removed in future release of alaqil, so using this file to
* keep these inappropriate names in your alaqil interface file is also not recommended.
* Instead, we provide a simple tool for converting your interface files to
* the new naming convention. You can get the tool from the alaqil distribution:
* Tools/pyname_patch.py
*/

%fragment("PySequence_Base", "header", fragment="alaqilPySequence_Base") {}
%fragment("PySequence_Cont", "header", fragment="alaqilPySequence_Cont") {}
%fragment("PyalaqilIterator_T", "header", fragment="alaqilPyIterator_T") {}
%fragment("PyPairBoolOutputIterator", "header", fragment="alaqilPyPairBoolOutputIterator") {}
%fragment("PyalaqilIterator", "header", fragment="alaqilPyIterator") {}
%fragment("PyalaqilIterator_T", "header", fragment="alaqilPyIterator_T") {}

%inline %{
#define PyMapIterator_T alaqilPyMapIterator_T
#define PyMapKeyIterator_T alaqilPyMapKeyIterator_T
#define PyMapValueIterator_T alaqilPyMapValueIterator_T
#define PyObject_ptr alaqilPtr_PyObject
#define PyObject_var alaqilVar_PyObject
#define PyOper alaqilPyOper
#define PySeq alaqilPySeq
#define PySequence_ArrowProxy alaqilPySequence_ArrowProxy
#define PySequence_Cont alaqilPySequence_Cont
#define PySequence_InputIterator alaqilPySequence_InputIterator
#define PySequence_Ref alaqilPySequence_Ref
#define PyalaqilClientData alaqilPyClientData
#define PyalaqilClientData_Del alaqilPyClientData_Del
#define PyalaqilClientData_New alaqilPyClientData_New
#define PyalaqilIterator alaqilPyIterator
#define PyalaqilIteratorClosed_T alaqilPyIteratorClosed_T
#define PyalaqilIteratorOpen_T alaqilPyIteratorOpen_T
#define PyalaqilIterator_T alaqilPyIterator_T
#define PyalaqilObject alaqilPyObject
#define PyalaqilObject_Check alaqilPyObject_Check
#define PyalaqilObject_GetDesc alaqilPyObject_GetDesc
#define PyalaqilObject_New alaqilPyObject_New
#define PyalaqilObject_acquire alaqilPyObject_acquire
#define PyalaqilObject_append alaqilPyObject_append
#define PyalaqilObject_as_number alaqilPyObject_as_number
#define PyalaqilObject_compare alaqilPyObject_compare
#define PyalaqilObject_dealloc alaqilPyObject_dealloc
#define PyalaqilObject_disown alaqilPyObject_disown
#define PyalaqilObject_format alaqilPyObject_format
#define PyalaqilObject_getattr alaqilPyObject_getattr
#define PyalaqilObject_hex alaqilPyObject_hex
#define PyalaqilObject_long alaqilPyObject_long
#define PyalaqilObject_next alaqilPyObject_next
#define PyalaqilObject_oct alaqilPyObject_oct
#define PyalaqilObject_own alaqilPyObject_own
#define PyalaqilObject_repr alaqilPyObject_repr
#define PyalaqilObject_richcompare alaqilPyObject_richcompare
#define PyalaqilObject_type alaqilPyObject_type
#define PyalaqilPacked alaqilPyPacked
#define PyalaqilPacked_Check alaqilPyPacked_Check
#define PyalaqilPacked_New alaqilPyPacked_New
#define PyalaqilPacked_UnpackData alaqilPyPacked_UnpackData
#define PyalaqilPacked_compare alaqilPyPacked_compare
#define PyalaqilPacked_dealloc alaqilPyPacked_dealloc
#define PyalaqilPacked_repr alaqilPyPacked_repr
#define PyalaqilPacked_str alaqilPyPacked_str
#define PyalaqilPacked_type alaqilPyPacked_type
#define pyseq alaqilpyseq
#define pyalaqilobject_type alaqilpyobject_type
#define pyalaqilpacked_type alaqilpypacked_type
%}
