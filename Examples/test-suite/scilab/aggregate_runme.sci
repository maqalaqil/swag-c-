exec("alaqiltest.start", -1);

if UP_get()<>1 then alaqiltesterror(); end
if typeof(UP_get())<>"constant" then pause; end

if DOWN_get()<>2 then alaqiltesterror(); end
if typeof(DOWN_get())<>"constant" then pause; end

if LEFT_get()<>3 then alaqiltesterror(); end
if typeof(LEFT_get())<>"constant" then pause; end

if RIGHT_get()<>4 then alaqiltesterror(); end
if typeof(RIGHT_get())<>"constant" then pause; end

// TODO: move is a Scilab function...
//result = move(UP_get());
//result = move(DOWN_get());
//result = move(LEFT_get());
//result = move(RIGHT_get());

exec("alaqiltest.quit", -1);
