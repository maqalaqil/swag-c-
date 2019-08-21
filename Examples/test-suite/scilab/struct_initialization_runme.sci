exec("alaqiltest.start", -1);

if StructC_x_get(instanceC1_get()) <> 10 then alaqiltesterror(); end

if StructD_x_get(instanceD1_get()) <> 10 then alaqiltesterror(); end

if StructD_x_get(instanceD2_get()) <> 20 then alaqiltesterror(); end

if StructD_x_get(instanceD3_get()) <> 30 then alaqiltesterror(); end

if StructE_x_get(instanceE1_get()) <> 1 then alaqiltesterror(); end

if StructF_x_get(instanceF1_get()) <> 1 then alaqiltesterror(); end

exec("alaqiltest.quit", -1);