`timescale 1ns / 1ps

module tb_unsigned_counter();

    logic clk,rst,start,forward;
    logic [7:0] number;

    initial begin
        clk = 1'b0;
        rst = 1'b0;
        start = 1'b0;
        forward = 1'b0;
        number[7:0] = 8'b0;
    end

    always 
        #1 clk = ~ clk;

    always begin
        #1
        #4  start   = 1'b0;
            forward = 1'b1;
        #4  start   = 1'b1;
        #8 start   = 1'b0;
        #4  start   = 1'b1;
        #4  rst     = 1'b1;
        #2  rst     = 1'b0;
        #4  forward = 1'b0;
        #8 start   = 1'b0;
        #4  rst     = 1'b1;
        #2  rst     = 1'b0;
        #4  start   = 1'b1;
            forward = 1'b1;
        #8 forward = 1'b0;
        #8 forward = 1'b1;
        #8 start   = 1'b0;
        #4  rst     = 1'b1;
        #2  rst     = 1'b0;
    end

    unsigned_counter #(.BITS(8)) counter_test (
        .clk(clk),
        .rst(rst),
        .start(start), //1 to start, 0 to stop
        .forward(forward), //1 to cout forward, 0 to count backwards
        .number(number[7:0])
    );

endmodule