exec("alaqiltest.start", -1);

if add(7, 9) <> 16 then alaqiltesterror(); end
if do_op(7, 9, funcvar_get()) <> 16 then alaqiltesterror(); end

exec("alaqiltest.quit", -1);
