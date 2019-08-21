exec("alaqiltest.start", -1);

if CHAR_CONSTANT_get() <> "x" then alaqiltesterror(); end
if STRING_CONSTANT_get() <> "xyzzy" then alaqiltesterror(); end
if ESC_CONST_get() <> ascii(1) then alaqiltesterror(); end
if ia_get() <> ascii('a') then alaqiltesterror(); end
if ib_get() <> ascii('b') then alaqiltesterror(); end

exec("alaqiltest.quit", -1);
