set fs [current_fileset]
puts "DESIGN TOP = [get_property top $fs]"
puts "DESIGN SOURCES:"
foreach f [get_files -of_objects $fs] { puts "  $f" }
set sim [get_filesets sim_1]
puts "SIM TOP = [get_property top $sim]"
puts "SIM SOURCES:"
foreach f [get_files -of_objects $sim] { puts "  $f" }
puts "CONSTRAINTS:"
foreach f [get_files -of_objects [get_filesets constrs_1]] { puts "  $f" }
