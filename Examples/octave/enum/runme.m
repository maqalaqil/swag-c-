# do not dump Octave core
if exist("crash_dumps_octave_core", "builtin")
  crash_dumps_octave_core(0);
endif

alaqilexample

# ----- Object creation -----

# Print out the value of some enums
printf("*** color ***\n");
printf("    RED    = %i\n", alaqilexample.RED);
printf("    BLUE   = %i\n", alaqilexample.BLUE);
printf("    GREEN  = %i\n", alaqilexample.GREEN);

printf("\n*** Foo::speed ***\n");
printf("    Foo_IMPULSE   = %i\n", alaqilexample.Foo_IMPULSE);
printf("    Foo_WARP      = %i\n", alaqilexample.Foo_WARP);
printf("    Foo_LUDICROUS = %i\n", alaqilexample.Foo_LUDICROUS);

printf("\nTesting use of enums with functions\n");

alaqilexample.enum_test(alaqilexample.RED, alaqilexample.Foo_IMPULSE);
alaqilexample.enum_test(alaqilexample.BLUE,  alaqilexample.Foo_WARP);
alaqilexample.enum_test(alaqilexample.GREEN, alaqilexample.Foo_LUDICROUS);
alaqilexample.enum_test(1234,5678)

printf("\nTesting use of enum with class method\n");
f = alaqilexample.Foo();

f.enum_test(alaqilexample.Foo_IMPULSE);
f.enum_test(alaqilexample.Foo_WARP);
f.enum_test(alaqilexample.Foo_LUDICROUS);
