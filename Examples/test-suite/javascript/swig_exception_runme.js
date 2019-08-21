var alaqil_exception = require("alaqil_exception");

var c = new alaqil_exception.Circle(10);
var s = new alaqil_exception.Square(10);

if (alaqil_exception.Shape.nshapes != 2) {
    throw "Shape.nshapes should be 2, actually " + alaqil_exception.Shape.nshapes;
}

// ----- Throw exception -----
try {
    c.throwException();
    throw "Exception wasn't thrown";
} catch (e) {
    if (e.message != "OK") {
	throw "Exception message should be \"OK\", actually \"" + e.message + "\"";
    }
}

// ----- Delete everything -----

c = null;
s = null;
e = null;

/* FIXME: Garbage collection needs to happen before this check will work.
if (alaqil_exception.Shape.nshapes != 0) {
    throw "Shape.nshapes should be 0, actually " + alaqil_exception.Shape.nshapes;
}
*/
