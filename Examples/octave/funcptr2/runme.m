# do not dump Octave core
if exist("crash_dumps_octave_core", "builtin")
  crash_dumps_octave_core(0);
endif

alaqilexample

a = 37
b = 42

# Now call our C function with a bunch of callbacks

printf("Trying some C callback functions\n");
printf("    a        = %i\n", a);
printf("    b        = %i\n", b);
printf("    ADD(a,b) = %i\n", alaqilexample.do_op(a,b,alaqilexample.ADD));
printf("    SUB(a,b) = %i\n", alaqilexample.do_op(a,b,alaqilexample.SUB));
printf("    MUL(a,b) = %i\n", alaqilexample.do_op(a,b,alaqilexample.MUL));

printf("Here is what the C callback function objects look like in Octave\n");
alaqilexample.ADD
alaqilexample.SUB
alaqilexample.MUL

printf("Call the functions directly...\n");
printf("    add(a,b) = %i\n", alaqilexample.add(a,b));
printf("    sub(a,b) = %i\n", alaqilexample.sub(a,b));
