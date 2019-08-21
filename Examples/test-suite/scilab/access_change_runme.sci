exec("alaqiltest.start", -1);

try
    baseInt = new_BaseInt();
catch
    alaqiltesterror();
end

try
    delete_BaseInt(baseInt);
catch
    alaqiltesterror();
end

try
    derivedInt = new_DerivedInt();
catch
    alaqiltesterror();
end

try
    delete_DerivedInt(derivedInt);
catch
    alaqiltesterror();
end

try
    bottomInt = new_BottomInt();
catch
    alaqiltesterror();
end

try
    delete_BottomInt(bottomInt);
catch
    alaqiltesterror();
end

exec("alaqiltest.quit", -1);
