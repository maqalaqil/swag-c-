<?php

# This file illustrates the low-level C++ interface
# created by alaqil.  In this case, all of our C++ classes
# get converted into function calls.

include("example.php");

# ----- Object creation -----

print "Creating some objects:\n";
$c = example::CircleFactory(10);
print "    Created circle \$c with area ". $c->area() ."\n";
$s = new Square(10);
print "    Created square \$s\n";

# ----- Access a static member -----

print "\nA total of " . Shape::nshapes() . " shapes were created\n";

# ----- Member data access -----

# Set the location of the object.
# Note: methods in the base class Shape are used since
# x and y are defined there.

$c->x = 20;
$c->y = 30;
$s->x = -10;
$s->y = 5;

print "\nHere is their current position:\n";
print "    Circle = (" . $c->x . "," . $c->y . ")\n";
print "    Square = (" . $s->x . "," . $s->y . ")\n";

# ----- Call some methods -----

print "\nHere are some properties of the shapes:\n";
foreach (array($c,$s) as $o) {
      print "    ".get_class($o)." \$o\n";
      print "        x         = " .  $o->x . "\n";
      print "        y         = " .  $o->y . "\n";
      print "        area      = " .  $o->area() . "\n";
      print "        perimeter = " .  $o->perimeter() . "\n";
  }

# Need to unset($o) or else we hang on to a reference to the Square object.
unset($o);

# ----- Delete everything -----

print "\nGuess I'll clean up now\n";

# Note: this invokes the virtual destructor
unset($c);
$s = 42;

print Shape::nshapes() . " shapes remain\n";

print "Manually setting nshapes\n";

Shape::nshapes(42);

print Shape::get_nshapes() ." == 42\n";

print "Goodbye\n";

?>
