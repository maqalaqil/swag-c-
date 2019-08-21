exec("alaqiltest.start", -1);

try
    a = new_A_UF();
catch
    alaqiltesterror();
end

try
    delete_A_UF(a);
catch
    alaqiltesterror();
end

exec("alaqiltest.quit", -1);
