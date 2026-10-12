`timescale 1ns/1ps
module fft8_radix2(input clk,input rst_n,input in_valid,output in_ready,input [31:0] in_data,input in_last,input in_beam,
 output out_valid,input out_ready,output signed [19:0] out_real,output signed [19:0] out_imag,output [2:0] out_bin,output out_last,output out_beam,output busy);
 localparam ST_LOAD=3'd0,ST_REORDER=3'd1,ST_STAGE1=3'd2,ST_STAGE2=3'd3,ST_STAGE3=3'd4,ST_OUTPUT=3'd5;
 reg [2:0] state;reg signed [15:0] xre[0:7],xim[0:7];reg signed [19:0] ar[0:7],ai[0:7];reg [2:0] load_idx,bf_idx,out_idx;reg frame_beam;integer i;
 assign in_ready=(state==ST_LOAD);assign busy=(state!=ST_LOAD)||(load_idx!=0);assign out_valid=(state==ST_OUTPUT);
 assign out_real=ar[out_idx];assign out_imag=ai[out_idx];assign out_bin=out_idx;assign out_last=(state==ST_OUTPUT)&&(out_idx==7);assign out_beam=frame_beam;
 reg [2:0] a_idx,b_idx;reg signed [15:0] tw_re,tw_im;
 always @* begin a_idx=0;b_idx=1;tw_re=16'sh7FFF;tw_im=0;case(state)
 ST_STAGE1:begin case(bf_idx)0:begin a_idx=0;b_idx=1;end 1:begin a_idx=2;b_idx=3;end 2:begin a_idx=4;b_idx=5;end default:begin a_idx=6;b_idx=7;end endcase end
 ST_STAGE2:begin case(bf_idx)0:begin a_idx=0;b_idx=2;tw_re=16'sh7FFF;tw_im=0;end 1:begin a_idx=1;b_idx=3;tw_re=0;tw_im=16'sh8001;end 2:begin a_idx=4;b_idx=6;tw_re=16'sh7FFF;tw_im=0;end default:begin a_idx=5;b_idx=7;tw_re=0;tw_im=16'sh8001;end endcase end
 ST_STAGE3:begin case(bf_idx)0:begin a_idx=0;b_idx=4;tw_re=16'sh7FFF;tw_im=0;end 1:begin a_idx=1;b_idx=5;tw_re=16'sh5A82;tw_im=16'shA57E;end 2:begin a_idx=2;b_idx=6;tw_re=0;tw_im=16'sh8001;end default:begin a_idx=3;b_idx=7;tw_re=16'shA57E;tw_im=16'shA57E;end endcase end
 default:begin a_idx=0;b_idx=1;tw_re=16'sh7FFF;tw_im=0;end endcase end
 wire signed [19:0] a_re=ar[a_idx],a_im=ai[a_idx],b_re=ar[b_idx],b_im=ai[b_idx];
 wire signed [35:0] m_rr=b_re*tw_re,m_ii=b_im*tw_im,m_ri=b_re*tw_im,m_ir=b_im*tw_re;
 wire signed [36:0] t_real_wide={m_rr[35],m_rr}-{m_ii[35],m_ii},t_imag_wide={m_ri[35],m_ri}+{m_ir[35],m_ir};
 wire signed [36:0] t_real_scaled=t_real_wide>>>15,t_imag_scaled=t_imag_wide>>>15;
 wire signed [20:0] t_re=t_real_scaled[20:0],t_im=t_imag_scaled[20:0];
 wire signed [20:0] a_re_ext={a_re[19],a_re},a_im_ext={a_im[19],a_im};
 wire signed [20:0] sum_re=a_re_ext+t_re,sum_im=a_im_ext+t_im,dif_re=a_re_ext-t_re,dif_im=a_im_ext-t_im;
 always @(posedge clk or negedge rst_n)begin
 if(!rst_n)begin state<=ST_LOAD;load_idx<=0;bf_idx<=0;out_idx<=0;frame_beam<=0;for(i=0;i<8;i=i+1)begin xre[i]<=0;xim[i]<=0;ar[i]<=0;ai[i]<=0;end end
 else case(state)
 ST_LOAD:if(in_valid&&in_ready)begin xre[load_idx]<=in_data[15:0];xim[load_idx]<=in_data[31:16];if(load_idx==0)frame_beam<=in_beam;if(load_idx==7)begin load_idx<=0;state<=ST_REORDER;end else load_idx<=load_idx+1'b1;end
 ST_REORDER:begin
 ar[0]<={{4{xre[0][15]}},xre[0]};ai[0]<={{4{xim[0][15]}},xim[0]};
 ar[1]<={{4{xre[4][15]}},xre[4]};ai[1]<={{4{xim[4][15]}},xim[4]};
 ar[2]<={{4{xre[2][15]}},xre[2]};ai[2]<={{4{xim[2][15]}},xim[2]};
 ar[3]<={{4{xre[6][15]}},xre[6]};ai[3]<={{4{xim[6][15]}},xim[6]};
 ar[4]<={{4{xre[1][15]}},xre[1]};ai[4]<={{4{xim[1][15]}},xim[1]};
 ar[5]<={{4{xre[5][15]}},xre[5]};ai[5]<={{4{xim[5][15]}},xim[5]};
 ar[6]<={{4{xre[3][15]}},xre[3]};ai[6]<={{4{xim[3][15]}},xim[3]};
 ar[7]<={{4{xre[7][15]}},xre[7]};ai[7]<={{4{xim[7][15]}},xim[7]};bf_idx<=0;state<=ST_STAGE1;end
 ST_STAGE1,ST_STAGE2,ST_STAGE3:begin ar[a_idx]<=sum_re[19:0];ai[a_idx]<=sum_im[19:0];ar[b_idx]<=dif_re[19:0];ai[b_idx]<=dif_im[19:0];if(bf_idx==3)begin bf_idx<=0;if(state==ST_STAGE1)state<=ST_STAGE2;else if(state==ST_STAGE2)state<=ST_STAGE3;else begin out_idx<=0;state<=ST_OUTPUT;end end else bf_idx<=bf_idx+1'b1;end
 ST_OUTPUT:if(out_valid&&out_ready)begin if(out_idx==7)begin out_idx<=0;state<=ST_LOAD;end else out_idx<=out_idx+1'b1;end
 default:state<=ST_LOAD;
 endcase end
endmodule