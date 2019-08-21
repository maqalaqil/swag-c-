open alaqil
open Extend_special_variables

let f = new_ForExtensionNewName '()
let s = f -> "extended_renamed" () as string
let s2 = f -> "extended_renamed" (10) as string

let _ =
  assert (s = "name:extended symname:extended_renamed wrapname: overname:__alaqil_0 decl:ForExtension::extended() fulldecl:char const * ForExtension::extended() parentclasssymname:ForExtensionNewName parentclassname:ForExtension")
  assert (s2 = "name:extended symname:extended_renamed wrapname: overname:__alaqil_1 decl:ForExtension::extended(int) fulldecl:char const * ForExtension::extended(int) parentclasssymname:ForExtensionNewName parentclassname:ForExtension")
;;

let e = new_ExtendTemplateInt '()
let _ = e -> "extending" ()
