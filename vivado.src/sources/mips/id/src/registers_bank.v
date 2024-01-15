`timescale 1ns / 1ps

`include "registers_bank.vh"

module registers_bank
    #(
        parameter REGISTERS_BANK_SIZE = `DEFAULT_REGISTERS_BANK_SIZE,
        parameter REGISTERS_SIZE      = `DEFAULT_REGISTERS_SIZE
    )
    (
        input  wire                                                i_clk, 
        input  wire                                                i_reset,
        input  wire                                                i_flush,
        input  wire                                                i_write_enable,
        input  wire [$clog2(REGISTERS_BANK_SIZE) - 1 : 0]          i_addr_a,
        input  wire [$clog2(REGISTERS_BANK_SIZE) - 1 : 0]          i_addr_b,
        input  wire [$clog2(REGISTERS_BANK_SIZE) - 1 : 0]          i_addr_wr,
        input  wire [REGISTERS_SIZE - 1 : 0]                       i_bus_wr,
        output wire [REGISTERS_SIZE - 1 : 0]                       o_bus_a,
        output wire [REGISTERS_SIZE - 1 : 0]                       o_bus_b,
        output wire [REGISTERS_BANK_SIZE * REGISTERS_SIZE - 1 : 0] o_bus_debug
    );
    
    reg [REGISTERS_SIZE - 1 : 0] registers [REGISTERS_BANK_SIZE - 1 : 0];
    
    integer i = 0;
    
    always @(negedge i_clk) 
    begin
        if (i_reset || i_flush)
            begin
                for (i = 0; i < REGISTERS_BANK_SIZE; i = i + 1)
                    registers[i] <= `CLEAR(REGISTERS_SIZE);
            end
        else
            begin
                if (i_write_enable)
                    registers[i_addr_wr] = (i_addr_wr != 0) ? i_bus_wr : `CLEAR(REGISTERS_SIZE);
            end
    end

    assign o_bus_a = registers[i_addr_a];
    assign o_bus_b = registers[i_addr_b];

    generate
        genvar j;
        
        for (j = 0; j < REGISTERS_BANK_SIZE; j = j + 1) begin : GEN_DEBUG_BUS
            assign o_bus_debug[(j + 1) * REGISTERS_SIZE - 1 : j * REGISTERS_SIZE] = registers[j];
        end
    endgenerate

endmodule