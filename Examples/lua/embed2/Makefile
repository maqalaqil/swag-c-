TOP        = ../..
alaqilEXE    = $(TOP)/../alaqil
alaqil_LIB_DIR = $(TOP)/../$(TOP_BUILDDIR_TO_TOP_SRCDIR)Lib
TARGET     = embed2
SRCS       = example.c
INTERFACE  = example.i
LUA_INTERP = embed2.c
LIBS       = -lm

# this is a little different to normal as we have our own special interpreter
# which we want to static link
check: build
	$(MAKE) -f $(TOP)/Makefile SRCDIR='$(SRCDIR)' TARGET='$(TARGET)' lua_embed_run

build:
	$(MAKE) -f $(TOP)/Makefile SRCDIR='$(SRCDIR)' $(alaqilLIB) SRCS='$(SRCS)' \
	alaqil_LIB_DIR='$(alaqil_LIB_DIR)' alaqilEXE='$(alaqilEXE)' \
	alaqilOPT='$(alaqilOPT)' TARGET='$(TARGET)' LIBS='$(LIBS)' INTERFACE='example.i' LUA_INTERP='$(LUA_INTERP)' lua_static

clean:
	$(MAKE) -f $(TOP)/Makefile SRCDIR='$(SRCDIR)' lua_clean
	rm -f $(TARGET)
