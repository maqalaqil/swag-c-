TOP        = ../..
alaqilEXE    = $(TOP)/../alaqil
alaqil_LIB_DIR = $(TOP)/../$(TOP_BUILDDIR_TO_TOP_SRCDIR)Lib
INTERFACE  = example.i
SRCS       =
CXXSRCS    = example.cxx
TARGET     = class
INCLUDE    =
alaqilOPT    =
VARIANT    =

# uncomment the following lines to build a static exe (only pick one of the CHICKEN_MAIN lines)
#CHICKEN_MAIN = runme-lowlevel.scm
#CHICKEN_MAIN = runme-tinyclos.scm
#VARIANT    = _static

check: build
	$(MAKE) -f $(TOP)/Makefile SRCDIR='$(SRCDIR)' CHICKEN_SCRIPT='runme-lowlevel.scm' chicken_run
	$(MAKE) -f $(TOP)/Makefile SRCDIR='$(SRCDIR)' CHICKEN_SCRIPT='runme-tinyclos.scm' chicken_run

build: $(TARGET) $(TARGET)_proxy

$(TARGET): $(INTERFACE) $(SRCS)
	$(MAKE) -f $(TOP)/Makefile SRCDIR='$(SRCDIR)' \
	SRCS='$(SRCS)' CXXSRCS='$(CXXSRCS)' CHICKEN_MAIN='$(CHICKEN_MAIN)' \
	alaqil_LIB_DIR='$(alaqil_LIB_DIR)' alaqilEXE='$(alaqilEXE)' \
	INCLUDE='$(INCLUDE)' alaqilOPT='$(alaqilOPT)' TARGET='$(TARGET)' \
	INTERFACE='$(INTERFACE)' CHICKENOPTS='$(CHICKENOPTS)' chicken$(VARIANT)_cpp

$(TARGET)_proxy: $(INTERFACE) $(SRCS)
	$(MAKE) -f $(TOP)/Makefile SRCDIR='$(SRCDIR)' \
	SRCS='$(SRCS)' CXXSRCS='$(CXXSRCS)' CHICKEN_MAIN='$(CHICKEN_MAIN)' \
	alaqil_LIB_DIR='$(alaqil_LIB_DIR)' alaqilEXE='$(alaqilEXE)' \
	INCLUDE='$(INCLUDE)' alaqilOPT='$(alaqilOPT) -proxy' TARGET='$(TARGET)_proxy' \
	INTERFACE='$(INTERFACE)' CHICKENOPTS='$(CHICKENOPTS)' chicken$(VARIANT)_cpp

clean:
	$(MAKE) -f $(TOP)/Makefile SRCDIR='$(SRCDIR)' chicken_clean
	rm -f example.scm
	rm -f $(TARGET)
