`timescale 1ns / 1ps

module tb_timer();
    logic clk,rst;

    logic [23:0] number;
    

    initial begin
        clk = 1'b0;
        rst = 1'b0;

        number[23:0] = 24'd0;
    end

    always 
        #1 clk = ~ clk;

    timer  #(.T_HOLD(5)) timer_inst(
        .clk(clk),
        .rst(rst),
        .number(number[23:0])
    );

endmodule