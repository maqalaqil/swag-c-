%module symbol_clash

// ::Vector and ::Text::Vector were incorrectly clashing in the target language symbol tables

#if defined(alaqilJAVA) || defined(alaqilCSHARP)

#if defined(alaqilJAVA)
%include "enumtypeunsafe.swg"
#elif defined(alaqilCSHARP)
%include "enumsimple.swg"
#endif

%inline %{
class Vector
{
};

namespace Text
{
  enum Preference
  {
    Raster,
    Vector
  };
}
%}

#endif
