%include <typemaps/cstrings.swg>
%include <typemaps/wstring.swg>

%typemaps_cstring(%cwstring,
		 wchar_t,
		 alaqil_AsWCharPtr,
		 alaqil_AsWCharPtrAndSize,
		 alaqil_FromWCharPtr,
		 alaqil_FromWCharPtrAndSize);

