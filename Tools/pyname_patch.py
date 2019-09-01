#!/usr/bin/env python
"""
From alaqil 1.3.37 we deprecated all alaqil symbols that start with Py,
since they are inappropriate and discouraged in Python documentation
(from http://www.python.org/doc/2.5.2/api/includes.html):

"All user visible names defined by Python.h (except those defined by the included
standard headers) have one of the prefixes "Py" or "_Py". Names beginning with
"_Py" are for internal use by the Python implementation and should not be used
by extension writers. Structure member names do not have a reserved prefix.

Important: user code should never define names that begin with "Py" or "_Py".
This confuses the reader, and jeopardizes the portability of the user code to
future Python versions, which may define additional names beginning with one
of these prefixes."

This file is a simple script used for change all of these symbols, for user code
or alaqil itself. 
"""
import re
from shutil import copyfile
import sys

symbols = [
        #(old name, new name)
        ("PySequence_Base", "alaqilPySequence_Base"),
        ("PySequence_Cont", "alaqilPySequence_Cont"),
        ("PyalaqilIterator_T", "alaqilPyIterator_T"),
        ("PyPairBoolOutputIterator", "alaqilPyPairBoolOutputIterator"),
        ("PyalaqilIterator", "alaqilPyIterator"),
        ("PyalaqilIterator_T", "alaqilPyIterator_T"),
        ("PyMapIterator_T", "alaqilPyMapIterator_T"),
        ("PyMapKeyIterator_T", "alaqilPyMapKeyIterator_T"),
        ("PyMapValueIterator_T", "alaqilPyMapValueITerator_T"),
        ("PyObject_ptr", "alaqilPtr_PyObject"),
        ("PyObject_var", "alaqilVar_PyObject"),
        ("PyOper", "alaqilPyOper"),
        ("PySeq", "alaqilPySeq"),
        ("PySequence_ArrowProxy", "alaqilPySequence_ArrowProxy"),
        ("PySequence_Cont", "alaqilPySequence_Cont"),
        ("PySequence_InputIterator", "alaqilPySequence_InputIterator"),
        ("PySequence_Ref", "alaqilPySequence_Ref"),
        ("PyalaqilClientData", "alaqilPyClientData"),
        ("PyalaqilClientData_Del", "alaqilPyClientData_Del"),
        ("PyalaqilClientData_New", "alaqilPyClientData_New"),
        ("PyalaqilIterator", "alaqilPyIterator"),
        ("PyalaqilIteratorClosed_T", "alaqilPyIteratorClosed_T"),
        ("PyalaqilIteratorOpen_T", "alaqilPyIteratorOpen_T"),
        ("PyalaqilIterator_T", "alaqilPyIterator_T"),
        ("PyalaqilObject", "alaqilPyObject"),
        ("PyalaqilObject_Check", "alaqilPyObject_Check"),
        ("PyalaqilObject_GetDesc", "alaqilPyObject_GetDesc"),
        ("PyalaqilObject_New", "alaqilPyObject_New"),
        ("PyalaqilObject_acquire", "alaqilPyObject_acquire"),
        ("PyalaqilObject_append", "alaqilPyObject_append"),
        ("PyalaqilObject_as_number", "alaqilPyObject_as_number"),
        ("PyalaqilObject_compare", "alaqilPyObject_compare"),
        ("PyalaqilObject_dealloc", "alaqilPyObject_dealloc"),
        ("PyalaqilObject_disown", "alaqilPyObject_disown"),
        ("PyalaqilObject_format", "alaqilPyObject_format"),
        ("PyalaqilObject_getattr", "alaqilPyObject_getattr"),
        ("PyalaqilObject_hex", "alaqilPyObject_hex"),
        ("PyalaqilObject_long", "alaqilPyObject_long"),
        ("PyalaqilObject_next", "alaqilPyObject_next"),
        ("PyalaqilObject_oct", "alaqilPyObject_oct"),
        ("PyalaqilObject_own", "alaqilPyObject_own"),
        ("PyalaqilObject_print", "alaqilPyObject_print"),
        ("PyalaqilObject_repr", "alaqilPyObject_repr"),
        ("PyalaqilObject_richcompare", "alaqilPyObject_richcompare"),
        ("PyalaqilObject_str", "alaqilPyObject_str"),
        ("PyalaqilObject_type", "alaqilPyObject_type"),
        ("PyalaqilPacked", "alaqilPyPacked"),
        ("PyalaqilPacked_Check", "alaqilPyPacked_Check"),
        ("PyalaqilPacked_New", "alaqilPyPacked_New"),
        ("PyalaqilPacked_UnpackData", "alaqilPyPacked_UnpackData"),
        ("PyalaqilPacked_compare", "alaqilPyPacked_compare"),
        ("PyalaqilPacked_dealloc", "alaqilPyPacked_dealloc"),
        ("PyalaqilPacked_print", "alaqilPyPacked_print"),
        ("PyalaqilPacked_repr", "alaqilPyPacked_repr"),
        ("PyalaqilPacked_str", "alaqilPyPacked_str"),
        ("PyalaqilPacked_type", "alaqilPyPacked_type"),
        ("pyseq", "alaqilpyseq"),
        ("pyalaqilobject_type", "alaqilpyobject_type"),
        ("pyalaqilpacked_type", "alaqilpypacked_type"),
    ]

res = [(re.compile("\\b(%s)\\b"%oldname), newname) for oldname, newname in symbols]

def patch_file(fn):
    newf = []
    changed = False
    for line in open(fn):
        for r, newname in res:
            line, n = r.subn(newname, line)
            if n>0:
                changed = True
        newf.append(line)

    if changed:
        copyfile(fn, fn+".bak")
        f = open(fn, "w")
        f.write("".join(newf))
        f.close()
    return changed

def main(fns):
    for fn in fns:
        try:
            if patch_file(fn):
                print "Patched file", fn
        except IOError:
            print "Error occurred during patching", fn
    return

if __name__=="__main__":
    if len(sys.argv) > 1:
        main(sys.argv[1:])
    else:
        print "Patch your interface file for alaqil's Py* symbol name deprecation."
        print "Usage:"
        print "    %s files..."%sys.argv[0]

        
