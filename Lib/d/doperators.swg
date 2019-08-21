/* -----------------------------------------------------------------------------
 * doperators.swg
 *
 * Mapping of C++ operator overloading methods to D.
 * ----------------------------------------------------------------------------- */

#if (alaqil_D_VERSION == 1)

%pragma(d) imdmodulecode=%{
template alaqilOperatorDefinitions() {
  public override int opEquals(Object o) {
    if (auto rhs = cast(typeof(this))o) {
      if (alaqilCPtr == rhs.alaqilCPtr) return 1;
      static if (is(typeof(alaqilOpEquals(rhs)))) {
        return alaqilOpEquals(rhs) ? 1 : 0;
      } else {
        return 0; 
      }
    }
    return super.opEquals(o);
  }
%}
// opEquals is emitted in pure C mode as well to define two proxy classes
// pointing to the same struct as equal.

#ifdef __cplusplus
%rename(opPos) *::operator+();
%rename(opPos) *::operator+() const;
%rename(opNeg) *::operator-();
%rename(opNeg) *::operator-() const;
%rename(opCom) *::operator~();
%rename(opCom) *::operator~() const;

%rename(opAdd) *::operator+;
%rename(opAddAssign) *::operator+=;
%rename(opSub) *::operator-;
%rename(opSubAssign) *::operator-=;
%rename(opMul) *::operator*;
%rename(opMulAssign) *::operator*=;
%rename(opDiv) *::operator/;
%rename(opDivAssign) *::operator/=;
%rename(opMod) *::operator%;
%rename(opModAssign) *::operator%=;
%rename(opAnd) *::operator&;
%rename(opAndAssign) *::operator&=;
%rename(opOr) *::operator|;
%rename(opOrAssign) *::operator|=;
%rename(opXor) *::operator^;
%rename(opXorAssign) *::operator^=;
%rename(opShl) *::operator<<;
%rename(opShlAssign) *::operator<<=;
%rename(opShr) *::operator>>;
%rename(opShrAssign) *::operator>>=;

%rename(opIndex) *::operator[](unsigned) const;
// opIndexAssign is not currently generated, it needs more extensive support
// mechanisms.

%rename(opCall) *::operator();
  
// !a is not overrideable in D1.
%ignoreoperator(LNOT) operator!;

// opCmp is used in D.
%rename(alaqilOpEquals) *::operator==;
%rename(alaqilOpLt) *::operator<;
%rename(alaqilOpLtEquals) *::operator<=;
%rename(alaqilOpGt) *::operator>;
%rename(alaqilOpGtEquals) *::operator>=;

// a != b is rewritten as !a.opEquals(b) in D.
%ignoreoperator(NOTEQUAL) operator!=;

// The logic operators are not overrideable in D.
%ignoreoperator(LAND) operator&&;
%ignoreoperator(LOR) operator||;

// ++/--a is rewritten as a +/-= 1 in D1,so ignore the prefix operators.
%ignoreoperator(PLUSPLUS) *::operator++();
%ignoreoperator(MINUSMINUS) *::operator--();
%rename(alaqilOpInc) *::operator++(int);
%rename(alaqilOpDec) *::operator--(int);

// The C++ assignment operator does not translate well to D where the proxy
// classes have reference semantics.
%ignoreoperator(EQ) operator=;

%pragma(d) imdmodulecode=%{
  public override int opCmp(Object o) {
    static if (is(typeof(alaqilOpLt(typeof(this).init) &&
        alaqilOpEquals(typeof(this).init)))) {
      if (auto rhs = cast(typeof(this))o) {
        if (alaqilOpLt(rhs)) {
          return -1;
        } else if (alaqilOpEquals(rhs)) {
          return 0;
        } else {
          return 1;
        }
      }
    }
    return super.opCmp(o);
  }

  public typeof(this) opPostInc(T = int)(T unused = 0) {
    static assert(
      is(typeof(alaqilOpInc(int.init))),
      "opPostInc called on " ~ typeof(this).stringof ~ ", but no postfix " ~
        "increment operator exists in the corresponding C++ class."
    );
    return alaqilOpInc(int.init);
  }

  public typeof(this) opPostDec(T = int)(T unused = 0) {
    static assert(
      is(typeof(alaqilOpDec(int.init))),
      "opPostInc called on " ~ typeof(this).stringof ~ ", but no postfix " ~
        "decrement operator exists in the corresponding C++ class."
    );
    return alaqilOpDec(int.init);
  }
%}
#endif

%pragma(d) imdmodulecode=%{
}
%}

#else
%pragma(d) imdmodulecode=%{
mixin template alaqilOperatorDefinitions() {
  public override bool opEquals(Object o) {
    if (auto rhs = cast(typeof(this))o) {
      if (alaqilCPtr == rhs.alaqilCPtr) return true;
      static if (is(typeof(alaqilOpEquals(rhs)))) {
        return alaqilOpEquals(rhs);
      } else {
        return false; 
      }
    }
    return super.opEquals(o);
  }
%}
// opEquals is emitted in pure C mode as well to define two proxy classes
// pointing to the same struct as equal.

#ifdef __cplusplus
%rename(alaqilOpPos) *::operator+();
%rename(alaqilOpPos) *::operator+() const;
%rename(alaqilOpNeg) *::operator-();
%rename(alaqilOpNeg) *::operator-() const;
%rename(alaqilOpCom) *::operator~();
%rename(alaqilOpCom) *::operator~() const;
%rename(alaqilOpInc) *::operator++();
%rename(alaqilOpDec) *::operator--();
%ignoreoperator(PLUSPLUS) *::operator++(int);
%ignoreoperator(MINUSMINUS) *::operator--(int);
// The postfix increment/decrement operators are ignored because they are
// rewritten to (auto t = e, ++e, t) in D2. The unary * operator (used for
// pointer dereferencing in C/C++) isn't mapped to opUnary("*") by default,
// despite this would be possible in D2 – the difference in member access
// semantics would only lead to confusion in most cases.

%rename(alaqilOpAdd) *::operator+;
%rename(alaqilOpSub) *::operator-;
%rename(alaqilOpMul) *::operator*;
%rename(alaqilOpDiv) *::operator/;
%rename(alaqilOpMod) *::operator%;
%rename(alaqilOpAnd) *::operator&;
%rename(alaqilOpOr) *::operator|;
%rename(alaqilOpXor) *::operator^;
%rename(alaqilOpShl) *::operator<<;
%rename(alaqilOpShr) *::operator>>;

%rename(alaqilOpAddAssign) *::operator+=;
%rename(alaqilOpSubAssign) *::operator-=;
%rename(alaqilOpMulAssign) *::operator*=;
%rename(alaqilOpDivAssign) *::operator/=;
%rename(alaqilOpModAssign) *::operator%=;
%rename(alaqilOpAndAssign) *::operator&=;
%rename(alaqilOpOrAssign) *::operator|=;
%rename(alaqilOpXorAssign) *::operator^=;
%rename(alaqilOpShlAssign) *::operator<<=;
%rename(alaqilOpShrAssign) *::operator>>=;

%rename(opIndex) *::operator[];
// opIndexAssign is not currently generated, it needs more extensive support
// mechanisms.

%rename(opCall) *::operator();

%rename(alaqilOpEquals) *::operator==;
%rename(alaqilOpLt) *::operator<;
%rename(alaqilOpLtEquals) *::operator<=;
%rename(alaqilOpGt) *::operator>;
%rename(alaqilOpGtEquals) *::operator>=;

// a != b is rewritten as !a.opEquals(b) in D.
%ignoreoperator(NOTEQUAL) operator!=;

// The logic operators are not overrideable in D.
%ignoreoperator(LAND) operator&&;
%ignoreoperator(LOR) operator||;

// The C++ assignment operator does not translate well to D where the proxy
// classes have reference semantics.
%ignoreoperator(EQ) operator=;

%pragma(d) imdmodulecode=%{  
  public override int opCmp(Object o) {
    static if (__traits(compiles, alaqilOpLt(typeof(this).init) &&
        alaqilOpEquals(typeof(this).init))) {
      if (auto rhs = cast(typeof(this))o) {
        if (alaqilOpLt(rhs)) {
          return -1;
        } else if (alaqilOpEquals(rhs)) {
          return 0;
        } else {
          return 1;
        }
      }
    }
    return super.opCmp(o);
  }

  private template alaqilOpBinary(string operator, string name) {
    enum alaqilOpBinary = `public void opOpAssign(string op, T)(T rhs) if (op == "` ~ operator ~
      `" && __traits(compiles, alaqilOp` ~ name ~ `Assign(rhs))) { alaqilOp` ~ name ~ `Assign(rhs);}` ~
      `public auto opBinary(string op, T)(T rhs) if (op == "` ~ operator ~
      `" && __traits(compiles, alaqilOp` ~ name ~ `(rhs))) { return alaqilOp` ~ name ~ `(rhs);}`;
  }
  mixin(alaqilOpBinary!("+", "Add"));
  mixin(alaqilOpBinary!("-", "Sub"));
  mixin(alaqilOpBinary!("*", "Mul"));
  mixin(alaqilOpBinary!("/", "Div"));
  mixin(alaqilOpBinary!("%", "Mod"));
  mixin(alaqilOpBinary!("&", "And"));
  mixin(alaqilOpBinary!("|", "Or"));
  mixin(alaqilOpBinary!("^", "Xor"));
  mixin(alaqilOpBinary!("<<", "Shl"));
  mixin(alaqilOpBinary!(">>", "Shr"));
  
  private template alaqilOpUnary(string operator, string name) {
    enum alaqilOpUnary = `public auto opUnary(string op)() if (op == "` ~ operator ~
      `" && __traits(compiles, alaqilOp` ~ name ~ `())) { return alaqilOp` ~ name ~ `();}`;   
  }
  mixin(alaqilOpUnary!("+", "Pos"));
  mixin(alaqilOpUnary!("-", "Neg"));
  mixin(alaqilOpUnary!("~", "Com"));
  mixin(alaqilOpUnary!("++", "Inc"));
  mixin(alaqilOpUnary!("--", "Dec"));
%}
#endif

%pragma(d) imdmodulecode=%{
}
%}

#endif
