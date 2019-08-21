/* File : example.i */
%module python_destructor_exception
%include exception.i

%exception ClassWithThrowingDestructor::~ClassWithThrowingDestructor()
{
  $action
  alaqil_exception(alaqil_RuntimeError, "I am the ClassWithThrowingDestructor dtor doing bad things");
}

%inline %{
class ClassWithThrowingDestructor
{
};

%}

%include <std_vector.i>
%template(VectorInt) std::vector<int>;
