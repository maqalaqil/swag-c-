%include <std_common.i>

%{
#include <utility>
%}


namespace std {
  template <class T, class U > struct pair {      
    typedef T first_type;
    typedef U second_type;
    
    %traits_alaqiltype(T);
    %traits_alaqiltype(U);

    %fragment(alaqil_Traits_frag(std::pair< T, U >), "header",
	      fragment=alaqil_Traits_frag(T),
	      fragment=alaqil_Traits_frag(U),
	      fragment="StdPairTraits") {
      namespace alaqil {
	template <>  struct traits<std::pair< T, U > > {
	  typedef pointer_category category;
	  static const char* type_name() {
	    return "std::pair<" #T "," #U " >";
	  }
	};
      }
    }

#ifndef alaqil_STD_PAIR_ASVAL
    %typemap_traits_ptr(alaqil_TYPECHECK_PAIR, std::pair< T, U >);
#else
    %typemap_traits(alaqil_TYPECHECK_PAIR, std::pair< T, U >);
#endif

    pair();
    pair(T first, U second);
    pair(const pair& other);

    template <class U1, class U2> pair(const pair< U1, U2 > &other);

    T first;
    U second;

#ifdef %alaqil_pair_methods
    // Add alaqil/language extra methods
    %alaqil_pair_methods(std::pair< T, U >)
#endif
  };

  // ***
  // The following specializations should disappear or get
  // simplified when a 'const alaqilTYPE*&' can be defined
  // ***
  template <class T, class U > struct pair< T, U* > {
    typedef T first_type;
    typedef U* second_type;
    
    %traits_alaqiltype(T);
    %traits_alaqiltype(U);
      
    %fragment(alaqil_Traits_frag(std::pair< T, U* >), "header",
	      fragment=alaqil_Traits_frag(T),
	      fragment=alaqil_Traits_frag(U),
	      fragment="StdPairTraits") {
      namespace alaqil {
	template <>  struct traits<std::pair< T, U* > > {
	  typedef pointer_category category;
	  static const char* type_name() {
	    return "std::pair<" #T "," #U " * >";
	  }
	};
      }
    }

    %typemap_traits_ptr(alaqil_TYPECHECK_PAIR, std::pair< T, U* >);

    pair();
    pair(T first, U* second);
    pair(const pair& other);

    T first;
    U* second;

#ifdef %alaqil_pair_methods
    // Add alaqil/language extra methods
    %alaqil_pair_methods(std::pair< T, U* >)
#endif
  };

  template <class T, class U > struct pair< T*, U > {
    typedef T* first_type;
    typedef U second_type;
    
    %traits_alaqiltype(T);
    %traits_alaqiltype(U);
      
    %fragment(alaqil_Traits_frag(std::pair< T*, U >), "header",
	      fragment=alaqil_Traits_frag(T),
	      fragment=alaqil_Traits_frag(U),
	      fragment="StdPairTraits") {
      namespace alaqil {
	template <>  struct traits<std::pair< T*, U > > {
	  typedef pointer_category category;
	  static const char* type_name() {
	    return "std::pair<" #T " *," #U " >";
	  }
	};
      }
    }

    %typemap_traits_ptr(alaqil_TYPECHECK_PAIR, std::pair< T*, U >);

    pair();
    pair(T* first, U second);
    pair(const pair& other);

    T* first;
    U second;

#ifdef %alaqil_pair_methods
    // Add alaqil/language extra methods
    %alaqil_pair_methods(std::pair< T*, U >)
#endif
  };

  template <class T, class U > struct pair< T*, U* > {
    typedef T* first_type;
    typedef U* second_type;

    %traits_alaqiltype(T);
    %traits_alaqiltype(U);
      
    %fragment(alaqil_Traits_frag(std::pair< T*, U* >), "header",
	      fragment=alaqil_Traits_frag(T),
	      fragment=alaqil_Traits_frag(U),
	      fragment="StdPairTraits") {
      namespace alaqil {
	template <>  struct traits<std::pair< T*, U* > > {
	  typedef pointer_category category;
	  static const char* type_name() {
	    return "std::pair<" #T " *," #U " * >";
	  }
	};
      }
    }

    %typemap_traits(alaqil_TYPECHECK_PAIR, std::pair< T*, U* >);

    pair();
    pair(T* first, U* second);
    pair(const pair& other);

    T* first;
    U* second;
 
#ifdef %alaqil_pair_methods
    // Add alaqil/language extra methods
    %alaqil_pair_methods(std::pair< T*, U* >)
#endif
  };

}
