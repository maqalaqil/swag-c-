%module xxx

#ifndef FOO
long long i;
/* Check we get an error for an unknown directive (this should be #elif).
 * Unknown directives were silently ignored by alaqil < 3.0.3. */
#elsif defined(BAR)
long i;
#else
int i;
#endif
