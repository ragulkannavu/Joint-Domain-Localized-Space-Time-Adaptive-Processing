VIVADO SETUP — JDL-STAP + ZYBO Z7-10 + PMODCLS
Open Vivado Tcl Console at this directory and run:
  source create_vivado_project.tcl
The script creates JDL_STAP_ZyboZ7_PmodCLS for xc7z010clg400-1. The intended
hardware top is zybo_z7_10_jdl_stap_lcd_top and wrapper simulation top is
tb_zybo_dynamic_demo.
Run source run_simulation.tcl to launch the accelerated wrapper simulation.
Run source run_full_flow.tcl to attempt synthesis, implementation and reports.
Check all messages and reports in your Vivado version before programming the
FPGA. The repository upload itself does not certify timing closure or power.
