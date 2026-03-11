/*
 * Copyright (c) 2026 Ben Watkins
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module tt_um_memgame (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // always 1 when the design is powered, so you can ignore it
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);

    // All output pins must be assigned. If not used, assign to 0.
    // assign uo_out  = ui_in + uio_in;  // Example: ou_out is the sum of ui_in and uio_in
    assign uio_out = 0;
    assign uio_oe  = 0;

    // List all unused inputs to prevent warnings
    wire _unused = &{ena, ui_in[7:4], 1'b0};


    // MY CODE ================================================================
    wire reset;
    assign reset = ~(rst_n); //positive polarity reset for my convenience
    wire btnU_UNSAFE, btnD_UNSAFE, btnL_UNSAFE, btnR_UNSAFE;
    assign btnU_UNSAFE = ui_in[0];
    assign btnD_UNSAFE = ui_in[1];
    assign btnL_UNSAFE = ui_in[2];
    assign btnR_UNSAFE = ui_in[3];
    wire ledU, ledD, ledL, ledR;
    assign uo_out = {4'b0, ledR, ledL, ledD, ledU};

    //state machine inputs/outputs
    wire take_sample_w;
    wire led_all_w, led_pattern_w, led_buttons_w;
    wire fail_w;
    wire end_pattern_w;
    wire show_pattern_w;
    wire take_pattern_w;
    wire badbtn_e;
    
    // Input buffering/edge detection ===============================
    logic btnU, btnD, btnL, btnR;
    logic btnU_n, btnD_n, btnL_n, btnR_n; //next value
    logic btnU_p, btnD_p, btnL_p, btnR_p; //prev value
    wire  btnU_e, btnD_e, btnL_e, btnR_e; //edge detection
    always @(posedge clk) begin
        if (reset) begin
            btnU_n <= 0;
            btnD_n <= 0;
            btnL_n <= 0;
            btnR_n <= 0;
            btnU <= 0;
            btnD <= 0;
            btnL <= 0;
            btnR <= 0;
            btnU_p <= 0;
            btnD_p <= 0;
            btnL_p <= 0;
            btnR_p <= 0;
        end else begin
            btnU_n <= btnU_UNSAFE;
            btnD_n <= btnD_UNSAFE;
            btnL_n <= btnL_UNSAFE;
            btnR_n <= btnR_UNSAFE;
            btnU <= btnU_n;
            btnD <= btnD_n;
            btnL <= btnL_n;
            btnR <= btnR_n;
            btnU_p <= btnU;
            btnD_p <= btnD;
            btnL_p <= btnL;
            btnR_p <= btnR;
        end
    end

    assign btnU_e = btnU & (~btnU_p);
    assign btnD_e = btnD & (~btnD_p);
    assign btnL_e = btnL & (~btnL_p);
    assign btnR_e = btnR & (~btnR_p);

    wire anybtn_e; //any button edge
    assign anybtn_e = btnU_e | btnD_e | btnL_e | btnR_e;

    // Random value generator =======================================
    // Just a counter that is always going. Randomness comes from input
    logic [1:0] rval;
    wire [2:0] sample_w;
    always @(posedge clk) begin
        if (reset) begin
            rval <= 2'd0;
        end else begin
            rval <= rval + 1;
        end
    end
    assign sample_w = {1'b0, rval[1:0]} + 1; //from 0-3 to 1-4


    // Memory for current output pattern ============================
    // logic [31:0] pattern_r [2:0]; //this didnt work, idk if its the simulator or just a skill issue
    logic [2:0] pattern0_r; //0 -> none, 1 -> U, 2 -> D, 3 -> L, 4 -> R
    logic [2:0] pattern1_r;
    logic [2:0] pattern2_r;
    logic [2:0] pattern3_r;
    logic [2:0] pattern4_r;
    logic [2:0] pattern5_r;
    logic [2:0] pattern6_r;
    logic [2:0] pattern7_r;
    logic [2:0] pattern8_r;
    logic [2:0] pattern9_r;
    logic [2:0] pattern10_r;
    logic [2:0] pattern11_r;
    logic [2:0] pattern12_r;
    logic [2:0] pattern13_r;
    logic [2:0] pattern14_r;
    logic [2:0] pattern15_r;

    logic [7:0] pattern_length_r;

    wire pattU_w;
    wire pattD_w;
    wire pattL_w;
    wire pattR_w;

    always @(posedge clk) begin
        if (reset | fail_w) begin
            pattern0_r <= 0;
            pattern1_r <= 0;
            pattern2_r <= 0;
            pattern3_r <= 0;
            pattern4_r <= 0;
            pattern5_r <= 0;
            pattern6_r <= 0;
            pattern7_r <= 0;
            pattern8_r <= 0;
            pattern9_r <= 0;
            pattern10_r <= 0;
            pattern11_r <= 0;
            pattern12_r <= 0;
            pattern13_r <= 0;
            pattern14_r <= 0;
            pattern15_r <= 0;

            pattern_length_r <= 0;
        end else if (take_sample_w) begin
            pattern0_r <= sample_w;

            pattern1_r <= pattern0_r;
            pattern2_r <= pattern1_r;
            pattern3_r <= pattern2_r;
            pattern4_r <= pattern3_r;
            pattern5_r <= pattern4_r;
            pattern6_r <= pattern5_r;
            pattern7_r <= pattern6_r;
            pattern8_r <= pattern7_r;
            pattern9_r <= pattern8_r;
            pattern10_r <= pattern9_r;
            pattern11_r <= pattern10_r;
            pattern12_r <= pattern11_r;
            pattern13_r <= pattern12_r;
            pattern14_r <= pattern13_r;
            pattern15_r <= pattern14_r;

            pattern_length_r <= pattern_length_r + 1;
        end
    end

    // Step through pattern =========================================
    logic [7:0] patt_step_r;    //where in the pattern are we?
    logic [7:0] patt_step_n;    //next step
    logic [2:0] curr_patt_r;    // store current step value
    logic [2:0] curr_patt_n;    // prepare next step value

    always @(posedge clk) begin
        if (reset) begin
            patt_step_r <= 0;
            curr_patt_r <= 0;
        end else begin
            patt_step_r <= patt_step_n;
            curr_patt_r <= curr_patt_n;
        end
    end
        
    //where in pattern are we (for displaying or playing)
    always @(*) begin
        if (take_sample_w) begin
            patt_step_n = 0;
        end else if (show_pattern_w) begin
            if (end_pattern_w) begin
                patt_step_n = 0;
            end else if (anybtn_e) begin //only step thru pattern on button press
                patt_step_n = patt_step_r + 1;
            end else begin
                patt_step_n = patt_step_r;
            end
        end else if (take_pattern_w) begin
            if (end_pattern_w | badbtn_e) begin
                patt_step_n = 0;
            end else if (anybtn_e) begin
                patt_step_n = patt_step_r + 1;
            end else begin
                patt_step_n = patt_step_r;
            end
        end else begin
            patt_step_n = patt_step_r;
        end
    end

    //update current register
    always @(*) begin
        case(patt_step_r)
            0: curr_patt_n = pattern0_r;
            1: curr_patt_n = pattern1_r;
            2: curr_patt_n = pattern2_r;
            3: curr_patt_n = pattern3_r;
            4: curr_patt_n = pattern4_r;
            5: curr_patt_n = pattern5_r;
            6: curr_patt_n = pattern6_r;
            7: curr_patt_n = pattern7_r;
            8: curr_patt_n = pattern8_r;
            9: curr_patt_n = pattern9_r;
            10: curr_patt_n = pattern10_r;
            11: curr_patt_n = pattern10_r;
            12: curr_patt_n = pattern10_r;
            13: curr_patt_n = pattern10_r;
            14: curr_patt_n = pattern10_r;
            15: curr_patt_n = pattern10_r;
            default: curr_patt_n = 0;
        endcase
    end

    //determine if correct button press
    logic [0:0] goodbtn;
    always @(*) begin
        if (anybtn_e) begin
            case (curr_patt_r)
                1: begin
                    if (btnU) goodbtn = 1;
                    else goodbtn = 0;
                end
                2: begin
                    if (btnD) goodbtn = 1;
                    else goodbtn = 0;
                end
                3: begin
                    if (btnL) goodbtn = 1;
                    else goodbtn = 0;
                end
                4: begin
                    if (btnR) goodbtn = 1;
                    else goodbtn = 0;
                end
                default: goodbtn = 0;
            endcase
        end
    end
    assign badbtn_e = anybtn_e & (~goodbtn);

    assign end_pattern_w = (patt_step_r == pattern_length_r);

    // LED Outputs ==================================================
    assign pattU_w = (curr_patt_r == 1);
    assign pattD_w = (curr_patt_r == 2);
    assign pattL_w = (curr_patt_r == 3);
    assign pattR_w = (curr_patt_r == 4);

    assign ledU = led_all_w | led_pattern_w & pattU_w | led_buttons_w & btnU;
    assign ledD = led_all_w | led_pattern_w & pattD_w | led_buttons_w & btnD;
    assign ledL = led_all_w | led_pattern_w & pattL_w | led_buttons_w & btnL;
    assign ledR = led_all_w | led_pattern_w & pattR_w | led_buttons_w & btnR;

    // Game state machine ===========================================
    //debug assignments

    gamestate simonstate (
        .clk(clk),
        .reset(reset),
        .btnU_e(btnU_e),
        .btnD_e(btnD_e),
        .btnL_e(btnL_e),
        .btnR_e(btnR_e),
        .anybtn_e(anybtn_e),
        .badbtn_e(badbtn_e),

        .end_pattern_w(end_pattern_w),

        .led_all_w(led_all_w),
        .led_pattern_w(led_pattern_w),
        .led_buttons_w(led_buttons_w),

        .show_pattern_w(show_pattern_w),
        .take_pattern_w(take_pattern_w),

        .take_sample_w(take_sample_w),
        .fail_w(fail_w)
    );


endmodule
