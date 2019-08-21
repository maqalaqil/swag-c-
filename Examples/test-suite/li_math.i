%module li_math
#ifdef alaqilPHP
// PHP already provides these functions with the same names, so just kill that
// warning.
%warnfilter(alaqilWARN_PARSE_KEYWORD);
#endif
%include math.i
