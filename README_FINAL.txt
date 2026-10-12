JDL-STAP Zybo Z7-10 + PmodCLS Faculty Demo

Hardware top: zybo_z7_10_jdl_stap_lcd_top
UART: 9600 baud, 8-N-1. LCD refresh: approximately 3 seconds.
Synthetic target scenarios update approximately every 5 seconds.

PmodCLS wiring:
- Zybo JD pin 1 / FPGA T14 -> PmodCLS J2 pin 4 / RXD
- Zybo JD pin 5 -> PmodCLS J2 pin 5 / GND
- Zybo JD pin 6 / 3.3 V -> PmodCLS J2 pin 6 / VCC
- Configure logical MD2/MD1/MD0 = 0/1/0 for 9600 baud.
Follow the PmodCLS revision manual for physical jumper orientation.

This is a synthetic digital demo with no RF/ADC input and no physical range
measurement. FAR/CLOSER are display scenario labels. Doppler output is an FFT
bin; physical velocity needs radar parameters. The complex coefficient shown
is a scaled FFT peak result.

Use create_vivado_project.tcl, run_simulation.tcl, and run_full_flow.tcl from
Vivado. Verify synthesis, timing, implementation and power reports before use.
