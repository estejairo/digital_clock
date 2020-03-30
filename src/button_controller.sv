`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: UTFSM
// Engineer: Jairo Gonzalez
// 
// Create Date: 07.01.2020 14:17:43
// Design Name: Button Controller
// Module Name: button_controller
// Project Name: digital_clock
// Target Devices: Nexys4 DDR
// Description: Emits button_signal pulse when PB is pressed. If it's pressed more 
//              than T_HOLD clock cycles, it starts emitting pulses every T_PULSE
//              clock cycles until PB is released (toggle).
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module button_controller#(
 parameter T_HOLD           = 100_000_000,      //Clock cycles number to wait
 parameter T_HOLD_WIDTH     = $clog2(T_HOLD),   //T_HOLD bits size
 parameter T_TOGGLE          = 5_000_000,       //Clock cycles number between pulses
 parameter T_TOGGLE_WIDTH    = $clog2(T_TOGGLE)   //T_TOGGLE bits size
 )(
    input   logic PB_pressed_status,
    input   logic PB_pressed_pulse,
    input   logic PB_released_pulse,
    input   logic clk,
    input   logic rst,
    output  logic button_signal
    );

    //States
    enum logic[2:0] {IDLE, COUNT, TOGGLE} state, state_next;
    
    //Signals to count clock cycles and resets these counters
    logic [T_HOLD_WIDTH-1:0]    hold_duration; 
    logic                       hold_duration_reset;

    logic [T_TOGGLE_WIDTH-1:0]   toggle_duration;
    logic                       toggle_duration_reset;

    
    //FSM
    always_comb begin

    //Default status
    state_next              = IDLE;
    button_signal           = 1'b0;
    hold_duration_reset     = 1'b1;
    toggle_duration_reset   = 1'b1;
    
    case(state)
        IDLE:   begin //Nothing happening
                    if(PB_pressed_pulse) begin //If PB pressed, emit a signal and start counting
                        state_next      = COUNT;
                        button_signal   = 1'b1;
                    end
                end
        COUNT:  begin //Counting until hold
                    // If PB is pressed and meets time requeriment, beging holding toogle state
                    if (PB_pressed_status && (hold_duration >= T_HOLD-1)) begin
                        state_next              = TOGGLE;
                        button_signal           = 1'b1;
                    end
                    else if (PB_pressed_status) begin
                        state_next          = COUNT;
                        hold_duration_reset = 1'b0;
                    end
                end
        TOGGLE:   begin //Hold status until PB is released
                    if (~PB_released_pulse && (toggle_duration >= T_TOGGLE-1)) begin
                        button_signal   = 1'b1;
                        state_next      = TOGGLE;
                    end
                    else if (~PB_released_pulse) begin
                        state_next              = TOGGLE;
                        toggle_duration_reset    = 1'b0;
                    end
                end
    endcase
    end

    always_ff @(posedge clk) begin
        if (rst)
            state <= IDLE;
        else
            state <= state_next;
    end

    always_ff @(posedge clk) begin
       if (rst || hold_duration_reset) 
           hold_duration <= 8'd0;
       else
           hold_duration <= hold_duration + 8'd1;       
    end

    always_ff @(posedge clk) begin
       if (rst || toggle_duration_reset) 
           toggle_duration <= 8'd0;
       else
           toggle_duration <= toggle_duration + 8'd1;       
    end

endmodule