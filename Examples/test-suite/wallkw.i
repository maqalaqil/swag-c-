%module wallkw

// test the -Wallkw option

%warnfilter(alaqilWARN_PARSE_KEYWORD) clone; // 'clone' is a PHP keyword, renaming to 'c_clone'
%warnfilter(alaqilWARN_PARSE_KEYWORD) delegate; // 'delegate' is a C# keyword, renaming to '_delegate'
%warnfilter(alaqilWARN_PARSE_KEYWORD) pass; // 'pass' is a python keyword, renaming to '_pass'
%warnfilter(alaqilWARN_PARSE_KEYWORD) alias; // 'alias' is a D keyword, renaming to '_alias'
%warnfilter(alaqilWARN_PARSE_KEYWORD) rescue; // 'rescue' is a ruby keyword, renaming to 'C_rescue'

%inline %{
const char * clone() { return "clone"; }
const char * delegate() { return "delegate"; }
const char * pass() { return "pass"; }
const char * alias() { return "alias"; }
const char * rescue() { return "rescue"; }
%}

