TOP        = ../..
alaqilEXE    = $(TOP)/../alaqil
alaqil_LIB_DIR = $(TOP)/../$(TOP_BUILDDIR_TO_TOP_SRCDIR)Lib
TARGET     = embed3
SRCS       = example.cpp
INTERFACE  = example.i
LUA_INTERP = embed3.cpp

# this is a little different to normal as we have our own special interpreter
# which we want to static link
# we also need the external runtime, so we can get access to certain internals of alaqil
check: build
	$(MAKE) -f $(TOP)/Makefile SRCDIR='$(SRCDIR)' TARGET='$(TARGET)' lua_embed_run

build:
	$(MAKE) -f $(TOP)/Makefile SRCDIR='$(SRCDIR)' \
	alaqil_LIB_DIR='$(alaqil_LIB_DIR)' alaqilEXE='$(alaqilEXE)' \
	lua_externalhdr
	$(MAKE) -f $(TOP)/Makefile SRCDIR='$(SRCDIR)' SRCS='$(SRCS)' \
	alaqil_LIB_DIR='$(alaqil_LIB_DIR)' alaqilEXE='$(alaqilEXE)' \
	alaqilOPT='$(alaqilOPT)' TARGET='$(TARGET)' INTERFACE='example.i' LUA_INTERP='$(LUA_INTERP)' lua_static_cpp

clean:
	$(MAKE) -f $(TOP)/Makefile SRCDIR='$(SRCDIR)' lua_clean
	rm -f alaqilluarun.h $(TARGET)
