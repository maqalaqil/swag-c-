%module typemap_namespace

/* Secret typedefs */
%{
namespace Foo {
   typedef char    Str1;
   typedef char    Str2;
}
%}

namespace Foo {
    struct Str1;
    struct Str2;

#ifdef alaqilCSHARP
    %typemap(ctype) Str1 * = char *;
    %typemap(imtype) Str1 * = char *;
    %typemap(cstype) Str1 * = char *;
    %typemap(csin) Str1 * = char *;
    %typemap(csout) Str1 * = char *;
#endif
#ifdef alaqilJAVA
    %typemap(jni) Str1 * = char *;
    %typemap(jtype) Str1 * = char *;
    %typemap(jstype) Str1 * = char *;
    %typemap(javain) Str1 * = char *;
    %typemap(javaout) Str1 * = char *;
#endif
#ifdef alaqilGO
    %typemap(gotype) Str1 * = char *;
#endif
#ifdef alaqilD
    %typemap(ctype) Str1 * = char *;
    %typemap(imtype) Str1 * = char *;
    %typemap(dtype) Str1 * = char *;
    %typemap(din) Str1 * = char *;
    %typemap(dout) Str1 * = char *;
#endif
    %typemap(in) Str1 * = char *;
#if !(defined(alaqilCSHARP) || defined(alaqilLUA) || defined(alaqilPHP) || defined(alaqilMZSCHEME) || defined(alaqilOCAML) || defined(alaqilGO) || defined(alaqilD))
    %typemap(freearg) Str1 * = char *;
#endif
    %typemap(typecheck) Str1 * = char *;
    %apply char * { Str2 * };
}

%inline %{
namespace Foo {
    char *test1(Str1 *s) {
          return s;
    }
    char *test2(Str2 *s) {
          return s;
    }
}
%}

    

