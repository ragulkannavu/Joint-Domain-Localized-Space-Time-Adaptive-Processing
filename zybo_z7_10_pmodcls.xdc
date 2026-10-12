## Zybo Z7-10 + PmodCLS UART LCD, XC7Z010CLG400-1
set_property -dict { PACKAGE_PIN K17 IOSTANDARD LVCMOS33 } [get_ports { sysclk }]
create_clock -add -name sys_clk_pin -period 8.00 -waveform {0 4} [get_ports { sysclk }]
set_property -dict { PACKAGE_PIN K18 IOSTANDARD LVCMOS33 } [get_ports { btn_reset }]
set_property PULLDOWN true [get_ports { btn_reset }]
## JD pin 1 / T14 drives PmodCLS J2 pin 4 (RXD)
set_property -dict { PACKAGE_PIN T14 IOSTANDARD LVCMOS33 DRIVE 4 SLEW SLOW } [get_ports { pmodcls_tx }]
set_property -dict { PACKAGE_PIN M14 IOSTANDARD LVCMOS33 DRIVE 4 SLEW SLOW } [get_ports { led_detected }]
set_property -dict { PACKAGE_PIN M15 IOSTANDARD LVCMOS33 DRIVE 4 SLEW SLOW } [get_ports { led_done }]
## Connect PmodCLS J2 pin 6 to 3.3 V and pin 5 to GND; these are not GPIOs.
