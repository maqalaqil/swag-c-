// A speed test of the ruby stl
%module ruby_li_std_speed

%include <std_list.i>
%include <std_vector.i>
%include <std_deque.i>
%include <std_set.i>

%template(RbList)   std::list<alaqil::GC_VALUE>;
%template(RbVector) std::vector<alaqil::GC_VALUE>;
%template(RbDeque)  std::deque<alaqil::GC_VALUE>;
%template(RbSet)    std::set<alaqil::GC_VALUE>; 

%template(RbFloatList)   std::list<float>;
%template(RbFloatVector) std::vector<float>;
%template(RbFloatDeque)  std::deque<float>;
%template(RbFloatSet)    std::set<float>; 
