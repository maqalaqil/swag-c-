/* -----------------------------------------------------------------------------
 * std_complex.i
 *
 * Typemaps for handling std::complex<float> and std::complex<double> as a .NET
 * System.Numerics.Complex type. Requires .NET 4 minimum.
 * ----------------------------------------------------------------------------- */

%{
#include <complex>
%}

%fragment("alaqilSystemNumericsComplex", "header") {
extern "C" {
// Identical to the layout of System.Numerics.Complex, but does assume that it is
// LayoutKind.Sequential on the managed side
struct alaqilSystemNumericsComplex {
  double real;
  double imag;
};
}

alaqilINTERN alaqilSystemNumericsComplex alaqilCreateSystemNumericsComplex(double real, double imag) {
  alaqilSystemNumericsComplex cpx;
  cpx.real = real;
  cpx.imag = imag;
  return cpx;
}
}

namespace std {

%naturalvar complex;

template<typename T>
class complex
{
public:
    complex(T re = T(), T im = T());
};

}

%define alaqil_COMPLEX_TYPEMAPS(T)
%typemap(ctype, fragment="alaqilSystemNumericsComplex") std::complex<T>, const std::complex<T> & "alaqilSystemNumericsComplex"
%typemap(imtype) std::complex<T>, const std::complex<T> & "System.Numerics.Complex"
%typemap(cstype) std::complex<T>, const std::complex<T> & "System.Numerics.Complex"

%typemap(in) std::complex<T>
%{$1 = std::complex< double >($input.real, $input.imag);%}

%typemap(in) const std::complex<T> &($*1_ltype temp)
%{temp = std::complex< T >((T)$input.real, (T)$input.imag);
  $1 = &temp;%}

%typemap(out, null="alaqilCreateSystemNumericsComplex(0.0, 0.0)") std::complex<T>
%{$result = alaqilCreateSystemNumericsComplex($1.real(), $1.imag());%}

%typemap(out, null="alaqilCreateSystemNumericsComplex(0.0, 0.0)") const std::complex<T> &
%{$result = alaqilCreateSystemNumericsComplex($1->real(), $1->imag());%}

%typemap(cstype) std::complex<T>, const std::complex<T> & "System.Numerics.Complex"

%typemap(csin) std::complex<T>, const std::complex<T> & "$csinput"

%typemap(csout, excode=alaqilEXCODE) std::complex<T>, const std::complex<T> & {
    System.Numerics.Complex ret = $imcall;$excode
    return ret;
  }

%typemap(csvarin, excode=alaqilEXCODE2) const std::complex<T> & %{
    set {
      $imcall;$excode
    }
  %}

%typemap(csvarout, excode=alaqilEXCODE2) const std::complex<T> & %{
    get {
      System.Numerics.Complex ret = $imcall;$excode
      return ret;
    }
  %}

%template() std::complex<T>;
%enddef

// By default, typemaps for both std::complex<double> and std::complex<float>
// are defined, but one of them can be disabled by predefining the
// corresponding symbol before including this file.
#ifndef alaqil_NO_STD_COMPLEX_DOUBLE
alaqil_COMPLEX_TYPEMAPS(double)
#endif

#ifndef alaqil_NO_STD_COMPLEX_FLOAT
alaqil_COMPLEX_TYPEMAPS(float)
#endif
