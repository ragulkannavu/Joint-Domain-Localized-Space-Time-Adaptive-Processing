`timescale 1ns/1ps
// Buffers 8 samples for each beam, then serializes both frames with TLAST.
module frame_serializer_2x8(input clk,input rst_n,input in_valid,input [31:0] beam0_data,input [31:0] beam1_data,
 output s_valid,input s_ready,output [31:0] s_data,output s_last,output s_beam,output reg done);
 reg [31:0] mem0[0:7],mem1[0:7];reg [2:0] collect_idx,send_idx;reg sending,send_beam;
 assign s_valid=sending;assign s_beam=send_beam;assign s_last=sending&&(send_idx==7);
 assign s_data=send_beam?mem1[send_idx]:mem0[send_idx];
 always @(posedge clk or negedge rst_n) begin
  if(!rst_n)begin collect_idx<=0;sending<=0;send_beam<=0;send_idx<=0;done<=0;end
  else begin done<=0;
   if(!sending&&in_valid)begin mem0[collect_idx]<=beam0_data;mem1[collect_idx]<=beam1_data;
    if(collect_idx==7)begin collect_idx<=0;sending<=1;send_beam<=0;send_idx<=0;end else collect_idx<=collect_idx+1'b1;end
   if(sending&&s_ready)begin if(send_idx==7)begin if(!send_beam)begin send_beam<=1;send_idx<=0;end
    else begin sending<=0;send_beam<=0;send_idx<=0;done<=1;end end else send_idx<=send_idx+1'b1;end
  end
 end
endmodule