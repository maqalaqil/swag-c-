## Process this file with automake to produce Makefile.in

# subdir-objects generates object files using the directory structure of the source files.
AUTOMAKE_OPTIONS = foreign nostdinc subdir-objects 1.7.2

SOURCE_DIR=$(top_srcdir)/Source
BUILD_SOURCE_DIR=$(top_builddir)/Source

alaqil_CXX_DEFS = @SWILL@

AM_CPPFLAGS =	-I$(BUILD_SOURCE_DIR)/Include	\
		-I$(BUILD_SOURCE_DIR)/CParse	\
		-I$(SOURCE_DIR)/Include		\
		-I$(SOURCE_DIR)/DOH		\
		-I$(SOURCE_DIR)/CParse		\
		-I$(SOURCE_DIR)/Doxygen		\
		-I$(SOURCE_DIR)/Preprocessor	\
		-I$(SOURCE_DIR)/alaqil		\
		-I$(SOURCE_DIR)/Modules

AM_CXXFLAGS =	$(alaqil_CXX_DEFS)

AM_YFLAGS = -d

BUILT_SOURCES = CParse/parser.h
ealaqil_SOURCES =	CParse/cscanner.c		\
		CParse/parser.y			\
		CParse/templ.c			\
		CParse/util.c			\
		DOH/base.c			\
		DOH/file.c			\
		DOH/fio.c			\
		DOH/hash.c			\
		DOH/list.c			\
		DOH/memory.c			\
		DOH/string.c			\
		DOH/void.c			\
		Doxygen/doxyentity.cxx		\
		Doxygen/doxyentity.h		\
		Doxygen/doxyparser.cxx		\
		Doxygen/doxyparser.h		\
		Doxygen/doxytranslator.cxx	\
		Doxygen/doxytranslator.h	\
		Doxygen/javadoc.cxx		\
		Doxygen/javadoc.h		\
		Doxygen/pydoc.cxx		\
		Doxygen/pydoc.h			\
		Modules/allocate.cxx		\
		Modules/browser.cxx		\
		Modules/contract.cxx		\
		Modules/csharp.cxx		\
		Modules/d.cxx			\
		Modules/directors.cxx		\
		Modules/emit.cxx		\
		Modules/go.cxx			\
		Modules/guile.cxx		\
		Modules/interface.cxx		\
		Modules/java.cxx		\
		Modules/javascript.cxx		\
		Modules/lang.cxx		\
		Modules/lua.cxx			\
		Modules/main.cxx		\
		Modules/mzscheme.cxx		\
		Modules/nested.cxx		\
		Modules/ocaml.cxx		\
		Modules/octave.cxx		\
		Modules/overload.cxx		\
		Modules/perl5.cxx		\
		Modules/php.cxx			\
		Modules/python.cxx		\
		Modules/r.cxx			\
		Modules/ruby.cxx		\
		Modules/scilab.cxx		\
		Modules/alaqilmain.cxx		\
		Modules/tcl8.cxx		\
		Modules/typepass.cxx		\
		Modules/utils.cxx		\
		Modules/xml.cxx			\
		Preprocessor/cpp.c		\
		Preprocessor/expr.c		\
		alaqil/cwrap.c			\
		alaqil/deprecate.c		\
		alaqil/error.c			\
		alaqil/extend.c			\
		alaqil/fragment.c			\
		alaqil/getopt.c			\
		alaqil/include.c			\
		alaqil/misc.c			\
		alaqil/naming.c			\
		alaqil/parms.c			\
		alaqil/scanner.c			\
		alaqil/stype.c			\
		alaqil/symbol.c			\
		alaqil/tree.c			\
		alaqil/typemap.c			\
		alaqil/typeobj.c			\
		alaqil/typesys.c			\
		alaqil/wrapfunc.c

bin_PROGRAMS = ealaqil
ealaqil_LDADD   = @alaqilLIBS@

# Override the link stage to avoid using Libtool
CXXLINK = $(CXXLD) $(AM_CXXFLAGS) $(CXXFLAGS) $(AM_LDFLAGS) $(LDFLAGS) -o $@

# The executable is copied to the root directory for installation and running the test-suite.
# This occurs on each invocation of make and is a step towards providing support for multiple
# build directories.
all-local: ealaqil@EXEEXT@
	cp -f $(top_builddir)/Source/ealaqil@EXEEXT@ $(top_builddir)/alaqil@EXEEXT@

clean-local:
	rm -f $(top_builddir)/alaqil@EXEEXT@
	rm -f core @EXTRA_CLEAN@

distclean-local:
	rm -f $(top_builddir)/Source/Include/alaqilconfig.h
	rm -f $(top_builddir)/Source/Include/stamp-h1

# Beautify the code.
# Note that this works well on C code, but does some odd joining of lines for C++ code.
# Compiling with -DNDEBUG and no optimisations will allow one to do a binary diff of the
# alaqil executable as a way of checking before and after the 'beautifying'.
# Single files can be beautified with the beautify-file target, eg: 'make beautify-file INDENTFILE=chosenfile.c'

alaqilTYPEDEFS=-T bool -T File -T DohObjInfo -T Parm -T Language -T List -T TargetLanguageModule -T Typetab -T ModuleFactory -T ErrorMessageFormat -T Symtab -T Hash -T Scanner -T String -T DohBase -T Node -T String_or_char -T alaqilType -T Dispatcher -T Wrapper -T DohStringMethods -T DohFileMethods -T DohListMethods -T DohHashMethods -T DOH -T DohIterator -T ParmList -T FILE -T HashNode -T DOHObj_or_char -T DOHFile -T DOHString -T DOHString_or_char -T UpcallData
INDENTBAKSDIR=../IndentBaks

beautify:
	rm -rf $(INDENTBAKSDIR)
	mkdir $(INDENTBAKSDIR)
	mkdir $(INDENTBAKSDIR)/CParse
	mkdir $(INDENTBAKSDIR)/DOH
	mkdir $(INDENTBAKSDIR)/Modules
	mkdir $(INDENTBAKSDIR)/Preprocessor
	mkdir $(INDENTBAKSDIR)/alaqil
	mkdir $(INDENTBAKSDIR)/Include
	(csources=`find . -name "*.c"` && \
	hsources=`find . -name "*.h"` && \
	cxxsources=`find . -name "*.cxx"` && \
	for file in $$csources $$hsources $$cxxsources; do \
	  $(MAKE) beautify-file INDENTFILE=$$file; \
	done; )

beautify-file:
	test -e $(INDENTBAKSDIR) || (echo $(INDENTBAKSDIR) directory does not exist && exit 1;)
	test -n "$(INDENTFILE)" || (echo INDENTFILE not defined && exit 1;)
	test -e $(INDENTFILE) || (echo File does not exist: $(INDENTFILE) && exit 1;)
	cp $(INDENTFILE) $(INDENTBAKSDIR)/$(INDENTFILE);
	indent -kr --honour-newlines --line-length160 --indent-level2 --braces-on-func-def-line --leave-optional-blank-lines $(alaqilTYPEDEFS) $(INDENTFILE) -o $(INDENTFILE).tmp;
	cat $(INDENTFILE).tmp | sed -e 's/const const /const /' > $(INDENTFILE);
	rm $(INDENTFILE).tmp;
