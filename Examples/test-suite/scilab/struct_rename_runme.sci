exec("alaqiltest.start", -1);

try
    a = new_Bar();
    Bar_x_set(a,100);
catch
    alaqiltesterror();
end
if Bar_x_get(a) <> 100 then alaqiltesterror(); end

exec("alaqiltest.quit", -1);
