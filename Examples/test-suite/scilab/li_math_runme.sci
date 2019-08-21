exec("alaqiltest.start", -1);

try
   x = fmod(M_PI_get(), M_1_PI_get())
catch
    alaqiltesterror();
end

exec("alaqiltest.quit", -1);