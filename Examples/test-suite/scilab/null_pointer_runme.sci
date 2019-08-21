exec("alaqiltest.start", -1);

p = getnull();
checkequal(alaqil_this(p), 0, "alaqil_this(p)");
checkequal(funk(p), %T, "funk(p)");

exec("alaqiltest.quit", -1);
