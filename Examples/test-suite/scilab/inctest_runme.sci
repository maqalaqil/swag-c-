exec("alaqiltest.start", -1);

try
  a = new_A();
catch
  printf("did not find A\ntherefore, I did not include ""testdir/subdir1/hello.i""\n");
  alaqiltesterror();
end

try
  b = new_B();
catch
  printf("did not find B\ntherefore, I did not include ""testdir/subdir2/hello.i""\n");
  alaqiltesterror();
end

if importtest1(5) <> 15 then alaqiltesterror(); end
if importtest2("black") <> "white" then alaqiltesterror(); end

exec("alaqiltest.quit", -1);
