/* -----------------------------------------------------------------------------
 * dclassgen.swg
 *
 * Typemaps containing D code used when generating D proxy classes.
 * ----------------------------------------------------------------------------- */

%typemap(dbase)               alaqilTYPE, alaqilTYPE *, alaqilTYPE &, alaqilTYPE [], alaqilTYPE (CLASS::*) ""
%typemap(dclassmodifiers)     alaqilTYPE, alaqilTYPE *, alaqilTYPE &, alaqilTYPE [], alaqilTYPE (CLASS::*) "class"
%typemap(dcode)               alaqilTYPE, alaqilTYPE *, alaqilTYPE &, alaqilTYPE [], alaqilTYPE (CLASS::*) ""
%typemap(dimports)            alaqilTYPE, alaqilTYPE *, alaqilTYPE &, alaqilTYPE [], alaqilTYPE (CLASS::*) ""
%typemap(dinterfaces)         alaqilTYPE, alaqilTYPE *, alaqilTYPE &, alaqilTYPE [], alaqilTYPE (CLASS::*) ""
%typemap(dinterfaces_derived) alaqilTYPE, alaqilTYPE *, alaqilTYPE &, alaqilTYPE [], alaqilTYPE (CLASS::*) ""

// See <denums.swg>.
%typemap(dclassmodifiers) enum alaqilTYPE "enum"
%typemap(dcode) enum alaqilTYPE ""


/*
 * Proxy classes.
 */

%typemap(dconstructor, excode=alaqilEXCODE,directorconnect="\n  alaqilDirectorConnect();") alaqilTYPE {
  this($imcall, true);$excode$directorconnect
}

%typemap(ddestructor) alaqilTYPE %{
~this() {
  dispose();
}
%}

// We do not use »override« attribute for generated dispose() methods to stay
// somewhat compatible to Phobos and older Tango versions where Object.dispose()
// does not exist.
%typemap(ddispose, methodname="dispose", methodmodifiers="public") alaqilTYPE {
  synchronized(this) {
    if (alaqilCPtr !is null) {
      if (alaqilCMemOwn) {
        alaqilCMemOwn = false;
        $imcall;
      }
      alaqilCPtr = null;
    }
  }
}

%typemap(ddispose_derived, methodname="dispose", methodmodifiers="public") alaqilTYPE {
  synchronized(this) {
    if (alaqilCPtr !is null) {
      if (alaqilCMemOwn) {
        alaqilCMemOwn = false;
        $imcall;
      }
      alaqilCPtr = null;
      super.dispose();
    }
  }
}


// Unfortunately, the »package« visibility attribute does not work in D when the
// module in question is in the root package (happens if no -package is specified
// at the alaqil command line), so we are stuck with public visibility for
// alaqilGetCPtr().
%typemap(dbody) alaqilTYPE %{
private void* alaqilCPtr;
protected bool alaqilCMemOwn;

public this(void* cObject, bool ownCObject) {
  alaqilCPtr = cObject;
  alaqilCMemOwn = ownCObject;
}

public static void* alaqilGetCPtr(typeof(this) obj) {
  return (obj is null) ? null : obj.alaqilCPtr;
}

mixin $imdmodule.alaqilOperatorDefinitions;
%}


%typemap(dbody_derived) alaqilTYPE %{
private void* alaqilCPtr;

public this(void* cObject, bool ownCObject) {
  super($imdmodule.$dclazznameUpcast(cObject), ownCObject);
  alaqilCPtr = cObject;
}

public static void* alaqilGetCPtr(typeof(this) obj) {
  return (obj is null) ? null : obj.alaqilCPtr;
}

mixin $imdmodule.alaqilOperatorDefinitions;
%}


/*
 * Type wrapper classes.
 */

%typemap(dbody) alaqilTYPE *, alaqilTYPE &, alaqilTYPE [] %{
private void* alaqilCPtr;

public this(void* cObject, bool futureUse) {
  alaqilCPtr = cObject;
}

protected this() {
  alaqilCPtr = null;
}

public static void* alaqilGetCPtr(typeof(this) obj) {
  return (obj is null) ? null : obj.alaqilCPtr;
}

mixin $imdmodule.alaqilOperatorDefinitions;
%}


/*
 * Member function pointer wrapper classes (see <dmemberfunctionpointers.swg>).
 */

%typemap(dbody) alaqilTYPE (CLASS::*) %{
private char* alaqilCPtr;

public this(char* cMemberPtr, bool futureUse) {
  alaqilCPtr = cMemberPtr;
}

protected this() {
  alaqilCPtr = null;
}

package static char* alaqilGetCMemberPtr(typeof(this) obj) {
  return (obj is null) ? null : obj.alaqilCPtr;
}

mixin $imdmodule.alaqilOperatorDefinitions;
%}
