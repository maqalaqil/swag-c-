/* -----------------------------------------------------------------------------
 * director_common.swg
 *
 * This file contains support for director classes which is common between
 * languages.
 * ----------------------------------------------------------------------------- */

/*
  Use -Dalaqil_DIRECTOR_STATIC if you prefer to avoid the use of the
  'alaqil' namespace. This could be useful for multi-modules projects.
*/
#ifdef alaqil_DIRECTOR_STATIC
/* Force anonymous (static) namespace */
#define alaqil
#endif
