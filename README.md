# Joint-Domain Localized Space-Time Adaptive Processing (JDL-STAP)

FPGA demonstration of a simplified JDL-STAP radar-processing chain for the **Digilent Zybo Z7-10 (XC7Z010)** with serial output to a **Digilent PmodCLS 16×2 LCD**.

## Hardware and demonstration

- Five-antenna synthetic radar scene generator.
- Two-beam spatial processing (nominal steering directions 2° and 45°).
- 8-point radix-2 Doppler FFT and peak detector.
- PmodCLS UART LCD output at 9600 baud, 8-N-1.
- Pseudo-random Doppler selection and scenario cycling.
- Vivado project, constraints, TCL scripts, and simulation testbenches.

**Scope:** This is a synthetic digital demo. It has no physical RF/ADC input and does not measure physical target range. The FAR/CLOSER labels are scenario labels, and the Doppler display is an FFT-bin index rather than calibrated velocity. The complex coefficient shown on the LCD is scaled for readability.

## Repository layout

- `zybo_z7_10_jdl_stap_lcd_top.v` — hardware top, scheduler, result selection, and LCD interface.
- `pmodcls_uart_lcd.v` — UART LCD driver.
- `zybo_z7_10_pmodcls.xdc` — active Zybo Z7-10 constraints.
- `Zybo-Z7-10_Project_Master.xdc` — reference master constraints.
- `jdl_stap_5ant_complete_sim/` — processing core, synthetic scene, beamformer, FIFO, FFT, peak detector, and testbench.
- `create_vivado_project.tcl` — project creation.
- `run_simulation.tcl` — wrapper simulation helper.
- `run_full_flow.tcl` — synthesis/implementation/report helper.
- `verify_vivado_project.tcl`, `power_check.tcl`, `power_safe_report.tcl`, `verify_power_design.tcl` — inspection/reporting helpers.

## Open the project in Vivado

1. Download or clone this repository.
2. Open the Vivado Tcl Console and change to the repository root.
3. Run:

   ```tcl
   source create_vivado_project.tcl
   ```

The intended project is `JDL_STAP_ZyboZ7_PmodCLS`, targeting `xc7z010clg400-1`. Hardware top: `zybo_z7_10_jdl_stap_lcd_top`. Wrapper testbench: `tb_zybo_dynamic_demo`.

Run `source run_simulation.tcl` for the accelerated wrapper simulation. Run `source run_full_flow.tcl` to attempt synthesis, implementation, and report generation. Inspect Vivado messages and reports before programming the board.

## PmodCLS wiring

| Zybo Z7-10 | PmodCLS J2 | Purpose |
|---|---|---|
| JD pin 1 / FPGA T14 | Pin 4 / RXD | UART data from FPGA to LCD |
| JD pin 5 | Pin 5 / GND | Ground |
| JD pin 6 / 3.3 V | Pin 6 / VCC | Power |

Configure the PmodCLS logical mode bits **MD2/MD1/MD0 = 0/1/0** for 9600-baud UART. Physical jumper orientation varies by PmodCLS revision; follow the manual for your specific board. Connect the FPGA TX signal to LCD RXD, not TXD.

## Power and verification

The design uses a BUFGCE clock gate in the processing datapath. This is intended to reduce switching while idle, but it is not a measured power guarantee. Use the Vivado power report with representative switching activity for an estimate.

The author has reported observing the LCD output on the physical board. This repository has been updated through the GitHub API, but a Vivado build, timing closure, and board test were not run by this upload workflow. Verify the final checkout in your Vivado installation before relying on build or power results.

## License

No license file is included. Add a license if you intend to permit redistribution or reuse.
