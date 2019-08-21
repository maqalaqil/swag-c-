%module cpp_extra_brackets

// Extra brackets was segfaulting in alaqil-3.0.0
struct ABC {
;
)))
int operator<<(ABC &) { return 0; }
int operator>>(ABC &) { return 0; }
};
