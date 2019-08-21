# File : Makefile.alaqil
# Makefile for a alaqil module.  Use this file if you are
# producing a Ruby extension for general use or distribution.
#
# 1.  Prepare extconf.rb.
# 2.  Modify this file as appropriate.
# 3.  Type 'make -f Makefile.alaqil' to generate wrapper code and Makefile.
# 4.  Type 'make' to build your extension.
# 5.  Type 'make install' to install your extension.
#

MODULE    = yourmodule
FEATURE   = $(MODULE)
INTERFACE = $(MODULE).i
RUBY      = ruby
alaqil      = alaqil

# for C extension
alaqilOPT   = -ruby
WRAPPER   = $(MODULE)_wrap.c

## for C++ extension
#alaqilOPT   = -ruby -c++
#WRAPPER   = $(MODULE)_wrap.cc


alaqilall: $(WRAPPER) Makefile

$(WRAPPER): $(INTERFACE)
	$(alaqil) $(alaqilOPT) -o $@ $(INTERFACE)

Makefile: extconf.rb
	$(RUBY) extconf.rb
	@if [ -f Makefile ] ; then\
		echo "include Makefile.alaqil" >> Makefile;\
	fi

alaqilclean:
	@if [ -f Makefile ] ; then\
		make -f Makefile clean;\
	fi
	rm -f Makefile $(WRAPPER)
