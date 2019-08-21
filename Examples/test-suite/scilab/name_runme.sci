exec("alaqiltest.start", -1);

try
    foo_2();
catch
    alaqiltesterror();
end
if bar_2_get() <> 17 then alaqiltesterror(); end
if Baz_2_get() <> 47 then alaqiltesterror(); end

exec("alaqiltest.quit", -1);
