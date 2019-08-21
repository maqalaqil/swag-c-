exec("alaqiltest.start", -1);

try
    small = new_SmallStruct();
    SmallStruct_jill_set(small, 200);

    big = new_BigStruct();
    BigStruct_jack_set(big, 300);

    Jill = SmallStruct_jill_get(small);
catch
    alaqiltesterror();
end
if Jill <> 200 then alaqiltesterror(); end

try
    Jack = BigStruct_jack_get(big);
catch
    alaqiltesterror();
end
if Jack <> 300 then alaqiltesterror(); end

exec("alaqiltest.quit", -1);
