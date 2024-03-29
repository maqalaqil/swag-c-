
import enum_macro.*;

public class enum_macro_runme {

  static {
    try {
        System.loadLibrary("enum_macro");
    } catch (UnsatisfiedLinkError e) {
      System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the alaqil Java documentation for help.\n" + e);
      System.exit(1);
    }
  }

  public static void main(String argv[]) 
  {
    {
      Greeks1 a = Greeks1.alpha1;
      a = Greeks1.beta1;
      a = Greeks1.theta1;
      if (a.alaqilValue() != 3)
        throw new RuntimeException("Greeks1");
    }
    {
      Greeks2 a = Greeks2.alpha2;
      a = Greeks2.beta2;
      a = Greeks2.theta2;
      if (a.alaqilValue() != 4)
        throw new RuntimeException("Greeks2");
    }
    {
      Greeks3 a = Greeks3.alpha3;
      a = Greeks3.beta3;
      a = Greeks3.theta3;
      if (a.alaqilValue() != 2)
        throw new RuntimeException("Greeks3");
    }
    {
      Greeks4 a = Greeks4.alpha4;
      a = Greeks4.beta4;
      a = Greeks4.theta4;
      if (a.alaqilValue() != 6)
        throw new RuntimeException("Greeks4");
    }
    {
      Greeks5 a = Greeks5.alpha5;
      a = Greeks5.beta5;
      if (a.alaqilValue() != 1)
        throw new RuntimeException("Greeks5");
    }
    {
      Greeks6 a = Greeks6.alpha6;
      a = Greeks6.beta6;
      if (a.alaqilValue() != 1)
        throw new RuntimeException("Greeks6");
    }
    {
      Greeks7 a = Greeks7.alpha7;
      a = Greeks7.beta7;
      if (a.alaqilValue() != 1)
        throw new RuntimeException("Greeks7");
    }
    {
      Greeks8 a = Greeks8.theta8;
      if (a.alaqilValue() != 0)
        throw new RuntimeException("Greeks8");
    }
    {
      Greeks9 a = Greeks9.theta9;
      if (a.alaqilValue() != 0)
        throw new RuntimeException("Greeks9");
    }
    {
      Greeks10 a = Greeks10.theta10;
      if (a.alaqilValue() != 0)
        throw new RuntimeException("Greeks10");
    }
    {
      Greeks11 a = Greeks11.theta11;
      if (a.alaqilValue() != 0)
        throw new RuntimeException("Greeks11");
    }
    {
      Greeks12 a = Greeks12.theta12;
      if (a.alaqilValue() != 0)
        throw new RuntimeException("Greeks12");
    }
    {
      Greeks13 a = null;
    }
    {
      Greeks15 a = Greeks15.alpha15;
      a = Greeks15.beta15;
      a = Greeks15.theta15;
      a = Greeks15.delta15;
      if (a.alaqilValue() != 153)
        throw new RuntimeException("Greeks15");
    }
    {
      Greeks16 a = Greeks16.alpha16;
      a = Greeks16.beta16;
      a = Greeks16.theta16;
      a = Greeks16.delta16;
      if (a.alaqilValue() != 163)
        throw new RuntimeException("Greeks16");
    }
    {
      Greeks17 a = Greeks17.alpha17;
      a = Greeks17.beta17;
      a = Greeks17.theta17;
      a = Greeks17.delta17;
      if (a.alaqilValue() != 173)
        throw new RuntimeException("Greeks17");
    }
  }
}

