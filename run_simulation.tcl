# Run the accelerated Zybo wrapper/LCD UART simulation.
set root [file normalize [file dirname [info script]]]
cd $root
source [file join $root create_vivado_project.tcl]
set_property top tb_zybo_dynamic_demo [get_filesets sim_1]
set_property xsim.simulate.runtime 40ms [get_filesets sim_1]
launch_simulation
run all
close_sim
puts "Wrapper/LCD UART simulation completed. Inspect pmodcls_tx and testbench console output."
