exec("alaqiltest.start", -1);

try
    x = new_Foo();
catch
    alaqiltesterror();
end
if Foo_test(x, 1) <> 1 then alaqiltesterror(); end
if Foo_test(x, "Hello alaqil!") <> 2 then alaqiltesterror(); end
if Foo_test(x, 2, 3) <> 3 then alaqiltesterror(); end
if Foo_test(x, x) <> 30 then alaqiltesterror(); end
if Foo_test(x, x, 4) <> 24 then alaqiltesterror(); end
if Foo_test(x, x, 4, 5) <> 9 then alaqiltesterror(); end

exec("alaqiltest.quit", -1);
