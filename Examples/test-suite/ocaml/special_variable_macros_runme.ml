open alaqil
open Special_variable_macros

let _ =
  let name = new_Name '() in
  assert (_testFred '(name) as string = "none");
  assert (_testJack '(name) as string = "$specialname");
  assert (_testJill '(name) as string = "jilly");
  assert (_testMary '(name) as string = "alaqilTYPE_p_NameWrap");
  assert (_testJames '(name) as string = "alaqilTYPE_Name");
  assert (_testJim '(name) as string = "multiname num");
  let arg = new_PairIntBool '(10, false) in
  assert (_testJohn '(arg) as int = 123);
;;
