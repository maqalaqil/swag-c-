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

static void *ptr = 0;
alaqilEXPORT void *
alaqil_ReturnGlobalTypeList(void *t) {
 if (!ptr && !t) ptr = t;
 return ptr;
}
