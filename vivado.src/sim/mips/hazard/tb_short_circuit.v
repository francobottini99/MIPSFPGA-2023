`timescale 1ns / 1ps

`include "tb.vh"
`include "codes.vh"

module tb_short_circuit;

    parameter MEM_ADDR_SIZE = 5;

    reg                          i_ex_mem_wb;
    reg                          i_mem_wb_wb;
    reg  [4 : 0]                 i_id_ex_rs;
    reg  [4 : 0]                 i_id_ex_rt;
    reg  [MEM_ADDR_SIZE - 1 : 0] i_ex_mem_addr;
    reg  [MEM_ADDR_SIZE - 1 : 0] i_mem_wb_addr;
    wire [1 : 0]                 o_sc_data_a_src;
    wire [1 : 0]                 o_sc_data_b_src;

    short_circuit 
    #(
        .MEM_ADDR_SIZE (MEM_ADDR_SIZE)
    ) 
    dut 
    (
        .i_ex_mem_wb     (i_ex_mem_wb),
        .i_mem_wb_wb     (i_mem_wb_wb),
        .i_id_ex_rs      (i_id_ex_rs),
        .i_id_ex_rt      (i_id_ex_rt),
        .i_ex_mem_addr   (i_ex_mem_addr),
        .i_mem_wb_addr   (i_mem_wb_addr),
        .o_sc_data_a_src (o_sc_data_a_src),
        .o_sc_data_b_src (o_sc_data_b_src)
    );

    integer i, j;

    reg [MEM_ADDR_SIZE - 1 : 0] random_addr;

    initial 
    begin
        $srandom(65651668);

        random_addr = $urandom_range(0, 2 ** MEM_ADDR_SIZE - 1);
        i_ex_mem_addr = random_addr;
        i_id_ex_rs    = random_addr;
        i_ex_mem_wb   = `HIGH;
        #10;
        if (o_sc_data_a_src != `CODE_SC_DATA_SRC_EX_MEM)
            $display("TEST 1 ERROR");
        else
            $display("TEST 1 PASS");

        random_addr = $urandom_range(0, 2 ** MEM_ADDR_SIZE - 1);
        i_mem_wb_addr = random_addr;
        i_id_ex_rt    = random_addr;
        i_mem_wb_wb   = `HIGH;
        #10;
        if (o_sc_data_b_src != `CODE_SC_DATA_SRC_MEM_WB)
            $display("TEST 2 ERROR");
        else
            $display("TEST 2 PASS");

        random_addr = $urandom_range(0, 2 ** MEM_ADDR_SIZE - 1);
        i_ex_mem_addr = random_addr;
        i_id_ex_rs    = random_addr;
        i_ex_mem_wb   = `LOW;
        #10;
        if (o_sc_data_a_src != `CODE_SC_DATA_SRC_ID_EX)
            $display("TEST 3 ERROR");
        else
            $display("TEST 3 PASS");

        random_addr = $urandom_range(0, 2 ** MEM_ADDR_SIZE - 1);
        i_mem_wb_addr = random_addr;
        i_id_ex_rt    = random_addr;
        i_mem_wb_wb   = `LOW;
        #10;
        if (o_sc_data_b_src != `CODE_SC_DATA_SRC_ID_EX)
            $display("TEST 4 ERROR");
        else
            $display("TEST 4 PASS");

        random_addr = $urandom_range(0, 2 ** MEM_ADDR_SIZE - 1);
        i_ex_mem_addr = random_addr;
        i_id_ex_rs    = random_addr;
        i_ex_mem_wb   = `HIGH;
        #10;
        if (o_sc_data_a_src != `CODE_SC_DATA_SRC_EX_MEM)
            $display("TEST 5 ERROR");
        else
            $display("TEST 5 PASS");

        random_addr = $urandom_range(0, 2 ** MEM_ADDR_SIZE - 1);
        i_mem_wb_addr = random_addr;
        i_id_ex_rt    = random_addr;
        i_mem_wb_wb   = `HIGH;
        #10;
        if (o_sc_data_b_src != `CODE_SC_DATA_SRC_MEM_WB)
            $display("TEST 6 ERROR");
        else
            $display("TEST 6 PASS");

        i_mem_wb_addr = 0;
        i_id_ex_rt    = 0;
        i_mem_wb_wb   = `HIGH;
        i_ex_mem_wb   = `HIGH;
        #10;
        if (o_sc_data_b_src != `CODE_SC_DATA_SRC_ID_EX)
            $display("TEST 7 ERROR");
        else
            $display("TEST 7 PASS");

        $finish;
    end

endmodule
