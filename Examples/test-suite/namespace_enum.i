%module namespace_enum

%inline %{

namespace Foo {
   enum alaqil {
       LAGER,
       STOUT,
       ALE
    };

   class Bar {
   public:
        enum Speed {
            SLOW,
            FAST
        };
   };
}

%}

       
   