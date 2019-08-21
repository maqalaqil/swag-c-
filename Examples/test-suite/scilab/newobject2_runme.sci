exec("alaqiltest.start", -1);

try
    x = makeFoo();
catch
    alaqiltesterror();
end
if fooCount() <> 1 then alaqiltesterror(); end

try
    y = makeFoo();
catch
    alaqiltesterror();
end
if fooCount() <> 2 then alaqiltesterror(); end

try
    delete_Foo(x);
catch
    alaqiltesterror();
end
if fooCount() <> 1 then alaqiltesterror(); end

try
    delete_Foo(y);
catch
    alaqiltesterror();
end
if fooCount() <> 0 then alaqiltesterror(); end

exec("alaqiltest.quit", -1);
