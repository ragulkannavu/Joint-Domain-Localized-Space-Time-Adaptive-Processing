`timescale 1ns/1ps
// Digilent PmodCLS UART LCD driver: 9600 baud, 8-N-1, 125 MHz clock.
// FPGA TX connects to PmodCLS J2 pin 4 (RXD).
// status: 0=detected, 1=not detected, 2=far demo label, 3=closer demo label.
module pmodcls_uart_lcd #(
    parameter integer CLK_HZ = 125_000_000,
    parameter integer BAUD = 9600,
    parameter integer DISPLAY_PERIOD_CYCLES = 375_000_000
)(
    input wire clk, input wire rst_n, input wire [1:0] status,
    input wire [6:0] actual_angle, input signed [3:0] actual_doppler,
    input wire detected_valid, input wire [6:0] detected_angle,
    input signed [3:0] detected_doppler, input signed [19:0] detected_real,
    input signed [19:0] detected_imag, input wire [20:0] detected_mag,
    output reg tx
);
localparam integer BIT_CLKS=(CLK_HZ+BAUD/2)/BAUD;
reg [30:0] display_timer; reg pending,active; reg [6:0] pos;
reg [7:0] frame_mem[0:31]; reg [15:0] baud_cnt; reg [3:0] bit_cnt;
reg [7:0] tx_byte; reg tx_busy; integer i;
function integer abs_int(input integer x); begin abs_int=(x<0)?-x:x; end endfunction
task put_angle(input integer value,input integer base); integer v; begin
 v=value;if(v<0)v=0;if(v>99)v=99;
 if(v>=10)begin frame_mem[base]=48+(v/10);frame_mem[base+1]=48+(v%10);end
 else begin frame_mem[base]="0";frame_mem[base+1]=48+v;end
end endtask
task put_doppler(input integer value,input integer base);begin
 if(value<0)begin frame_mem[base]="-";frame_mem[base+1]=48+abs_int(value);end
 else begin frame_mem[base]="+";frame_mem[base+1]=48+value;end
end endtask
task build_frame;
 integer a,d,da,dd,xr,xi,j;
 begin
  for(j=0;j<32;j=j+1)frame_mem[j]=" ";
  a=actual_angle;d=actual_doppler;da=detected_angle;dd=detected_doppler;xr=detected_real;xi=detected_imag;
  case(status)
   0:begin frame_mem[0]="D";frame_mem[1]="E";frame_mem[2]="T";frame_mem[3]="E";frame_mem[4]="C";frame_mem[5]="T";frame_mem[6]="E";frame_mem[7]="D";frame_mem[8]=" ";frame_mem[9]="A";put_angle(da,10);frame_mem[12]=" ";frame_mem[13]="D";put_doppler(dd,14);end
   1:begin frame_mem[0]="N";frame_mem[1]="O";frame_mem[2]="T";frame_mem[3]=" ";frame_mem[4]="D";frame_mem[5]="E";frame_mem[6]="T";frame_mem[7]="E";frame_mem[8]="C";frame_mem[9]="T";frame_mem[10]="E";frame_mem[11]="D";end
   2:begin frame_mem[0]="F";frame_mem[1]="A";frame_mem[2]="R";frame_mem[3]=" ";frame_mem[4]="A";put_angle(a,5);frame_mem[7]=" ";frame_mem[8]="D";frame_mem[9]="-";frame_mem[10]="-";end
   default:begin frame_mem[0]="C";frame_mem[1]="L";frame_mem[2]="O";frame_mem[3]="S";frame_mem[4]="E";frame_mem[5]="R";frame_mem[6]=" ";frame_mem[7]="A";put_angle(a,8);frame_mem[10]=" ";frame_mem[11]="D";frame_mem[12]="-";frame_mem[13]="-";end
  endcase
  if(status==1)begin frame_mem[16]="A";put_angle(a,17);frame_mem[19]=" ";frame_mem[20]="D";frame_mem[21]="-";frame_mem[22]="-";end
  else begin
   frame_mem[16]="X";frame_mem[17]="=";
   if(detected_valid)begin
    xr=xr>>>13;xi=xi>>>13;
    if(xr<0)begin frame_mem[18]="-";xr=-xr;end else frame_mem[18]="+";
    if(xr>99)xr=99;frame_mem[19]=48+((xr/10)%10);frame_mem[20]=48+(xr%10);
    if(xi<0)begin frame_mem[21]="-";xi=-xi;end else frame_mem[21]="+";
    frame_mem[22]="j";if(xi>99)xi=99;frame_mem[23]=48+((xi/10)%10);frame_mem[24]=48+(xi%10);
   end else for(j=18;j<32;j=j+1)frame_mem[j]="-";
  end
 end
endtask
always @(posedge clk or negedge rst_n)begin
 if(!rst_n)begin display_timer<=0;pending<=1;active<=0;pos<=0;baud_cnt<=0;bit_cnt<=0;tx_byte<=0;tx_busy<=0;tx<=1;end
 else begin
  if(display_timer<DISPLAY_PERIOD_CYCLES-1)display_timer<=display_timer+1'b1;
  else begin display_timer<=0;pending<=1;end
  if(!active&&!tx_busy&&pending)begin build_frame();pos<=0;active<=1;pending<=0;end
  if(active&&!tx_busy)begin
   if(pos==0)tx_byte<=8'h1B;else if(pos==1)tx_byte<=8'h5B;else if(pos==2)tx_byte<=8'h6A;
   else if(pos==3)tx_byte<=8'h1B;else if(pos==4)tx_byte<=8'h5B;else if(pos==5)tx_byte<=8'h30;
   else if(pos==6)tx_byte<=8'h3B;else if(pos==7)tx_byte<=8'h30;else if(pos==8)tx_byte<=8'h48;
   else if(pos>=9&&pos<=24)tx_byte<=frame_mem[pos-9];
   else if(pos==25)tx_byte<=8'h1B;else if(pos==26)tx_byte<=8'h5B;else if(pos==27)tx_byte<=8'h31;
   else if(pos==28)tx_byte<=8'h3B;else if(pos==29)tx_byte<=8'h30;else if(pos==30)tx_byte<=8'h48;
   else if(pos>=31&&pos<=46)tx_byte<=frame_mem[pos-15];
   tx_busy<=1;baud_cnt<=0;bit_cnt<=0;tx<=0;
  end else if(tx_busy)begin
   if(baud_cnt==BIT_CLKS-1)begin baud_cnt<=0;
    if(bit_cnt<8)begin tx<=tx_byte[bit_cnt];bit_cnt<=bit_cnt+1'b1;end
    else if(bit_cnt==8)begin tx<=1;bit_cnt<=9;end
    else begin tx<=1;tx_busy<=0;if(pos==46)begin active<=0;pos<=0;end else pos<=pos+1'b1;end
   end else baud_cnt<=baud_cnt+1'b1;
  end
 end
end
endmodule