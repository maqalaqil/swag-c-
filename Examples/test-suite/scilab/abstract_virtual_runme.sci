exec("alaqiltest.start", -1);

try
    d = new_D();
catch
    alaqiltesterror();
end

try
    delete_D(d);
catch
    alaqiltesterror();
end

try
    e = new_E();
catch
    alaqiltesterror();
end

try
    delete_E(e);
catch
    alaqiltesterror();
end

exec("alaqiltest.quit", -1);
