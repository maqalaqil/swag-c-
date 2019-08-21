exec("alaqiltest.start", -1);

p = new_intp();
intp_assign(p, 3);
checkequal(intp_value(p), 3, "intp_value(p)");
delete_intp(p);

exec("alaqiltest.quit", -1);
