open alaqil
open Template_extend2

let _ =
  let a = new_lBaz '() and b = new_dBaz '() in
  assert (a -> foo () as string = "lBaz::foo");
  assert (b -> foo () as string = "dBaz::foo")
;;
