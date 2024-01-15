`timescale 1ns / 1ps

`include "tb.vh"

module tb_top;
    
    localparam CLK_PERIOD = 20;
    localparam BUS_SIZE   = 32;
    localparam DATA_BITS  = 8;
    localparam SB_TICKS   = 16;
    localparam DVSR       = 27;
 
    reg           i_clk; 
    reg           i_reset;
    reg           i_rx;
    wire          o_tx;
    wire [15 : 0] o_status_led;
    
    top
    #(
        .UART_DVSR (DVSR)
    )
    top_unit
    (
        .i_clk        (i_clk),
        .i_reset      (i_reset),
        .i_rx         (i_rx),
        .o_tx         (o_tx),
        .o_status_led (o_status_led)
    );

    `CLK_TOGGLE(i_clk, CLK_PERIOD)
    
    integer i, j, k;

    reg [DATA_BITS - 1 : 0] w_byte;
    reg [DATA_BITS - 1 : 0] r_byte;

    reg [BUS_SIZE - 1 : 0]                   w_data;
    reg [BUS_SIZE + (DATA_BITS * 3) - 1 : 0] r_data;
    
    task automatic send();
        begin 
            i_rx = `LOW;
             
            #(DVSR * SB_TICKS * CLK_PERIOD);
            
            for (i = 0; i < DATA_BITS; i = i + 1)
                begin
                    i_rx = w_byte[i];
                    #(DVSR * SB_TICKS * CLK_PERIOD); 
                end
            
            i_rx = `HIGH;
            
            #(DVSR * SB_TICKS * CLK_PERIOD);
        end
    endtask
    
    task automatic receive();
        begin
            while (o_tx)
                `TICKS_DELAY_1(CLK_PERIOD);
                
            #(DVSR * SB_TICKS * CLK_PERIOD);
            
            for (i = 0; i < DATA_BITS; i = i + 1)
                begin
                    r_byte[i] = o_tx;
                    #(DVSR * SB_TICKS * CLK_PERIOD);
                end
            
            while (~o_tx)
                `TICKS_DELAY_1(CLK_PERIOD);
                
            #(DVSR * SB_TICKS * CLK_PERIOD);
        end
    endtask

    task automatic send_4byte();
        for (k = 0; k < 4; k = k + 1)
            begin
                w_byte = w_data[k * 8 +: 8];
                send();
                `TICKS_DELAY_1(CLK_PERIOD);
            end
    endtask

    task automatic receive_7byte();
        for (k = 0; k < 7; k = k + 1)
            begin
                receive();
                r_data[k * 8 +: 8] = r_byte;
            end
    endtask

    reg [BUS_SIZE - 1 : 0] first_program [28 : 0];

    initial
    begin
        first_program[0]  = `ADDI(`R4, `R0, 16'd7123);
        first_program[1]  = `ADDI(`R3, `R0, 16'd85);
        first_program[2]  = `ADDU(`R5, `R4, `R3);
        first_program[3]  = `SUBU(`R6, `R4, `R3);
        first_program[4]  = `AND(`R7, `R4, `R3);
        first_program[5]  = `OR(`R8, `R4, `R3);
        first_program[6]  = `XOR(`R9, `R4, `R3);
        first_program[7]  = `NOR(`R10, `R3, `R4);
        first_program[8]  = `SLT(`R11, `R3, `R4);
        first_program[9]  = `SLL(`R12, `R10, 5'd2);
        first_program[10] = `SRL(`R13, `R10, 5'd2);
        first_program[11] = `SRA(`R14, `R10, 5'd2);
        first_program[12] = `SLLV(`R15, `R10, `R11);
        first_program[13] = `SRLV(`R16, `R10, `R11);
        first_program[14] = `SRAV(`R17, `R10, `R11);
        first_program[15] = `SB(`R13, `R0, 16'd4);
        first_program[16] = `SH(`R13, `R0, 16'd8);
        first_program[17] = `SW(`R13, `R0, 16'd12);
        first_program[18] = `LB(`R18, `R0, 16'd12);
        first_program[19] = `ANDI(`R19, `R18, 16'd6230);
        first_program[20] = `LH(`R20, `R0, 16'd12);
        first_program[21] = `ORI(`R21, `R20, 16'd6230);
        first_program[22] = `LW(`R22, `R0, 16'd12);
        first_program[23] = `XORI(`R23, `R22, 16'd6230);
        first_program[24] = `LWU(`R24, `R0, 16'd12);
        first_program[25] = `LUI(`R25, 16'd6230);
        first_program[26] = `LBU(`R26, `R0, 16'd12);
        first_program[27] = `SLTI(`R27, `R19, 16'd22614);
        first_program[28] = `HALT;
    end

    initial
    begin
        i_reset = `HIGH;
        i_clk   = `LOW;
        i_rx    = `HIGH;

        j = 0;
        
        `RANDOM_TICKS_DELAY_MAX_20(CLK_PERIOD) i_reset = 0;
        
        w_data = "L";
        send_4byte();
        
        repeat(29)
        begin
            w_data = first_program[j];
            send_4byte();
            j = j + 1;  
        end

        receive_7byte();
        $display("r_data = %h", r_data);

        w_data = "D";
        send_4byte();

        repeat(64)
        begin
            receive_7byte();
            $display("r_data = %h", r_data);
        end
        
        receive_7byte();
        $display("r_data = %h", r_data);
        
        `TICKS_DELAY_10(CLK_PERIOD);
 
        $finish;
    end
    
endmodule
