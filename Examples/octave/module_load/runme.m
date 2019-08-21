# do not dump Octave core
if exist("crash_dumps_octave_core", "builtin")
  crash_dumps_octave_core(0);
endif

# load module
clear all;
assert(exist("alaqilexample") == 3);
alaqilexample;
assert(isglobal("alaqilexample"));
assert(cvar.ivar == ifunc);
clear all
assert(exist("alaqilexample") == 3);
alaqilexample;
assert(isglobal("alaqilexample"));
assert(cvar.ivar == ifunc);
clear all

# load module in a function globally before base context
clear all;
function testme_1
  assert(exist("alaqilexample") == 3);
  alaqilexample;
  assert(isglobal("alaqilexample"));
  assert(cvar.ivar == ifunc);
endfunction
testme_1
testme_1
assert(exist("alaqilexample") == 3);
alaqilexample;
assert(isglobal("alaqilexample"));
assert(cvar.ivar == ifunc);
clear all
function testme_2
  assert(exist("alaqilexample") == 3);
  alaqilexample;
  assert(isglobal("alaqilexample"));
  assert(cvar.ivar == ifunc);
endfunction
testme_2
testme_2
assert(exist("alaqilexample") == 3);
alaqilexample;
assert(isglobal("alaqilexample"));
assert(cvar.ivar == ifunc);
clear all

# load module in a function globally after base context
clear all;
assert(exist("alaqilexample") == 3);
alaqilexample;
assert(isglobal("alaqilexample"));
assert(cvar.ivar == ifunc);
function testme_3
  assert(exist("alaqilexample") == 3);
  alaqilexample;
  assert(isglobal("alaqilexample"));
  assert(cvar.ivar == ifunc);
endfunction
testme_3
testme_3
clear all
assert(exist("alaqilexample") == 3);
alaqilexample;
assert(isglobal("alaqilexample"));
assert(cvar.ivar == ifunc);
function testme_4
  assert(exist("alaqilexample") == 3);
  alaqilexample;
  assert(isglobal("alaqilexample"));
  assert(cvar.ivar == ifunc);
endfunction
testme_4
testme_4
clear all

# octave 3.0.5 randomly crashes on the remaining tests
if !alaqil_octave_prereq(3,2,0)
  exit
endif

# load module with no cvar
clear all;
who;
assert(exist("alaqilexample2") == 3);
alaqilexample2;
assert(isglobal("alaqilexample2"));
assert(alaqilexample2.ivar == ifunc);
assert(!exist("cvar", "var"));
clear all
assert(exist("alaqilexample2") == 3);
alaqilexample2;
assert(isglobal("alaqilexample2"));
assert(alaqilexample2.ivar == ifunc);
assert(!exist("cvar", "var"));
clear all
