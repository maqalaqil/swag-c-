# do not dump Octave core
if exist("crash_dumps_octave_core", "builtin")
  crash_dumps_octave_core(0);
endif

alaqilexample

printf("ICONST  = %i (should be 42)\n", alaqilexample.ICONST);
printf("FCONST  = %f (should be 2.1828)\n", alaqilexample.FCONST);
printf("CCONST  = %s (should be 'x')\n", alaqilexample.CCONST);
printf("CCONST2 = %s (this should be on a new line)\n", alaqilexample.CCONST2);
printf("SCONST  = %s (should be 'Hello World')\n", alaqilexample.SCONST);
printf("SCONST2 = %s (should be '\"Hello World\"')\n", alaqilexample.SCONST2);
printf("EXPR    = %f (should be 48.5484)\n", alaqilexample.EXPR);
printf("iconst  = %i (should be 37)\n", alaqilexample.iconst);
printf("fconst  = %f (should be 3.14)\n", alaqilexample.fconst);

try
    printf("EXTERN = %s (Arg! This shouldn't printf(anything)\n", alaqilexample.EXTERN);
catch
    printf("EXTERN isn't defined (good)\n");
end_try_catch

try
    printf("FOO    = %i (Arg! This shouldn't printf(anything)\n", alaqilexample.FOO);
catch
    printf("FOO isn't defined (good)\n");
end_try_catch
