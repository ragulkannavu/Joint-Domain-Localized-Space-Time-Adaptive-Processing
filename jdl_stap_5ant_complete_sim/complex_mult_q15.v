`timescale 1ns/1ps
// Q1.15 complex multiplier with signed saturation.
module complex_mult_q15(input signed [15:0] ar,input signed [15:0] ai,input signed [15:0] br,input signed [15:0] bi,output signed [15:0] pr,output signed [15:0] pi);
 wire signed [31:0] ac=ar*br,bd=ai*bi,ad=ar*bi,bc=ai*br;
 wire signed [32:0] real_wide={ac[31],ac}-{bd[31],bd};
 wire signed [32:0] imag_wide={ad[31],ad}+{bc[31],bc};
 wire signed [32:0] real_scaled=real_wide>>>15,imag_scaled=imag_wide>>>15;
 function signed [15:0] sat16(input signed [32:0] x);
  begin if(x>33'sd32767)sat16=16'sh7FFF;else if(x<-(33'sd32768))sat16=16'sh8000;else sat16=x[15:0];end
 endfunction
 assign pr=sat16(real_scaled);assign pi=sat16(imag_scaled);
endmodule