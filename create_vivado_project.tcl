# Location-independent Vivado project setup for Zybo Z7-10 + PmodCLS.
set script_dir [file normalize [file dirname [info script]]]
set project_name "JDL_STAP_ZyboZ7_PmodCLS"
set project_dir [file join $script_dir "vivado_project"]
set rtl_dir [file join $script_dir "jdl_stap_5ant_complete_sim"]
set top_file [file join $script_dir "zybo_z7_10_jdl_stap_lcd_top.v"]
set lcd_file [file join $script_dir "pmodcls_uart_lcd.v"]
set xdc_file [file join $script_dir "zybo_z7_10_pmodcls.xdc"]
create_project $project_name $project_dir -part xc7z010clg400-1 -force
set rtl_files {}
foreach f [glob -nocomplain -types f [file join $rtl_dir *.v]] {
    if {[file tail $f] ne "tb_jdl_stap_5ant.v"} { lappend rtl_files $f }
}
if {[llength $rtl_files] == 0} { error "No JDL-STAP RTL files found in $rtl_dir" }
add_files -norecurse $rtl_files
add_files -norecurse [list $lcd_file $top_file]
set sim_tb [file join $rtl_dir "tb_jdl_stap_5ant.v"]
if {[file exists $sim_tb]} { add_files -fileset sim_1 -norecurse $sim_tb }
set sim_wrapper_tb [file join $script_dir "tb_zybo_dynamic_demo.v"]
if {[file exists $sim_wrapper_tb]} { add_files -fileset sim_1 -norecurse $sim_wrapper_tb }
add_files -fileset constrs_1 -norecurse $xdc_file
set_property top zybo_z7_10_jdl_stap_lcd_top [current_fileset]
set_property top tb_zybo_dynamic_demo [get_filesets sim_1]
set_property target_language Verilog [current_project]
update_compile_order -fileset sources_1
update_compile_order -fileset sim_1
catch {set_property STEPS.POWER_OPT_DESIGN.IS_ENABLED true [get_runs impl_1]}
puts "Created $project_name for xc7z010clg400-1. Review constraints and run synthesis."
