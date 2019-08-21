#                         srun.swg                            #
#
# This is the basic code that is needed at run time within R to
# provide and define the relevant classes.  It is included
# automatically in the generated code by copying the contents of
# srun.swg into the newly created binding code.


# This could be provided as a separate run-time library but this
# approach allows the code to be included directly into the
# generated bindings and so removes the need to have and install an
# additional library.  We may however end up with multiple copies of
# this and some confusion at run-time as to which class to use. This
# is an issue when we use NAMESPACES as we may need to export certain
# classes.

######################################################################

if(length(getClassDef("RalaqilStruct")) == 0) 
  setClass("RalaqilStruct", representation("VIRTUAL"))



if(length(getClassDef("ExternalReference")) == 0) 
# Should be virtual but this means it loses its slots currently
#representation("VIRTUAL")
  setClass("ExternalReference", representation( ref = "externalptr"))



if(length(getClassDef("NativeRoutinePointer")) == 0) 
  setClass("NativeRoutinePointer", 
              representation(parameterTypes = "character",
                             returnType = "character",
                             "VIRTUAL"), 
              contains = "ExternalReference")

if(length(getClassDef("CRoutinePointer")) == 0) 
  setClass("CRoutinePointer", contains = "NativeRoutinePointer")


if(length(getClassDef("EnumerationValue")) == 0) 
  setClass("EnumerationValue", contains = "integer")


if(!isGeneric("copyToR")) 
 setGeneric("copyToR",
            function(value, obj = new(gsub("Ref$", "", class(value)))) 
               standardGeneric("copyToR"
           ))

setGeneric("delete", function(obj) standardGeneric("delete"))


alaqil_createNewRef = 
function(className, ..., append = TRUE)
{
  f = get(paste("new", className, sep = "_"), mode = "function")

  f(...)
}

if(!isGeneric("copyToC")) 
 setGeneric("copyToC", 
             function(value, obj = alaqil_createNewRef(class(value)))
              standardGeneric("copyToC"
            ))


# 
defineEnumeration =
function(name, .values, where = topenv(parent.frame()), suffix = "Value")
{
   # Mirror the class definitions via the E analogous to .__C__
  defName = paste(".__E__", name, sep = "")
  delayedAssign(defName,  .values, assign.env = where)

  if(nchar(suffix))
    name = paste(name, suffix, sep = "")

  setClass(name, contains = "EnumerationValue", where = where)
}

enumToInteger <- function(name,type)
{
   if (is.character(name)) {
   ans <- as.integer(get(paste(".__E__", type, sep = ""))[name])
   if (is.na(ans)) {warning("enum not found ", name, " ", type)}
   ans
   } 
}

enumFromInteger =
function(i,type)
{
  itemlist <- get(paste(".__E__", type, sep=""))
  names(itemlist)[match(i, itemlist)]
}

coerceIfNotSubclass =
function(obj, type) 
{
    if(!is(obj, type)) {as(obj, type)} else obj
}


setClass("alaqilArray", representation(dims = "integer"), contains = "ExternalReference")

setMethod("length", "alaqilArray", function(x) x@dims[1])


defineEnumeration("SCopyReferences",
                   .values = c( "FALSE" = 0, "TRUE" = 1, "DEEP" = 2))

assert = 
function(condition, message = "")
{
  if(!condition)
    stop(message)

  TRUE
}


if(FALSE) {
print.alaqilFunction =
function(x, ...)
 {
 }
}


#######################################################################

R_alaqil_getCallbackFunctionStack =
function()
{
    # No PACKAGE argument as we don't know what the DLL is.
  .Call("R_alaqil_debug_getCallbackFunctionData")
}

R_alaqil_addCallbackFunctionStack =
function(fun, userData = NULL)
{
    # No PACKAGE argument as we don't know what the DLL is.
  .Call("R_alaqil_R_pushCallbackFunctionData", fun, userData)
}


#######################################################################
