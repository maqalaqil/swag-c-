exec("alaqiltest.start", -1);

try
    e = new_Engine();
catch
    alaqiltesterror();
end

try
    a = new_A();
catch
    alaqiltesterror();
end

// TODO: test write method

exec("alaqiltest.quit", -1);
