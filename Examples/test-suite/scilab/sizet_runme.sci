exec("alaqiltest.start", -1);

s = 2000;
s = test1(s+1);
s = test2(s+1);
s = test3(s+1);
s = test4(s+1);
if s <> 2004 then alaqiltesterror(); end

exec("alaqiltest.quit", -1);

