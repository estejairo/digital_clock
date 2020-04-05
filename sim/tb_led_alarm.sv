`timescale 1ns / 1ps

module tb_led_alarm();
    logic clk,rst,play;
    logic [13:0] leds;

    initial begin
        clk = 1'b0;
        rst = 1'b0;
        play  = 1'b0;
        leds[13:0] = 14'd0;
    end

    always 
        #1 clk = ~ clk;
    
    always begin
        #1
        #10 play = 1'b1;
    end
    
    led_alarm #(
        .ALARM_TIME(500),
        .BLINK_TIME(12),
        .PATTERN_TIME(48)
    ) led_inst(
        .clk(clk),
        .rst(rst),
        .start(play),
        .LED(leds[13:0])
    );


endmodule