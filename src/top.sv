`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: UTFSM
// Engineer: Jairo Gonzalez
// 
// Create Date: 05.01.2020 14:17:43
// Design Name: digital_clock
// Module Name: top
// Project Name: digital_clock
// Target Devices: Nexys4 DDR
// Description: digital clock, configurable led alarm
// 
// Dependencies:
//                  * clv_divider.v
//                  * unsigned_to_bcd.v
//                  * bcd_to_ss.v
//                  * display_mux_v
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module top(
        input 	logic CLK100MHZ,
        input   logic CPU_RESETN,
        output 	logic [7:0]AN,
        output  logic CA,CB,CC,CD,CE,CF,CG,DP
    );

    logic rst_status;
    logic rst_press;
    logic rst_release;
    PB_Debouncer cpu_reset_debouncer(
        .clk(CLK100MHZ),
        .rst(1'b0),
        .PB(~CPU_RESETN),
        .PB_pressed_status(rst_status),
        .PB_pressed_pulse(rst_press),
        .PB_released_pulse(rst_release)
    );

    logic clk_display;
    clk_divider #(.O_CLK_FREQ(1000)) clk_divider_display (
        .clk_in(CLK100MHZ),
        .reset(rst_press),
        .clk_out(clk_display)
    );

    clk_divider #(.O_CLK_FREQ(1)) clk_divider_timer (
        .clk_in(CLK100MHZ),
        .reset(rst_press),
        .clk_out(clk_timer)
    );

    
    // logic [7:0] seconds;
    // logic [7:0] minutes;
    // logic [7:0] hours;
    logic [23:0] number;
    timer timer_inst(
        .clk(CLK100MHZ),
        .clk_timer(clk_timer),
        .rst(rst_press),
        .number(number[23:0])
    );

    logic idle;
    logic [31:0] bcd;
    unsigned_to_bcd u32_to_bcd_inst (
		.clk(CLK100MHZ),
		.trigger(1'b1),
		.in({8'd0,number[23:0]}),
		.idle(idle),
		.bcd(bcd[31:0])
	);

    display_mux display_inst (
        .clk(clk_display),
        .clk_enable(1'b1),
        .bcd({8'hFF,bcd[23:0]}),
        .dots(8'd0),
        .is_negative(1'b0),
        .turn_off(1'b0),
        .ss_value({DP,CG,CF,CE,CD,CC,CB,CA}),
        .ss_select(AN[7:0])
    );

endmodule
