/*
  The %implicit macro allows a alaqilType (Class) to be accepted
  as an input parameter and use its implicit constructors when needed.

  For example:


  %implicit(A, int, double, B);

  %inline 
  {
    struct B { };  
    struct A
    {
      int ii;
      A(int i) { ii = 1; }
      A(double d) { ii = 2; }
      A(const B& b) { ii = 3; }
    };
  
    int get(A a) { return a.ii; }
  }

  Here, you can call 'get' as 

    get(1)    ==> get(A(1))
    get(2.0)  ==> get(A(2.0))
    get(B())  ==> get(A(B()))

   and alaqil will construct an 'A' temporal variable using the
   corresponding implicit constructor.


  The plain implicit macro takes care of simple type list. If it doesn't
  work because you are passing template types with commas, then use
  the %implicit_{1,2,3} versions and/or the %arg macro.

*/

%define %implicit_type(Type...)
%traits_alaqiltype(Type);
%enddef

%define %implicit_frag(Type...) ,fragment=alaqil_Traits_frag(Type) %enddef

%define %implicit_code(Type...)
{
  Type _v;
  int res = alaqil::asval<Type >(obj, &_v);  
  if (alaqil_IsOK(res)) {
    if (val) *val = new value_type(static_cast<const Type& >(_v));
    return alaqil_AddNewMask(res);
  }
}
%enddef

/* implicit */

%define %implicit(Type, ...)

%formacro_1(%implicit_type,__VA_ARGS__);

%fragment(alaqil_Traits_frag(Type),"header",
	  fragment="StdTraits"
          %formacro_1(%implicit_frag,__VA_ARGS__)) %{
namespace alaqil {
  template <>  struct traits<Type > {   
    typedef pointer_category category;
    static const char* type_name() { return "Type"; }
  };
   
  template <> struct traits_asptr< Type > {
  typedef Type value_type;
  static int asptr(alaqil_Object obj, value_type **val) { 
    Type *vptr;
    static alaqil_type_info* descriptor = alaqil_TypeQuery("Type *");
    int res = descriptor ? alaqil_ConvertPtr(obj, (void **)&vptr, descriptor, 0) : alaqil_ERROR;
    if (alaqil_IsOK(res)) {
      if (val) *val = vptr;
      return res;
    } else {
      %formacro_1(%implicit_code,__VA_ARGS__)
    }
    return alaqil_TypeError;
  }
 };
}
%}

%typemap_traits_ptr(%checkcode(POINTER),Type);
%enddef

/* implicit_1 */


%define %implicit_1(Type, Imp1)
%traits_alaqiltype(Imp1);

%fragment(alaqil_Traits_frag(Type),"header",
	  fragment="StdTraits",
	  fragment=alaqil_Traits_frag(Imp1)) %{
namespace alaqil {
  template <>  struct traits< Type > {   
    typedef pointer_category category;
    static const char* type_name() { return "Type"; }
  };
   
  template <> struct traits_asptr< Type > {   
  typedef Type value_type;
  static int asptr(alaqil_Object obj, value_type **val) { 
    Type *vptr;
    static alaqil_type_info* descriptor = alaqil_TypeQuery("Type *");
    int res = descriptor ? alaqil_ConvertPtr(obj, (void **)&vptr, descriptor, 0) : alaqil_ERROR;
    if (alaqil_IsOK(res)) {
      if (val) *val = vptr;
      return res;
    } else {
      %implicit_code(Imp1);
    }
    return alaqil_TypeError;
  }
 };
}
%}

%typemap_traits_ptr(%checkcode(POINTER),Type);

%enddef

/* implicit_2 */

%define %implicit_2(Type, Imp1, Imp2)
%traits_alaqiltype(Imp1);
%traits_alaqiltype(Imp2);

%fragment(alaqil_Traits_frag(Type),"header",
	  fragment="StdTraits",
	  fragment=alaqil_Traits_frag(Imp1),
	  fragment=alaqil_Traits_frag(Imp2)) %{
namespace alaqil {
  template <>  struct traits< Type > {   
    typedef pointer_category category;
    static const char* type_name() { return "Type"; }
  };

  template <> struct traits_asptr< Type > {   
  typedef Type value_type;
  static int asptr(alaqil_Object obj, value_type **val) { 
    Type *vptr;
    static alaqil_type_info* descriptor = alaqil_TypeQuery("Type *");
    int res = descriptor ? alaqil_ConvertPtr(obj, (void **)&vptr, descriptor, 0) : alaqil_ERROR;
    if (alaqil_IsOK(res)) {
      if (val) *val = vptr;
      return alaqil_OLDOBJ;
    } else {
      %implicit_code(Imp1);
      %implicit_code(Imp2);
    }
    return alaqil_TypeError;
  }
 };
}
%}

%typemap_traits_ptr(%checkcode(POINTER),Type);
%enddef


/* implicit_3 */

%define %implicit_3(Type, Imp1, Imp2, Imp3)
%traits_alaqiltype(Imp1);
%traits_alaqiltype(Imp2);
%traits_alaqiltype(Imp3);

%fragment(alaqil_Traits_frag(Type),"header",
	  fragment="StdTraits",
	  fragment=alaqil_Traits_frag(Imp1),
	  fragment=alaqil_Traits_frag(Imp2),
	  fragment=alaqil_Traits_frag(Imp3)) %{
namespace alaqil {
  template <>  struct traits< Type > {   
    typedef pointer_category category;
    static const char* type_name() { return "Type"; }
  };

  template <> struct traits_asptr< Type > {   
    typedef Type value_type;
    static int asptr(alaqil_Object obj, value_type **val) { 
    Type *vptr;
    static alaqil_type_info* descriptor = alaqil_TypeQuery("Type *");
    int res = descriptor ? alaqil_ConvertPtr(obj, (void **)&vptr, descriptor, 0) : alaqil_ERROR;
    if (alaqil_IsOK(res)) {
      if (val) *val = vptr;
      return res;
    } else {
      %implicit_code(Imp1);
      %implicit_code(Imp2);
      %implicit_code(Imp3);
    }
    return alaqil_TypeError;
  }
 };
}
%}

%typemap_traits_ptr(%checkcode(POINTER),Type);
%enddef
