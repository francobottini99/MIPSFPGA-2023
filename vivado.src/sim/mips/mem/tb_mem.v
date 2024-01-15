`timescale 1ns / 1ps

`include "tb.vh"

module tb_mem;

    localparam IO_BUS_SIZE   = 32;
    localparam MEM_ADDR_SIZE = 5;

    reg                                           i_clk;
    reg                                           i_reset;
    reg                                           i_flush;
    reg                                           i_mem_wr_rd;
    reg  [1 : 0]                                  i_mem_wr_src;
    reg  [2 : 0]                                  i_mem_rd_src;
    reg  [MEM_ADDR_SIZE - 1 : 0]                  i_mem_addr;
    reg  [IO_BUS_SIZE - 1 : 0]                    i_bus_b;
    wire [IO_BUS_SIZE - 1 : 0]                    o_mem_rd;
    wire [2**MEM_ADDR_SIZE * IO_BUS_SIZE - 1 : 0] o_bus_debug;

    mem
    #(
        .IO_BUS_SIZE   (IO_BUS_SIZE),
        .MEM_ADDR_SIZE (MEM_ADDR_SIZE)
    )
    dut
    (
        .i_clk        (i_clk),
        .i_reset      (i_reset),
        .i_flush      (i_flush),
        .i_mem_wr_rd  (i_mem_wr_rd),
        .i_mem_wr_src (i_mem_wr_src),
        .i_mem_rd_src (i_mem_rd_src),
        .i_mem_addr   (i_mem_addr),
        .i_bus_b      (i_bus_b),
        .o_mem_rd     (o_mem_rd),
        .o_bus_debug  (o_bus_debug)
    );

    `CLK_TOGGLE(i_clk, `CLK_PERIOD)

    integer i = 0;

    initial
    begin
        $srandom(14161612);

        i_clk = 0;
        i_reset = 1;
        i_flush = 0;
        i_mem_wr_rd = 0;
        i_mem_wr_src = 0;
        i_mem_rd_src = 0;
        i_mem_addr = 0;
        i_bus_b = 0;

        `RANDOM_TICKS_DELAY_MAX_20(`CLK_PERIOD) i_reset = 0;

        $display("\nWrite 20 values:");

        repeat(20)
        begin
                                                     i_bus_b = $urandom;
                                                     i_mem_wr_src = $urandom_range(0, 2);
                                                     $display(" - Write: %b in Addr: %h Wr_src: %b", i_bus_b, i_mem_addr, i_mem_wr_src);
                                                     i_mem_wr_rd = 1;
             `TICKS_DELAY_1(`CLK_PERIOD)             i_mem_wr_rd = 0; 
             `RANDOM_TICKS_DELAY_MAX_20(`CLK_PERIOD) i_mem_addr = i_mem_addr + 1;
        end

        `RANDOM_TICKS_DELAY_MAX_20(`CLK_PERIOD) i_mem_addr = 0; i_bus_b = 0;

        $display("\nRead 20 values:");

        repeat(20)
        begin
             `RANDOM_TICKS_DELAY_MAX_20(`CLK_PERIOD) i_mem_rd_src = $urandom_range(0, 4);
             `RANDOM_TICKS_DELAY_MAX_20(`CLK_PERIOD) $display(" - Read: %b in Addr: %h Rd_src: %b", o_mem_rd, i_mem_addr, i_mem_rd_src);
             `RANDOM_TICKS_DELAY_MAX_20(`CLK_PERIOD) i_mem_addr = i_mem_addr + 1;
        end

        `RANDOM_TICKS_DELAY_MAX_20(`CLK_PERIOD);

        $display("\nDebug bus:");
        for (i = 0; i < 2**MEM_ADDR_SIZE; i = i + 1)
            $display(" - Addr: %h Data: %b", i, o_bus_debug[i * IO_BUS_SIZE +: IO_BUS_SIZE]);

        $finish;
    end

endmodule