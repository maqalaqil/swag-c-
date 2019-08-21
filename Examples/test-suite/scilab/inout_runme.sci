exec("alaqiltest.start", -1);

a = AddOne1(10);
if a <> 11 then alaqiltesterror(); end

[a, b, c] = AddOne3(1, 2, 3);
if a <> 2 then alaqiltesterror(); end
if b <> 3 then alaqiltesterror(); end
if c <> 4 then alaqiltesterror(); end

a = AddOne1r(20);
if a <> 21 then alaqiltesterror(); end


exec("alaqiltest.quit", -1);
