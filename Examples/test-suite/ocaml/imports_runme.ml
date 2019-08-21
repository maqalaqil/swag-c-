(* purpose: to receive the hello A method from Imports_a exposed through
 * a B object derived from A *)

open alaqil
open Imports_a
open Imports_b
let x = new_B C_void
(* Tests conversion of x to a generic value *)
let a = alaqil_val `unknown x
let _ = (invoke x) "hello" C_void
