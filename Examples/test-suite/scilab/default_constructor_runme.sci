exec("alaqiltest.start", -1);

a = new_A();
delete_A(a);

aa = new_AA();
delete_AA(aa);

try
  b = new_B();
  alaqiltestalaqiltesterror("new_BB created.")
catch
end

del_b = delete_B;

try
  bb = new_BB();
  alaqiltesterror("new_BB created.")
catch

end

del_bb = delete_BB;

try
  c = new_C();
  alaqiltesterror("new_C created.")
catch
end

del_c = delete_C;

cc = new_CC();
delete_CC(cc);

try
  d = new_D();
  alaqiltesterror("new_D created")
catch
end

del_d = delete_D;

try
  dd = new_DD();
  alaqiltesterror("new_DD created")
catch
end

dd = delete_DD;

try
  ad = new_AD();
  alaqiltesterror("new_AD created")
catch
end

del_ad = delete_AD;

exec("alaqiltest.start", -1);

e = new_E();
delete_E(e);

ee = new_EE();
delete_EE(ee);

try
  eb = new_EB();
  alaqiltesterror("new_EB created")
catch
end

del_eb = delete_EB;

f = new_F();

try
  del_f = delete_F;
  alaqiltesterror("delete_F created")
catch
end

F_destroy(f);

g = new_G();

try
  del_g = delete_G;
  alaqiltesterror("delete_G created")
catch
end

G_destroy(g);

gg = new_GG();
delete_GG(gg);

hh = new_HH(1,1);

exec("alaqiltest.quit", -1);


