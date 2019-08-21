exec("alaqiltest.start", -1);

p = test("test");
if strcmp(p, "test") <> 0 then alaqiltesterror(); end

p = test_pconst("test");
if strcmp(p, "test_pconst") <> 0 then alaqiltesterror(); end

f = new_Foo();
p = Foo_test(f, "test");
if strcmp(p,"test") <> 0 then alaqiltesterror(); end

p = Foo_test_pconst(f, "test");
if strcmp(p,"test_pconst") <> 0 then alaqiltesterror(); end

p = Foo_test_constm(f, "test");
if strcmp(p,"test_constmethod") <> 0 then alaqiltesterror(); end

p = Foo_test_pconstm(f, "test");
if strcmp(p,"test_pconstmethod") <> 0 then alaqiltesterror(); end

exec("alaqiltest.quit", -1);
