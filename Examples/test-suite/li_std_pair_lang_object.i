%module li_std_pair_lang_object

%include <std_pair.i>

namespace std {
  %template(ValuePair) pair< alaqil::LANGUAGE_OBJ, alaqil::LANGUAGE_OBJ >;
}

