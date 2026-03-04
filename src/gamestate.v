module gamestate (
    input clk,
    input reset,

    input btnU_e, //button edges
    input btnD_e,
    input btnL_e,
    input btnR_e,
    input anybtn_e,
    input badbtn_e,

    input end_pattern_w,

    output led_all_w,
    output led_pattern_w,
    output led_buttons_w,

    output show_pattern_w,
    output take_pattern_w,

    output take_sample_w,
    output fail_w
);


// Start with all lights on (led_all_w)
// If any button is pressed, sample, then step through pattern with each subsequent press (led_pattern)
// After pattern is stepped through, wait for input
// each correct input flashes the assocaited light (led_buttons_w)
// any incorrect returns to reset state

//declarations ======================================================
localparam RESET_S = 0;
localparam PATTERN_S = 1;
localparam INPUT_S = 2;

logic [4:0] STATE_r;
logic [4:0] STATE_n;


//output logic ======================================================
// assign take_sample_w = (STATE_r == RESET_S) & anybtn_e;
assign take_sample_w = (STATE_n == PATTERN_S) && (STATE_r != PATTERN_S); //transitioning into showing pattern
assign led_all_w = (STATE_r == RESET_S);
assign led_pattern_w = (STATE_r == PATTERN_S);
assign led_buttons_w = (STATE_r == INPUT_S);
assign fail_w = (STATE_n == RESET_S) && (STATE_r == INPUT_S);
assign show_pattern_w = (STATE_r == PATTERN_S);
assign take_pattern_w = (STATE_r == INPUT_S);


// State logic ======================================================
// update state
always @(posedge clk) begin
    if (reset) begin
        STATE_r <= RESET_S;
    end else begin
        STATE_r <= STATE_n;
    end
end

// next state logic
always @(*) begin
    case (STATE_r)
        RESET_S: begin
            if (anybtn_e) begin
                STATE_n = PATTERN_S;
            end
            else STATE_n = STATE_r;
        end 
        PATTERN_S: begin
            if (end_pattern_w) begin //finished showing pattern
                STATE_n = INPUT_S;
            end 
            else STATE_n = STATE_r;
        end
        INPUT_S: begin
            if (badbtn_e) begin //wrong input
                STATE_n = RESET_S;
            end else if (end_pattern_w) begin //end of pattern
                STATE_n = PATTERN_S;
            end
            else STATE_n = STATE_r;
        end
        default: STATE_n = STATE_r;
    endcase
end


endmodule