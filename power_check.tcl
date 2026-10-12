puts "--- Power optimization and clock gate check ---"
puts "BUFGCE cells: [llength [get_cells -hier -filter {REF_NAME == BUFGCE}]]"
puts "Top module: [get_property top [current_fileset]]"
report_clocks
