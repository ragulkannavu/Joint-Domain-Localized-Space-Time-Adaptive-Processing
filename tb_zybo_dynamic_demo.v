`timescale 1ns/1ps
module tb_zybo_dynamic_demo;
 reg sysclk=0;reg btn_reset=0;wire pmodcls_tx;wire led_detected,led_done;
 zybo_z7_10_jdl_stap_lcd_top #(.CLK_HZ(125_000_000),.STARTUP_CYCLES(20),.TARGET_PERIOD_CYCLES(625_000),.DISPLAY_PERIOD_CYCLES(375_000)) DUT(.sysclk(sysclk),.btn_reset(btn_reset),.pmodcls_tx(pmodcls_tx),.led_detected(led_detected),.led_done(led_done));
 always #4 sysclk=~sysclk;
 always @(posedge sysclk)begin if(DUT.start)$display("NEW TARGET: scenario=%0d angle=%0d doppler=%0d",DUT.scenario_idx,DUT.actual_angle,DUT.target_doppler);if(DUT.done)$display("RESULT: status=%0d actual=(%0d,%0d) detected_valid=%0d detected=(%0d,%0d)",DUT.lcd_status,DUT.actual_angle,DUT.actual_doppler,DUT.lcd_detected,DUT.detected_angle,DUT.detected_doppler);end
 initial begin #100;btn_reset=1;#16;btn_reset=0;#40000000;$display("Dynamic wrapper simulation complete.");$finish;end
endmodule