`timescale 1ns / 1ps

module tb_button_controller();
    logic clk,rst,PB;

    initial begin
        clk = 1'b0;
        rst = 1'b0;
        PB  = 1'b0;
    end

    always 
        #1 clk = ~ clk;
    
    always begin
        #1
        #2 PB = 1'b1;
        #300 PB = 1'b0;
        #10 PB = 1'b1;
        #4000 PB = 1'b0;
        #400 PB = 1'b0;
    end

    logic button_signal;
    button_controller b_controller(
        .PB_pressed_status(PB_pressed_status),
        .PB_pressed_pulse(PB_pressed_pulse),
        .PB_released_pulse(PB_released_pulse),
        .clk(clk),
        .rst(rst),
        .button_signal(button_signal)
    );

    PB_Debouncer debouncer(
        .clk(clk),
        .rst(rst),
        .PB(PB),
        .PB_pressed_status(PB_pressed_status),
        .PB_pressed_pulse(PB_pressed_pulse),
        .PB_released_pulse(PB_released_pulse)
    );

endmodule