%module php_namewarn_rename

#ifdef alaqilPHP
%warnfilter(alaqilWARN_PARSE_KEYWORD) Empty();
%warnfilter(alaqilWARN_PARSE_KEYWORD) stdClass;
%warnfilter(alaqilWARN_PARSE_KEYWORD) directory;
%warnfilter(alaqilWARN_PARSE_KEYWORD) Hello::empty();
#endif

%ignore prev::operator++;
%extend prev {
  void next() { ++(*self); }
}

%inline %{

  int Exception() { return 13; }

  void Empty() {}

  class stdClass
  {
  };

  class directory
  {
  };

  struct Hello
  {
    void empty() {}
  };

  struct prev {
    prev & operator++() { return *this; }
    prev operator++(int) { return *this; }
  };

%}
