/* This example illustrates the use of the %exceptionclass feature.  By
   default, if a method has a throws specification then alaqil will generate
   code to catch the exception and pass it on the scripting language.
   
   If a method does not have a throws specification, but does throw 
   an exception, then the %exceptionclass feature can be used to tell
   alaqil about the exception class so it can be properly added to Ruby.
   This is done by making the exception class inherit from rb_eRuntimeError.*/

%module example

%{
#include "example.h"
%}


/* The EmpytError doesn't appear in a throw declaration, and hence
  we need to tell alaqil that the dequeue method throws it.  This can
  now be done via the %catchs feature. */
%catches(FullError) *::enqueue;
%catches(EmptyError) *::dequeue();


/* What the catches clause is doing under the covers is this:

%exceptionclass EmptyError;

%exception *::dequeue {
   try {
      $action
   } catch(EmptyError& e) {
     // Create a new instance of the EmptyError, wrap it as a Ruby object that Ruby owns,
     // and return it as the exception.  For this to work EmtpyError must inherit from
     // a standard Ruby exception class such as rb_eRuntimeError.  alaqil automatically does
     // this when the class is marked as %exceptionclass or is a throws specification.
     %raise(alaqil_NewPointerObj(new EmptyError(e),alaqilTYPE_p_EmptyError, alaqil_POINTER_OWN), 
            "EmptyError", alaqilTYPE_p_EmptyError);
   }
}
*/

/* Grab the original header file */
%include "example.h"

/* Instantiate a few templates */
%template(IntQueue) Queue<int>;
%template(DoubleQueue) Queue<double>;
