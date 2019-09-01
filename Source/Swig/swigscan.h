/* ----------------------------------------------------------------------------- 
 * This file is part of alaqil, which is licensed as a whole under version 3 
 * (or any later version) of the GNU General Public License. Some additional
 * terms also apply to certain portions of alaqil. The full details of the alaqil
 * license and copyrights can be found in the LICENSE and COPYRIGHT files
 * included with the alaqil source code as distributed by the alaqil developers
 * and at http://www.alaqil.org/legal.html.
 *
 * alaqilscan.h
 *
 * C/C++ scanner. 
 * ----------------------------------------------------------------------------- */

typedef struct Scanner Scanner;

extern Scanner     *NewScanner(void);
extern void         DelScanner(Scanner *);
extern void         Scanner_clear(Scanner *);
extern void         Scanner_push(Scanner *, String *);
extern void         Scanner_pushtoken(Scanner *, int, const_String_or_char_ptr value);
extern int          Scanner_token(Scanner *);
extern String      *Scanner_text(Scanner *);
extern void         Scanner_skip_line(Scanner *);
extern int          Scanner_skip_balanced(Scanner *, int startchar, int endchar);
extern String      *Scanner_get_raw_text_balanced(Scanner *, int startchar, int endchar);
extern void         Scanner_set_location(Scanner *, String *file, int line);
extern String      *Scanner_file(Scanner *);
extern int          Scanner_line(Scanner *);
extern int          Scanner_start_line(Scanner *);
extern void         Scanner_idstart(Scanner *, const char *idchar);
extern String      *Scanner_errmsg(Scanner *);
extern int          Scanner_errline(Scanner *);
extern int          Scanner_isoperator(int tokval);
extern void         Scanner_locator(Scanner *, String *loc);

/* Note: Tokens in range 100+ are for C/C++ operators */

#define   alaqil_MAXTOKENS          200
#define   alaqil_TOKEN_LPAREN       1        /* ( */
#define   alaqil_TOKEN_RPAREN       2        /* ) */
#define   alaqil_TOKEN_SEMI         3        /* ; */
#define   alaqil_TOKEN_LBRACE       4        /* { */
#define   alaqil_TOKEN_RBRACE       5        /* } */
#define   alaqil_TOKEN_LBRACKET     6        /* [ */
#define   alaqil_TOKEN_RBRACKET     7        /* ] */
#define   alaqil_TOKEN_BACKSLASH    8        /* \ */
#define   alaqil_TOKEN_ENDLINE      9        /* \n */
#define   alaqil_TOKEN_STRING       10       /* "str" */
#define   alaqil_TOKEN_POUND        11       /* # */
#define   alaqil_TOKEN_COLON        12       /* : */
#define   alaqil_TOKEN_DCOLON       13       /* :: */
#define   alaqil_TOKEN_DCOLONSTAR   14       /* ::* */
#define   alaqil_TOKEN_ID           15       /* identifier */
#define   alaqil_TOKEN_FLOAT        16       /* 3.1415F */
#define   alaqil_TOKEN_DOUBLE       17       /* 3.1415 */
#define   alaqil_TOKEN_INT          18       /* 314 */
#define   alaqil_TOKEN_UINT         19       /* 314U */
#define   alaqil_TOKEN_LONG         20       /* 314L */
#define   alaqil_TOKEN_ULONG        21       /* 314UL */
#define   alaqil_TOKEN_CHAR         22       /* 'charconst' */
#define   alaqil_TOKEN_PERIOD       23       /* . */
#define   alaqil_TOKEN_AT           24       /* @ */
#define   alaqil_TOKEN_DOLLAR       25       /* $ */
#define   alaqil_TOKEN_CODEBLOCK    26       /* %{ ... %} ... */
#define   alaqil_TOKEN_RSTRING      27       /* `charconst` */
#define   alaqil_TOKEN_LONGLONG     28       /* 314LL */
#define   alaqil_TOKEN_ULONGLONG    29       /* 314ULL */
#define   alaqil_TOKEN_QUESTION     30       /* ? */
#define   alaqil_TOKEN_COMMENT      31       /* C or C++ comment */
#define   alaqil_TOKEN_BOOL         32       /* true or false */
#define   alaqil_TOKEN_WSTRING      33       /* L"str" */
#define   alaqil_TOKEN_WCHAR        34       /* L'c' */

#define   alaqil_TOKEN_ILLEGAL      99
#define   alaqil_TOKEN_ERROR        -1

#define   alaqil_TOKEN_COMMA        101      /* , */
#define   alaqil_TOKEN_STAR         102      /* * */
#define   alaqil_TOKEN_TIMES        102      /* * */
#define   alaqil_TOKEN_EQUAL        103      /* = */
#define   alaqil_TOKEN_EQUALTO      104      /* == */
#define   alaqil_TOKEN_NOTEQUAL     105      /* != */
#define   alaqil_TOKEN_PLUS         106      /* + */
#define   alaqil_TOKEN_MINUS        107      /* - */
#define   alaqil_TOKEN_AND          108      /* & */
#define   alaqil_TOKEN_LAND         109      /* && */
#define   alaqil_TOKEN_OR           110      /* | */
#define   alaqil_TOKEN_LOR          111      /* || */
#define   alaqil_TOKEN_XOR          112      /* ^ */
#define   alaqil_TOKEN_LESSTHAN     113      /* < */
#define   alaqil_TOKEN_GREATERTHAN  114      /* > */
#define   alaqil_TOKEN_LTEQUAL      115      /* <= */
#define   alaqil_TOKEN_GTEQUAL      116      /* >= */
#define   alaqil_TOKEN_NOT          117      /* ~ */
#define   alaqil_TOKEN_LNOT         118      /* ! */
#define   alaqil_TOKEN_SLASH        119      /* / */
#define   alaqil_TOKEN_DIVIDE       119      /* / */
#define   alaqil_TOKEN_PERCENT      120      /* % */
#define   alaqil_TOKEN_MODULO       120      /* % */
#define   alaqil_TOKEN_LSHIFT       121      /* << */
#define   alaqil_TOKEN_RSHIFT       122      /* >> */
#define   alaqil_TOKEN_PLUSPLUS     123      /* ++ */
#define   alaqil_TOKEN_MINUSMINUS   124      /* -- */
#define   alaqil_TOKEN_PLUSEQUAL    125      /* += */
#define   alaqil_TOKEN_MINUSEQUAL   126      /* -= */
#define   alaqil_TOKEN_TIMESEQUAL   127      /* *= */
#define   alaqil_TOKEN_DIVEQUAL     128      /* /= */
#define   alaqil_TOKEN_ANDEQUAL     129      /* &= */
#define   alaqil_TOKEN_OREQUAL      130      /* |= */
#define   alaqil_TOKEN_XOREQUAL     131      /* ^= */
#define   alaqil_TOKEN_LSEQUAL      132      /* <<= */
#define   alaqil_TOKEN_RSEQUAL      133      /* >>= */
#define   alaqil_TOKEN_MODEQUAL     134      /* %= */
#define   alaqil_TOKEN_ARROW        135      /* -> */
#define   alaqil_TOKEN_ARROWSTAR    136      /* ->* */
