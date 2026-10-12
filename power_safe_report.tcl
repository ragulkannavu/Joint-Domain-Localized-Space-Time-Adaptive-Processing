# Run after implementation with the implemented design open.
catch {set_property STEPS.POWER_OPT_DESIGN.IS_ENABLED true [get_runs impl_1]}
reset_switching_activity -all
set_switching_activity -default_toggle_rate 2.0 -default_static_probability 0.5
catch {set_switching_activity -static_probability 1.0 -toggle_rate 0 [get_ports btn_reset]}
catch {set_switching_activity -static_probability 0.5 -toggle_rate 0.2 [get_ports pmodcls_tx]}
catch {set_switching_activity -static_probability 0.5 -toggle_rate 0.1 [get_ports led_detected]}
catch {set_switching_activity -static_probability 0.5 -toggle_rate 0.1 [get_ports led_done]}
catch {power_opt_design}
report_utilization -file power_safe_utilization.rpt
report_power -file power_safe_report.rpt
report_switching_activity -file power_safe_switching_activity.rpt
puts "Power report generated. Use representative SAIF activity for sign-off."
