`timescale 1ns/1ps
// Five-antenna, two-beam digital beamformer. Q1.15 steering weights.
module beamformer5_2beam(input clk,input rst_n,input in_valid,input [159:0] ant_bus,output reg out_valid,output reg [31:0] beam0_data,output reg [31:0] beam1_data);
 localparam [79:0] B0_WR={16'h73E2,16'h7922,16'h7CEE,16'h7F3A,16'h7FFF};
 localparam [79:0] B0_WI={16'hC9A6,16'hD6A8,16'hE428,16'hF1FF,16'h0000};
 localparam [79:0] B1_WR={16'h9227,16'h76D0,16'hDDEC,16'hB279,16'h7FFF};
 localparam [79:0] B1_WI={16'hBE4D,16'hD063,16'h7B60,16'h9A28,16'h0000};
 wire [79:0] b0_pr_bus,b0_pi_bus,b1_pr_bus,b1_pi_bus;genvar g;
 generate for(g=0;g<5;g=g+1)begin:GEN_BF
  wire signed [15:0] xr=ant_bus[g*32+:16],xi=ant_bus[g*32+16+:16];
  wire signed [15:0] b0wr=B0_WR[g*16+:16],b0wi=B0_WI[g*16+:16],b1wr=B1_WR[g*16+:16],b1wi=B1_WI[g*16+:16];
  wire signed [15:0] b0pr,b0pi,b1pr,b1pi;
  complex_mult_q15 U_B0(.ar(xr),.ai(xi),.br(b0wr),.bi(b0wi),.pr(b0pr),.pi(b0pi));
  complex_mult_q15 U_B1(.ar(xr),.ai(xi),.br(b1wr),.bi(b1wi),.pr(b1pr),.pi(b1pi));
  assign b0_pr_bus[g*16+:16]=b0pr;assign b0_pi_bus[g*16+:16]=b0pi;
  assign b1_pr_bus[g*16+:16]=b1pr;assign b1_pi_bus[g*16+:16]=b1pi;
 end endgenerate
 integer k;reg signed [18:0] sum0r,sum0i,sum1r,sum1i;
 always @* begin sum0r=0;sum0i=0;sum1r=0;sum1i=0;
  for(k=0;k<5;k=k+1)begin sum0r=sum0r+$signed(b0_pr_bus[k*16+:16]);sum0i=sum0i+$signed(b0_pi_bus[k*16+:16]);sum1r=sum1r+$signed(b1_pr_bus[k*16+:16]);sum1i=sum1i+$signed(b1_pi_bus[k*16+:16]);end
 end
 wire signed [18:0] avg0r=sum0r/19'sd5,avg0i=sum0i/19'sd5,avg1r=sum1r/19'sd5,avg1i=sum1i/19'sd5;
 always @(posedge clk or negedge rst_n)begin if(!rst_n)begin out_valid<=0;beam0_data<=0;beam1_data<=0;end else begin out_valid<=in_valid;if(in_valid)begin beam0_data<={avg0i[15:0],avg0r[15:0]};beam1_data<={avg1i[15:0],avg1r[15:0]};end end end
endmodule