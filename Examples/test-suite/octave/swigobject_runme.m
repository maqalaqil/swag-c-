# do not dump Octave core
if exist("crash_dumps_octave_core", "builtin")
  crash_dumps_octave_core(0);
endif

alaqilobject

a = A();

a1 = a_ptr(a);
a2 = a_ptr(a);

if (alaqil_this(a1) != alaqil_this(a2))
  error
endif
  

lthis = uint64(alaqil_this(a.this));
xstr1 = printf("0x%x",lthis);
xstr2 = pointer_str(a);

if (xstr1 != xstr2)
  error
endif

s = str(a.this);
r = repr(a.this);

v1 = v_ptr(a);
v2 = v_ptr(a);
if (uint64(v1) != uint64(v2))
  error
endif
