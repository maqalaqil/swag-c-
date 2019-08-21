# This is the import runtime testcase.

# Workaround seg fault occurring during interpreter cleanup/exit in version 3.1 and 3.2, seems okay in 3.6
if (compare_versions(version(), "3.3", ">="))
  imports_b;
  imports_a;

  x = imports_b.B();
  x.hello();

  a = imports_a.A();

  c = imports_b.C();
  a1 = c.get_a(c);
  a2 = c.get_a_type(c);

  a1.hello();
  a2.hello();
  assert(alaqil_this(a1)==alaqil_this(a2));
  assert(strcmp(alaqil_type(a1),alaqil_type(a2)));
endif

