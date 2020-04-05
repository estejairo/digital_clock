`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: UTFSM
// Engineer: Jairo Gonzalez
// 
// Create Date: 07.02.2020 14:17:43
// Design Name: timer
// Module Name: timer
// Project Name: digital_clock
// Target Devices: Nexys4 DDR
// Description: Enable a timer with adjustable period. Seconds, minutes and hours
//              availables.
// 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module timer#(
    parameter T_HOLD           = 100_000_000,     //Clock cycles number to wait
    parameter T_HOLD_WIDTH     = $clog2(T_HOLD)   //T_HOLD bits size
    )(
    input   logic clk,
    input   logic rst,
    input   logic start_timer,
    input   logic adjust_minutes,
    input   logic adjust_hours,
    output  logic [23:0] number
    
    );
    
    logic [7:0] seconds;
    logic start_seconds = 1'b0;
    logic rst_seconds = 1'b0;
    unsigned_counter #(.BITS(8)) second (
        .clk(clk),
        .rst(rst||rst_seconds),
        .start(start_seconds), //1 to start, 0 to stop
        .forward(1'b1), //1 to cout forward, 0 to count backwards
        .number(seconds[7:0])
    );


    logic [7:0] minutes;
    logic start_minutes = 1'b0;
    logic rst_minutes = 1'b0;
    unsigned_counter #(.BITS(8)) minute (
        .clk(clk),
        .rst(rst||rst_minutes),
        .start(start_minutes), //1 to start, 0 to stop
        .forward(1'b1), //1 to cout forward, 0 to count backwards
        .number(minutes[7:0])
    );


    logic [7:0] hours;
    logic start_hours = 1'b0;
    logic rst_hours = 1'b0;
    unsigned_counter #(.BITS(8)) hour (
        .clk(clk),
        .rst(rst||rst_hours),
        .start(start_hours), //1 to start, 0 to stop
        .forward(1'b1), //1 to cout forward, 0 to count backwards
        .number(hours[7:0])
    );
    
    enum logic[2:0] {WAIT, ADD_SECOND, ADD_MINUTE, ADD_HOUR} state, state_next;

    logic [T_HOLD_WIDTH-1:0]    hold_duration = 'b0; 
    logic                       hold_duration_reset = 1'b0;

    always_comb begin
        
        start_seconds = 1'b0;
        start_minutes = 1'b0;
        start_hours   = 1'b0;

        rst_seconds = 1'b0;
        rst_minutes = 1'b0;
        rst_hours   = 1'b0;

        state_next = WAIT;
        hold_duration_reset = 1'b0;

        case(state)
            WAIT:       begin
                            if (adjust_minutes)
                                state_next = ADD_MINUTE;
                            else if (adjust_hours)
                                state_next = ADD_HOUR;
                            else if (hold_duration >= T_HOLD-1)
                                state_next = ADD_SECOND;                   
                        end

            ADD_SECOND:  begin
                            state_next = WAIT;
                            hold_duration_reset = 1'b1;
                            start_seconds       = start_timer;
                            if (seconds[7:0]>=8'd59) begin
                                start_seconds   = 1'b0;
                                rst_seconds     = 1'b1;
                                start_minutes   = 1'b1;
                                if (minutes[7:0]>=8'd59) begin
                                    start_minutes   = 1'b0;
                                    rst_minutes     = 1'b1;
                                    start_hours     = 1'b1;
                                    if (hours[7:0]>=8'd23) begin
                                        start_hours = 1'b0;
                                        rst_hours   = 1'b1;
                                    end
                                end
                            end
                        end
            
            ADD_MINUTE: begin
                            state_next = WAIT;
                            if (hold_duration >= T_HOLD-1) begin
                                hold_duration_reset = 1'b1;
                                start_seconds       = start_timer;
                                if (seconds[7:0]>=8'd59) begin
                                    start_seconds   = 1'b0;
                                    rst_seconds     = 1'b1;
                                end
                            end
                            start_minutes   = 1'b1;
                            if (minutes[7:0]>=8'd59) begin
                                start_minutes   = 1'b0;
                                rst_minutes     = 1'b1;
                            end
                        end

            ADD_HOUR:   begin
                            state_next = WAIT;
                            if (hold_duration >= T_HOLD-1) begin
                                hold_duration_reset = 1'b1;
                                start_seconds       = start_timer;
                                if (seconds[7:0]>=8'd59) begin
                                    start_seconds   = 1'b0;
                                    rst_seconds     = 1'b1;
                                    start_minutes   = 1'b1;
                                    if (minutes[7:0]>=8'd59) begin
                                        start_minutes   = 1'b0;
                                        rst_minutes     = 1'b1;
                                    end
                                end
                            end
                            start_hours     = 1'b1;
                            if (hours[7:0]>=8'd23) begin
                                start_hours = 1'b0;
                                rst_hours   = 1'b1;
                            end
                        end
        endcase
    end
    
    always_ff @(posedge clk) begin
       if (rst || hold_duration_reset) 
           hold_duration <= 'd0;
       else
           hold_duration <= hold_duration + 'd1;       
    end

    always_ff @(posedge clk) begin
        if (rst)
            state <= WAIT;
        else
            state <= state_next;
    end

    assign number[23:0] = {8'd0,hours[7:0]}* 'd10000 + {8'd0,minutes[7:0]} * 'd100  + {8'd0,seconds[7:0]};


endmodule
