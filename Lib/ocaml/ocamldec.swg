/* -----------------------------------------------------------------------------
 * ocamldec.swg
 *
 * Ocaml runtime code -- declarations
 * ----------------------------------------------------------------------------- */

#include <stdio.h>
#include <string.h>
#include <stdlib.h>

#ifdef __cplusplus
#define alaqilEXT extern "C"
alaqilEXT {
#else
#define alaqilEXT 
#endif
#define value caml_value_t
#define CAML_VALUE caml_value_t
#define CAML_NAME_SPACE
#include <caml/alloc.h>
#include <caml/custom.h>
#include <caml/mlvalues.h>
#include <caml/memory.h>
#include <caml/callback.h>
#include <caml/fail.h>
#include <caml/misc.h>

#if defined(CAMLassert)
/* Both this macro and version.h were introduced in version 4.02.0 */
#include <caml/version.h>
#else
#define OCAML_VERSION 0 /* Unknown, but < 40200 */
#endif

#define caml_array_set alaqil_caml_array_set

/* Adapted from memory.h and mlvalues.h */

#define alaqil_CAMLlocal1(x) \
  caml_value_t x = 0; \
  CAMLxparam1 (x)

#define alaqil_CAMLlocal2(x, y) \
  caml_value_t x = 0, y = 0; \
  CAMLxparam2 (x, y)

#define alaqil_CAMLlocal3(x, y, z) \
  caml_value_t x = 0, y = 0, z = 0; \
  CAMLxparam3 (x, y, z)

#define alaqil_CAMLlocal4(x, y, z, t) \
  caml_value_t x = 0, y = 0, z = 0, t = 0; \
  CAMLxparam4 (x, y, z, t)

#define alaqil_CAMLlocal5(x, y, z, t, u) \
  caml_value_t x = 0, y = 0, z = 0, t = 0, u = 0; \
  CAMLxparam5 (x, y, z, t, u)

#define alaqil_CAMLlocalN(x, size) \
  caml_value_t x [(size)] = { 0, /* 0, 0, ... */ }; \
  CAMLxparamN (x, (size))

#define alaqil_Field(x, i) (((caml_value_t *)(x)) [i])           /* Also an l-value. */
#define alaqil_Store_field(block, offset, val) do{ \
  mlsize_t caml__temp_offset = (offset); \
  caml_value_t caml__temp_val = (val); \
  caml_modify (&alaqil_Field ((block), caml__temp_offset), caml__temp_val); \
}while(0)

#define alaqil_Data_custom_val(v) ((void *) &alaqil_Field((v), 1))
#ifdef ARCH_BIG_ENDIAN
#define alaqil_Tag_val(val) (((unsigned char *) (val)) [-1])
                                                 /* Also an l-value. */
#define alaqil_Tag_hp(hp) (((unsigned char *) (hp)) [sizeof(caml_value_t)-1])
                                                 /* Also an l-value. */
#else
#define alaqil_Tag_val(val) (((unsigned char *) (val)) [-sizeof(caml_value_t)])
                                                 /* Also an l-value. */
#define alaqil_Tag_hp(hp) (((unsigned char *) (hp)) [0])
                                                 /* Also an l-value. */
#endif

#ifdef CAMLreturn0
#undef CAMLreturn0
#endif
#define CAMLreturn0 do{ \
  caml_local_roots = caml__frame; \
  return; \
}while (0)

#ifdef CAMLreturn
#undef CAMLreturn
#endif
#define CAMLreturn(result) do{ \
  caml_value_t caml__temp_result = (result); \
  caml_local_roots = caml__frame; \
  return (caml__temp_result); \
}while(0)

#define CAMLreturn_type(result) do{ \
  caml_local_roots = caml__frame; \
  return result; \
}while(0)

#ifdef CAMLnoreturn
#undef CAMLnoreturn
#endif
#define CAMLnoreturn ((void) caml__frame)


#ifndef ARCH_ALIGN_INT64
#if OCAML_VERSION >= 40300
#define alaqil_Int64_val(v) (*((int64_t *) alaqil_Data_custom_val(v)))
#else
#define alaqil_Int64_val(v) (*((int64 *) alaqil_Data_custom_val(v)))
#endif
#else
#if OCAML_VERSION >= 40300
CAMLextern int64_t Int64_val(caml_value_t v);
#else
CAMLextern int64 Int64_val(caml_value_t v);
#endif
#define alaqil_Int64_val(v) Int64_val(v)
#endif

#define alaqil_NewPointerObj(p,type,flags) caml_val_ptr(p,type)
#define alaqil_GetModule(clientdata) alaqil_Ocaml_GetModule(clientdata)
#define alaqil_SetModule(clientdata, pointer) alaqil_Ocaml_SetModule(pointer)

typedef enum {
  alaqil_OCamlArithmeticException,
  alaqil_OCamlDirectorPureVirtual,
  alaqil_OCamlOutOfMemoryError,
  alaqil_OCamlOverflowException,
  alaqil_OCamlIllegalArgumentException,
  alaqil_OCamlIndexOutOfBoundsException,
  alaqil_OCamlRuntimeException,
  alaqil_OCamlSystemException,
  alaqil_OCamlUnknownError
} alaqil_OCamlExceptionCodes;

alaqilINTERN void alaqil_OCamlThrowException(alaqil_OCamlExceptionCodes code, const char *msg) {
  CAMLparam0();
  alaqil_CAMLlocal1(str);

  switch (code) {
  case alaqil_OCamlIllegalArgumentException:
    caml_invalid_argument(msg);
    break;
  case alaqil_OCamlSystemException:
    str = caml_copy_string(msg);
    caml_raise_sys_error(str);
    break;
  case alaqil_OCamlArithmeticException:
  case alaqil_OCamlIndexOutOfBoundsException:
  case alaqil_OCamlOutOfMemoryError:
  case alaqil_OCamlOverflowException:
  case alaqil_OCamlRuntimeException:
  case alaqil_OCamlUnknownError:
  default:
    caml_failwith(msg);
    break;
  }
  CAMLreturn0;
}

#define alaqil_contract_assert(expr, msg) if(!(expr)) {alaqil_OCamlThrowException(alaqil_OCamlRuntimeException, msg);}

    alaqilINTERN int
    alaqil_GetPtr(void *source, void **result, alaqil_type_info *type, alaqil_type_info *result_type);

    alaqilINTERN CAML_VALUE caml_list_nth( CAML_VALUE lst, int n );
    alaqilINTERN CAML_VALUE caml_list_append( CAML_VALUE lst, CAML_VALUE elt );
    alaqilINTERN int caml_list_length( CAML_VALUE lst );
    alaqilINTERN CAML_VALUE caml_array_new( int n );
    alaqilINTERN void caml_array_set( CAML_VALUE arr, int n, CAML_VALUE item );
    alaqilINTERN CAML_VALUE caml_array_nth( CAML_VALUE arr, int n );
    alaqilINTERN int caml_array_len( CAML_VALUE arr );

    alaqilINTERN CAML_VALUE caml_val_char( char c );
    alaqilINTERN CAML_VALUE caml_val_uchar( unsigned char c );

    alaqilINTERN CAML_VALUE caml_val_short( short s );
    alaqilINTERN CAML_VALUE caml_val_ushort( unsigned short s );
    
    alaqilINTERN CAML_VALUE caml_val_int( int x );
    alaqilINTERN CAML_VALUE caml_val_uint( unsigned int x );

    alaqilINTERN CAML_VALUE caml_val_long( long x );
    alaqilINTERN CAML_VALUE caml_val_ulong( unsigned long x );

    alaqilINTERN CAML_VALUE caml_val_float( float f );
    alaqilINTERN CAML_VALUE caml_val_double( double d );

    alaqilINTERN CAML_VALUE caml_val_ptr( void *p, alaqil_type_info *descriptor );

    alaqilINTERN CAML_VALUE caml_val_string( const char *str );
    alaqilINTERN CAML_VALUE caml_val_string_len( const char *str, int len );

    alaqilINTERN long caml_long_val( CAML_VALUE v );
    alaqilINTERN double caml_double_val( CAML_VALUE v );

    alaqilINTERN int caml_ptr_val_internal( CAML_VALUE v, void **out,
				      alaqil_type_info *descriptor );
    alaqilINTERN void *caml_ptr_val( CAML_VALUE v, alaqil_type_info *descriptor );

    alaqilINTERN char *caml_string_val( CAML_VALUE v );
    alaqilINTERN int caml_string_len( CAML_VALUE v );

#ifdef __cplusplus
}
#endif
