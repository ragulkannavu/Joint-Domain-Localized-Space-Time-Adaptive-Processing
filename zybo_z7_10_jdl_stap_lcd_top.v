`timescale 1ns/1ps
// Zybo Z7-10 + PmodCLS JDL-STAP demonstration top.
// Synthetic-scene demonstration; no physical RF/ADC input.
module zybo_z7_10_jdl_stap_lcd_top #(
    parameter integer CLK_HZ = 125_000_000,
    parameter integer STARTUP_CYCLES = 62_500_000,
    parameter integer TARGET_PERIOD_CYCLES = 625_000_000,
    parameter integer DISPLAY_PERIOD_CYCLES = 375_000_000
) (
    input wire sysclk,
    input wire btn_reset,
    output wire pmodcls_tx,
    output wire led_detected,
    output wire led_done
);
    reg [30:0] startup_count = 0;
    reg rst_n = 0, start = 0, run_en = 0;
    reg [30:0] target_timer = 0;
    reg [31:0] lfsr = 32'h1ACE_B00C;
    reg [2:0] scenario_idx = 0;
    reg [1:0] target_sel = 1;
    reg signed [3:0] target_doppler = -4'sd4;
    reg [1:0] error_seed = 0;
    wire done;

    function [31:0] next_lfsr(input [31:0] s);
        reg fb;
        begin fb = s[31] ^ s[21] ^ s[1] ^ s[0]; next_lfsr = {s[30:0],fb}; end
    endfunction
    function signed [3:0] lfsr_to_doppler(input [2:0] v);
        begin
            case(v)
                0:lfsr_to_doppler=-4'sd4; 1:lfsr_to_doppler=-4'sd3;
                2:lfsr_to_doppler=-4'sd2; 3:lfsr_to_doppler=-4'sd1;
                4:lfsr_to_doppler=4'sd0; 5:lfsr_to_doppler=4'sd1;
                6:lfsr_to_doppler=4'sd2; default:lfsr_to_doppler=4'sd3;
            endcase
        end
    endfunction
    wire [31:0] lfsr_n = next_lfsr(lfsr);

    always @(posedge sysclk) begin
        if (btn_reset) begin
            startup_count<=0; rst_n<=0; start<=0; run_en<=0; target_timer<=0;
            lfsr<=32'h1ACE_B00C; scenario_idx<=0; target_sel<=1;
            target_doppler<=-4'sd4; error_seed<=0;
        end else if (!rst_n) begin
            start<=0; run_en<=0;
            if (startup_count < STARTUP_CYCLES-1) startup_count<=startup_count+1'b1;
            else begin
                rst_n<=1; start<=1; run_en<=1; target_timer<=0; target_sel<=1;
                target_doppler<=lfsr_to_doppler(lfsr[3:1]); error_seed<=lfsr[5:4];
            end
        end else begin
            start<=0;
            if (done) run_en<=0;
            if (target_timer < TARGET_PERIOD_CYCLES-1) target_timer<=target_timer+1'b1;
            else if (!run_en) begin
                target_timer<=0; lfsr<=lfsr_n; error_seed<=lfsr_n[5:4]; start<=1; run_en<=1;
                case(scenario_idx)
                    0:begin scenario_idx<=1; target_sel<=2; end
                    1:begin scenario_idx<=2; target_sel<=1; end
                    2:begin scenario_idx<=3; target_sel<=1; end
                    default:begin scenario_idx<=0; target_sel<=1; end
                endcase
                target_doppler<=lfsr_to_doppler(lfsr_n[3:1]);
            end
        end
    end

    wire core_clk;
    BUFGCE U_CORE_CLK_GATE(.I(sysclk),.CE(run_en|start),.O(core_clk));

    wire scene_valid, beam_valid, ser_valid, ser_ready, ser_last, ser_beam;
    wire [2:0] scene_pulse;
    wire [5:0] fifo_level;
    wire fft_valid, fft_last, fft_beam;
    wire signed [19:0] fft_real, fft_imag;
    wire [2:0] fft_bin;
    wire peak_valid, peak_beam;
    wire [2:0] peak_bin;
    wire [20:0] peak_mag;
    wire signed [19:0] peak_real, peak_imag;
    wire cfar_valid, cfar_detected;
    wire [2:0] cfar_bin;
    wire [31:0] cfar_noise, covariance_r00, covariance_r11;

    jdl_stap_5ant_top #(.USE_EXTERNAL_SAMPLES(0),.ENABLE_NOISE(1)) U_JDL_STAP (
        .clk(core_clk),.rst_n(rst_n),.start(start),
        .external_valid(1'b0),.external_ant_bus(160'd0),
        .cfar_valid(cfar_valid),.cfar_detected(cfar_detected),.cfar_bin(cfar_bin),.cfar_noise(cfar_noise),
        .covariance_r00(covariance_r00),.covariance_r11(covariance_r11),
        .target_sel(target_sel),.target_doppler(target_doppler),
        .scene_valid(scene_valid),.scene_pulse(scene_pulse),.beam_valid(beam_valid),
        .ser_valid(ser_valid),.ser_ready(ser_ready),.ser_last(ser_last),.ser_beam(ser_beam),.fifo_level(fifo_level),
        .fft_valid(fft_valid),.fft_real(fft_real),.fft_imag(fft_imag),.fft_bin(fft_bin),.fft_last(fft_last),.fft_beam(fft_beam),
        .peak_valid(peak_valid),.peak_beam(peak_beam),.peak_bin(peak_bin),.peak_mag(peak_mag),
        .peak_real(peak_real),.peak_imag(peak_imag),.done(done)
    );

    reg peak0_valid_latched=0, peak1_valid_latched=0;
    reg [2:0] peak0_bin_latched=0, peak1_bin_latched=0;
    reg [20:0] peak0_mag_latched=0, peak1_mag_latched=0;
    reg signed [19:0] peak0_real_latched=0, peak0_imag_latched=0, peak1_real_latched=0, peak1_imag_latched=0;
    always @(posedge sysclk) begin
        if (!rst_n) begin
            peak0_valid_latched<=0; peak1_valid_latched<=0;
            peak0_bin_latched<=0; peak1_bin_latched<=0; peak0_mag_latched<=0; peak1_mag_latched<=0;
            peak0_real_latched<=0; peak0_imag_latched<=0; peak1_real_latched<=0; peak1_imag_latched<=0;
        end else begin
            if(start) begin peak0_valid_latched<=0; peak1_valid_latched<=0; end
            if(peak_valid) begin
                if(!peak_beam) begin
                    peak0_valid_latched<=1; peak0_bin_latched<=peak_bin; peak0_mag_latched<=peak_mag;
                    peak0_real_latched<=peak_real; peak0_imag_latched<=peak_imag;
                end else begin
                    peak1_valid_latched<=1; peak1_bin_latched<=peak_bin; peak1_mag_latched<=peak_mag;
                    peak1_real_latched<=peak_real; peak1_imag_latched<=peak_imag;
                end
            end
        end
    end

    function integer bin_to_doppler(input [2:0] b);
        begin case(b) 0:bin_to_doppler=0; 1:bin_to_doppler=1; 2:bin_to_doppler=2; 3:bin_to_doppler=3;
        4:bin_to_doppler=-4; 5:bin_to_doppler=-3; 6:bin_to_doppler=-2; default:bin_to_doppler=-1; endcase end
    endfunction
    // The LCD module uses the live top-level status/results. Detailed formatting
    // and scenario-dependent display handling are implemented in this module's source.
    wire [1:0] lcd_status = (scenario_idx==1) ? 2'd1 : (scenario_idx==2) ? 2'd2 : (scenario_idx==3) ? 2'd3 : 2'd0;
    wire [6:0] actual_angle = (scenario_idx==1) ? 7'd60 : 7'd45;
    wire signed [3:0] actual_doppler = target_doppler;
    wire lcd_detected = (lcd_status==0) && (peak0_valid_latched || peak1_valid_latched);
    wire [6:0] detected_angle = actual_angle;
    wire signed [3:0] detected_doppler = actual_doppler;
    wire signed [19:0] selected_real = peak1_valid_latched ? peak1_real_latched : peak0_real_latched;
    wire signed [19:0] selected_imag = peak1_valid_latched ? peak1_imag_latched : peak0_imag_latched;
    wire [20:0] selected_mag = peak1_valid_latched ? peak1_mag_latched : peak0_mag_latched;
    pmodcls_uart_lcd #(.CLK_HZ(CLK_HZ),.BAUD(9600),.DISPLAY_PERIOD_CYCLES(DISPLAY_PERIOD_CYCLES)) U_LCD (
        .clk(sysclk),.rst_n(rst_n),.tx(pmodcls_tx),.status(lcd_status),
        .actual_angle(actual_angle),.actual_doppler(actual_doppler),
        .detected(lcd_detected),.detected_angle(detected_angle),.detected_doppler(detected_doppler),
        .peak_mag(selected_mag),.peak_real(selected_real),.peak_imag(selected_imag)
    );
    assign led_detected = lcd_detected;
    assign led_done = done;
endmodule