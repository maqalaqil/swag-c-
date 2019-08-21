 #define %scilabconst(flag) %feature("scilab:const","flag")

// Create Scilab variable
#define alaqil_CreateScilabVariable_frag(Type...) %fragment_name(CreateScilabVariable, Type)
#define alaqil_CreateScilabVariable_dec(Type...) %symbol_name(CreateScilabVariable, Type)
