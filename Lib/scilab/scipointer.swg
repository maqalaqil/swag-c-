/*
 * POINTER
 */
%fragment("alaqil_ConvertPtr", "header") {
#define alaqil_ConvertPtr(scilabValue, voidPointer, pointerDescriptor, flags) alaqilScilabPtrToObject(pvApiCtx, scilabValue, voidPointer, pointerDescriptor, flags, alaqil_Scilab_GetFuncName())
}

%fragment("alaqil_NewPointerObj", "header") {
#define alaqil_NewPointerObj(pointer, pointerDescriptor, flags) alaqilScilabPtrFromObject(pvApiCtx, alaqil_Scilab_GetOutputPosition(), pointer, pointerDescriptor, flags, NULL)
}

/*
 * FUNCTION POINTER
 */
%fragment("alaqil_ConvertFunctionPtr", "header") {
#define alaqil_ConvertFunctionPtr(scilabValue, voidPointer, pointerDescriptor) alaqilScilabPtrToObject(pvApiCtx, scilabValue, voidPointer, pointerDescriptor, 0, alaqil_Scilab_GetFuncName())
}

%fragment("alaqil_NewFunctionPtrObj", "header") {
#define alaqil_NewFunctionPtrObj(pointer, pointerDescriptor) alaqilScilabPtrFromObject(pvApiCtx, alaqil_Scilab_GetOutputPosition(), pointer, pointerDescriptor, 0, NULL)
}
// No fragment used here, the functions "alaqilScilabPtrToObject" and "alaqilScilabPtrFromObject" are defined in sciruntime.swg

/*
 * C++ member pointers, ie, member methods
 */
%fragment("alaqil_NewMemberObj", "header") {
#define alaqil_NewMemberObj(ptr, sz, tp) alaqil_Scilab_NewMemberObj(pvApiCtx, $result, ptr, sz, tp)
}
%fragment("alaqil_ConvertMember", "header") {
#define alaqil_ConvertMember(obj, ptr, sz, ty) alaqil_Scilab_ConvertPacked(pvApiCtx, obj, ptr, sz, ty, alaqil_Scilab_GetFuncName())
}
