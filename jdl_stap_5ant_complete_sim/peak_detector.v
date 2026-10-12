timescale 1ns/1ps
module peak_detector(input clk,input rst_n,input fft_valid,input signed [19:0] fft_real,input signed [19:0] fft_imag,input [2:0] fft_bin,input fft_last,input fft_beam,output reg peak_valid,output reg peak_beam,output reg [2:0] peak_bin,output reg [20:0] peak_mag,output reg signed [19:0] peak_real,output reg signed [19:0] peak_imag);
 wire [19:0] abs_r=fft_real[19]?(~fft_real+20'd1):fft_real;
 wire [19:0] abs_i=fft_imag[19]?(~fft_imag+20'd1):fft_imag;
 wire [20:0] mag_now={1'b0,abs_r}+{1'b0,abs_i};
 reg [20:0] max_mag;reg [2:0] max_bin;reg signed [19:0] max_real,max_imag;
 always @(posedge clk or negedge rst_n)begin
 if(!rst_n)begin peak_valid<=0;peak_beam<=0;peak_bin<=0;peak_mag<=0;peak_real<=0;peak_imag<=0;max_mag<=0;max_bin<=0;max_real<=0;max_imag<=0;end
 else begin peak_valid<=0;if(fft_valid)begin
 if(fft_bin==0)begin max_mag<=mag_now;max_bin<=0;max_real<=fft_real;max_imag<=fft_imag;end
 else if(fft_last)begin peak_valid<=1;peak_beam<=fft_beam;if(mag_now>max_mag)begin peak_bin<=fft_bin;peak_mag<=mag_now;peak_real<=fft_real;peak_imag<=fft_imag;end else begin peak_bin<=max_bin;peak_mag<=max_mag;peak_real<=max_real;peak_imag<=max_imag;end end
 else if(mag_now>max_mag)begin max_mag<=mag_now;max_bin<=fft_bin;max_real<=fft_real;max_imag<=fft_imag;end end end end
endmodule