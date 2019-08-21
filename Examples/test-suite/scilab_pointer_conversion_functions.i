%module scilab_pointer_conversion_functions

%warnfilter(alaqilWARN_TYPEMAP_alaqilTYPELEAK_MSG) pfoo; /* Setting a pointer/reference variable may leak memory. */

%inline %{

void *getNull() { return NULL; }
bool isNull(void *p) { return p == NULL; }

int foo = 3;
int *pfoo = &foo;

double getFooAddress() { return (double) (unsigned long) pfoo; }
bool equalFooPointer(void *p) { return p == pfoo; }

%}

%typemap(out, noblock=1) struct structA* {
  if (alaqilScilabPtrFromObject(pvApiCtx, alaqil_Scilab_GetOutputPosition(), $1, alaqil_Scilab_TypeQuery("struct structA *"), 0, NULL) != alaqil_OK) {
    return alaqil_ERROR;
  }
  alaqil_Scilab_SetOutput(pvApiCtx, alaqil_NbInputArgument(pvApiCtx) + alaqil_Scilab_GetOutputPosition());
}

%inline %{

struct structA {
  int x;
};

%}
