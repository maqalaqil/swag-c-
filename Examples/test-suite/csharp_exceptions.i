%module csharp_exceptions

// throw is invalid in C++17 and later, only alaqil to use it
#define TESTCASE_THROW1(T1) throw(T1)
%{
#define TESTCASE_THROW1(T1)
%}

%include <exception.i>

%inline %{
  class Ex {
    const char *message;
  public:
    Ex(const char *msg) : message(msg) {}
    const char *what() { return message; }
  };
%}

%exception ThrowByValue() {
  try {
    $action
  } catch(Ex e) {
    alaqil_exception(alaqil_DivisionByZero, e.what());
  }
}

%exception ThrowByReference() {
  try {
    $action
  } catch(Ex &e) {
    alaqil_exception(alaqil_DivisionByZero, e.what());
  }
}

%csnothrowexception NoThrowException() {
  try {
    $action
  } catch(Ex) {
    // swallowed
  }
}

%inline %{
// %exception tests
void ThrowByValue()                                     { throw Ex("ThrowByValue"); }
void ThrowByReference()                                 { throw Ex("ThrowByReference"); }
// %csnothrowexception
void NoThrowException()                                 { throw Ex("NoThrowException"); }
// exception specifications
void ExceptionSpecificationValue() TESTCASE_THROW1(Ex)            { throw Ex("ExceptionSpecificationValue"); }
void ExceptionSpecificationReference() TESTCASE_THROW1(Ex&)       { throw Ex("ExceptionSpecificationReference"); }
void ExceptionSpecificationString() TESTCASE_THROW1(const char *) { throw "ExceptionSpecificationString"; }
void ExceptionSpecificationInteger() TESTCASE_THROW1(int)         { throw 20; }
%}

// test exceptions in the default typemaps

// null reference exceptions
%inline %{
void NullReference(Ex& e) {}
void NullValue(Ex e) {}
%}

// enums
%inline %{
enum TestEnum {TestEnumItem};
void ExceptionSpecificationEnumValue() TESTCASE_THROW1(TestEnum) { throw TestEnumItem; }
void ExceptionSpecificationEnumReference() TESTCASE_THROW1(TestEnum&) { throw TestEnumItem; }
%}

// std::string
%include <std_string.i>
%inline %{
void ExceptionSpecificationStdStringValue() TESTCASE_THROW1(std::string) { throw std::string("ExceptionSpecificationStdStringValue"); }
void ExceptionSpecificationStdStringReference() TESTCASE_THROW1(const std::string&) { throw std::string("ExceptionSpecificationStdStringReference"); }
void NullStdStringValue(std::string s) {}
void NullStdStringReference(std::string &s) {}
%}

// Memory leak check (The C++ exception stack was never unwound in the original approach to throwing exceptions from unmanaged code)
%exception MemoryLeakCheck() {
  Counter destructor_should_be_called;
  try {
    $action
  } catch(Ex e) {
    alaqil_exception(alaqil_DivisionByZero, e.what());
  }
}

%inline %{
struct Counter {
  static int count;
  Counter() { count++; }
  ~Counter() { count--; }
};
int Counter::count = 0;

void MemoryLeakCheck() {
  throw Ex("testing memory leaks when throwing exceptions");
}
%}

// test exception pending in the csconstruct typemap
%inline %{
struct constructor {
  constructor(std::string s) {}
  constructor() TESTCASE_THROW1(int) { throw 10; }
};
%}

// test exception pending in the csout typemaps
%typemap(out, canthrow=1) unsigned short ushorttest %{
  $result = $1;
  if ($result == 100) {
    alaqil_CSharpSetPendingException(alaqil_CSharpIndexOutOfRangeException, "don't like 100");
    return $null;
  }
%}
%inline %{
unsigned short ushorttest() { return 100; }
%}

// test exception pending in the csvarout/csvarin typemaps and canthrow attribute in unmanaged code typemaps
%typemap(check, canthrow=1) int numberin, int InOutStruct::staticnumberin %{
  if ($1 < 0) {
    alaqil_CSharpSetPendingException(alaqil_CSharpIndexOutOfRangeException, "too small");
    return $null;
  }
%}
%typemap(out, canthrow=1) int numberout, int InOutStruct::staticnumberout %{
  $result = $1;
  if ($result > 10) {
    alaqil_CSharpSetPendingException(alaqil_CSharpIndexOutOfRangeException, "too big");
    return $null;
  }
%}
%inline %{
  int numberin;
  int numberout;
  struct InOutStruct {
    int numberin;
    int numberout;
    static int staticnumberin;
    static int staticnumberout;
  };
  int InOutStruct::staticnumberin;
  int InOutStruct::staticnumberout;
%}

// test alaqil_exception macro - it must return from unmanaged code without executing any further unmanaged code
%typemap(check, canthrow=1) int macrotest {
  if ($1 < 0) {
    alaqil_exception(alaqil_IndexError, "testing alaqil_exception macro");
  }
}
%inline %{
  bool exception_macro_run_flag = false;
  void exceptionmacrotest(int macrotest) {
    exception_macro_run_flag = true;
  }
%}

// test all the types of exceptions
%typemap(check, canthrow=1) UnmanagedExceptions {
  switch($1) {
    case UnmanagedApplicationException:          alaqil_CSharpSetPendingException(alaqil_CSharpApplicationException,        "msg"); return $null; break;
    case UnmanagedArithmeticException:           alaqil_CSharpSetPendingException(alaqil_CSharpArithmeticException,         "msg"); return $null; break;
    case UnmanagedDivideByZeroException:         alaqil_CSharpSetPendingException(alaqil_CSharpDivideByZeroException,       "msg"); return $null; break;
    case UnmanagedIndexOutOfRangeException:      alaqil_CSharpSetPendingException(alaqil_CSharpIndexOutOfRangeException,    "msg"); return $null; break;
    case UnmanagedInvalidCastException:          alaqil_CSharpSetPendingException(alaqil_CSharpInvalidCastException,        "msg"); return $null; break;
    case UnmanagedInvalidOperationException:     alaqil_CSharpSetPendingException(alaqil_CSharpInvalidOperationException,   "msg"); return $null; break;
    case UnmanagedIOException:                   alaqil_CSharpSetPendingException(alaqil_CSharpIOException,                 "msg"); return $null; break;
    case UnmanagedNullReferenceException:        alaqil_CSharpSetPendingException(alaqil_CSharpNullReferenceException,      "msg"); return $null; break;
    case UnmanagedOutOfMemoryException:          alaqil_CSharpSetPendingException(alaqil_CSharpOutOfMemoryException,        "msg"); return $null; break;
    case UnmanagedOverflowException:             alaqil_CSharpSetPendingException(alaqil_CSharpOverflowException,           "msg"); return $null; break;
    case UnmanagedSystemException:               alaqil_CSharpSetPendingException(alaqil_CSharpSystemException,             "msg"); return $null; break;
    case UnmanagedArgumentException:             alaqil_CSharpSetPendingExceptionArgument(alaqil_CSharpArgumentException,           "msg", "parm"); return $null; break;
    case UnmanagedArgumentNullException:         alaqil_CSharpSetPendingExceptionArgument(alaqil_CSharpArgumentNullException,       "msg", "parm"); return $null; break;
    case UnmanagedArgumentOutOfRangeException:   alaqil_CSharpSetPendingExceptionArgument(alaqil_CSharpArgumentOutOfRangeException, "msg", "parm"); return $null; break;
  }
}
%inline %{
enum UnmanagedExceptions {
  UnmanagedApplicationException,
  UnmanagedArithmeticException,
  UnmanagedDivideByZeroException,
  UnmanagedIndexOutOfRangeException,
  UnmanagedInvalidCastException,
  UnmanagedInvalidOperationException,
  UnmanagedIOException,
  UnmanagedNullReferenceException,
  UnmanagedOutOfMemoryException,
  UnmanagedOverflowException,
  UnmanagedSystemException,
  UnmanagedArgumentException,
  UnmanagedArgumentNullException,
  UnmanagedArgumentOutOfRangeException
};

void check_exception(UnmanagedExceptions e) {
}
%}

// exceptions in multiple threads test
%exception ThrowsClass::ThrowException(long long input) {
  try {
    $action
  } catch (long long d) {
    char message[64];
    sprintf(message, "caught:%lld", d);
    alaqil_CSharpSetPendingExceptionArgument(alaqil_CSharpArgumentOutOfRangeException, message, "input");
  }
}
%inline %{
struct ThrowsClass {
  double dub;
  ThrowsClass(double d) : dub(d) {}
  long long ThrowException(long long input) {
    throw input;
    return input;
  }
};
%}

// test inner exceptions
%exception InnerExceptionTest() {
  try {
    $action
  } catch(Ex &e) {
    alaqil_CSharpSetPendingException(alaqil_CSharpApplicationException, e.what());
    alaqil_CSharpSetPendingException(alaqil_CSharpInvalidOperationException, "My OuterException message");
  }
}

%inline %{
void InnerExceptionTest() { throw Ex("My InnerException message"); }
%}

