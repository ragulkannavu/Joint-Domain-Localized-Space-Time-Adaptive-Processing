puts "--- Power design checks ---"
puts "BUFGCE count: [llength [get_cells -hier -filter {REF_NAME == BUFGCE}]]"
puts "Core clock gate cell: [get_cells -hier U_CORE_CLK_GATE -quiet]"
puts "Top: [get_property top [current_fileset]]"
report_clocks
