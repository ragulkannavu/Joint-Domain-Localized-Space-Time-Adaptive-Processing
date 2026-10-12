timescale 1ns/1ps
module tb_jdl_stap_5ant;
 reg clk,rst_n,start;reg [1:0] target_sel;reg signed [3:0] target_doppler;
 wire scene_valid;wire [2:0] scene_pulse;wire beam_valid;wire ser_valid,ser_ready,ser_last,ser_beam;wire [5:0] fifo_level;
 wire fft_valid;wire signed [19:0] fft_real,fft_imag;wire [2:0] fft_bin;wire fft_last,fft_beam;
 wire peak_valid,peak_beam;wire [2:0] peak_bin;wire [20:0] peak_mag;wire signed [19:0] peak_real,peak_imag;wire done;
 jdl_stap_5ant_top DUT(.clk(clk),.rst_n(rst_n),.start(start),.external_valid(1'b0),.external_ant_bus(160'd0),.cfar_valid(),.cfar_detected(),.cfar_bin(),.cfar_noise(),.covariance_r00(),.covariance_r11(),.target_sel(target_sel),.target_doppler(target_doppler),.scene_valid(scene_valid),.scene_pulse(scene_pulse),.beam_valid(beam_valid),.ser_valid(ser_valid),.ser_ready(ser_ready),.ser_last(ser_last),.ser_beam(ser_beam),.fifo_level(fifo_level),.fft_valid(fft_valid),.fft_real(fft_real),.fft_imag(fft_imag),.fft_bin(fft_bin),.fft_last(fft_last),.fft_beam(fft_beam),.peak_valid(peak_valid),.peak_beam(peak_beam),.peak_bin(peak_bin),.peak_mag(peak_mag),.peak_real(peak_real),.peak_imag(peak_imag),.done(done));
 initial clk=0;always #5 clk=~clk;
 always @(posedge clk)if(peak_valid)$display("PEAK: target_sel=%0d target_doppler=%0d beam=%0d bin=%0d mag=%0d X=%0d+j%0d",target_sel,target_doppler,peak_beam,peak_bin,peak_mag,peak_real,peak_imag);
 task run_case;input [1:0] sel;input signed [3:0] dop;begin target_sel=sel;target_doppler=dop;@(posedge clk);start=1;@(posedge clk);start=0;wait(done==1);#20;$display("CASE COMPLETE: angle=%0d doppler=%0d",(sel==0)?2:(sel==1)?45:60,dop);end endtask
 initial begin rst_n=0;start=0;target_sel=0;target_doppler=1;#30;rst_n=1;$display("DYNAMIC SINGLE-TARGET JDL-STAP CORE TEST");run_case(0,1);run_case(1,-2);run_case(2,3);$display("CORE TEST COMPLETE");$finish;end
 initial begin #10000;$display("TIMEOUT: simulation did not finish.");$finish;end
endmodule