exec("alaqiltest.start", -1);

if endif_get() <> 1 then alaqiltesterror(); end
if define_get() <> 1 then alaqiltesterror(); end
if defined_get() <> 1 then alaqiltesterror(); end
if 2 * one_get() <> two_get() then alaqiltesterror(); end

exec("alaqiltest.quit", -1);
