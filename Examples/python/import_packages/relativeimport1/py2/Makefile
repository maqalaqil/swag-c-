TOP        = ../../../..
alaqilOPT    =
LIBS       =

build:
	cd pkg2 && $(MAKE) alaqilOPT='$(alaqilOPT)' LIBS='$(LIBS)' build

static:
	cd pkg2 && $(MAKE) alaqilOPT='$(alaqilOPT)' LIBS='$(LIBS)' static

clean:
	$(MAKE) -f $(TOP)/Makefile SRCDIR='$(SRCDIR)' python_clean
	cd pkg2 && $(MAKE) clean
