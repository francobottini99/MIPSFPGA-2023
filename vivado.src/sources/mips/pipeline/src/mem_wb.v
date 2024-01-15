`timescale 1ns / 1ps

`include "mem_wb.vh"

module mem_wb
    #(  
        parameter BUS_SIZE      = `DEFAULT_WB_IO_BUS_SIZE,
        parameter MEM_ADDR_SIZE = `DEFAULT_DATA_MEMORY_ADDR_SIZE
    )
    (
        // Basic signals
        input  wire                         i_clk,
        input  wire                         i_reset,
        input  wire                         i_enable,
        input  wire                         i_flush,
        // Control input signals
        input  wire                         i_wb,
        input  wire                         i_mem_to_reg,
        input  wire                         i_halt,
        // Data input signals
        input  wire [BUS_SIZE - 1 : 0]      i_mem_result,
        input  wire [BUS_SIZE - 1 : 0]      i_alu_result,
        input  wire [MEM_ADDR_SIZE - 1 : 0] i_addr_wr,
        // Control output signals
        output wire                         o_wb,
        output wire                         o_mem_to_reg,
        output wire                         o_halt,
        // Data output signals
        output wire [BUS_SIZE - 1 : 0]      o_mem_result,
        output wire [BUS_SIZE - 1 : 0]      o_alu_result,
        output wire [MEM_ADDR_SIZE - 1 : 0] o_addr_wr
    );

    reg                         wb;
    reg                         mem_to_reg;
    reg [BUS_SIZE - 1 : 0]      mem_result;
    reg [BUS_SIZE - 1 : 0]      alu_result;
    reg [MEM_ADDR_SIZE - 1 : 0] addr_wr;
    reg                         halt;

    always @(posedge i_clk)
    begin
        if (i_reset || i_flush)
            begin
                wb         <= `LOW;
                mem_to_reg <= `LOW;
                mem_result <= `CLEAR(BUS_SIZE);
                alu_result <= `CLEAR(BUS_SIZE);
                addr_wr    <= `CLEAR(MEM_ADDR_SIZE);
                halt       <= `LOW;
            end
        else if (i_enable)
            begin
                wb         <= i_wb;
                mem_to_reg <= i_mem_to_reg;
                mem_result <= i_mem_result;
                alu_result <= i_alu_result;
                addr_wr    <= i_addr_wr;
                halt       <= i_halt;
            end
    end

    assign o_wb         = wb;
    assign o_mem_to_reg = mem_to_reg;
    assign o_mem_result = mem_result;
    assign o_alu_result = alu_result;
    assign o_addr_wr    = addr_wr;
    assign o_halt       = halt;

endmodule