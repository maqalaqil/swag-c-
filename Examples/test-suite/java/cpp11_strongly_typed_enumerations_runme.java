import cpp11_strongly_typed_enumerations.*;

public class cpp11_strongly_typed_enumerations_runme {

  static {
    try {
        System.loadLibrary("cpp11_strongly_typed_enumerations");
    } catch (UnsatisfiedLinkError e) {
      System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the alaqil Java documentation for help.\n" + e);
      System.exit(1);
    }
  }

  public static int enumCheck(int actual, int expected) {
    if (actual != expected)
      throw new RuntimeException("Enum value mismatch. Expected " + expected + " Actual: " + actual);
    return expected + 1;
  }

  public static void main(String argv[]) {
    int val = 0;
    val = enumCheck(Enum1.Val1.alaqilValue(), val);
    val = enumCheck(Enum1.Val2.alaqilValue(), val);
    val = enumCheck(Enum1.Val3.alaqilValue(), 13);
    val = enumCheck(Enum1.Val4.alaqilValue(), val);
    val = enumCheck(Enum1.Val5a.alaqilValue(), 13);
    val = enumCheck(Enum1.Val6a.alaqilValue(), val);

    val = 0;
    val = enumCheck(Enum2.Val1.alaqilValue(), val);
    val = enumCheck(Enum2.Val2.alaqilValue(), val);
    val = enumCheck(Enum2.Val3.alaqilValue(), 23);
    val = enumCheck(Enum2.Val4.alaqilValue(), val);
    val = enumCheck(Enum2.Val5b.alaqilValue(), 23);
    val = enumCheck(Enum2.Val6b.alaqilValue(), val);

    val = 0;
    val = enumCheck(Enum4.Val1.alaqilValue(), val);
    val = enumCheck(Enum4.Val2.alaqilValue(), val);
    val = enumCheck(Enum4.Val3.alaqilValue(), 43);
    val = enumCheck(Enum4.Val4.alaqilValue(), val);

    val = 0;
    val = enumCheck(Enum5.Val1.alaqilValue(), val);
    val = enumCheck(Enum5.Val2.alaqilValue(), val);
    val = enumCheck(Enum5.Val3.alaqilValue(), 53);
    val = enumCheck(Enum5.Val4.alaqilValue(), val);

    val = 0;
    val = enumCheck(Enum6.Val1.alaqilValue(), val);
    val = enumCheck(Enum6.Val2.alaqilValue(), val);
    val = enumCheck(Enum6.Val3.alaqilValue(), 63);
    val = enumCheck(Enum6.Val4.alaqilValue(), val);

    val = 0;
    val = enumCheck(Enum7td.Val1.alaqilValue(), val);
    val = enumCheck(Enum7td.Val2.alaqilValue(), val);
    val = enumCheck(Enum7td.Val3.alaqilValue(), 73);
    val = enumCheck(Enum7td.Val4.alaqilValue(), val);

    val = 0;
    val = enumCheck(Enum8.Val1.alaqilValue(), val);
    val = enumCheck(Enum8.Val2.alaqilValue(), val);
    val = enumCheck(Enum8.Val3.alaqilValue(), 83);
    val = enumCheck(Enum8.Val4.alaqilValue(), val);

    val = 0;
    val = enumCheck(Enum10.Val1.alaqilValue(), val);
    val = enumCheck(Enum10.Val2.alaqilValue(), val);
    val = enumCheck(Enum10.Val3.alaqilValue(), 103);
    val = enumCheck(Enum10.Val4.alaqilValue(), val);

    val = 0;
    val = enumCheck(Class1.Enum12.Val1.alaqilValue(), 1121);
    val = enumCheck(Class1.Enum12.Val2.alaqilValue(), 1122);
    val = enumCheck(Class1.Enum12.Val3.alaqilValue(), val);
    val = enumCheck(Class1.Enum12.Val4.alaqilValue(), val);
    val = enumCheck(Class1.Enum12.Val5c.alaqilValue(), 1121);
    val = enumCheck(Class1.Enum12.Val6c.alaqilValue(), val);

    val = 0;
    val = enumCheck(Class1.Enum13.Val1.alaqilValue(), 1131);
    val = enumCheck(Class1.Enum13.Val2.alaqilValue(), 1132);
    val = enumCheck(Class1.Enum13.Val3.alaqilValue(), val);
    val = enumCheck(Class1.Enum13.Val4.alaqilValue(), val);
    val = enumCheck(Class1.Enum13.Val5d.alaqilValue(), 1131);
    val = enumCheck(Class1.Enum13.Val6d.alaqilValue(), val);

    val = 0;
    val = enumCheck(Class1.Enum14.Val1.alaqilValue(), 1141);
    val = enumCheck(Class1.Enum14.Val2.alaqilValue(), 1142);
    val = enumCheck(Class1.Enum14.Val3.alaqilValue(), val);
    val = enumCheck(Class1.Enum14.Val4.alaqilValue(), val);
    val = enumCheck(Class1.Enum14.Val5e.alaqilValue(), 1141);
    val = enumCheck(Class1.Enum14.Val6e.alaqilValue(), val);

    val = 0;
    val = enumCheck(Class1.Struct1.Enum12.Val1.alaqilValue(), 3121);
    val = enumCheck(Class1.Struct1.Enum12.Val2.alaqilValue(), 3122);
    val = enumCheck(Class1.Struct1.Enum12.Val3.alaqilValue(), val);
    val = enumCheck(Class1.Struct1.Enum12.Val4.alaqilValue(), val);
    val = enumCheck(Class1.Struct1.Enum12.Val5f.alaqilValue(), 3121);
    val = enumCheck(Class1.Struct1.Enum12.Val6f.alaqilValue(), val);

    val = 0;
    val = enumCheck(Class1.Struct1.Enum13.Val1.alaqilValue(), 3131);
    val = enumCheck(Class1.Struct1.Enum13.Val2.alaqilValue(), 3132);
    val = enumCheck(Class1.Struct1.Enum13.Val3.alaqilValue(), val);
    val = enumCheck(Class1.Struct1.Enum13.Val4.alaqilValue(), val);

    val = 0;
    val = enumCheck(Class1.Struct1.Enum14.Val1.alaqilValue(), 3141);
    val = enumCheck(Class1.Struct1.Enum14.Val2.alaqilValue(), 3142);
    val = enumCheck(Class1.Struct1.Enum14.Val3.alaqilValue(), val);
    val = enumCheck(Class1.Struct1.Enum14.Val4.alaqilValue(), val);
    val = enumCheck(Class1.Struct1.Enum14.Val5g.alaqilValue(), 3141);
    val = enumCheck(Class1.Struct1.Enum14.Val6g.alaqilValue(), val);

    val = 0;
    val = enumCheck(Class2.Enum12.Val1.alaqilValue(), 2121);
    val = enumCheck(Class2.Enum12.Val2.alaqilValue(), 2122);
    val = enumCheck(Class2.Enum12.Val3.alaqilValue(), val);
    val = enumCheck(Class2.Enum12.Val4.alaqilValue(), val);
    val = enumCheck(Class2.Enum12.Val5h.alaqilValue(), 2121);
    val = enumCheck(Class2.Enum12.Val6h.alaqilValue(), val);

    val = 0;
    val = enumCheck(Class2.Enum13.Val1.alaqilValue(), 2131);
    val = enumCheck(Class2.Enum13.Val2.alaqilValue(), 2132);
    val = enumCheck(Class2.Enum13.Val3.alaqilValue(), val);
    val = enumCheck(Class2.Enum13.Val4.alaqilValue(), val);
    val = enumCheck(Class2.Enum13.Val5i.alaqilValue(), 2131);
    val = enumCheck(Class2.Enum13.Val6i.alaqilValue(), val);

    val = 0;
    val = enumCheck(Class2.Enum14.Val1.alaqilValue(), 2141);
    val = enumCheck(Class2.Enum14.Val2.alaqilValue(), 2142);
    val = enumCheck(Class2.Enum14.Val3.alaqilValue(), val);
    val = enumCheck(Class2.Enum14.Val4.alaqilValue(), val);
    val = enumCheck(Class2.Enum14.Val5j.alaqilValue(), 2141);
    val = enumCheck(Class2.Enum14.Val6j.alaqilValue(), val);

    val = 0;
    val = enumCheck(Class2.Struct1.Enum12.Val1.alaqilValue(), 4121);
    val = enumCheck(Class2.Struct1.Enum12.Val2.alaqilValue(), 4122);
    val = enumCheck(Class2.Struct1.Enum12.Val3.alaqilValue(), val);
    val = enumCheck(Class2.Struct1.Enum12.Val4.alaqilValue(), val);
    val = enumCheck(Class2.Struct1.Enum12.Val5k.alaqilValue(), 4121);
    val = enumCheck(Class2.Struct1.Enum12.Val6k.alaqilValue(), val);

    val = 0;
    val = enumCheck(Class2.Struct1.Enum13.Val1.alaqilValue(), 4131);
    val = enumCheck(Class2.Struct1.Enum13.Val2.alaqilValue(), 4132);
    val = enumCheck(Class2.Struct1.Enum13.Val3.alaqilValue(), val);
    val = enumCheck(Class2.Struct1.Enum13.Val4.alaqilValue(), val);
    val = enumCheck(Class2.Struct1.Enum13.Val5l.alaqilValue(), 4131);
    val = enumCheck(Class2.Struct1.Enum13.Val6l.alaqilValue(), val);

    val = 0;
    val = enumCheck(Class2.Struct1.Enum14.Val1.alaqilValue(), 4141);
    val = enumCheck(Class2.Struct1.Enum14.Val2.alaqilValue(), 4142);
    val = enumCheck(Class2.Struct1.Enum14.Val3.alaqilValue(), val);
    val = enumCheck(Class2.Struct1.Enum14.Val4.alaqilValue(), val);
    val = enumCheck(Class2.Struct1.Enum14.Val5m.alaqilValue(), 4141);
    val = enumCheck(Class2.Struct1.Enum14.Val6m.alaqilValue(), val);

    Class1 class1 = new Class1();
    enumCheck(class1.class1Test1(Enum1.Val5a).alaqilValue(), 13);
    enumCheck(class1.class1Test2(Class1.Enum12.Val5c).alaqilValue(), 1121);
    enumCheck(class1.class1Test3(Class1.Struct1.Enum12.Val5f).alaqilValue(), 3121);

    enumCheck(cpp11_strongly_typed_enumerations.globalTest1(Enum1.Val5a).alaqilValue(), 13);
    enumCheck(cpp11_strongly_typed_enumerations.globalTest2(Class1.Enum12.Val5c).alaqilValue(), 1121);
    enumCheck(cpp11_strongly_typed_enumerations.globalTest3(Class1.Struct1.Enum12.Val5f).alaqilValue(), 3121);
  }
}
