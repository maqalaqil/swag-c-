/*
  Include the internal alaqil macro codes. These macros correspond to
  the one found in Source/Include/alaqilwarn.h plus the 'alaqil' prefix.
  
  For example, in the include file 'alaqilwarn.h' you will find

    #define WARN_TYPEMAP_CHARLEAK ...

  and in the 'alaqilwarn.swg' interface, you will see

    %define alaqilWARN_TYPEMAP_CHARLEAK ...

  This code can be used in warning filters as follows:

    %warnfilter(alaqilWARN_TYPEMAP_CHARLEAK);

  Warnings messages used in typemaps. Message names will be the same
  as those in Lib/alaqilwarn.swg but with the suffix _MSG.
   
  For example, for the code alaqilWARN_TYPEMAP_CHARLEAK, once you use

    %typemapmsg(CHARLEAK,<msg>);

  you use the message in your typemap as

    %typemap(varin,warning=alaqilWARN_TYPEMAP_CHARLEAK_MSG) char * 

  while you suppress the warning using

    %warnfilter(alaqilWARN_TYPEMAP_CHARLEAK);

  as described above.
*/

/* -----------------------------------------------------------------------------
 * alaqil warning codes
 * ----------------------------------------------------------------------------- */

%include <alaqilwarn.swg>

/* -----------------------------------------------------------------------------
 * Auxiliary macros
 * ----------------------------------------------------------------------------- */

/* Macro to define warning messages */
#define %_warningmsg(Val, Msg...) `Val`":"Msg 
#define %warningmsg(Val, Msg...) %_warningmsg(Val, Msg)

/* -----------------------------------------------------------------------------
 *  Typemap related warning messages
 * ----------------------------------------------------------------------------- */

%define alaqilWARN_TYPEMAP_CHARLEAK_MSG         "451:Setting a const char * variable may leak memory." %enddef
%define alaqilWARN_TYPEMAP_alaqilTYPELEAK_MSG     "454:Setting a pointer/reference variable may leak memory." %enddef
%define alaqilWARN_TYPEMAP_THREAD_UNSAFE_MSG    "470:Thread/reentrant unsafe wrapping, consider returning by value instead." %enddef
%define alaqilWARN_TYPEMAP_DIRECTOROUT_PTR_MSG  "473:Returning a pointer or reference in a director method is not recommended." %enddef
%define alaqilWARN_TYPEMAP_INITIALIZER_LIST_MSG "476:Initialization using std::initializer_list." %enddef

/* -----------------------------------------------------------------------------
 * Operator related warning messages 
 * ----------------------------------------------------------------------------- */

%define alaqilWARN_IGNORE_OPERATOR_NEW_MSG        "350:operator new ignored"  %enddef
%define alaqilWARN_IGNORE_OPERATOR_DELETE_MSG     "351:operator delete ignored"  %enddef
%define alaqilWARN_IGNORE_OPERATOR_PLUS_MSG       "352:operator+ ignored"  %enddef
%define alaqilWARN_IGNORE_OPERATOR_MINUS_MSG      "353:operator- ignored"  %enddef
%define alaqilWARN_IGNORE_OPERATOR_MUL_MSG        "354:operator* ignored"  %enddef
%define alaqilWARN_IGNORE_OPERATOR_DIV_MSG        "355:operator/ ignored"  %enddef
%define alaqilWARN_IGNORE_OPERATOR_MOD_MSG        "356:operator% ignored"  %enddef
%define alaqilWARN_IGNORE_OPERATOR_XOR_MSG        "357:operator^ ignored"  %enddef
%define alaqilWARN_IGNORE_OPERATOR_AND_MSG        "358:operator& ignored"  %enddef
%define alaqilWARN_IGNORE_OPERATOR_OR_MSG         "359:operator| ignored"  %enddef
%define alaqilWARN_IGNORE_OPERATOR_NOT_MSG        "360:operator~ ignored"  %enddef
%define alaqilWARN_IGNORE_OPERATOR_LNOT_MSG       "361:operator! ignored"  %enddef
%define alaqilWARN_IGNORE_OPERATOR_EQ_MSG         "362:operator= ignored"  %enddef
%define alaqilWARN_IGNORE_OPERATOR_LT_MSG         "363:operator< ignored" %enddef
%define alaqilWARN_IGNORE_OPERATOR_GT_MSG         "364:operator> ignored" %enddef
%define alaqilWARN_IGNORE_OPERATOR_PLUSEQ_MSG     "365:operator+= ignored"  %enddef
%define alaqilWARN_IGNORE_OPERATOR_MINUSEQ_MSG    "366:operator-= ignored"  %enddef
%define alaqilWARN_IGNORE_OPERATOR_MULEQ_MSG      "367:operator*= ignored"  %enddef
%define alaqilWARN_IGNORE_OPERATOR_DIVEQ_MSG      "368:operator/= ignored"  %enddef
%define alaqilWARN_IGNORE_OPERATOR_MODEQ_MSG      "369:operator%= ignored"  %enddef
%define alaqilWARN_IGNORE_OPERATOR_XOREQ_MSG      "370:operator^= ignored"  %enddef
%define alaqilWARN_IGNORE_OPERATOR_ANDEQ_MSG      "371:operator&= ignored"  %enddef
%define alaqilWARN_IGNORE_OPERATOR_OREQ_MSG       "372:operator|= ignored"  %enddef
%define alaqilWARN_IGNORE_OPERATOR_LSHIFT_MSG     "373:operator<< ignored" %enddef
%define alaqilWARN_IGNORE_OPERATOR_RSHIFT_MSG     "374:operator>> ignored" %enddef
%define alaqilWARN_IGNORE_OPERATOR_LSHIFTEQ_MSG   "375:operator<<= ignored"  %enddef
%define alaqilWARN_IGNORE_OPERATOR_RSHIFTEQ_MSG   "376:operator>>= ignored"  %enddef
%define alaqilWARN_IGNORE_OPERATOR_EQUALTO_MSG    "377:operator== ignored" %enddef
%define alaqilWARN_IGNORE_OPERATOR_NOTEQUAL_MSG   "378:operator!= ignored"  %enddef
%define alaqilWARN_IGNORE_OPERATOR_LTEQUAL_MSG    "379:operator<= ignored" %enddef
%define alaqilWARN_IGNORE_OPERATOR_GTEQUAL_MSG    "380:operator>= ignored" %enddef
%define alaqilWARN_IGNORE_OPERATOR_LAND_MSG       "381:operator&& ignored"  %enddef
%define alaqilWARN_IGNORE_OPERATOR_LOR_MSG        "382:operator|| ignored"  %enddef
%define alaqilWARN_IGNORE_OPERATOR_PLUSPLUS_MSG   "383:operator++ ignored"  %enddef
%define alaqilWARN_IGNORE_OPERATOR_MINUSMINUS_MSG "384:operator-- ignored"  %enddef
%define alaqilWARN_IGNORE_OPERATOR_COMMA_MSG      "385:operator-- ignored"  %enddef
%define alaqilWARN_IGNORE_OPERATOR_ARROWSTAR_MSG  "386:operator->* ignored"  %enddef
%define alaqilWARN_IGNORE_OPERATOR_ARROW_MSG      "387:operator-> ignored" %enddef
%define alaqilWARN_IGNORE_OPERATOR_CALL_MSG       "388:operator() ignored" %enddef
%define alaqilWARN_IGNORE_OPERATOR_INDEX_MSG      "389:operator[] ignored (consider using %%extend)"  %enddef
%define alaqilWARN_IGNORE_OPERATOR_UPLUS_MSG      "390:operator+ ignored" %enddef
%define alaqilWARN_IGNORE_OPERATOR_UMINUS_MSG     "391:operator- ignored" %enddef
%define alaqilWARN_IGNORE_OPERATOR_UMUL_MSG       "392:operator* ignored" %enddef
%define alaqilWARN_IGNORE_OPERATOR_UAND_MSG       "393:operator& ignored" %enddef
%define alaqilWARN_IGNORE_OPERATOR_NEWARR_MSG     "394:operator new[] ignored"  %enddef
%define alaqilWARN_IGNORE_OPERATOR_DELARR_MSG     "395:operator delete[] ignored"  %enddef
%define alaqilWARN_IGNORE_OPERATOR_REF_MSG        "396:operator*() ignored" %enddef

#define %ignoreoperator(Oper) %ignorewarn(alaqilWARN_IGNORE_OPERATOR_##Oper##_MSG)

/* -----------------------------------------------------------------------------
 * Macros for keyword and built-in names 
 * ----------------------------------------------------------------------------- */

#define %keywordwarn(msg...) %namewarn(%warningmsg(alaqilWARN_PARSE_KEYWORD, msg)) 
#define %builtinwarn(msg...) %namewarn(%warningmsg(alaqilWARN_PARSE_BUILTIN_NAME, msg), %$isfunction)


/* -----------------------------------------------------------------------------
 * Warning filter feature
 * ----------------------------------------------------------------------------- */

#define %_warnfilter(filter...) %feature("warnfilter",`filter`)
#define %warnfilter(filter...) %_warnfilter(filter)



