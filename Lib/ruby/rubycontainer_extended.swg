/* -----------------------------------------------------------------------------
 * rubycontainer_extended.swg
 *
 * This file contains additional functions that make containers
 * behave closer to ruby primitive types.
 * However, some of these functions place some restrictions on
 * the underlying object inside of the container and the iterator
 * (that it has to have an == comparison function, that it has to have 
 * an = assignment operator, etc).
 * ----------------------------------------------------------------------------- */

/** 
 * Macro used to add extend functions that require operator== in object.
 * 
 * @param Container    STL container
 * @param Type         class inside container
 *
 */
%define %alaqil_container_with_equal_operator( Container, Type )

  VALUE __delete__( const Type& val ) {
    VALUE r = Qnil;
    Container<Type >::iterator e = $self->end();
    Container<Type >::iterator i = std::remove( $self->begin(), e, val );
    // remove dangling elements now
    $self->erase( i, e );
    
    if ( i != e )
      r = alaqil::from< Type >( val );
    else if ( rb_block_given_p() )
      r = rb_yield(Qnil);
    return r;
  }

%enddef  // end of  %alaqil_container_with_equal_operator




/** 
 * Macro used to add extend functions that require the assignment 
 * operator (ie. = ) of contained class
 * 
 * @param Container    STL container
 * @param Type         class inside container
 * 
 */

%define %alaqil_container_with_assignment( Container, Type )


  //
  // map!  -- the equivalent of std::transform
  //
  Container< Type >* map_bang() {

    if ( !rb_block_given_p() )
      rb_raise( rb_eArgError, "No block given" );

    VALUE r = Qnil;
    Container< Type >::iterator i = $self->begin();
    Container< Type >::iterator e = $self->end();

    try {
      for ( ; i != e; ++i )
	{
	  r = alaqil::from< Type >( *i );
	  r = rb_yield( r );
	  *i = alaqil::as< Type >( r );
	}
    }
    catch (const std::invalid_argument&)
      {
	rb_raise(rb_eTypeError,
		 "Yield block did not return a valid element for " "Container");
      }
    
    return $self;
  }


%enddef  // end of  %alaqil_container_with_assignment





/** 
 * Macro used to add all extended functions to a container
 * 
 * @param Container    STL container
 * @param Type         class inside container
 * 
 */
%define %alaqil_container_extend( Container, Type )

%extend Container< Type > {

  %alaqil_container_with_assignment( %arg(Container), Type );
  %alaqil_container_with_equal_operator( %arg(Container), Type );

}

%enddef


/** 
 * Private macro used to add all extended functions to C/C++
 * primitive types
 * 
 * @param Container an STL container, like std::vector (with no class template)
 *
 */
%define %__alaqil_container_extend_primtypes( Container )

%alaqil_container_extend( %arg( Container ), bool );
%alaqil_container_extend( %arg( Container ), char );
%alaqil_container_extend( %arg( Container ), short );
%alaqil_container_extend( %arg( Container ), int );
%alaqil_container_extend( %arg( Container ), unsigned short );
%alaqil_container_extend( %arg( Container ), unsigned int );
%alaqil_container_extend( %arg( Container ), float );
%alaqil_container_extend( %arg( Container ), double );
%alaqil_container_extend( %arg( Container ), std::complex );
%alaqil_container_extend( %arg( Container ), std::string );
%alaqil_container_extend( %arg( Container ), alaqil::GC_VALUE );

%enddef


%__alaqil_container_extend_primtypes( std::vector );
%__alaqil_container_extend_primtypes( std::deque );
%__alaqil_container_extend_primtypes( std::list );

