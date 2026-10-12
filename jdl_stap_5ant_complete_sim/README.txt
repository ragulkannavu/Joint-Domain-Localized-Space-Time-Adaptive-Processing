JDL-STAP 5-ANTENNA CORE
========================

This directory contains the synthesizable processing chain.

The scene generator creates ONE target at a time and accepts:
  target_sel=0 -> 2 degrees
  target_sel=1 -> 45 degrees
  target_sel=2 -> 60 degrees (outside the supported two-beam region)
  target_doppler -> signed FFT bin -4..+3

The beamformer has two steering directions: 2 and 45 degrees. The core
demonstrates beam/Doppler detection for those two directions and intentionally
supports an out-of-region 60-degree case for NOT DETECTED.

Run the fast core test with tb_jdl_stap_5ant.v. It tests all three target
locations without waiting the full hardware 5-second scheduler interval.
