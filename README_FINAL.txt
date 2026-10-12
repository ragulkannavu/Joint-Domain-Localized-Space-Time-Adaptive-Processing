JDL-STAP Zybo Z7-10 + PmodCLS Faculty Demo

Hardware top: zybo_z7_10_jdl_stap_lcd_top

The FPGA processes synthetic five-antenna data through a two-beam processing
chain and an 8-point Doppler FFT. PmodCLS uses UART 9600 baud, 8-N-1.
Target scenarios update approximately every 5 seconds and LCD refresh is
approximately every 3 seconds.

LCD examples:
1. DETECTED A45 D+3 / X=+85+j32
2. NOT DETECTED / A60 D--
3. FAR A45 D-- / X=+85-j32
4. CLOSER A45 D-- / X=+85+j32

The complex coefficient is derived from the detected FFT peak and scaled for
display. FAR/CLOSER are demo labels, not range measurements. The 60-degree
NOT DETECTED case is outside the two supported steering directions (2 and 45
degrees). There is no physical RF/ADC input and no physical range estimation.

PmodCLS wiring:
- Zybo JD pin 1 / FPGA T14 -> PmodCLS J2 pin 4 / RXD
- Zybo JD pin 5 -> PmodCLS J2 pin 5 / GND
- Zybo JD pin 6 / 3.3 V -> PmodCLS J2 pin 6 / VCC
- Configure logical MD2/MD1/MD0 = 0/1/0 for 9600-baud UART.
- Jumper polarity varies by PmodCLS revision; follow its manual.

Run create_vivado_project.tcl in Vivado. Use run_simulation.tcl for accelerated
simulation and run_full_flow.tcl for synthesis, implementation, and reports.
Vivado synthesis/implementation and physical board behavior have not been
verified in this environment; inspect errors and reports before programming.
