/* Contrived example to test the Java specific directives on the type wrapper classes */

%module java_typemaps_typewrapper


%typemap(javaimports) alaqilTYPE * "import java.math.*;";
%typemap(javacode) Farewell * %{
  public static $javaclassname CreateNullPointer() {
    return new $javaclassname();
  }
  public void saybye(BigDecimal num_times) {
    // BigDecimal requires the java.math library
  }
%}
%typemap(javaclassmodifiers) Farewell * "public final class";

%typemap(javaimports) Greeting * %{
import java.util.*; // for EventListener
import java.lang.*; // for Exception
%};

%typemap(javabase) Greeting * "Exception";
%typemap(javainterfaces) Greeting * "EventListener";
%typemap(javacode) Greeting * %{
  public static final long serialVersionUID = 0x52151000; // Suppress ecj warning
  // Pure Java code generated using %typemap(javacode) 
  public static $javaclassname CreateNullPointer() {
    return new $javaclassname();
  }

  public void sayhello() {
    $javaclassname.cheerio(new $javaclassname());
  }

  public static void cheerio(EventListener e) {
  }
%}

// Create a new getCPtr() function which takes Java null and is public
// Make the pointer constructor public
%typemap(javabody) Farewell * %{
  private transient long alaqilCPtr;

  public $javaclassname(long cPtr, boolean bFutureUse) {
    alaqilCPtr = cPtr;
  }

  protected $javaclassname() {
    alaqilCPtr = 0;
  }

  public static long getCPtr($javaclassname obj) {
    return (obj == null) ? 0 : obj.alaqilCPtr;
  }
%}

%{
class Greeting {};
class Farewell {};
%}

%inline %{
    Greeting* solong(Farewell* f) { return NULL; }
%}

// Illegal special variable crash
%typemap(jstype) WasCrashing "$javaclassname /*jstype $*javaclassname*/" // $*javaclassname was causing crash
%inline %{
struct WasCrashing {};
void hoop(WasCrashing was) {}
%}

