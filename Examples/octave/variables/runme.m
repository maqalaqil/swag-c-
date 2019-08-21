# do not dump Octave core
if exist("crash_dumps_octave_core", "builtin")
  crash_dumps_octave_core(0);
endif

alaqilexample

# Try to set the values of some global variables

alaqilexample.cvar.ivar   =  42;
alaqilexample.cvar.svar   = -31000;
alaqilexample.cvar.lvar   =  65537;
alaqilexample.cvar.uivar  =  123456;
alaqilexample.cvar.usvar  =  61000;
alaqilexample.cvar.ulvar  =  654321;
alaqilexample.cvar.scvar  =  -13;
alaqilexample.cvar.ucvar  =  251;
alaqilexample.cvar.cvar   =  "S";
alaqilexample.cvar.fvar   =  3.14159;
alaqilexample.cvar.dvar   =  2.1828;
alaqilexample.cvar.strvar =  "Hello World";
alaqilexample.cvar.iptrvar= alaqilexample.new_int(37);
alaqilexample.cvar.ptptr  = alaqilexample.new_Point(37,42);
alaqilexample.cvar.name   = "Bill";

# Now print out the values of the variables

printf("Variables (values printed from Octave)\n");

printf("ivar      = %i\n", alaqilexample.cvar.ivar);
printf("svar      = %i\n", alaqilexample.cvar.svar);
printf("lvar      = %i\n", alaqilexample.cvar.lvar);
printf("uivar     = %i\n", alaqilexample.cvar.uivar);
printf("usvar     = %i\n", alaqilexample.cvar.usvar);
printf("ulvar     = %i\n", alaqilexample.cvar.ulvar);
printf("scvar     = %i\n", alaqilexample.cvar.scvar);
printf("ucvar     = %i\n", alaqilexample.cvar.ucvar);
printf("fvar      = %i\n", alaqilexample.cvar.fvar);
printf("dvar      = %i\n", alaqilexample.cvar.dvar);
printf("cvar      = %s\n", alaqilexample.cvar.cvar);
printf("strvar    = %s\n", alaqilexample.cvar.strvar);
#printf("cstrvar   = %s\n", alaqilexample.cvar.cstrvar);
alaqilexample.cvar.iptrvar
printf("name      = %i\n", alaqilexample.cvar.name);
printf("ptptr     = %s\n", alaqilexample.Point_print(alaqilexample.cvar.ptptr));
#printf("pt        = %s\n", alaqilexample.cvar.Point_print(alaqilexample.cvar.pt));

printf("\nVariables (values printed from C)\n");

alaqilexample.print_vars();

printf("\nNow I'm going to try and modify some read only variables\n");

printf("     Trying to set 'path'\n");
try
    alaqilexample.cvar.path = "Whoa!";
    printf("Hey, what's going on?!?! This shouldn't work\n");
catch
    printf("Good.\n");
end_try_catch

printf("     Trying to set 'status'\n");
try
    alaqilexample.cvar.status = 0;
    printf("Hey, what's going on?!?! This shouldn't work\n");
catch
    printf("Good.\n");
end_try_catch


printf("\nI'm going to try and update a structure variable.\n");

alaqilexample.cvar.pt = alaqilexample.cvar.ptptr;

printf("The new value is %s\n", alaqilexample.Point_print(alaqilexample.cvar.pt));
