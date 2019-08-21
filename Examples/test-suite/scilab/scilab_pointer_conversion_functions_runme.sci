exec("alaqiltest.start", -1);

// Test on NULL
null = getNull();
checkequal(alaqil_this(null), 0, "alaqil_this(null)");

null = alaqil_ptr(0);
checkequal(isNull(null), %T, "func(null)");

// Test on variable
expected_foo_addr = getFooAddress();
foo_addr = alaqil_this(pfoo_get());
checkequal(foo_addr, expected_foo_addr, "alaqil_this(pfoo_get())");

pfoo = alaqil_ptr(foo_addr);
checkequal(equalFooPointer(pfoo), %T, "equalFooPointer(pfoo)");

// Test conversion of mlist type pointers
stA = new_structA();
checkequal(typeof(stA), "_p_structA");
p = alaqil_ptr(stA);
checkequal(typeof(p), "pointer");

exec("alaqiltest.quit", -1);
