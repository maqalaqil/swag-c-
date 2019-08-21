exec("alaqiltest.start", -1);

try
    D = new_D();
catch
    alaqiltesterror();
end
if A_do_x(D) <> 1 then alaqiltesterror(); end

try
    delete_D(D);
catch
    alaqiltesterror();
end

exec("alaqiltest.quit", -1);
