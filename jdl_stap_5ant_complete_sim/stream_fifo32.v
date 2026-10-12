`timescale 1ns/1ps
// Synchronous 32-word stream FIFO. Stored word: beam[33], last[32], data[31:0].
module stream_fifo32 (
 input clk,input rst_n,input s_valid,output s_ready,input [31:0] s_data,input s_last,input s_beam,
 output m_valid,input m_ready,output [31:0] m_data,output m_last,output m_beam,output [5:0] level
);
 reg [33:0] mem[0:31]; reg [4:0] wr_ptr,rd_ptr; reg [5:0] count;
 wire push=s_valid&&s_ready; wire pop=m_valid&&m_ready;
 assign s_ready=(count<6'd32); assign m_valid=(count!=0);
 assign m_data=mem[rd_ptr][31:0]; assign m_last=mem[rd_ptr][32]; assign m_beam=mem[rd_ptr][33]; assign level=count;
 always @(posedge clk or negedge rst_n) begin
  if(!rst_n) begin wr_ptr<=0;rd_ptr<=0;count<=0;end
  else begin
   if(push) begin mem[wr_ptr]<={s_beam,s_last,s_data};wr_ptr<=wr_ptr+1'b1;end
   if(pop) rd_ptr<=rd_ptr+1'b1;
   case({push,pop}) 2'b10:count<=count+1'b1;2'b01:count<=count-1'b1;default:count<=count;endcase
  end
 end
endmodule