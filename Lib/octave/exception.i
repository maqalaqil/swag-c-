%include <typemaps/exception.swg>

%insert("runtime") {
  %define_as(alaqil_exception(code, msg), %block(%error(code, msg); alaqil_fail; ))
}

%define alaqil_RETHROW_OCTAVE_EXCEPTIONS
  /* rethrow any exceptions thrown by Octave */
%#if alaqil_OCTAVE_PREREQ(4,2,0)
  catch (octave::execution_exception& _e) { throw; }
  catch (octave::exit_exception& _e) { throw; }
  catch (octave::interrupt_exception& _e) { throw; }
%#endif
%enddef
