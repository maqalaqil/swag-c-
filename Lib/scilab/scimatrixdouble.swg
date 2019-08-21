/*
 * C-type: double array
 * Scilab type: double matrix
 */

%include <scidouble.swg>

// in (double *IN, int IN_ROWCOUNT, int IN_COLCOUNT)

%typemap(in, noblock=1, fragment="alaqil_SciDouble_AsDoubleArrayAndSize") (double *IN, int IN_ROWCOUNT, int IN_COLCOUNT)
{
  if (alaqil_SciDouble_AsDoubleArrayAndSize(pvApiCtx, $input, &$2, &$3, &$1, fname) != alaqil_OK) {
    return alaqil_ERROR;
  }
}

// in (int IN_ROWCOUNT, int IN_COLCOUNT, double *IN)

%typemap(in, noblock=1, fragment="alaqil_SciDouble_AsDoubleArrayAndSize") (int IN_ROWCOUNT, int IN_COLCOUNT, double *IN)
{
  if (alaqil_SciDouble_AsDoubleArrayAndSize(pvApiCtx, $input, &$1, &$2, &$3, fname) != alaqil_OK) {
    return alaqil_ERROR;
  }
}

// in (double *IN, int IN_SIZE)

%typemap(in, noblock=1, fragment="alaqil_SciDouble_AsDoubleArrayAndSize") (double *IN, int IN_SIZE) (int rowCount, int colCount)
{
  if (alaqil_SciDouble_AsDoubleArrayAndSize(pvApiCtx, $input, &rowCount, &colCount, &$1, fname) == alaqil_OK) {
	$2 = rowCount * colCount;
  }
  else {
	return alaqil_ERROR;
  }
}

// in (int IN_SIZE, double *IN)

%typemap(in, noblock=1, fragment="alaqil_SciDouble_AsDoubleArrayAndSize") (int IN_SIZE, double *IN) (int rowCount, int colCount)
{
  if (alaqil_SciDouble_AsDoubleArrayAndSize(pvApiCtx, $input, &rowCount, &colCount, &$2, fname) == alaqil_OK) {
    $1 = rowCount * colCount;
  }
  else {
    return alaqil_ERROR;
  }
}

// out (double **OUT, int *OUT_ROWCOUNT, int *OUT_COLCOUNT)

%typemap(in, noblock=1, numinputs=0) (double **OUT, int *OUT_ROWCOUNT, int *OUT_COLCOUNT)
{
}

%typemap(arginit, noblock=1) (double **OUT, int *OUT_ROWCOUNT, int *OUT_COLCOUNT)
{
  $1 = (double**) malloc(sizeof(double*));
  $2 = (int*) malloc(sizeof(int));
  $3 = (int*) malloc(sizeof(int));
}

%typemap(freearg, noblock=1) (double **OUT, int *OUT_ROWCOUNT, int *OUT_COLCOUNT)
{
  free(*$1);
  free($1);
  free($2);
  free($3);
}

%typemap(argout, noblock=1, fragment="alaqil_SciDouble_FromDoubleArrayAndSize") (double **OUT, int *OUT_ROWCOUNT, int *OUT_COLCOUNT)
{
  if (alaqil_SciDouble_FromDoubleArrayAndSize(pvApiCtx, alaqil_Scilab_GetOutputPosition(), *$2, *$3, *$1) == alaqil_OK) {
    alaqil_Scilab_SetOutput(pvApiCtx, alaqil_NbInputArgument(pvApiCtx) + alaqil_Scilab_GetOutputPosition());
  }
  else {
    return alaqil_ERROR;
  }
}

// out (int *OUT_ROWCOUNT, int *OUT_COLCOUNT, double **OUT)

%typemap(in, noblock=1, numinputs=0) (int *OUT_ROWCOUNT, int *OUT_COLCOUNT, double **OUT)
{
}

%typemap(arginit, noblock=1) (int *OUT_ROWCOUNT, int *OUT_COLCOUNT, double **OUT)
{
  $1 = (int*) malloc(sizeof(int));
  $2 = (int*) malloc(sizeof(int));
  $3 = (double**) malloc(sizeof(double*));
}

%typemap(argout, noblock=1, fragment="alaqil_SciDouble_FromDoubleArrayAndSize") (int *IN_ROWCOUNT, int *IN_COLCOUNT, double **OUT)
{
  if (alaqil_SciDouble_FromDoubleArrayAndSize(pvApiCtx, alaqil_Scilab_GetOutputPosition(), *$1, *$2, *$3) == alaqil_OK) {
    alaqil_Scilab_SetOutput(pvApiCtx, alaqil_NbInputArgument(pvApiCtx) + alaqil_Scilab_GetOutputPosition());
  }
  else {
    return alaqil_ERROR;
  }
}

%typemap(freearg, noblock=1) (int *OUT_ROWCOUNT, int *OUT_COLCOUNT, double **OUT)
{
  free($1);
  free($2);
  free(*$3);
  free($3);
}


// out (double **OUT, int *OUT_SIZE)

%typemap(in, noblock=1, numinputs=0) (double **OUT, int *OUT_SIZE)
{
}

%typemap(arginit, noblock=1) (double **OUT, int *OUT_SIZE)
{
  $1 = (double**) malloc(sizeof(double*));
  $2 = (int*) malloc(sizeof(int));
}

%typemap(argout, noblock=1, fragment="alaqil_SciDouble_FromDoubleArrayAndSize") (double **OUT, int *OUT_SIZE)
{
  if (alaqil_SciDouble_FromDoubleArrayAndSize(pvApiCtx, alaqil_Scilab_GetOutputPosition(), 1, *$2, *$1) == alaqil_OK) {
    alaqil_Scilab_SetOutput(pvApiCtx, alaqil_NbInputArgument(pvApiCtx) + alaqil_Scilab_GetOutputPosition());
  }
  else {
    return alaqil_ERROR;
  }
}

%typemap(freearg, noblock=1) (double **OUT, int *OUT_SIZE)
{
  free(*$1);
  free($1);
  free($2);
}


// out (int *OUT_SIZE, double **OUT)

%typemap(in, noblock=1, numinputs=0) (int *OUT_SIZE, double **OUT)
{
}

%typemap(arginit, noblock=1) (int *OUT_SIZE, double **OUT)
{
  $1 = (int*) malloc(sizeof(int));
  $2 = (double**) malloc(sizeof(double*));
}

%typemap(argout, noblock=1, fragment="alaqil_SciDouble_FromDoubleArrayAndSize") (int *OUT_SIZE, double **OUT)
{
  if (alaqil_SciDouble_FromDoubleArrayAndSize(pvApiCtx, alaqil_Scilab_GetOutputPosition(), 1, *$1, *$2) == alaqil_OK) {
    alaqil_Scilab_SetOutput(pvApiCtx, alaqil_NbInputArgument(pvApiCtx) + alaqil_Scilab_GetOutputPosition());
  }
  else {
    return alaqil_ERROR;
  }
}

%typemap(freearg, noblock=1) (int *OUT_SIZE, double **OUT)
{
  free($1);
  free(*$2);
  free($2);
}
