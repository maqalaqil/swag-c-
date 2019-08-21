#include <chicken/chicken_ext_test_wrap_hdr.h>
#include <imports_a.h>

void test_create(C_word,C_word,C_word) C_noret;
void test_create(C_word argc, C_word closure, C_word continuation) {
  C_word resultobj;
  alaqil_type_info *type;
  A *newobj;
  C_word *known_space = C_alloc(C_SIZEOF_alaqil_POINTER);

  C_trace("test-create");
  if (argc!=2) C_bad_argc(argc,2);


  newobj = new A();

  type = alaqil_TypeQuery("A *");
  resultobj = alaqil_NewPointerObj(newobj, type, 1);

  C_kontinue(continuation, resultobj);
}
