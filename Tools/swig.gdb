# User-defined commands for easier debugging of alaqil in gdb
#
# This file can be "included" into your main .gdbinit file using:
# source alaqil.gdb
# or otherwise paste the contents into .gdbinit
#
# Note all user defined commands can be seen using:
# (gdb) show user
# The documentation for each command can be easily viewed, for example:
# (gdb) help alaqilprint

define alaqilprint
    if ($argc == 2)
        set $expand_count = $arg1
    else
        set $expand_count = -1
    end
    printf "%s\n", alaqil_to_string($arg0, $expand_count)
end
document alaqilprint
Displays any alaqil DOH object
Usage: alaqilprint alaqilobject [hashexpandcount]
  alaqilobject      - The object to display.
  hashexpandcount - Number of nested Hash types to expand (default is 1). See alaqil_set_max_hash_expand() to change default.
end


define localaqilprint
    if ($argc == 2)
        set $expand_count = $arg1
    else
        set $expand_count = -1
    end
    printf "%s\n", alaqil_to_string_with_location($arg0, $expand_count)
end
document localaqilprint
Displays any alaqil DOH object prefixed with file and line location
Usage: localaqilprint alaqilobject [hashexpandcount]
  alaqilobject      - The object to display.
  hashexpandcount - Number of nested Hash types to expand (default is 1). See alaqil_set_max_hash_expand() to change default.
end
