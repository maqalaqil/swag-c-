module member_pointer_runme;

import Float = tango.text.convert.Float;
import member_pointer.member_pointer;
import member_pointer.Square;
import member_pointer.alaqilTYPE_m_Shape__f_void__double;

void main() {
  auto s = new Square(10);

  // Do some calculations
  auto area_pt = areapt();
  auto perim_pt = perimeterpt();
  check("Square area ", 100.0, do_op(s, area_pt));
  check("Square perim", 40.0, do_op(s, perim_pt));

  alaqilTYPE_m_Shape__f_void__double memberPtr = null;
  memberPtr = areavar;
  memberPtr = perimetervar;

  // Try the variables
  check("Square area ", 100.0, do_op(s, areavar));
  check("Square perim", 40.0, do_op(s, perimetervar));

  // Modify one of the variables
  areavar = perim_pt;
  check("Square perimeter", 40.0, do_op(s,areavar));

  // Try the constants
  memberPtr = AREAPT;
  memberPtr = PERIMPT;
  memberPtr = NULLPT;

  check("Square area", 100.0, do_op(s, AREAPT));
  check("Square perim", 40.0, do_op(s, PERIMPT));
}

void check(char[] what, double expected, double actual) {
  if (expected != actual) {
    throw new Exception("Failed: " ~ what ~ ": expected "
      ~ Float.toString(expected) ~ ", but got " ~ Float.toString(actual));
  }
}
