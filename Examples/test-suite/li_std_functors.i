%module li_std_functors

%include <std_vector.i>
%include <std_deque.i>
%include <std_list.i>
%include <std_set.i>
%include <std_map.i>
%include <std_functors.i>

%template(Vector  ) std::vector  <alaqil::LANGUAGE_OBJ>;
%template(Deque   ) std::deque   <alaqil::LANGUAGE_OBJ>;
%template(List    ) std::list    <alaqil::LANGUAGE_OBJ>;

%template(Set     ) std::set     <alaqil::LANGUAGE_OBJ,
                                   alaqil::BinaryPredicate<> >;
%template(Map     ) std::map     <alaqil::LANGUAGE_OBJ,alaqil::LANGUAGE_OBJ,
                                   alaqil::BinaryPredicate<> >;

