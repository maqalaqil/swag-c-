exec("alaqiltest.start", -1);

try
    Spam = new_Spam()
catch
    alaqiltesterror();
end
  
if Foo_blah(Spam)<>0 then alaqiltesterror; end

exec("alaqiltest.quit", -1);
