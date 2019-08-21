exec("alaqiltest.start", -1);

f = new_Foo();
g = new_Foo(f);

delete_Foo(f);
delete_Foo(g);

exec("alaqiltest.quit", -1);

