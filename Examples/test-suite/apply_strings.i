/* Test %apply for char *, signed char *, unsigned char *
   This won't work in all situations, so does not necessarily have to be implemented. See
   http://groups.google.com.ai/group/comp.lang.c++.moderated/browse_thread/thread/ad5873ce25d49324/0ae94552452366be?lnk=raot */
%module(directors="1") apply_strings

%warnfilter(alaqilWARN_TYPEMAP_THREAD_UNSAFE,alaqilWARN_TYPEMAP_DIRECTOROUT_PTR) DirectorTest;
%warnfilter(alaqilWARN_TYPEMAP_VARIN_UNDEF) DigitsGlobalB;
%warnfilter(alaqilWARN_TYPEMAP_alaqilTYPELEAK) DigitsGlobalC;

#if defined(alaqilSCILAB)
%rename(TNum) TNumber;
%rename(DirTest) DirectorTest;
#endif

%apply char * {UCharPtr};
%apply char * {SCharPtr};
%apply const char * {CUCharPtr};
%apply const char * {CSCharPtr};

%inline %{
  typedef unsigned char* UCharPtr;
  typedef signed char* SCharPtr;
  typedef const unsigned char* CUCharPtr;
  typedef const signed char* CSCharPtr;

  UCharPtr UCharFunction(UCharPtr str) { return str; }
  SCharPtr SCharFunction(SCharPtr str) { return str; }
  CUCharPtr CUCharFunction(CUCharPtr str) { return str; }
  CSCharPtr CSCharFunction(CSCharPtr str) { return str; }
%}

%typemap(freearg) alaqilTYPE * ""
%apply alaqilTYPE* {CharPtr};
%apply alaqilTYPE* {CCharPtr};

%inline %{
  typedef char* CharPtr;
  typedef const char* CCharPtr;

  CharPtr CharFunction(CharPtr buffer) { return buffer; }
  CCharPtr CCharFunction(CCharPtr buffer) { return buffer; }
%}

// unsigned char* as strings
#if defined(alaqilJAVA) || defined(alaqilCSHARP)

/* Note: Chicken does not allow unsigned char * in strings */

%apply char [ANY] {TAscii[ANY]}
%apply char [] {TAscii []}
%apply char * {TAscii *}

#endif

%inline %{
typedef unsigned char TAscii;
typedef struct {
   TAscii DigitsMemberA[20];
   TAscii *DigitsMemberB;
} TNumber;

TAscii DigitsGlobalA[20];
TAscii DigitsGlobalB[] = {(unsigned char)'A', (unsigned char)'B', 0};
TAscii *DigitsGlobalC;

%}

// Director test
%feature("director");

#if defined(alaqilGO)
%typemap(godirectorout) CharPtr, CCharPtr ""
#endif

%inline %{
  struct DirectorTest {
    virtual UCharPtr UCharFunction(UCharPtr str) { return str; }
    virtual SCharPtr SCharFunction(SCharPtr str) { return str; }
    virtual CUCharPtr CUCharFunction(CUCharPtr str) { return str; }
    virtual CSCharPtr CSCharFunction(CSCharPtr str) { return str; }
    virtual CharPtr CharFunction(CharPtr buffer) { return buffer; }
    virtual CCharPtr CCharFunction(CCharPtr buffer) { return buffer; }
    virtual ~DirectorTest() {}
  };
%}


