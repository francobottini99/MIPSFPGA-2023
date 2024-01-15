`timescale 1ns / 1ps

`include "short_circuit.vh"

module short_circuit
    #(
        parameter MEM_ADDR_SIZE = `DEFAULT_SHORT_CIRCUIT_MEM_ADDR_SIZE
    )
    (   
        input  wire                         i_ex_mem_wb,
        input  wire                         i_mem_wb_wb,
        input  wire [4 : 0]                 i_id_ex_rs,
        input  wire [4 : 0]                 i_id_ex_rt,
        input  wire [MEM_ADDR_SIZE - 1 : 0] i_ex_mem_addr,
        input  wire [MEM_ADDR_SIZE - 1 : 0] i_mem_wb_addr,
        output wire [1 : 0]                 o_sc_data_a_src,
        output wire [1 : 0]                 o_sc_data_b_src
    );

    assign o_sc_data_a_src = i_ex_mem_addr == i_id_ex_rs && i_id_ex_rs != 0 && i_ex_mem_wb  ? `CODE_SC_DATA_SRC_EX_MEM : 
                             i_mem_wb_addr == i_id_ex_rs && i_id_ex_rs != 0 && i_mem_wb_wb  ? `CODE_SC_DATA_SRC_MEM_WB : 
                                                                                              `CODE_SC_DATA_SRC_ID_EX;

    assign o_sc_data_b_src = i_ex_mem_addr == i_id_ex_rt && i_id_ex_rt != 0 && i_ex_mem_wb  ? `CODE_SC_DATA_SRC_EX_MEM :
                             i_mem_wb_addr == i_id_ex_rt && i_id_ex_rt != 0 && i_mem_wb_wb  ? `CODE_SC_DATA_SRC_MEM_WB :
                                                                                              `CODE_SC_DATA_SRC_ID_EX;

endmodule