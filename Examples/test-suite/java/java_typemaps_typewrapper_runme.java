
// This is the java_typemaps_typewrapper runtime testcase. Contrived example checks that the pure Java code generated from the Java typemaps compiles.

import java_typemaps_typewrapper.*;

public class java_typemaps_typewrapper_runme {

  static {
    try {
	System.loadLibrary("java_typemaps_typewrapper");
    } catch (UnsatisfiedLinkError e) {
      System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the alaqil Java documentation for help.\n" + e);
      System.exit(1);
    }
  }

  public static void main(String argv[]) {

    alaqilTYPE_p_Greeting greet = alaqilTYPE_p_Greeting.CreateNullPointer();
    alaqilTYPE_p_Farewell bye = alaqilTYPE_p_Farewell.CreateNullPointer();

    // Check that pure Java methods have been added
    greet.sayhello();
    bye.saybye(new java.math.BigDecimal(java.math.BigInteger.ONE));

    // Check that alaqilTYPE_p_Greeting is derived from Exception
    try {
      throw alaqilTYPE_p_Greeting.CreateNullPointer();
    } catch (alaqilTYPE_p_Greeting g) {
        String msg = g.getMessage(); 
    }

    // Check that alaqilTYPE_p_Greeting has implemented the EventListener interface
    alaqilTYPE_p_Greeting.cheerio(greet); 

    // The default getCPtr() call in each method will through an exception if null is passed.
    // Make sure the modified version works with and without null objects.
    java_typemaps_typewrapper.solong(null);
    java_typemaps_typewrapper.solong(bye);

    // Create a NULL pointer for Farewell using the constructor with changed modifiers
    alaqilTYPE_p_Farewell nullFarewell = new alaqilTYPE_p_Farewell(0, false);
  }
}

