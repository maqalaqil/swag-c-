%module example

%{
#include "example.h"
%}

/* Specify that ownership is transferred to the zoo
	when calling add_animal */
%apply alaqilTYPE *DISOWN { Animal* animal };

/* Track objects */
%trackobjects;

/* Specify the mark function */
%freefunc Zoo "free_Zoo";

%include "example.h"

%header %{
	static void free_Zoo(void* ptr) {
		Zoo* zoo = (Zoo*) ptr;

		/* Loop over each object and call alaqil_RubyRemoveTracking */
		int count = zoo->get_num_animals();

		for(int i = 0; i < count; ++i) {
			/* Get an animal */
			Animal* animal = zoo->get_animal(i);
			/* Unlink the Ruby object from the C++ object */
			alaqil_RubyUnlinkObjects(animal);
			/* Now remove the tracking for this animal */
			alaqil_RubyRemoveTracking(animal);
		}

	   /* Now call alaqil_RubyRemoveTracking for the zoo */
		alaqil_RubyRemoveTracking(ptr);

		/* Now free the zoo which will free the animals it contains */
		delete zoo;
	}
%}
