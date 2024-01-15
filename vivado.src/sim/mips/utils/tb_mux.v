`timescale 1ns / 1ps

`include "tb.vh"

module tb_mux;

    localparam CHANNELS_2 = 2;
    localparam CHANNELS_4 = 4;

    reg  [CHANNELS_2 - 1 : 0]                      selector_2;
    reg  [CHANNELS_2 * `ARQUITECTURE_BITS - 1 : 0] data_in_2;
    wire [`ARQUITECTURE_BITS - 1 : 0]              data_out_2;

    reg  [CHANNELS_4 - 1 : 0]                      selector_4;
    reg  [CHANNELS_4 * `ARQUITECTURE_BITS - 1 : 0] data_in_4;
    wire [`ARQUITECTURE_BITS - 1 : 0]              data_out_4;

    mux 
    #(
        .CHANNELS(CHANNELS_2), 
        .BUS_SIZE(`ARQUITECTURE_BITS)
    ) 
    mux_2 
    (
        .selector(selector_2),
        .data_in (data_in_2),
        .data_out(data_out_2)
    );

    mux 
    #(
        .CHANNELS(CHANNELS_4), 
        .BUS_SIZE(`ARQUITECTURE_BITS)
    ) 
    mux_4 
    (
        .selector(selector_4),
        .data_in (data_in_4),
        .data_out(data_out_4)
    );
    
    integer i = 0;

    initial 
    begin
        $srandom(948956);

        $display("Comprobando el mux de 2 canales...");

        for (i = 0; i < CHANNELS_2; i = i + 1)
            data_in_2[`ARQUITECTURE_BITS * i +: `ARQUITECTURE_BITS] = $random;

        selector_2 = 0;
        #10;
        if (data_out_2 !== data_in_2[`ARQUITECTURE_BITS * selector_2 +: `ARQUITECTURE_BITS])
            $display("TEST 1 NO PASS. data_out_2 = %b, expected = %b", data_out_2, data_in_2[`ARQUITECTURE_BITS * selector_2 +: `ARQUITECTURE_BITS]);
        else 
            $display("TEST 1 PASS.");

        selector_2 = 1;
        #10;
        if (data_out_2 !== data_in_2[`ARQUITECTURE_BITS * selector_2 +: `ARQUITECTURE_BITS])
            $display("TEST 2 NO PASS. data_out_2 = %b, expected = %b", data_out_2, data_in_2[`ARQUITECTURE_BITS * selector_2 +: `ARQUITECTURE_BITS]);
        else 
            $display("TEST 2 PASS.");

        selector_2 = 1'bx;
        #10;
        if (data_out_2 !== { `ARQUITECTURE_BITS {1'bz} })
            $display("TEST 3 NO PASS. data_out_2 = %b, expected = %b", data_out_2, { `ARQUITECTURE_BITS {1'bz} });
        else 
            $display("TEST 3 PASS.");

        $display("Comprobando el mux de 4 canales...");

        for (i = 0; i < CHANNELS_4; i = i + 1)
            data_in_4[`ARQUITECTURE_BITS * i +: `ARQUITECTURE_BITS] = $random;

        selector_4 = 0;
        #10;
        if (data_out_4 !== data_in_4[`ARQUITECTURE_BITS * selector_4 +: `ARQUITECTURE_BITS])
            $display("TEST 4 NO PASS. data_out_4 = %b, expected = %b", data_out_4, data_in_4[`ARQUITECTURE_BITS * selector_4 +: `ARQUITECTURE_BITS]);
        else 
            $display("TEST 4 PASS.");

        selector_4 = 1;
        #10;
        if (data_out_4 !== data_in_4[`ARQUITECTURE_BITS * selector_4 +: `ARQUITECTURE_BITS])
            $display("TEST 5 NO PASS. data_out_4 = %b, expected = %b", data_out_4, data_in_4[`ARQUITECTURE_BITS * selector_4 +: `ARQUITECTURE_BITS]);
        else 
            $display("TEST 5 PASS.");

        selector_4 = 2;
        #10;
        if (data_out_4 !== data_in_4[`ARQUITECTURE_BITS * selector_4 +: `ARQUITECTURE_BITS])
            $display("TEST 6 NO PASS. data_out_4 = %b, expected = %b", data_out_4, data_in_4[`ARQUITECTURE_BITS * selector_4 +: `ARQUITECTURE_BITS]);
        else 
            $display("TEST 6 PASS.");
        
        selector_4 = 3;
        #10;
        if (data_out_4 !== data_in_4[`ARQUITECTURE_BITS * selector_4 +: `ARQUITECTURE_BITS])
            $display("TEST 7 NO PASS. data_out_4 = %b, expected = %b", data_out_4, data_in_4[`ARQUITECTURE_BITS * selector_4 +: `ARQUITECTURE_BITS]);
        else 
            $display("TEST 7 PASS.");
        
        selector_4 = 1'bx;
        #10;
        if (data_out_4 !== { `ARQUITECTURE_BITS {1'bz} })
            $display("TEST 8 NO PASS. data_out_4 = %b, expected = %b", data_out_4, { `ARQUITECTURE_BITS {1'bz} });
        else 
            $display("TEST 8 PASS.");

        $finish;
    end

endmodule
