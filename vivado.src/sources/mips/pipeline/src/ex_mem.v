`timescale 1ns / 1ps

`include "ex_mem.vh"

module ex_mem
    #(
        parameter BUS_SIZE      = `DEFAULT_EX_BUS_SIZE,
        parameter MEM_ADDR_SIZE = `DEFAULT_DATA_MEMORY_ADDR_SIZE 
    )
    (
        // Basic signals
        input  wire                         i_clk,
        input  wire                         i_reset,
        input  wire                         i_enable,
        input  wire                         i_flush,
        // Control input signals
        input  wire [2 : 0]                 i_mem_rd_src,
        input  wire [1 : 0]                 i_mem_wr_src,
        input  wire                         i_mem_write,
        input  wire                         i_wb,
        input  wire                         i_mem_to_reg,
        input  wire                         i_halt,
        // Data input signals
        input  wire [BUS_SIZE - 1 : 0]      i_bus_b,
        input  wire [BUS_SIZE - 1 : 0]      i_alu_result,
        input  wire [MEM_ADDR_SIZE - 1 : 0] i_addr_wr,
        // Control output signals
        output wire [2 : 0]                 o_mem_rd_src,
        output wire [1 : 0]                 o_mem_wr_src,
        output wire                         o_mem_write,
        output wire                         o_wb,
        output wire                         o_mem_to_reg,
        output wire                         o_halt,
        // Data output signals
        output wire [BUS_SIZE - 1 : 0]      o_bus_b,
        output wire [BUS_SIZE - 1 : 0]      o_alu_result,
        output wire [MEM_ADDR_SIZE - 1 : 0] o_addr_wr
    );

    reg [2 : 0]                 mem_rd_src;
    reg [1 : 0]                 mem_wr_src;
    reg                         mem_write;
    reg                         wb;
    reg                         mem_to_reg;
    reg [BUS_SIZE - 1 : 0]      bus_b;
    reg [BUS_SIZE - 1 : 0]      alu_result;
    reg [MEM_ADDR_SIZE - 1 : 0] addr_wr;
    reg                         halt;

    always @(posedge i_clk)
    begin
        if (i_reset || i_flush)
            begin
                mem_rd_src <= `CLEAR(3);
                mem_wr_src <= `CLEAR(2);
                mem_write  <= `LOW;
                wb         <= `LOW;
                mem_to_reg <= `LOW;
                bus_b      <= `CLEAR(BUS_SIZE);
                alu_result <= `CLEAR(BUS_SIZE);
                addr_wr    <= `CLEAR(MEM_ADDR_SIZE);
                halt       <= `LOW;
            end
        else if (i_enable)
            begin
                mem_rd_src <= i_mem_rd_src;
                mem_wr_src <= i_mem_wr_src;
                mem_write  <= i_mem_write;
                wb         <= i_wb;
                mem_to_reg <= i_mem_to_reg;
                bus_b      <= i_bus_b;
                alu_result <= i_alu_result;
                addr_wr    <= i_addr_wr;
                halt       <= i_halt;
            end
    end

    assign o_mem_rd_src = mem_rd_src;
    assign o_mem_wr_src = mem_wr_src;
    assign o_mem_write  = mem_write;
    assign o_wb         = wb;
    assign o_mem_to_reg = mem_to_reg;
    assign o_bus_b      = bus_b;
    assign o_alu_result = alu_result;
    assign o_addr_wr    = addr_wr;
    assign o_halt       = halt;
    
endmodule