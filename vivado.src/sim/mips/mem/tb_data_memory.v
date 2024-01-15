`timescale 1ns / 1ps

`include "tb.vh"

module tb_data_memory;

    localparam ADDR_SIZE = 5;
    localparam SLOT_SIZE = 32;

    reg                                     i_clk;
    reg                                     i_reset;
    reg                                     i_flush;
    reg                                     i_wr_rd;
    reg  [ADDR_SIZE - 1 : 0]                i_addr;
    reg  [SLOT_SIZE - 1 : 0]                i_data;
    wire [SLOT_SIZE - 1 : 0]                o_data;
    wire [2**ADDR_SIZE * SLOT_SIZE - 1 : 0] o_bus_debug;

    data_memory
    #(
        .ADDR_SIZE (ADDR_SIZE),
        .SLOT_SIZE (SLOT_SIZE)
    )
    dut
    (
        .i_clk       (i_clk),
        .i_reset     (i_reset),
        .i_flush     (i_flush),
        .i_wr_rd     (i_wr_rd),
        .i_addr      (i_addr),
        .i_data      (i_data),
        .o_data      (o_data),
        .o_bus_debug (o_bus_debug)
    );

    `CLK_TOGGLE(i_clk, `CLK_PERIOD)
    
    integer i = 0;
    
    initial
    begin
        $srandom(456613274);
        
        i_clk = 0;
        i_reset = 1;
        i_wr_rd = 0;
        i_addr = 0;
        i_data = 0;
        i_flush = 0;

        `RANDOM_TICKS_DELAY_MAX_20(`CLK_PERIOD) i_reset = 0;

        $display("\nWrite 10 values:");

        repeat(10)
        begin
                                                     i_data = $urandom;
                                                     $display(" - Write: %h in Addr: %h", i_data, i_addr);
                                                     i_wr_rd = 1;
             `TICKS_DELAY_1(`CLK_PERIOD)             i_wr_rd = 0; 
             `RANDOM_TICKS_DELAY_MAX_20(`CLK_PERIOD) i_addr = i_addr + 1;
        end

        `RANDOM_TICKS_DELAY_MAX_20(`CLK_PERIOD) i_wr_rd = 0; i_addr = 0; i_data = 0;

        $display("\nRead 10 values:");

        repeat(10)
        begin
             `RANDOM_TICKS_DELAY_MAX_20(`CLK_PERIOD) $display(" - Read: %h in Addr: %h", o_data, i_addr);
             `RANDOM_TICKS_DELAY_MAX_20(`CLK_PERIOD) i_addr = i_addr + 1;
        end
        
        `RANDOM_TICKS_DELAY_MAX_20(`CLK_PERIOD);
           
        $display("\nDebug bus:");
        for (i = 0; i < 2**ADDR_SIZE; i = i + 1)
            $display(" - Data %d: %h", i, o_bus_debug[i * SLOT_SIZE +: SLOT_SIZE]);
        
        $finish;
    end
endmodule