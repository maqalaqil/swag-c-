/* ------------------------------------------------------------
 *  Enums mapped as integer values
 * ------------------------------------------------------------ */

%apply int { enum alaqilTYPE };
%apply const int& { const enum alaqilTYPE & };
%apply const int& { const enum alaqilTYPE && };

%typemap(in,fragment=alaqil_AsVal_frag(int),noblock=1) const enum alaqilTYPE & (int val, int ecode, $basetype temp) {  
  ecode = alaqil_AsVal(int)($input, &val);
  if (!alaqil_IsOK(ecode)) {
    %argument_fail(ecode, "$type", $symname, $argnum);
  } else {
    temp = %static_cast(val,$basetype);
    $1 = &temp;
  }
}

%typemap(in,fragment=alaqil_AsVal_frag(int),noblock=1) const enum alaqilTYPE && (int val, int ecode, $basetype temp) {  
  ecode = alaqil_AsVal(int)($input, &val);
  if (!alaqil_IsOK(ecode)) {
    %argument_fail(ecode, "$type", $symname, $argnum);
  } else {
    temp = %static_cast(val,$basetype);
    $1 = &temp;
  }
}

%typemap(varin,fragment=alaqil_AsVal_frag(int),noblock=1) enum alaqilTYPE {
  if (sizeof(int) != sizeof($1)) {
    %variable_fail(alaqil_AttributeError,"$type", "arch, read-only $name");
  }  else {
    int ecode = alaqil_AsVal(int)($input, %reinterpret_cast(&$1,int*));
    if (!alaqil_IsOK(ecode)) {
      %variable_fail(ecode, "$type", "$name");
    }
  }
}

