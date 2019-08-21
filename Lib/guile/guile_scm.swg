/* -----------------------------------------------------------------------------
 * guile_scm.swg
 *
 * This alaqil interface file is processed if the Guile module is run
 * with SCM_ flavor.
 * ----------------------------------------------------------------------------- */

#define alaqilGUILE_SCM

%runtime "alaqilrun.swg"       // Common C API type-checking code
%runtime "alaqilerrors.swg"    // alaqil errors

%runtime "guile_scm_run.swg"
%include <guile.i>

%runtime %{

#define GUILE_MAYBE_VALUES \
      if (galaqil_list_p) galaqil_result = scm_values(galaqil_result);

#define GUILE_MAYBE_VECTOR \
      if (galaqil_list_p) galaqil_result = scm_vector(galaqil_result);

#define alaqil_APPEND_VALUE(object)						\
    if (galaqil_result == SCM_UNSPECIFIED)						\
        galaqil_result = object;							\
    else {									\
      if (!galaqil_list_p) {							\
	      galaqil_list_p = 1;							\
	      galaqil_result = scm_list_n(galaqil_result, object, SCM_UNDEFINED);	\
      }									\
      else									\
            galaqil_result = scm_append(scm_list_n(galaqil_result, scm_list_n(object, SCM_UNDEFINED), SCM_UNDEFINED));		\
    }

%}

%insert(init) "alaqilinit.swg"

%init %{
alaqil_GUILE_INIT_STATIC void
alaqil_init(void)
{
  alaqil_InitializeModule(0);
  alaqil_PropagateClientData();
%}
