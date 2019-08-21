# do not dump Octave core
if exist("crash_dumps_octave_core", "builtin")
  crash_dumps_octave_core(0);
endif

# This file illustrates the cross language polymorphism using directors.

alaqilexample

OctCallback=@() subclass(alaqilexample.Callback(),"run",@(self) printf("OctCallback.run()\n"));

# Create an Caller instance

caller = alaqilexample.Caller();

# Add a simple C++ callback (caller owns the callback, so
# we disown it first)

printf("Adding and calling a normal C++ callback\n");
printf("----------------------------------------\n");

callback = alaqilexample.Callback().__disown();
caller.setCallback(callback);
caller.call();
caller.delCallback();

printf("Adding and calling a Octave callback\n");
printf("------------------------------------\n");

# Add a Octave callback (caller owns the callback, so we
# disown it first by calling __disown).

caller.setCallback(OctCallback().__disown())
caller.call();
caller.delCallback();

printf("Adding and calling another Octave callback\n");
printf("------------------------------------------\n");

# Let's do the same but use the weak reference this time.

callback = OctCallback().__disown();
caller.setCallback(callback);
caller.call();
caller.delCallback();

# careful-- using callback here may cause problems; octave_alaqil_type still
# exists, but is holding a destroyed object (the C++ alaqilexample.Callback).
# to manually drop the octave-side reference, you can use
clear callback;

# Let's call them directly now

printf("Calling Octave and C++ callbacks directly\n");
printf("------------------------------------------\n");

a = OctCallback();
a.run();
a.Callback.run();


# All done.

printf("octave exit\n");
