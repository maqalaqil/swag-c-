#include <guile_ext_test_wrap_hdr.h>
#include <imports_a.h>

SCM test_create()
{
#define FUNC_NAME "test-create"
  SCM result;
  A *newobj;
  alaqil_type_info *type;
  
  newobj = new A();
  type = alaqil_TypeQuery("A *");
  result = alaqil_NewPointerObj(newobj, type, 1);
  
  return result;
#undef FUNC_NAME
}

SCM test_is_pointer(SCM val)
{
#define FUNC_NAME "test-is-pointer"
  return SCM_BOOL(alaqil_IsPointer(val));
#undef FUNC_NAME
}
