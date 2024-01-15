`timescale 1ns / 1ps

`include "uart_brg.vh"
`include "common.vh"

module uart_brg
    #(
        parameter BAUDRATE_PRECISION = `BAUDRATE_PRECISION,
        parameter BAUDRATE_PERIOD    = `BAUDRATE_PERIOD
    )
    (
        input  wire                              clk,
        input  wire                              reset,
        output wire                              baud_tick,
        output wire [BAUDRATE_PRECISION - 1 : 0] baud_rate
    );
    
    reg  [BAUDRATE_PRECISION - 1 : 0] counter_reg;
    wire [BAUDRATE_PRECISION - 1 : 0] counter_next;
    
    always @ (posedge clk) 
    begin
        if (reset)
            counter_reg <= 0;
        else
            counter_reg <= counter_next;
    end

    assign counter_next = (counter_reg == (BAUDRATE_PERIOD - 1)) ? `CLEAR(BAUDRATE_PRECISION) : counter_reg + 1;
    
    assign baud_rate    = counter_reg;
    assign baud_tick    = (counter_reg == (BAUDRATE_PERIOD - 1)) ? `HIGH : `LOW;
endmodule
