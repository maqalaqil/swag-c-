/* -----------------------------------------------------------------------------
 * exceptions.swg
 *
 * This alaqil library file provides language independent exception handling
 * ----------------------------------------------------------------------------- */

%include <typemaps/alaqilmacros.swg>


/* macros for error manipulation */
#define %nullref_fmt()                     "invalid null reference "		   
#define %varfail_fmt(_type,_name)          "in variable '"`_name`"' of type '"`_type`"'"
#ifndef %argfail_fmt
#define %argfail_fmt(_type,_name,_argn)    "in method '" `_name` "', argument " `_argn`" of type '" `_type`"'"
#endif
#define %outfail_fmt(_type)                "in output value of type '"_type"'"
#ifndef	%argnullref_fmt
#define %argnullref_fmt(_type,_name,_argn) %nullref_fmt() %argfail_fmt(_type, _name, _argn)
#endif  
#define %varnullref_fmt(_type,_name)       %nullref_fmt() %varfail_fmt(_type, _name)  		   
#define %outnullref_fmt(_type)             %nullref_fmt() %outfail_fmt(_type)         

/* setting an error */
#define %error(code,msg...)               alaqil_Error(code, msg)
#define %type_error(msg...)               alaqil_Error(alaqil_TypeError,  msg)



%insert("runtime") {

%define_as(alaqil_exception_fail(code, msg), %block(%error(code, msg); alaqil_fail))

%define_as(alaqil_contract_assert(expr, msg), if (!(expr)) { %error(alaqil_RuntimeError, msg); alaqil_fail; } else)

}

#ifdef __cplusplus
/*
  You can use the alaqil_CATCH_STDEXCEPT macro with the %exception
  directive as follows:

  %exception {
    try {
      $action
    }
    catch (my_except& e) {
      ...
    }
    alaqil_CATCH_STDEXCEPT // catch std::exception
    catch (...) {
     alaqil_exception_fail(alaqil_UnknownError, "Unknown exception");
    }
  }
*/

%fragment("<stdexcept>");

%define alaqil_CATCH_STDEXCEPT
  /* catching std::exception  */
  catch (std::invalid_argument& e) {
    alaqil_exception_fail(alaqil_ValueError, e.what() );
  } catch (std::domain_error& e) {
    alaqil_exception_fail(alaqil_ValueError, e.what() );
  } catch (std::overflow_error& e) {
    alaqil_exception_fail(alaqil_OverflowError, e.what() );
  } catch (std::out_of_range& e) {
    alaqil_exception_fail(alaqil_IndexError, e.what() );
  } catch (std::length_error& e) {
    alaqil_exception_fail(alaqil_IndexError, e.what() );
  } catch (std::runtime_error& e) {
    alaqil_exception_fail(alaqil_RuntimeError, e.what() );
  } catch (std::exception& e) {
    alaqil_exception_fail(alaqil_SystemError, e.what() );
  }
%enddef
%define alaqil_CATCH_UNKNOWN
  catch (std::exception& e) {
    alaqil_exception_fail(alaqil_SystemError, e.what() );
  }
  catch (...) {
    alaqil_exception_fail(alaqil_UnknownError, "unknown exception");
  }
%enddef


#endif /* __cplusplus */
