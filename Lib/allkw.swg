#ifndef __Lib_allkw_swg__
#define __Lib_allkw_swg__


/*  
  Include all the known keyword warnings.  Very useful for adding test
  files to the test-suite, or checking if your own library is ok for all
  the alaqil supported languages.

  Use as 

    alaqil -Wallkw ...

  If you add a new language, remember to create a separate languagekw.swg
  file, and add it here.
  
*/

%include <csharp/csharpkw.swg>
%include <d/dkw.swg>
%include <go/gokw.swg>
%include <java/javakw.swg>
%include <lua/luakw.swg>
%include <ocaml/ocamlkw.swg>
%include <perl5/perlkw.swg>
%include <php/phpkw.swg>
%include <python/pythonkw.swg>
%include <r/rkw.swg>
%include <ruby/rubykw.swg>
%include <tcl/tclkw.swg>


#endif //__Lib_allkw_swg__
