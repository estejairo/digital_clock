module  led_alarm#(
 parameter ALARM_TIME = 500_000_000,
 parameter ALARM_TIME_WIDTH = $clog2(ALARM_TIME),
 parameter BLINK_TIME = 12_000_000,
 parameter BLINK_TIME_WIDTH = $clog2(BLINK_TIME),
 parameter PATTERN_TIME = 48_000_000,
 parameter PATTERN_TIME_WIDTH = $clog2(PATTERN_TIME)
 )(
    input   logic clk,
    input   logic rst,
    input   logic start,
    output  logic [13:0] LED
    );

    logic [ALARM_TIME_WIDTH-1:0]    alarm_duration = 'd0;
    logic                           alarm_duration_reset = 1'b0;

    logic [BLINK_TIME_WIDTH-1:0]    blink_duration = 'd0;
    logic                           blink_duration_reset = 1'b0;

    logic [PATTERN_TIME_WIDTH-1:0]  pattern_duration = 'd0;
    logic                           pattern_duration_reset = 1'b0;


    logic play;
    posedge_detector posedge_int(
        .clk(clk),
        .rst(rst),
        .signal(start),
        .detection(play)
        );
    assign possignal = play;

    enum logic[2:0] {WAIT, BLINK, PATTERN} state, state_next;

    logic [13:0] LED_next = 14'd0;

    always_comb begin
        state_next = WAIT;
        LED_next = LED[13:0];
        alarm_duration_reset    = 1'b0;
        blink_duration_reset    = 1'b0;
        pattern_duration_reset  = 1'b0;
        case(state)
            WAIT:       begin
                            alarm_duration_reset    = 1'b1;
                            blink_duration_reset    = 1'b1;
                            pattern_duration_reset  = 1'b1;
                            if (play) begin
                                state_next = BLINK;
                            end
                        end
            BLINK:      begin
                            state_next = BLINK;
                            if (blink_duration >= BLINK_TIME-1) begin
                                blink_duration_reset = 1'b1;
                                LED_next[13:0] = ~LED[13:0];
                            end
                            if (pattern_duration >= PATTERN_TIME-1) begin
                                blink_duration_reset = 1'b1;
                                pattern_duration_reset = 1'b1;
                                state_next = PATTERN;
                            end
                            if (alarm_duration >= ALARM_TIME-1) begin
                                alarm_duration_reset = 1'b1;
                                blink_duration_reset = 1'b1;
                                pattern_duration_reset = 1'b1;
                                LED_next[13:0] = 14'd0;
                                state_next = WAIT;
                            end
                        end
            PATTERN:    begin
                            blink_duration_reset    = 1'b1;
                            state_next = PATTERN;
                            if (pattern_duration >= PATTERN_TIME-1) begin
                                pattern_duration_reset = 1'b1;
                                state_next = BLINK;
                            end
                        end
        endcase  
    end

    always_ff @(posedge clk) begin
       if (rst ||alarm_duration_reset) 
           alarm_duration <= 'd0;
       else
           alarm_duration <= alarm_duration + 'd1;       
    end

    always_ff @(posedge clk) begin
       if (rst ||blink_duration_reset) 
           blink_duration <= 'd0;
       else
           blink_duration <= blink_duration + 'd1;       
    end

    always_ff @(posedge clk) begin
       if (rst ||pattern_duration_reset) 
           pattern_duration <= 'd0;
       else
           pattern_duration <= pattern_duration + 'd1;       
    end

    always_ff @(posedge clk) begin
        if (rst) begin
            state <= WAIT;
            LED[13:0] <= 14'd0;
        end
        else begin
            state <= state_next;
            LED[13:0] <= LED_next[13:0];
        end

    end


endmodule