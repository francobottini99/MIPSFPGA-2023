`timescale 1ns / 1ps

`include "data_memory.vh"

module data_memory
    #(
        parameter ADDR_SIZE = `DEFAULT_DATA_MEMORY_ADDR_SIZE,
        parameter SLOT_SIZE = `DEFAULT_DATA_MEMORY_SLOT_SIZE
    )
    (      
        input  wire                                    i_clk,
        input  wire                                    i_reset,
        input  wire                                    i_flush,
        input  wire                                    i_wr_rd,
        input  wire [ADDR_SIZE - 1 : 0]                i_addr,
        input  wire [SLOT_SIZE - 1 : 0]                i_data,
        output wire [SLOT_SIZE - 1 : 0]                o_data,
        output wire [2**ADDR_SIZE * SLOT_SIZE - 1 : 0] o_bus_debug
    );

    reg [SLOT_SIZE - 1 : 0] memory [2**ADDR_SIZE - 1 : 0];
    reg [SLOT_SIZE - 1 : 0] read_data;

    integer i = 0;

    always@(negedge i_clk) 
    begin
        if (i_reset || i_flush) 
            begin
                for (i = 0; i < 2**ADDR_SIZE; i = i + 1)
                    memory[i] <= `CLEAR(SLOT_SIZE);

                read_data <= `CLEAR(SLOT_SIZE);
            end
        else
            begin
                if (i_wr_rd)
                    memory[i_addr] <= i_data;
                else
                    read_data <= memory[i_addr];
            end
    end

    assign o_data = read_data;

    generate
        genvar j;
        
        for (j = 0; j < 2**ADDR_SIZE; j = j + 1) begin : GEN_DEBUG_BUS
            assign o_bus_debug[(j + 1) * SLOT_SIZE - 1 : j * SLOT_SIZE] = memory[j];
        end
    endgenerate
endmodule