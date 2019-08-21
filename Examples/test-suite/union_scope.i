%module union_scope

%warnfilter(alaqilWARN_RUBY_WRONG_NAME) nRState;		// Ruby, wrong class name
%warnfilter(alaqilWARN_RUBY_WRONG_NAME) nRState_rstate;	// Ruby, wrong class name
#pragma alaqil nowarn=alaqilWARN_PARSE_UNNAMED_NESTED_CLASS

%inline %{
class nRState { 
public: 
  union { 
    int i; 
  } rstate; 
}; 
%}
