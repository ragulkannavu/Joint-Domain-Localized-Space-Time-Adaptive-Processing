# ModelSim/Questa simulation for the original JDL-STAP core.
# Run from this directory: do run_modelsim.do
vlib work
vlog complex_mult_q15.v
vlog scene_generator_5ant.v
vlog radar_noise_clutter.v
vlog beamformer5_2beam.v
vlog radar_covariance_2beam.v
vlog frame_serializer_2x8.v
vlog stream_fifo32.v
vlog fft8_radix2.v
vlog peak_detector.v
vlog radar_cfar8.v
vlog jdl_stap_5ant_top.v
vlog tb_jdl_stap_5ant.v
vsim -c tb_jdl_stap_5ant -do "run -all; quit -f"
