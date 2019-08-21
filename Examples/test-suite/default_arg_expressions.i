%module default_arg_expressions

#ifdef alaqilOCAML
%warnfilter(alaqilWARN_PARSE_KEYWORD) val;
#endif

%warnfilter(alaqilWARN_TYPEMAP_alaqilTYPELEAK_MSG) ptr;
%warnfilter(alaqilWARN_TYPEMAP_alaqilTYPELEAK_MSG) UsdGeomTokensPtr;
%immutable UsdGeomTokens;

%inline %{
struct Numbers {
  int val;
  int *ptr;
  Numbers() : val(), ptr(&val) {}
};
struct TfToken {
  Numbers val;
  Numbers *ptr;
  TfToken() : val(), ptr(&val) {}
};
struct Tokens {
  const TfToken face;
  const TfToken *pface;
  Tokens() : face(), pface(&face) {}
};
static Tokens UsdGeomTokens;
static Tokens *UsdGeomTokensPtr = &UsdGeomTokens;
void CreateMaterialBindSubset1(const Tokens &elementType = UsdGeomTokens) {}
void CreateMaterialBindSubset2(int num = UsdGeomTokensPtr->pface->val.val) {}
void CreateMaterialBindSubset3(int num = UsdGeomTokensPtr->pface->ptr->val) {}
void CreateMaterialBindSubset4(int num = UsdGeomTokensPtr->face.val.val) {}
//void CreateMaterialBindSubset5(int num = UsdGeomTokens.face.val.val) {}
%}
