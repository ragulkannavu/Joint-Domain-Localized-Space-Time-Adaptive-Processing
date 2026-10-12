`timescale 1ns/1ps
// 8-bin compact CA-CFAR-inspired detector. Guard=1 on each side; threshold=2*mean+offset.
module radar_cfar8 #(parameter [20:0] OFFSET=21'd512)(
 input clk,input rst_n,input fft_valid,input [2:0] fft_bin,input fft_last,input fft_beam,
 input signed [19:0] fft_real,input signed [19:0] fft_imag,
 output reg det_valid,output reg det_beam,output reg detected,output reg [2:0] det_bin,
 output reg [20:0] det_mag,output reg [20:0] noise_est);
 reg [20:0] bins[0:7]; integer i,j,k; reg [2:0] best_idx; reg [20:0] best_mag;
 reg [24:0] train_sum; reg [20:0] train_mean; reg [20:0] now_mag; reg [20:0] a_re,a_im;
 always @* begin
  a_re=fft_real[19]?(~fft_real+20'd1):fft_real;
  a_im=fft_imag[19]?(~fft_imag+20'd1):fft_imag;
  now_mag={1'b0,a_re}+{1'b0,a_im}; best_idx=0;best_mag=0;
  for(j=0;j<8;j=j+1) if((fft_valid&&fft_last&&fft_bin==j?now_mag:bins[j])>best_mag) begin
   best_mag=(fft_valid&&fft_last&&fft_bin==j?now_mag:bins[j]);best_idx=j;end
  train_sum=0;
  for(k=0;k<8;k=k+1) if((k!=best_idx)&&(k!=((best_idx+1)%8))&&(k!=((best_idx+7)%8)))
   train_sum=train_sum+(fft_valid&&fft_last&&fft_bin==k?now_mag:bins[k]);
  train_mean=train_sum/5;
 end
 always @(posedge clk or negedge rst_n) begin
  if(!rst_n) begin det_valid<=0;det_beam<=0;detected<=0;det_bin<=0;det_mag<=0;noise_est<=0;for(i=0;i<8;i=i+1)bins[i]<=0;end
  else begin det_valid<=0;if(fft_valid) begin bins[fft_bin]<=now_mag;
   if(fft_last) begin det_valid<=1;det_beam<=fft_beam;det_bin<=best_idx;det_mag<=best_mag;noise_est<=train_mean;
    detected<=({1'b0,best_mag}>({1'b0,train_mean}<<1)+OFFSET);end end end
 end
endmodule