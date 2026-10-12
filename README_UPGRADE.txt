JDL-STAP Zybo Z7-10 PmodCLS faculty demo upgrade.
This project uses synthetic five-antenna data, a two-beam beamformer, an 8-point
Doppler FFT, peak selection and a PmodCLS UART LCD status output.
Hardware target interval: approximately 5 seconds. LCD refresh: approximately
3 seconds. LCD UART: 9600 baud, 8-N-1.
This is a digital demo, not a full radar front end: no physical RF/ADC input and
no physical range measurement. Doppler values are FFT bins, not calibrated speed.
