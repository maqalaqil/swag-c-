exec("alaqiltest.start", -1);

try
    // This call must fail because the constructor does not exist
    Spam = new_Spam()
    alaqiltesterror();
catch
end

exec("alaqiltest.quit", -1);
