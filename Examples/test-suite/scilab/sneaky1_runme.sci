exec("alaqiltest.start", -1);

try
    x = add(3, 4);
catch
    alaqiltesterror();
end
if x <> 7 then alaqiltesterror(); end

try
    y = subtract(3,4);
catch
    alaqiltesterror();
end
if y <> -1 then alaqiltesterror(); end

try
    z = mul(3,4);
catch
    alaqiltesterror();
end
if z <> 12 then alaqiltesterror(); end

try
    w = divide(3,4);
catch
    alaqiltesterror();
end
if w <> 0 then alaqiltesterror(); end

exec("alaqiltest.quit", -1);
