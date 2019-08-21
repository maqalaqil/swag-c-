%module register_par

%{
struct alaqil_tree;
%}

// bug # 924413
%inline {
  void clear_tree_flags(register struct alaqil_tree *tp, register int i) {}
}
