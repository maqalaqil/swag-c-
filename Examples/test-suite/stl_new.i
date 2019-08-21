%module stl_new

%include <std_vector.i>
%include <std_deque.i>
%include <std_list.i>
%include <std_set.i>
%include <std_map.i>

%template(Vector  ) std::vector  <alaqil::LANGUAGE_OBJ>;
%template(Deque   ) std::deque   <alaqil::LANGUAGE_OBJ>;
%template(List    ) std::list    <alaqil::LANGUAGE_OBJ>;

%template(Set     ) std::set     <alaqil::LANGUAGE_OBJ,
				  alaqil::BinaryPredicate<> >;
%template(Map     ) std::map     <alaqil::LANGUAGE_OBJ,alaqil::LANGUAGE_OBJ,
                                   alaqil::BinaryPredicate<> >;


// %inline %{
//     namespace alaqil {
//         void nth_element(alaqil::Iterator_T< _Iter>& first,
//                          alaqil::Iterator_T< _Iter>& nth,
//                          alaqil::Iterator_T< _Iter>& last,
//                          const alaqil::BinaryPredicate<>& comp = alaqil::BinaryPredicate<>())
//         {
// 	  std::nth_element( first, nth, last, comp);
//         }
//     }
// %}
