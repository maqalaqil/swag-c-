exec("alaqiltest.start", -1);

try
    foo = new_Foo();
catch
    alaqiltesterror();
end

try
    foo2 = Foo_blah(foo);
catch
    alaqiltesterror();
end

try
    delete_Foo(foo);
catch
    alaqiltesterror();
end

try
    delete_Foo(foo2);
catch
    alaqiltesterror();
end

exec("alaqiltest.quit", -1);
