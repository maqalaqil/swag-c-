# do not dump Octave core
if exist("crash_dumps_octave_core", "builtin")
  crash_dumps_octave_core(0);
endif

alaqilexample

# Call our gcd() function

x = 42;
y = 105;
g = alaqilexample.gcd(x,y);
printf("The gcd of %d and %d is %d\n",x,y,g);

# Manipulate the Foo global variable

# Output its current value
printf("Foo = %f\n", alaqilexample.cvar.Foo);

# Change its value
alaqilexample.cvar.Foo = 3.1415926;

# See if the change took effect
printf("Foo = %f\n", alaqilexample.cvar.Foo);
