`timescale 1ns / 1ps

`include "id_ex.vh"

module id_ex
    #(
        parameter BUS_SIZE = `DEFAULT_ID_BUS_SIZE
    )
    (
        // Basic signals
        input  wire                    i_clk,
        input  wire                    i_reset,
        input  wire                    i_enable,
        input  wire                    i_flush,
        // Control input signals
        input  wire                    i_jmp_stop,
        input  wire [2 : 0]            i_mem_rd_src,
        input  wire [1 : 0]            i_mem_wr_src,
        input  wire                    i_mem_write,
        input  wire                    i_wb,
        input  wire                    i_mem_to_reg,
        input  wire [1 : 0]            i_reg_dst,
        input  wire                    i_alu_src_a,
        input  wire [2 : 0]            i_alu_src_b,
        input  wire [2 : 0]            i_alu_op,
        input  wire                    i_halt,
        // Data input signals
        input  wire [BUS_SIZE - 1 : 0] i_bus_a,
        input  wire [BUS_SIZE - 1 : 0] i_bus_b,
        input  wire [4 : 0]            i_rs,
        input  wire [4 : 0]            i_rt,
        input  wire [4 : 0]            i_rd,
        input  wire [5 : 0]            i_funct,
        input  wire [5 : 0]            i_op,
        input  wire [BUS_SIZE - 1 : 0] i_shamt_ext_unsigned,
        input  wire [BUS_SIZE - 1 : 0] i_inm_ext_signed,
        input  wire [BUS_SIZE - 1 : 0] i_inm_upp,
        input  wire [BUS_SIZE - 1 : 0] i_inm_ext_unsigned,
        input  wire [BUS_SIZE - 1 : 0] i_next_seq_pc,
        // Control output signals
        output wire                    o_jmp_stop,
        output wire [2 : 0]            o_mem_rd_src,
        output wire [1 : 0]            o_mem_wr_src,
        output wire                    o_mem_write,
        output wire                    o_wb,
        output wire                    o_mem_to_reg,
        output wire [1 : 0]            o_reg_dst,
        output wire                    o_alu_src_a,
        output wire [2 : 0]            o_alu_src_b,
        output wire [2 : 0]            o_alu_op,
        output wire                    o_halt,
        // Data output signals
        output wire [BUS_SIZE - 1 : 0] o_bus_a,
        output wire [BUS_SIZE - 1 : 0] o_bus_b,
        output wire [4 : 0]            o_rs,
        output wire [4 : 0]            o_rt,
        output wire [4 : 0]            o_rd,
        output wire [5 : 0]            o_funct,
        output wire [5 : 0]            o_op,
        output wire [BUS_SIZE - 1 : 0] o_shamt_ext_unsigned,
        output wire [BUS_SIZE - 1 : 0] o_inm_ext_signed,
        output wire [BUS_SIZE - 1 : 0] o_inm_upp,
        output wire [BUS_SIZE - 1 : 0] o_inm_ext_unsigned,
        output wire [BUS_SIZE - 1 : 0] o_next_seq_pc
    );

    reg                    jmp_stop;
    reg [2 : 0]            mem_rd_src;
    reg [1 : 0]            mem_wr_src;
    reg                    mem_write;
    reg                    wb;
    reg                    mem_to_reg;
    reg [1 : 0]            reg_dst;
    reg                    alu_src_a;
    reg [2 : 0]            alu_src_b;
    reg [2 : 0]            alu_op;
    reg [BUS_SIZE - 1 : 0] bus_a;
    reg [BUS_SIZE - 1 : 0] bus_b;
    reg [4 : 0]            rs;
    reg [4 : 0]            rt;
    reg [4 : 0]            rd;
    reg [5 : 0]            funct;
    reg [5 : 0]            op;
    reg [BUS_SIZE - 1 : 0] shamt_ext_unsigned;
    reg [BUS_SIZE - 1 : 0] inm_ext_signed;
    reg [BUS_SIZE - 1 : 0] inm_upp;
    reg [BUS_SIZE - 1 : 0] inm_ext_unsigned;
    reg [BUS_SIZE - 1 : 0] next_seq_pc;
    reg                    halt;

    always @(posedge i_clk)
    begin
        if (i_reset || i_flush)
            begin
                jmp_stop           <= `LOW;
                mem_rd_src         <= `CLEAR(3);
                mem_wr_src         <= `CLEAR(2);
                mem_write          <= `LOW;
                wb                 <= `LOW;
                mem_to_reg         <= `LOW;
                reg_dst            <= `CLEAR(2);
                alu_src_a          <= `LOW;
                alu_src_b          <= `CLEAR(3);
                alu_op             <= `CLEAR(3);
                bus_a              <= `CLEAR(BUS_SIZE);
                bus_b              <= `CLEAR(BUS_SIZE);
                rs                 <= `CLEAR(5);
                rt                 <= `CLEAR(5);
                rd                 <= `CLEAR(5);
                funct              <= `CLEAR(6);
                op                 <= `CLEAR(6);
                shamt_ext_unsigned <= `CLEAR(BUS_SIZE);
                inm_ext_signed     <= `CLEAR(BUS_SIZE);
                inm_upp            <= `CLEAR(BUS_SIZE);
                inm_ext_unsigned   <= `CLEAR(BUS_SIZE);
                next_seq_pc        <= `CLEAR(BUS_SIZE);
                halt               <= `LOW;
            end
        else if (i_enable)
            begin
                jmp_stop           <= i_jmp_stop;
                mem_rd_src         <= i_mem_rd_src;
                mem_wr_src         <= i_mem_wr_src;
                mem_write          <= i_mem_write;
                wb                 <= i_wb;
                mem_to_reg         <= i_mem_to_reg;
                reg_dst            <= i_reg_dst;
                alu_src_a          <= i_alu_src_a;
                alu_src_b          <= i_alu_src_b;
                alu_op             <= i_alu_op;
                bus_a              <= i_bus_a;
                bus_b              <= i_bus_b;
                rs                 <= i_rs;
                rt                 <= i_rt;
                rd                 <= i_rd;
                funct              <= i_funct;
                op                 <= i_op;
                shamt_ext_unsigned <= i_shamt_ext_unsigned;
                inm_ext_signed     <= i_inm_ext_signed;
                inm_upp            <= i_inm_upp;
                inm_ext_unsigned   <= i_inm_ext_unsigned;
                next_seq_pc        <= i_next_seq_pc;
                halt               <= i_halt;
            end
    end

    assign o_jmp_stop           = jmp_stop;
    assign o_mem_rd_src         = mem_rd_src;
    assign o_mem_wr_src         = mem_wr_src;
    assign o_mem_write          = mem_write;
    assign o_wb                 = wb;
    assign o_mem_to_reg         = mem_to_reg;
    assign o_reg_dst            = reg_dst;
    assign o_alu_src_a          = alu_src_a;
    assign o_alu_src_b          = alu_src_b;
    assign o_alu_op             = alu_op;
    assign o_bus_a              = bus_a;
    assign o_bus_b              = bus_b;
    assign o_rs                 = rs;
    assign o_rt                 = rt;
    assign o_rd                 = rd;
    assign o_funct              = funct;
    assign o_op                 = op;
    assign o_shamt_ext_unsigned = shamt_ext_unsigned;
    assign o_inm_ext_signed     = inm_ext_signed;
    assign o_inm_upp            = inm_upp;
    assign o_inm_ext_unsigned   = inm_ext_unsigned;
    assign o_next_seq_pc        = next_seq_pc;
    assign o_halt               = halt;

endmodule