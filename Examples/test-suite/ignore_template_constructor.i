%module ignore_template_constructor
%include std_vector.i

#if defined(alaqilCSHARP) || defined(alaqilPYTHON) || defined(alaqilPERL) || defined(alaqilRUBY)
#define alaqil_GOOD_VECTOR
%ignore std::vector<Flow>::vector(size_type);
%ignore std::vector<Flow>::resize(size_type);
#endif

#if defined(alaqilJAVA)
#define alaqil_GOOD_VECTOR
%ignore std::vector<Flow>::vector(jint);
%ignore std::vector<Flow>::resize(jint);
#endif

#if defined(alaqilTCL) || defined(alaqilPERL)
#define alaqil_GOOD_VECTOR
/* here, for languages with bad declaration */
%ignore std::vector<Flow>::vector(unsigned int);
%ignore std::vector<Flow>::resize(unsigned int);
#endif

#if defined(alaqil_GOOD_VECTOR)
%inline %{
class Flow {
double x;
 Flow():x(0.0) {}
public:
 Flow(double d) : x(d) {}
};
%}

#else
/* here, for languages with bad typemaps */

%inline %{
class Flow {
double x;
public:
 Flow(): x(0.0) {}
 Flow(double d) : x(d) {}
};
%}

#endif

%template(VectFlow) std::vector<Flow>;

%inline %{
std::vector<Flow> inandout(std::vector<Flow> v) {
  return v;
}
%}
