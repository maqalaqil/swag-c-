
/* Export the alaqil initialization function */
%header %{
#ifdef __cplusplus
extern "C"
#endif
#ifndef PERL_OBJECT
#ifndef MULTIPLICITY
alaqilEXPORT void alaqil_init (CV* cv);
#else
alaqilEXPORT void alaqil_init (pTHXo_ CV* cv);
#endif
#else
alaqilEXPORT void alaqil_init (CV *cv, CPerlObj *);
#endif
%}

/* Module initialization function */

%insert(init) "alaqilinit.swg"

%init %{

#if defined(__cplusplus) && ! defined(XSPROTO)
extern "C"
#endif

XS(alaqil_init) {
    dXSARGS;
    int i;
    (void)items;

    alaqil_InitializeModule(0);

    /* Install commands */
    for (i = 0; alaqil_commands[i].name; i++) {
      /* Casts only needed for Perl < 5.10. */
#ifdef __cplusplus
      newXS(const_cast<char*>(alaqil_commands[i].name), alaqil_commands[i].wrapper, const_cast<char*>(__FILE__));
#else
      newXS((char*)alaqil_commands[i].name, alaqil_commands[i].wrapper, (char*)__FILE__);
#endif
    }

    /* Install variables */
    for (i = 0; alaqil_variables[i].name; i++) {
      SV *sv;
      sv = get_sv(alaqil_variables[i].name, TRUE | 0x2 | GV_ADDMULTI);
      if (alaqil_variables[i].type) {
	alaqil_MakePtr(sv,(void *)1, *alaqil_variables[i].type,0);
      } else {
	sv_setiv(sv,(IV) 0);
      }
      alaqil_create_magic(sv, alaqil_variables[i].name, alaqil_variables[i].set, alaqil_variables[i].get); 
    }

    /* Install constant */
    for (i = 0; alaqil_constants[i].type; i++) {
      SV *sv;
      sv = get_sv(alaqil_constants[i].name, TRUE | 0x2 | GV_ADDMULTI);
      switch(alaqil_constants[i].type) {
      case alaqil_INT:
	sv_setiv(sv, (IV) alaqil_constants[i].lvalue);
	break;
      case alaqil_FLOAT:
	sv_setnv(sv, (double) alaqil_constants[i].dvalue);
	break;
      case alaqil_STRING:
	sv_setpv(sv, (const char *) alaqil_constants[i].pvalue);
	break;
      case alaqil_POINTER:
	alaqil_MakePtr(sv, alaqil_constants[i].pvalue, *(alaqil_constants[i].ptype),0);
	break;
      case alaqil_BINARY:
	alaqil_MakePackedObj(sv, alaqil_constants[i].pvalue, alaqil_constants[i].lvalue, *(alaqil_constants[i].ptype));
	break;
      default:
	break;
      }
      SvREADONLY_on(sv);
    }
%}
