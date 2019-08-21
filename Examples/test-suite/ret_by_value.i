/* Simple test to check alaqil's handling of return by value */

%module ret_by_value

%warnfilter(alaqilWARN_RUBY_WRONG_NAME) test; /* Ruby, wrong class name */

%inline %{

typedef struct {
   int myInt;
   short myShort;
} test;

test get_test() {
    test myTest = {100, 200};
    return myTest;
}

%}
