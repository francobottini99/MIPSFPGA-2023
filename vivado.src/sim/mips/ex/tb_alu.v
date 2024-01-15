`timescale 1ns / 1ps

`include "tb.vh"
`include "codes.vh"

module tb_alu;

    parameter IO_BUS_WIDTH  = 32;
    parameter CTR_BUS_WIDTH = 4;

    reg        [CTR_BUS_WIDTH - 1 : 0] i_ctr_code;
    reg  signed [IO_BUS_WIDTH - 1 : 0] i_data_a;
    reg  signed [IO_BUS_WIDTH - 1 : 0] i_data_b;
    wire signed [IO_BUS_WIDTH - 1 : 0] o_data;

    alu 
    #(
        .IO_BUS_WIDTH  (IO_BUS_WIDTH),
        .CTR_BUS_WIDTH (CTR_BUS_WIDTH)
    ) 
    dut 
    (
        .i_ctr_code (i_ctr_code),
        .i_data_a   (i_data_a),
        .i_data_b   (i_data_b),
        .o_data     (o_data)
    );

    initial 
    begin
        $srandom(4551551);

        i_ctr_code = `CODE_ALU_EX_ADD;
        i_data_a = $urandom;
        i_data_b = $urandom;
        #10;
        if (o_data == i_data_a + i_data_b)
            $display("TEST ADD  PASSED");
        else
            $display("TEST ADD  ERROR  -> Esperado: %b, Obtenido: %b", i_data_a + i_data_b, o_data);

        i_ctr_code = `CODE_ALU_EX_ADDU;
        i_data_a = $urandom;
        i_data_b = $urandom;
        #10;
        if (o_data == i_data_a + i_data_b)
            $display("TEST ADDU PASSED");
        else
            $display("TEST ADDU ERROR  -> Esperado: %b, Obtenido: %b", i_data_a + i_data_b, o_data);

        i_ctr_code = `CODE_ALU_EX_SUB;
        i_data_a = $urandom;
        i_data_b = $urandom;
        #10;
        if (o_data == i_data_a - i_data_b)
            $display("TEST ADD  PASSED");
        else
            $display("TEST ADD  ERROR  -> Esperado: %b, Obtenido: %b", i_data_a - i_data_b, o_data);

        i_ctr_code = `CODE_ALU_EX_SUBU;
        i_data_a = $urandom;
        i_data_b = $urandom;
        #10;
        if (o_data == i_data_a - i_data_b)
            $display("TEST SUBU PASSED");
        else
            $display("TEST SUBU ERROR  -> Esperado: %b, Obtenido: %b", i_data_a - i_data_b, o_data);

        i_ctr_code = `CODE_ALU_EX_AND;
        i_data_a = $urandom;
        i_data_b = $urandom;
        #10;
        if (o_data == (i_data_a & i_data_b))
            $display("TEST AND  PASSED");
        else
            $display("TEST AND  ERROR  -> Esperado: %b, Obtenido: %b", i_data_a & i_data_b, o_data);
        
        i_ctr_code = `CODE_ALU_EX_OR;
        i_data_a = $urandom;
        i_data_b = $urandom;
        #10;
        if (o_data == (i_data_a | i_data_b))
            $display("TEST OR   PASSED");
        else
            $display("TEST OR   ERROR  -> Esperado: %b, Obtenido: %b", i_data_a | i_data_b, o_data);

        i_ctr_code = `CODE_ALU_EX_XOR;
        i_data_a = $urandom;
        i_data_b = $urandom;
        #10;
        if (o_data == (i_data_a ^ i_data_b))
            $display("TEST XOR  PASSED");
        else
            $display("TEST XOR  ERROR  -> Esperado: %b, Obtenido: %b", i_data_a ^ i_data_b, o_data);

        i_ctr_code = `CODE_ALU_EX_NOR;
        i_data_a = $urandom;
        i_data_b = $urandom;
        #10;
        if (o_data == ~(i_data_a | i_data_b))
            $display("TEST NOR  PASSED");
        else
            $display("TEST NOR  ERROR  -> Esperado: %b, Obtenido: %b", ~(i_data_a | i_data_b), o_data);

        i_ctr_code = `CODE_ALU_EX_SLT;
        i_data_a = $urandom;
        i_data_b = $urandom;
        #10;
        if (o_data == (i_data_a < i_data_b))
            $display("TEST SLT  PASSED");
        else
            $display("TEST SLT  ERROR  -> Esperado: %b, Obtenido: %b", (i_data_a < i_data_b), o_data);

        i_ctr_code = `CODE_ALU_EX_SLL;
        i_data_a = $urandom;
        i_data_b = $urandom;
        #10;
        if (o_data == (i_data_a << i_data_b))
            $display("TEST SLL  PASSED");
        else
            $display("TEST SLL  ERROR  -> Esperado: %b, Obtenido: %b", (i_data_a << i_data_b), o_data);

        i_ctr_code = `CODE_ALU_EX_SRL;
        i_data_a = $urandom;
        i_data_b = $urandom;
        #10;
        if (o_data == (i_data_a >> i_data_b))
            $display("TEST SRL  PASSED");
        else
            $display("TEST SRL  ERROR  -> Esperado: %b, Obtenido: %b", (i_data_a >> i_data_b), o_data);

        i_ctr_code = `CODE_ALU_EX_SRA;
        i_data_a = $urandom;
        i_data_b = $urandom;
        #10;
        if (o_data == (i_data_a >>> i_data_b))
            $display("TEST SRA  PASSED");
        else
            $display("TEST SRA  ERROR  -> Esperado: %b, Obtenido: %b", (i_data_a >>> i_data_b), o_data);

        i_ctr_code = `CODE_ALU_EX_SLLV;
        i_data_a = $urandom;
        i_data_b = $urandom;
        #10;
        if (o_data == (i_data_a << i_data_b))
            $display("TEST SLLV PASSED");
        else
            $display("TEST SLLV ERROR  -> Esperado: %b, Obtenido: %b", (i_data_a << i_data_b), o_data);

        i_ctr_code = `CODE_ALU_EX_SRLV;
        i_data_a = $urandom;
        i_data_b = $urandom;
        #10;
        if (o_data == (i_data_a >> i_data_b))
            $display("TEST SRLV PASSED");
        else
            $display("TEST SRLV ERROR  -> Esperado: %b, Obtenido: %b", (i_data_a >> i_data_b), o_data);

        i_ctr_code = `CODE_ALU_EX_SRAV;
        i_data_a = $urandom;
        i_data_b = $urandom;
        #10;
        if (o_data == (i_data_a >>> i_data_b))
            $display("TEST SRAV PASSED");
        else
            $display("TEST SRAV ERROR  -> Esperado: %b, Obtenido: %b", (i_data_a >>> i_data_b), o_data);

        i_ctr_code = `CODE_ALU_EX_SC_B;
        i_data_a = $urandom;
        i_data_b = $urandom;
        #10;
        if (o_data == i_data_b)
            $display("TEST SC_B PASSED");
        else
            $display("TEST SC_B ERROR  -> Esperado: %b, Obtenido: %b", i_data_b, o_data);

        i_ctr_code = `CODE_ALU_EX_NOP;
        i_data_a = $urandom;
        i_data_b = $urandom;
        #10;
        if (o_data === {IO_BUS_WIDTH {1'bz}})
            $display("TEST NOP  PASSED");
        else
            $display("TEST NOP  ERROR  -> Esperado: %b, Obtenido: %b", {IO_BUS_WIDTH {1'bz}}, o_data);

        $finish;
    end

endmodule
