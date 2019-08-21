%module samename

#if !(defined(alaqilCSHARP) || defined(alaqilJAVA) || defined(alaqilD))
class samename {
 public:
  void do_something() {
    // ...
  }
};
#endif

%{

class samename {
 public:
  void do_something() {
    // ...
  }
};

%}

