/* -----------------------------------------------------------------------------
 * alaqilarch.i
 *
 * alaqil library file for 32bit/64bit code specialization and checking.
 *
 * Use only in extreme cases, when no arch. independent code can be
 * generated
 * 
 * To activate architecture specific code, use
 *
 *     alaqil -DalaqilWORDSIZE32
 *
 * or
 *
 *     alaqil -DalaqilWORDSIZE64
 *
 * Note that extra checking code will be added to the wrapped code,
 * which will prevent the compilation in a different architecture.
 *
 * If you don't specify the alaqilWORDSIZE (the default case), alaqil will
 * generate architecture independent and/or 32bits code, with no extra
 * checking code added.
 * ----------------------------------------------------------------------------- */

#if !defined(alaqilWORDSIZE32) &&  !defined(alaqilWORDSIZE64)
# if (__WORDSIZE == 32)
#  define alaqilWORDSIZE32
# endif
#endif
  
#if !defined(alaqilWORDSIZE64) &&  !defined(alaqilWORDSIZE32) 
# if defined(__x86_64) || defined(__x86_64__) || (__WORDSIZE == 64)
#  define alaqilWORDSIZE64
# endif
#endif


#ifdef alaqilWORDSIZE32
%{
#define alaqilWORDSIZE32
#ifndef LONG_MAX
#include <limits.h>
#endif
#if (__WORDSIZE == 64) || (LONG_MAX != INT_MAX)
# error "alaqil wrapped code invalid in 64 bit architecture, regenerate code using -DalaqilWORDSIZE64"
#endif
%}
#endif

#ifdef alaqilWORDSIZE64
%{
#define alaqilWORDSIZE64
#ifndef LONG_MAX
#include <limits.h>
#endif
#if (__WORDSIZE == 32) || (LONG_MAX == INT_MAX)
# error "alaqil wrapped code invalid in 32 bit architecture, regenerate code using -DalaqilWORDSIZE32"
#endif
%}
#endif
  

