ZYBO Z7-10 + DIGILENT PMODCLS 16x2 LCD
1. JD pin 1 / FPGA T14 -> PmodCLS J2 pin 4 (RXD).
2. JD pin 5 -> PmodCLS J2 pin 5 (GND).
3. JD pin 6 (3.3 V) -> PmodCLS J2 pin 6 (VCC).
4. Configure logical MD2/MD1/MD0 = 0/1/0 for UART 9600 baud.
Jumper positions vary by PmodCLS hardware revision; use the board manual.
Do not connect the FPGA TX signal to PmodCLS TXD. The FPGA output is UART TX
and must connect to the LCD's RXD input.
