`timescale 1ns/1ps
// Two-channel exponentially weighted sample covariance monitor; not an MVDR inverse.
module radar_covariance_2beam(input clk,input rst_n,input valid_in,
 input [31:0] beam0,input [31:0] beam1,output reg [31:0] r00,output reg [31:0] r11,
 output reg signed [31:0] r01_re,output reg signed [31:0] r01_im);
 wire signed [15:0] a=beam0[15:0],b=beam0[31:16],c=beam1[15:0],d=beam1[31:16];
 wire signed [31:0] aa=a*a,bb=b*b,cc=c*c,dd=d*d;
 wire signed [32:0] e00=$signed({1'b0,aa[31:0]})+$signed({1'b0,bb[31:0]});
 wire signed [32:0] e11=$signed({1'b0,cc[31:0]})+$signed({1'b0,dd[31:0]});
 wire signed [32:0] cross_re=(a*c)+(b*d),cross_im=(b*c)-(a*d);
 always @(posedge clk or negedge rst_n) begin
  if(!rst_n) begin r00<=0;r11<=0;r01_re<=0;r01_im<=0;end
  else if(valid_in) begin
   r00<=r00-(r00>>3)+({1'b0,e00[32:2]}>>3);
   r11<=r11-(r11>>3)+({1'b0,e11[32:2]}>>3);
   r01_re<=r01_re-(r01_re>>>3)+((cross_re>>>2)>>>3);
   r01_im<=r01_im-(r01_im>>>3)+((cross_im>>>2)>>>3);
  end
 end
endmodule