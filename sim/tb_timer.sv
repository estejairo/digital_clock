`timescale 1ns / 1ps

module tb_timer();

    logic clk,clk_timer,rst;
    logic [23:0] number = 24'b0;

    initial begin
        clk = 1'b0;
        clk_timer = 1'b0;
        rst = 1'b0;
        #3 rst = 1'b1;
        #3 rst = 1'b0;
    end

    always 
        #1 clk = ~ clk;
    
    always
        #61 clk_timer = ~ clk_timer;

    timer timer_inst(
        .clk(clk),
        .clk_timer(clk_timer),
        .rst(rst),
        .number(number[23:0])
    );

endmodule