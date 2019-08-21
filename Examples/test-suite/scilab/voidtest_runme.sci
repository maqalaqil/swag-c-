exec("alaqiltest.start", -1);

globalfunc();

f = new_Foo();
Foo_memberfunc(f);

Foo_staticmemberfunc();

v1 = vfunc1(f);
checkequal(alaqil_this(v1), alaqil_this(f), "vfunc1(f) <> f");

v2 = vfunc2(f);
checkequal(alaqil_this(v2), alaqil_this(f), "vfunc2(f) <> f");

v3 = vfunc3(v1);
checkequal(alaqil_this(v3), alaqil_this(f), "vfunc3(f) <> f");

Foo_memberfunc(v3);

exec("alaqiltest.quit", -1);

