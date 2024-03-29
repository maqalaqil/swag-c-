# Note: as a convention an example must be in a child directory of this.
# These paths are relative to such an example directory

ifneq (, $(ENGINE))
	JSENGINE=$(ENGINE)
else
	JSENGINE=node
endif

ifneq (, $(V8_VERSION))
	JSV8_VERSION=$(V8_VERSION)
else
	JSV8_VERSION=0x031110
endif

EXAMPLES_TOP   = ../..
alaqil_TOP       = ../../..
alaqilEXE        = $(alaqil_TOP)/alaqil
alaqil_LIB_DIR   = $(alaqil_TOP)/$(TOP_BUILDDIR_TO_TOP_SRCDIR)Lib
TARGET         = example
INTERFACE      = example.i
alaqilOPT        = -$(JSENGINE) -DV8_VERSION=$(JSV8_VERSION)

check: build
	$(MAKE) -f $(EXAMPLES_TOP)/Makefile SRCDIR='$(SRCDIR)' JSENGINE='$(JSENGINE)' TARGET='$(TARGET)' javascript_run

build:
	$(MAKE) -f $(EXAMPLES_TOP)/Makefile SRCDIR='$(SRCDIR)' CXXSRCS='$(SRCS)' \
	alaqil_LIB_DIR='$(alaqil_LIB_DIR)' alaqilEXE='$(alaqilEXE)' \
	alaqilOPT='$(alaqilOPT)' TARGET='$(TARGET)' INTERFACE='$(INTERFACE)' javascript_wrapper_cpp
	$(MAKE) -f $(EXAMPLES_TOP)/Makefile SRCDIR='$(SRCDIR)' CXXSRCS='$(SRCS)' \
	alaqil_LIB_DIR='$(alaqil_LIB_DIR)' alaqilEXE='$(alaqilEXE)' \
	alaqilOPT='$(alaqilOPT)' TARGET='$(TARGET)' INTERFACE='$(INTERFACE)' JSENGINE='$(JSENGINE)' javascript_build_cpp

clean:
	$(MAKE) -f $(EXAMPLES_TOP)/Makefile SRCDIR='$(SRCDIR)' javascript_clean
