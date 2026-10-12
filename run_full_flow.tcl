# Run with: vivado -mode batch -source run_full_flow.tcl
set root [file normalize [file dirname [info script]]]
cd $root
source [file join $root create_vivado_project.tcl]
set out [file join $root results]
file mkdir $out
set_property strategy Flow_PerfOptimized_high [get_runs synth_1]
launch_runs synth_1 -jobs 2
wait_on_run synth_1
if {[get_property STATUS [get_runs synth_1]] ne "synth_design Complete!"} {
 puts "Synthesis status: [get_property STATUS [get_runs synth_1]]"
 error "Synthesis unsuccessful"
}
open_run synth_1
report_utilization -hierarchical -file [file join $out synth_util_hier.rpt]
report_timing_summary -file [file join $out synth_timing.rpt]
report_power -file [file join $out synth_power.rpt]
close_design
launch_runs impl_1 -to_step route_design -jobs 2
wait_on_run impl_1
set status [get_property STATUS [get_runs impl_1]]
puts "Implementation status: $status"
if {![string match "*Complete*" $status]} {error "Implementation failed: $status"}
open_run impl_1
report_utilization -hierarchical -file [file join $out impl_util_hier.rpt]
report_timing_summary -file [file join $out impl_timing.rpt]
report_drc -file [file join $out impl_drc.rpt]
reset_switching_activity -all
set_switching_activity -default_toggle_rate 2.0 -default_static_probability 0.5
report_power -file [file join $out impl_power_ESTIMATE.rpt]
puts "DONE. Inspect results under $out before attempting bitstream generation."
