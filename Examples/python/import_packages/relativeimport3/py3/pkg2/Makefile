TOP        = ../../../../..
alaqilEXE    = $(TOP)/../alaqil
alaqil_LIB_DIR = $(TOP)/../$(TOP_BUILDDIR_TO_TOP_SRCDIR)Lib
alaqilOPT    =
LIBS       =

build:
	$(MAKE) -f $(TOP)/Makefile SRCDIR='$(SRCDIR)' \
	alaqil_LIB_DIR='$(alaqil_LIB_DIR)' alaqilEXE='$(alaqilEXE)' \
	alaqilOPT='$(alaqilOPT)' LIBS='$(LIBS)' TARGET='bar' INTERFACE='bar.i' python_cpp
	cd pkg3 && $(MAKE) alaqilOPT='$(alaqilOPT)' LIBS='$(LIBS)' build

static:
	$(MAKE) -f $(TOP)/Makefile SRCDIR='$(SRCDIR)' \
	alaqil_LIB_DIR='$(alaqil_LIB_DIR)' alaqilEXE='$(alaqilEXE)' \
	alaqilOPT='$(alaqilOPT)' LIBS='$(LIBS)' TARGET='bar' INTERFACE='bar.i' python_cpp
	cd pkg3 && $(MAKE) alaqilOPT='$(alaqilOPT)' LIBS='$(LIBS)' static

clean:
	$(MAKE) -f $(TOP)/Makefile SRCDIR='$(SRCDIR)' TARGET='bar' python_clean
	cd pkg3 && $(MAKE) clean
