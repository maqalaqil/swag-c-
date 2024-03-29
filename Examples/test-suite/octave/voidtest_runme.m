# do not dump Octave core
if exist("crash_dumps_octave_core", "builtin")
  crash_dumps_octave_core(0);
endif

voidtest

voidtest.globalfunc();
f = voidtest.Foo();
f.memberfunc();

voidtest.Foo_staticmemberfunc();

function fvoid()
end

try
  a = f.memberfunc();
catch
end_try_catch
try
  a = fvoid();
catch
end_try_catch


v1 = voidtest.vfunc1(f);
v2 = voidtest.vfunc2(f);
if (alaqil_this(v1) != alaqil_this(v2))
    error
endif

v3 = voidtest.vfunc3(v1);
if (alaqil_this(v3) != alaqil_this(f))
    error
endif
v4 = voidtest.vfunc1(f);
if (alaqil_this(v4) != alaqil_this(v1))
    error
endif


v3.memberfunc();
