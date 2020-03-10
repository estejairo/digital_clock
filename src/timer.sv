`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: UTFSM
// Engineer: Jairo Gonzalez
// 
// Create Date: 07.01.2020 14:17:43
// Design Name: unsigned counter
// Module Name: unsigned_counter
// Project Name: digital_clock
// Target Devices: Nexys4 DDR
// Description: unsigned counter N bits. start, stop, forward and backwards modes
// 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module timer (
    input   logic clk,
    input   logic clk_timer,
    input   logic rst,
    output  logic [23:0] number
    
    );

    logic rst_seconds,rst_seconds_next;
    logic start_minutes,start_minutes_next;
    
    logic [7:0] seconds;

    logic seconds_main_rst = (rst||rst_seconds);

    unsigned_counter #(.BITS(8)) second (
        .clk(clk_timer),
        .rst(seconds_main_rst),
        .start(1'b1), //1 to start, 0 to stop
        .forward(1'b1), //1 to cout forward, 0 to count backwards
        .number(seconds[7:0])
    );

    always_comb begin
        rst_seconds_next = 1'b0;
        start_minutes_next = 1'b0;
        if (seconds[7:0]>=8'd59) begin
            rst_seconds_next = 1'b1;
            start_minutes_next = 1'b1;
        end
        else begin
            rst_seconds_next = 1'b0;
            start_minutes_next = 1'b0;
        end
    end

    always_ff @(posedge clk) begin
        if (rst) begin
            rst_seconds <= 1'b0;
            start_minutes <= 1'b0;
        end
        else begin
            rst_seconds <= rst_seconds_next;
            start_minutes <= start_minutes_next;
        end
    end

    
    logic rst_minutes,rst_minutes_next;
    logic start_hours,start_hours_next;
    logic [7:0] minutes;
    
    logic minutes_main_rst = (rst||rst_minutes);

    unsigned_counter #(.BITS(8)) minute (
        .clk(clk_timer),
        .rst(minutes_main_rst),
        .start(start_minutes), //1 to start, 0 to stop
        .forward(1'b1), //1 to cout forward, 0 to count backwards
        .number(minutes[7:0])
    );

    always_comb begin
        rst_minutes_next = 1'b0;
        start_hours_next = 1'b0;
        if ((minutes[7:0]>=8'd59)&&(seconds[7:0]>=8'd59)) begin
            rst_minutes_next = 1'b1;
            start_hours_next = 1'b1;
        end
        else begin
            rst_minutes_next = 1'b0;
            start_hours_next = 1'b0;
        end
    end

    always_ff @(posedge clk) begin
        if (rst) begin
            rst_minutes <= 1'b0;
            start_hours <= 1'b0;
        end
        else begin
            rst_minutes <= rst_minutes_next;
            start_hours <= start_hours_next;
        end
    end

    logic rst_hours,rst_hours_next;
    logic [7:0] hours;

    logic hours_main_rst = (rst||rst_hours);

    unsigned_counter #(.BITS(8)) hour (
        .clk(clk_timer),
        .rst(hours_main_rst),
        .start(start_hours), //1 to start, 0 to stop
        .forward(1'b1), //1 to cout forward, 0 to count backwards
        .number(hours[7:0])
    );


    always_comb begin
        rst_hours_next = 1'b0;
        if ((hours[7:0]>=8'd23)&&(minutes[7:0]>=8'd59)&&(seconds[7:0]>=8'd59)) begin
            rst_hours_next = 1'b1;
        end
        else begin
            rst_hours_next = 1'b0;
        end
    end

    always_ff @(posedge clk) begin
        if (rst) begin
            rst_hours <= 1'b0;
        end
        else begin
            rst_hours <= rst_hours_next;
        end
    end
    
    assign number[23:0] = {8'd0,hours[7:0]}* 'd10000 + {8'd0,minutes[7:0]} * 'd100  + {8'd0,seconds[7:0]};

endmodule