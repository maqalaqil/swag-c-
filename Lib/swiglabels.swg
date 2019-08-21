/* -----------------------------------------------------------------------------
 *  This section contains generic alaqil labels for method/variable
 *  declarations/attributes, and other compiler dependent labels.
 * ----------------------------------------------------------------------------- */

/* template workaround for compilers that cannot correctly implement the C++ standard */
#ifndef alaqilTEMPLATEDISAMBIGUATOR
# if defined(__SUNPRO_CC) && (__SUNPRO_CC <= 0x560)
#  define alaqilTEMPLATEDISAMBIGUATOR template
# elif defined(__HP_aCC)
/* Needed even with `aCC -AA' when `aCC -V' reports HP ANSI C++ B3910B A.03.55 */
/* If we find a maximum version that requires this, the test would be __HP_aCC <= 35500 for A.03.55 */
#  define alaqilTEMPLATEDISAMBIGUATOR template
# else
#  define alaqilTEMPLATEDISAMBIGUATOR
# endif
#endif

/* inline attribute */
#ifndef alaqilINLINE
# if defined(__cplusplus) || (defined(__GNUC__) && !defined(__STRICT_ANSI__))
#   define alaqilINLINE inline
# else
#   define alaqilINLINE
# endif
#endif

/* attribute recognised by some compilers to avoid 'unused' warnings */
#ifndef alaqilUNUSED
# if defined(__GNUC__)
#   if !(defined(__cplusplus)) || (__GNUC__ > 3 || (__GNUC__ == 3 && __GNUC_MINOR__ >= 4))
#     define alaqilUNUSED __attribute__ ((__unused__))
#   else
#     define alaqilUNUSED
#   endif
# elif defined(__ICC)
#   define alaqilUNUSED __attribute__ ((__unused__))
# else
#   define alaqilUNUSED
# endif
#endif

#ifndef alaqil_MSC_UNSUPPRESS_4505
# if defined(_MSC_VER)
#   pragma warning(disable : 4505) /* unreferenced local function has been removed */
# endif
#endif

#ifndef alaqilUNUSEDPARM
# ifdef __cplusplus
#   define alaqilUNUSEDPARM(p)
# else
#   define alaqilUNUSEDPARM(p) p alaqilUNUSED
# endif
#endif

/* internal alaqil method */
#ifndef alaqilINTERN
# define alaqilINTERN static alaqilUNUSED
#endif

/* internal inline alaqil method */
#ifndef alaqilINTERNINLINE
# define alaqilINTERNINLINE alaqilINTERN alaqilINLINE
#endif

/* exporting methods */
#if defined(__GNUC__)
#  if (__GNUC__ >= 4) || (__GNUC__ == 3 && __GNUC_MINOR__ >= 4)
#    ifndef GCC_HASCLASSVISIBILITY
#      define GCC_HASCLASSVISIBILITY
#    endif
#  endif
#endif

#ifndef alaqilEXPORT
# if defined(_WIN32) || defined(__WIN32__) || defined(__CYGWIN__)
#   if defined(STATIC_LINKED)
#     define alaqilEXPORT
#   else
#     define alaqilEXPORT __declspec(dllexport)
#   endif
# else
#   if defined(__GNUC__) && defined(GCC_HASCLASSVISIBILITY)
#     define alaqilEXPORT __attribute__ ((visibility("default")))
#   else
#     define alaqilEXPORT
#   endif
# endif
#endif

/* calling conventions for Windows */
#ifndef alaqilSTDCALL
# if defined(_WIN32) || defined(__WIN32__) || defined(__CYGWIN__)
#   define alaqilSTDCALL __stdcall
# else
#   define alaqilSTDCALL
# endif
#endif

/* Deal with Microsoft's attempt at deprecating C standard runtime functions */
#if !defined(alaqil_NO_CRT_SECURE_NO_DEPRECATE) && defined(_MSC_VER) && !defined(_CRT_SECURE_NO_DEPRECATE)
# define _CRT_SECURE_NO_DEPRECATE
#endif

/* Deal with Microsoft's attempt at deprecating methods in the standard C++ library */
#if !defined(alaqil_NO_SCL_SECURE_NO_DEPRECATE) && defined(_MSC_VER) && !defined(_SCL_SECURE_NO_DEPRECATE)
# define _SCL_SECURE_NO_DEPRECATE
#endif

/* Deal with Apple's deprecated 'AssertMacros.h' from Carbon-framework */
#if defined(__APPLE__) && !defined(__ASSERT_MACROS_DEFINE_VERSIONS_WITHOUT_UNDERSCORES)
# define __ASSERT_MACROS_DEFINE_VERSIONS_WITHOUT_UNDERSCORES 0
#endif

/* Intel's compiler complains if a variable which was never initialised is
 * cast to void, which is a common idiom which we use to indicate that we
 * are aware a variable isn't used.  So we just silence that warning.
 * See: https://github.com/alaqil/alaqil/issues/192 for more discussion.
 */
#ifdef __INTEL_COMPILER
# pragma warning disable 592
#endif
