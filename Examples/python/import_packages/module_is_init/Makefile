TOP        = ../../..
LIBS       =

check: build
	$(MAKE) -f $(TOP)/Makefile SRCDIR='$(SRCDIR)' python_run

build:
	cd pkg1 && $(MAKE) alaqilOPT='$(alaqilOPT)' LIBS='$(LIBS)' build

static:
	cd pkg1 && $(MAKE) alaqilOPT='$(alaqilOPT)' LIBS='$(LIBS)' static

clean:
	$(MAKE) -f $(TOP)/Makefile SRCDIR='$(SRCDIR)' python_clean
	cd pkg1 && $(MAKE) clean
