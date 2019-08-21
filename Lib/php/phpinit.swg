
/* ------------------------------------------------------------
 * The start of the PHP initialization function
 * ------------------------------------------------------------ */

%insert(init) "alaqilinit.swg"

%init %{
alaqil_php_minit {
  alaqil_InitializeModule((void*)&module_number);
%}

%fragment("alaqil_php_init_member_ptr2", "header") %{
#define alaqil_MEMBER_PTR "CLASS::*"

static void alaqil_member_ptr_dtor(zend_resource *res) {
  efree(res->ptr);
}

static int alaqil_member_ptr = 0;
%}

%fragment("alaqil_php_init_member_ptr", "init", fragment="alaqil_php_init_member_ptr2") %{
  alaqil_member_ptr = zend_register_list_destructors_ex(alaqil_member_ptr_dtor, NULL, alaqil_MEMBER_PTR, module_number);
%}
