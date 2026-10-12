`timescale 1ns/1ps
// Deterministic verification stimulus: common stationary clutter + bounded pseudo-noise.
// Q1.15 samples. Saturating addition prevents wraparound.
module radar_noise_clutter #(parameter NOISE_SHIFT=7, CLUTTER_SHIFT=5) (
 input clk,input rst_n,input enable,input valid_in,input [159:0] ant_in,
 output valid_out,output [159:0] ant_out
);
 reg [31:0] lfsr;
 always @(posedge clk or negedge rst_n)
  if(!rst_n) lfsr<=32'hCAFE1235;
  else if(valid_in) lfsr<={lfsr[30:0],lfsr[31]^lfsr[21]^lfsr[1]^lfsr[0]};
 assign valid_out=valid_in;
 function [15:0] sat(input signed [17:0] x);
  begin if(x>18'sd32767) sat=16'h7fff; else if(x< -18'sd32768) sat=16'h8000; else sat=x[15:0]; end
 endfunction
 genvar a;
 generate for(a=0;a<5;a=a+1) begin:G
  wire signed [15:0] re=ant_in[a*32+:16], im=ant_in[a*32+16+:16];
  wire signed [15:0] nr=$signed({{8{lfsr[(a*5)%24+7]}},lfsr[(a*5)%24+:8]}) <<< NOISE_SHIFT;
  wire signed [15:0] ni=$signed({{8{lfsr[(a*5+3)%24+7]}},lfsr[(a*5+3)%24+:8]}) <<< NOISE_SHIFT;
  wire signed [17:0] rr=$signed(re)+($signed(nr)>>>3)+($signed(18'sd8192)>>>CLUTTER_SHIFT);
  wire signed [17:0] ii=$signed(im)+($signed(ni)>>>3);
  assign ant_out[a*32+:16]=enable?sat(rr):re;
  assign ant_out[a*32+16+:16]=enable?sat(ii):im;
 end endgenerate
endmodule