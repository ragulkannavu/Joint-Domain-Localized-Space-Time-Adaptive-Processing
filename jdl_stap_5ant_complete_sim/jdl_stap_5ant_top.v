`timescale 1ns/1ps
// COMPLETE 5-ANTENNA JDL-STAP PREPROCESSING DEMO
module jdl_stap_5ant_top #(parameter USE_EXTERNAL_SAMPLES=0, parameter ENABLE_NOISE=0) (
 input clk,input rst_n,input start,input external_valid,input [159:0] external_ant_bus,
 output cfar_valid,output cfar_detected,output [2:0] cfar_bin,output [20:0] cfar_noise,
 output [31:0] covariance_r00,output [31:0] covariance_r11,
 input [1:0] target_sel,input signed [3:0] target_doppler,
 output scene_valid,output [2:0] scene_pulse,output beam_valid,
 output ser_valid,output ser_ready,output ser_last,output ser_beam,output [5:0] fifo_level,
 output fft_valid,output signed [19:0] fft_real,output signed [19:0] fft_imag,output [2:0] fft_bin,output fft_last,output fft_beam,
 output peak_valid,output peak_beam,output [2:0] peak_bin,output [20:0] peak_mag,output signed [19:0] peak_real,output signed [19:0] peak_imag,output reg done
);
 wire [159:0] ant_bus; wire scene_done;
 scene_generator_5ant U_SCENE(.clk(clk),.rst_n(rst_n),.start(start),.target_sel(target_sel),.target_doppler(target_doppler),.pulse_valid(scene_valid),.pulse_index(scene_pulse),.ant_bus(ant_bus),.done(scene_done));
 wire [31:0] beam0_data,beam1_data;
 wire [159:0] input_ant_bus=USE_EXTERNAL_SAMPLES?external_ant_bus:ant_bus;
 wire input_valid=USE_EXTERNAL_SAMPLES?external_valid:scene_valid;
 wire [159:0] conditioned_ant_bus; wire conditioned_valid;
 radar_noise_clutter U_NOISE(.clk(clk),.rst_n(rst_n),.enable(ENABLE_NOISE!=0),.valid_in(input_valid),.ant_in(input_ant_bus),.valid_out(conditioned_valid),.ant_out(conditioned_ant_bus));
 beamformer5_2beam U_BF(.clk(clk),.rst_n(rst_n),.in_valid(conditioned_valid),.ant_bus(conditioned_ant_bus),.out_valid(beam_valid),.beam0_data(beam0_data),.beam1_data(beam1_data));
 wire signed [31:0] covariance_cross_re,covariance_cross_im;
 radar_covariance_2beam U_COV(.clk(clk),.rst_n(rst_n),.valid_in(beam_valid),.beam0(beam0_data),.beam1(beam1_data),.r00(covariance_r00),.r11(covariance_r11),.r01_re(covariance_cross_re),.r01_im(covariance_cross_im));
 wire [31:0] ser_data; wire serializer_done;
 frame_serializer_2x8 U_SER(.clk(clk),.rst_n(rst_n),.in_valid(beam_valid),.beam0_data(beam0_data),.beam1_data(beam1_data),.s_valid(ser_valid),.s_ready(ser_ready),.s_data(ser_data),.s_last(ser_last),.s_beam(ser_beam),.done(serializer_done));
 wire fifo_valid,fifo_ready; wire [31:0] fifo_data; wire fifo_last,fifo_beam;
 stream_fifo32 U_FIFO(.clk(clk),.rst_n(rst_n),.s_valid(ser_valid),.s_ready(ser_ready),.s_data(ser_data),.s_last(ser_last),.s_beam(ser_beam),.m_valid(fifo_valid),.m_ready(fifo_ready),.m_data(fifo_data),.m_last(fifo_last),.m_beam(fifo_beam),.level(fifo_level));
 wire fft_busy; wire fft_out_ready=1'b1;
 fft8_radix2 U_FFT(.clk(clk),.rst_n(rst_n),.in_valid(fifo_valid),.in_ready(fifo_ready),.in_data(fifo_data),.in_last(fifo_last),.in_beam(fifo_beam),.out_valid(fft_valid),.out_ready(fft_out_ready),.out_real(fft_real),.out_imag(fft_imag),.out_bin(fft_bin),.out_last(fft_last),.out_beam(fft_beam),.busy(fft_busy));
 peak_detector U_PEAK(.clk(clk),.rst_n(rst_n),.fft_valid(fft_valid),.fft_real(fft_real),.fft_imag(fft_imag),.fft_bin(fft_bin),.fft_last(fft_last),.fft_beam(fft_beam),.peak_valid(peak_valid),.peak_beam(peak_beam),.peak_bin(peak_bin),.peak_mag(peak_mag),.peak_real(peak_real),.peak_imag(peak_imag));
 wire cfar_beam; wire [20:0] cfar_mag;
 radar_cfar8 U_CFAR(.clk(clk),.rst_n(rst_n),.fft_valid(fft_valid),.fft_bin(fft_bin),.fft_last(fft_last),.fft_beam(fft_beam),.fft_real(fft_real),.fft_imag(fft_imag),.det_valid(cfar_valid),.det_beam(cfar_beam),.detected(cfar_detected),.det_bin(cfar_bin),.det_mag(cfar_mag),.noise_est(cfar_noise));
 reg [1:0] peak_count;
 always @(posedge clk or negedge rst_n) begin
  if(!rst_n) begin peak_count<=0;done<=0;end
  else begin done<=0;if(start)peak_count<=0;if(peak_valid)begin if(peak_count==1)begin peak_count<=2;done<=1;end else peak_count<=peak_count+1'b1;end end
 end
endmodule