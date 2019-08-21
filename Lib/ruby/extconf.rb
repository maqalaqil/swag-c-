require 'mkmf'

dir_config('yourlib')

if have_header('yourlib.h') and have_library('yourlib', 'yourlib_init')
  # If you use alaqil -c option, you may have to link libalaqilrb.
  # have_library('alaqilrb')
  create_makefile('yourlib')
end
