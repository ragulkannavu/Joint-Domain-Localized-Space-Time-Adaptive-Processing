`timescale 1ns/1ps
// Synthetic single-target radar scene: 8 pulses, five antenna channels.
module scene_generator_5ant(input clk,input rst_n,input start,input [1:0] target_sel,input signed [3:0] target_doppler,
 output pulse_valid,output [2:0] pulse_index,output [159:0] ant_bus,output reg done);
 reg active;reg [2:0] pcount;
 localparam [79:0] SV2_RE={16'h73E2,16'h7922,16'h7CEE,16'h7F3A,16'h7FFF};
 localparam [79:0] SV2_IM={16'h365A,16'h2958,16'h1BD8,16'h0E01,16'h0000};
 localparam [79:0] SV45_RE={16'h9227,16'h76D0,16'hDDEC,16'hB279,16'h7FFF};
 localparam [79:0] SV45_IM={16'h41B3,16'h2F9D,16'h84A0,16'h65D8,16'h0000};
 localparam [79:0] SV60_RE={16'hF198,16'hD92F,16'h5543,16'h8B2D,16'h7FFF};
 localparam [79:0] SV60_IM={16'h80D1,16'h79F8,16'hA089,16'h344C,16'h0000};
 reg [79:0] sv_re,sv_im;
 always @* case(target_sel)
  2'd0:begin sv_re=SV2_RE;sv_im=SV2_IM;end
  2'd1:begin sv_re=SV45_RE;sv_im=SV45_IM;end
  default:begin sv_re=SV60_RE;sv_im=SV60_IM;end
 endcase
 reg signed [6:0] phase_product;wire [2:0] phase_index=phase_product[2:0];
 always @* phase_product=$signed(target_doppler)*$signed({1'b0,pcount});
 reg [31:0] tone;
 always @* case(phase_index)
  0:tone={16'h0000,16'h7FFF};1:tone={16'h5A82,16'h5A82};
  2:tone={16'h7FFF,16'h0000};3:tone={16'h5A82,16'hA57E};
  4:tone={16'h0000,16'h8001};5:tone={16'hA57E,16'hA57E};
  6:tone={16'h8001,16'h0000};default:tone={16'hA57E,16'h5A82};
 endcase
 wire signed [15:0] tone_r=tone[15:0],tone_i=tone[31:16];
 genvar g;generate for(g=0;g<5;g=g+1)begin:GEN_ANT
  wire signed [15:0] sr=sv_re[g*16+:16],si=sv_im[g*16+:16],tr,ti;
  wire signed [15:0] tr_q=tr>>>2,ti_q=ti>>>2;
  complex_mult_q15 U_TGT(.ar(sr),.ai(si),.br(tone_r),.bi(tone_i),.pr(tr),.pi(ti));
  assign ant_bus[g*32+:16]=tr_q;assign ant_bus[g*32+16+:16]=ti_q;
 end endgenerate
 assign pulse_valid=active;assign pulse_index=pcount;
 always @(posedge clk or negedge rst_n)begin
  if(!rst_n)begin active<=0;pcount<=0;done<=0;end
  else begin done<=0;if(start&&!active)begin active<=1;pcount<=0;end
   else if(active)if(pcount==7)begin active<=0;pcount<=0;done<=1;end else pcount<=pcount+1'b1;
  end
 end
endmodule