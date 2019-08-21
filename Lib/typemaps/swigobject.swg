/* ------------------------------------------------------------
 * Language Object *  - Just pass straight through unmodified
 * ------------------------------------------------------------ */

%typemap(in)   alaqil_Object "$1 = $input;";

%typemap(in,noblock=1)   alaqil_Object const & ($*ltype temp)
{
  temp = %static_cast($input, $*ltype);
  $1 = &temp;
}

%typemap(out,noblock=1) alaqil_Object {
  %set_output($1);
}

%typemap(out,noblock=1)  alaqil_Object const & {
  %set_output(*$1);
}

%typecheck(alaqil_TYPECHECK_alaqilOBJECT) alaqil_Object "$1 = ($input != 0);";

%typemap(throws,noblock=1) alaqil_Object {
  %raise($1, "$type", 0);
}

%typemap(constcode,noblock=1) alaqil_Object {
  %set_constant("$symname", $value);
}

#if defined(alaqil_DIRECTOR_TYPEMAPS)

%typemap(directorin) alaqil_Object "$input = $1;";
%typemap(directorout) alaqil_Object "$result = $input;";

#endif /* alaqil_DIRECTOR_TYPEMAPS */

