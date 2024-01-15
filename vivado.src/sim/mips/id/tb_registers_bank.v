`timescale 1ns / 1ps

`include "tb.vh"

module tb_registers_bank;

    parameter REGISTERS_BANK_SIZE = 10;
    parameter REGISTERS_SIZE      = 32;

    reg                                                 i_clk;
    reg                                                 i_reset;
    reg                                                 i_flush;
    reg                                                 i_write_enable; 
    reg  [$clog2(REGISTERS_BANK_SIZE) - 1 : 0]          i_addr_a;
    reg  [$clog2(REGISTERS_BANK_SIZE) - 1 : 0]          i_addr_b;
    reg  [$clog2(REGISTERS_BANK_SIZE) - 1 : 0]          i_addr_wr;
    reg  [REGISTERS_SIZE - 1 : 0]                       i_bus_wr;
    wire [REGISTERS_SIZE - 1 : 0]                       o_bus_a;
    wire [REGISTERS_SIZE - 1 : 0]                       o_bus_b;
    wire [REGISTERS_BANK_SIZE * REGISTERS_SIZE - 1 : 0] o_bus_debug;

    registers_bank 
    #(
        .REGISTERS_BANK_SIZE (REGISTERS_BANK_SIZE),
        .REGISTERS_SIZE      (REGISTERS_SIZE)
    ) 
    dut 
    (
        .i_clk          (i_clk),
        .i_reset        (i_reset),
        .i_flush        (i_flush),
        .i_write_enable (i_write_enable),
        .i_addr_a       (i_addr_a),
        .i_addr_b       (i_addr_b),
        .i_addr_wr      (i_addr_wr),
        .i_bus_wr       (i_bus_wr),
        .o_bus_a        (o_bus_a),
        .o_bus_b        (o_bus_b),
        .o_bus_debug    (o_bus_debug)
    );

    `CLK_TOGGLE(i_clk, `CLK_PERIOD)

    initial 
    begin
        //Temer en cuenta que R0 no se escribe.
        
        $srandom(616563);
        
        i_clk = 0;
        i_reset = 1;
        i_flush = 0;
        i_write_enable = 0;
        i_addr_a = 9;
        i_addr_b = 0;
        i_addr_wr = 0;
        i_bus_wr = 0;

        `RANDOM_TICKS_DELAY_MAX_20(`CLK_PERIOD) i_reset = 0;
        `RANDOM_TICKS_DELAY_MAX_20(`CLK_PERIOD) i_write_enable = 1;
        
        repeat(10)
        begin
                                                     i_bus_wr  = $urandom;
                                                     $display("Write: %h in Addr: %h", i_bus_wr, i_addr_wr);
             `RANDOM_TICKS_DELAY_MAX_20(`CLK_PERIOD) i_addr_wr = i_addr_wr + 1;
            
        end

        `RANDOM_TICKS_DELAY_MAX_20(`CLK_PERIOD) i_write_enable = 0;

        repeat(5)
        begin
            `RANDOM_TICKS_DELAY_MAX_20(`CLK_PERIOD) $display("Read bus A: %h in Addr: %h", o_bus_a, i_addr_a);
                                                    i_addr_a = i_addr_a - 1;
            `RANDOM_TICKS_DELAY_MAX_20(`CLK_PERIOD) $display("Read bus B: %h in Addr: %h", o_bus_b, i_addr_b);
                                                    i_addr_b = i_addr_b + 1;
        end

        `RANDOM_TICKS_DELAY_MAX_20(`CLK_PERIOD);

        $finish;
    end

endmodule