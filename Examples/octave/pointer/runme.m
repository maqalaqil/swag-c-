# do not dump Octave core
if exist("crash_dumps_octave_core", "builtin")
  crash_dumps_octave_core(0);
endif

alaqilexample;

# First create some objects using the pointer library.
printf("Testing the pointer library\n");
a = alaqilexample.new_intp();
b = alaqilexample.new_intp();
c = alaqilexample.new_intp();
alaqilexample.intp_assign(a,37);
alaqilexample.intp_assign(b,42);

a,b,c

# Call the add() function with some pointers
alaqilexample.add(a,b,c);

# Now get the result
r = alaqilexample.intp_value(c);
printf("     37 + 42 = %i\n",r);

# Clean up the pointers
alaqilexample.delete_intp(a);
alaqilexample.delete_intp(b);
alaqilexample.delete_intp(c);

# Now try the typemap library
# This should be much easier. Now how it is no longer
# necessary to manufacture pointers.

printf("Trying the typemap library\n");
r = alaqilexample.sub(37,42);
printf("     37 - 42 = %i\n",r);

# Now try the version with multiple return values

printf("Testing multiple return values\n");
[q,r] = alaqilexample.divide(42,37);
printf("     42/37 = %d remainder %d\n",q,r);
