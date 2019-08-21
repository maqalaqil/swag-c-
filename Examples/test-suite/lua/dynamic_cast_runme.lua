require("import")	-- the import fn
import("dynamic_cast")	-- import code

f = dynamic_cast.Foo()
b = dynamic_cast.Bar()

x = f:blah()
y = b:blah()

-- alaqil_type is a alaqillua specific function which gets the alaqil_type_info's name
assert(alaqil_type(f)==alaqil_type(x))
assert(alaqil_type(b)==alaqil_type(y))

-- the real test: is y a Foo* or a Bar*?
assert(dynamic_cast.do_test(y)=="Bar::test")
