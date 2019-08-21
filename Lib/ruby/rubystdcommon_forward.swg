%fragment("StdTraitsForwardDeclaration","header")
{
namespace alaqil {
  template <class Type> struct traits_asptr;
  template <class Type> struct traits_asval;
  struct pointer_category;
  template <class Type, class Category> struct traits_as;
  template <class Type> struct traits_from;
  template <class Type> struct traits_from_ptr;
  template <class Type> struct noconst_traits;
  template <class Type> alaqil_type_info* type_info();
  template <class Type> const char* type_name();
  template <class Type> VALUE from(const Type& val);
}
}
