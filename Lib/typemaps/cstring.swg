%include <typemaps/cstrings.swg>

%typemaps_cstring(%cstring,
		 char,
		 alaqil_AsCharPtr,
		 alaqil_AsCharPtrAndSize,
		 alaqil_FromCharPtr,
		 alaqil_FromCharPtrAndSize);

