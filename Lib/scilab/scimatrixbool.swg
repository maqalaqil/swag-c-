/*
 * C-type: bool array
 * Scilab type: bool matrix
 */

%include <scibool.swg>

// in (bool *IN, int IN_ROWCOUNT, int IN_COLCOUNT)

%typemap(in, noblock=1, fragment="alaqil_SciBoolean_AsBoolArrayAndSize") (bool *IN, int IN_ROWCOUNT, int IN_COLCOUNT)
{
  if (alaqil_SciBoolean_AsBoolArrayAndSize(pvApiCtx, $input, &$2, &$3, &$1, fname) != alaqil_OK) {
    return alaqil_ERROR;
  }
}

// in (int IN_ROWCOUNT, int IN_COLCOUNT, bool *IN)

%typemap(in, noblock=1, fragment="alaqil_SciBoolean_AsBoolArrayAndSize") (int IN_ROWCOUNT, int IN_COLCOUNT, bool *IN)
{
  if (alaqil_SciBoolean_AsBoolArrayAndSize(pvApiCtx, $input, &$1, &$2, &$3, fname) != alaqil_OK) {
    return alaqil_ERROR;
  }
}

// in (bool *IN, int IN_SIZE)

%typemap(in, noblock=1, fragment="alaqil_SciBoolean_AsBoolArrayAndSize") (bool *IN, int IN_SIZE) (int rowCount, int colCount)
{
  if (alaqil_SciBoolean_AsBoolArrayAndSize(pvApiCtx, $input, &rowCount, &colCount, &$1, fname) == alaqil_OK) {
    $2 = rowCount * colCount;
  }
  else {
    return alaqil_ERROR;
  }
}

// in (int IN_SIZE, bool *IN)

%typemap(in, noblock=1) (int IN_SIZE, bool *IN) (int rowCount, int colCount)
{
  if (alaqil_SciBoolean_AsBoolArrayAndSize(pvApiCtx, $input, &rowCount, &colCount, &$2, fname) == alaqil_OK) {
    $1 = rowCount * colCount;
  }
  else {
    return alaqil_ERROR;
  }
}

// out (bool **OUT, int *OUT_ROWCOUNT, int *OUT_COLCOUNT)

%typemap(in, noblock=1, numinputs=0) (bool **OUT, int *OUT_ROWCOUNT, int *OUT_COLCOUNT)
{
}

%typemap(arginit, noblock=1) (bool **OUT, int *OUT_ROWCOUNT, int *OUT_COLCOUNT)
{
  $1 = (bool**) malloc(sizeof(bool*));
  $2 = (int*) malloc(sizeof(int));
  $3 = (int*) malloc(sizeof(int));
}

%typemap(freearg, noblock=1) (bool **OUT, int *OUT_ROWCOUNT, int *OUT_COLCOUNT)
{
  free(*$1);
  free($1);
  free($2);
  free($3);
}

%typemap(argout, noblock=1, fragment="alaqil_SciBoolean_FromBoolArrayAndSize") (bool **OUT, int *OUT_ROWCOUNT, int *OUT_COLCOUNT)
{
  if (alaqil_SciBoolean_FromBoolArrayAndSize(pvApiCtx, alaqil_Scilab_GetOutputPosition(), *$2, *$3, *$1) == alaqil_OK) {
    alaqil_Scilab_SetOutput(pvApiCtx, alaqil_NbInputArgument(pvApiCtx) + alaqil_Scilab_GetOutputPosition());
  }
  else {
    return alaqil_ERROR;
  }
}

// out (int *OUT_ROWCOUNT, int *OUT_COLCOUNT, bool **OUT)

%typemap(in, noblock=1, numinputs=0) (int *OUT_ROWCOUNT, int *OUT_COLCOUNT, bool **OUT)
{
}

%typemap(arginit, noblock=1) (int *OUT_ROWCOUNT, int *OUT_COLCOUNT, bool **OUT)
{
  $1 = (int*) malloc(sizeof(int));
  $2 = (int*) malloc(sizeof(int));
  $3 = (bool**) malloc(sizeof(bool*));
}

%typemap(argout, noblock=1, fragment="alaqil_SciBoolean_FromBoolArrayAndSize") (int *OUT_ROWCOUNT, int *OUT_COLCOUNT, bool **OUT)
{
  if (alaqil_SciBoolean_FromBoolArrayAndSize(pvApiCtx, alaqil_Scilab_GetOutputPosition(), *$1, *$2, *$3) == alaqil_OK) {
    alaqil_Scilab_SetOutput(pvApiCtx, alaqil_NbInputArgument(pvApiCtx) + alaqil_Scilab_GetOutputPosition());
  }
  else {
    return alaqil_ERROR;
  }
}

%typemap(freearg, noblock=1) (int *OUT_ROWCOUNT, int *OUT_COLCOUNT, bool **OUT)
{
  free($1);
  free($2);
  free(*$3);
  free($3);
}


// out (bool **OUT, int *OUT_SIZE)

%typemap(in, noblock=1, numinputs=0) (bool **OUT, int *OUT_SIZE)
{
}

%typemap(arginit, noblock=1) (bool **OUT, int *OUT_SIZE)
{
  $1 = (bool**) malloc(sizeof(bool*));
  $2 = (int*) malloc(sizeof(int));
}

%typemap(argout, noblock=1, fragment="alaqil_SciBoolean_FromBoolArrayAndSize") (bool **OUT, int *OUT_SIZE)
{
  if (alaqil_SciBoolean_FromBoolArrayAndSize(pvApiCtx, alaqil_Scilab_GetOutputPosition(), 1, *$2, *$1) == alaqil_OK) {
    alaqil_Scilab_SetOutput(pvApiCtx, alaqil_NbInputArgument(pvApiCtx) + alaqil_Scilab_GetOutputPosition());
  }
  else {
    return alaqil_ERROR;
  }
}

%typemap(freearg, noblock=1) (bool **OUT, int *OUT_SIZE)
{
  free(*$1);
  free($1);
  free($2);
}


// out (int *OUT_SIZE, bool **OUT)

%typemap(in, noblock=1, numinputs=0) (int *OUT_SIZE, bool **OUT)
{
}

%typemap(arginit, noblock=1) (int *OUT_SIZE, bool **OUT)
{
  $1 = (int*) malloc(sizeof(int));
  $2 = (bool**) malloc(sizeof(bool*));
}

%typemap(argout, noblock=1, fragment="alaqil_SciBoolean_FromBoolArrayAndSize") (int *OUT_SIZE, bool **OUT)
{
  if (alaqil_SciBoolean_FromBoolArrayAndSize(pvApiCtx, alaqil_Scilab_GetOutputPosition(), 1, *$1, *$2) == alaqil_OK) {
    alaqil_Scilab_SetOutput(pvApiCtx, alaqil_NbInputArgument(pvApiCtx) + alaqil_Scilab_GetOutputPosition());
  }
  else {
    return alaqil_ERROR;
  }
}

%typemap(freearg, noblock=1) (int *OUT_SIZE, bool **OUT)
{
  free($1);
  free(*$2);
  free($2);
}
