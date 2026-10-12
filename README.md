# Joint-Domain Localized Space-Time Adaptive Processing (JDL-STAP)

FPGA-based demonstration of a simplified JDL-STAP radar-processing chain on the **Digilent Zybo Z7-10 (XC7Z010)**, with serial status output to a **Digilent PmodCLS 16×2 LCD**.

> **Project scope:** This is a digital demonstration using a synthetic scene generator. It is not a complete radar front end: there is no physical RF/ADC input, and the current demo does not estimate physical target range. The display labels **FAR** and **CLOSER** are demonstration classifications, not measured range outputs.

## Features

- Five-antenna synthetic scene generation.
- Two-beam processing (steering directions around 2° and 45°).
- 8-point Doppler FFT and peak selection.
- UART LCD controller (9600 baud, 8-N-1).
- Zybo Z7-10 pin constraints, Vivado TCL scripts, and simulation testbenches.

## Project setup

1. Clone or download this repository.
2. Open the Vivado Tcl Console and change directory to the repository root.
3. Run:

   ```tcl
   source create_vivado_project.tcl
   ```

The script is intended to create a project named `JDL_STAP_ZyboZ7_PmodCLS` under `vivado_project/`. The intended hardware top is `zybo_z7_10_jdl_stap_lcd_top`; the wrapper simulation top is `tb_zybo_dynamic_demo`.

## LCD connection

For the Pmod JD connection described by the included XDC:

| Zybo Z7-10 | PmodCLS J2 | Purpose |
|---|---|---|
| JD pin 1 / FPGA T14 | Pin 4 / RXD | UART data from FPGA to LCD |
| JD pin 5 | Pin 5 / GND | Ground |
| JD pin 6 / 3.3 V | Pin 6 / VCC | Power |

Configure the PmodCLS logical mode bits **MD2/MD1/MD0 = 0/1/0** for 9600-baud UART. Physical jumper polarity may differ by PmodCLS revision; follow the markings/manual for your board. Connect the FPGA signal to PmodCLS RXD, not TXD.

## Demo interpretation

The demo cycles through synthetic target scenarios, updating the scenario approximately every 5 seconds and refreshing the LCD approximately every 3 seconds. Example LCD states include detection status, angle/Doppler information, and a scaled complex FFT coefficient. A deliberately out-of-region 60° scenario can produce `NOT DETECTED`.

An 8-point FFT provides Doppler-bin information; converting bins to physical velocity requires additional radar parameters. The displayed complex coefficient is a scaled display value, not a physical unit.

## Power and verification

The RTL uses clock gating to reduce switching activity in the processing datapath. This is not a measured power guarantee. Use Vivado synthesis/implementation reports and suitable switching activity to assess power and timing.

**Verification note:** Source files and setup scripts should be checked with your installed Vivado version. Vivado synthesis, timing closure, and physical-board operation have not been independently verified in this environment.

## License

No license file is included. Add a license before redistributing the project if you intend to permit reuse.