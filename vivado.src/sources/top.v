`timescale 1ns / 1ps

module top 
    #(
        parameter MIPS_BUS_SIZE                              = 32,
        parameter MIPS_INSTRUCTION_MEMORY_WORD_SIZE_IN_BYTES = 4,
        parameter MIPS_INSTRUCTION_MEMORY_SIZE_IN_WORDS      = 64,
        parameter MIPS_REGISTERS_BANK_SIZE                   = 32,
        parameter MIPS_DATA_MEMORY_ADDR_SIZE                 = 5,
        parameter UART_DATA_BITS                             = 8,
        parameter UART_SB_TICKS                              = 16,
        parameter UART_DVSR_BIT                              = 9,
        parameter UART_DVSR                                  = 326,
        parameter UART_FIFO_SIZE                             = 512
    )
    (
        input  wire          i_clk, 
        input  wire          i_reset,
        input  wire          i_rx,
        output wire          o_tx,
        output wire [15 : 0] o_status_led
    );

	localparam MIPS_REGISTER_CONTETNT_BUS_SIZE = MIPS_REGISTERS_BANK_SIZE * MIPS_BUS_SIZE;
	localparam MIPS_MEMORY_CONTETNT_BUS_SIZE   = 2**MIPS_DATA_MEMORY_ADDR_SIZE * MIPS_BUS_SIZE;

	wire 					      	  	           mips_flush;
	wire 					      	  	           mips_clear_program;
	wire 					      	  	           mips_enabled;
	wire 					      	  	           mips_end_program;
	wire                                           mips_instruction_wr;
	wire								           mips_instruction_memory_full;
	wire								           mips_instruction_memory_empty;
	wire [MIPS_BUS_SIZE - 1 : 0]                   mips_instruction;
	wire [MIPS_REGISTER_CONTETNT_BUS_SIZE - 1 : 0] mips_registers_conntent;
	wire [MIPS_MEMORY_CONTETNT_BUS_SIZE - 1 : 0]   mips_memory_conntent;

    wire 					      	  		 	   uart_rd;
    wire 					      	  		 	   uart_wr;
    wire 					      	  		 	   uart_rx_empty;
    wire 					      	  		 	   uart_tx_full;
	wire [UART_DATA_BITS - 1 : 0] 	  		 	   uart_data_wr;
	wire [UART_DATA_BITS - 1 : 0] 	  		 	   uart_data_rd;

    wire [4: 0]                                    state;

    uart
    #(
      .DATA_BITS (UART_DATA_BITS),
      .SB_TICKS  (UART_SB_TICKS),
      .DVSR_BIT  (UART_DVSR_BIT),
      .DVSR      (UART_DVSR),
      .FIFO_SIZE (UART_FIFO_SIZE)
    )
    uart_unit
    (
      .clk          (i_clk),
      .reset        (i_reset),
      .rd_uart      (uart_rd),
      .wr_uart      (uart_wr),
      .rx           (i_rx),
      .w_data       (uart_data_wr),
      .tx_full      (uart_tx_full),
      .rx_empty     (uart_rx_empty),
      .tx           (o_tx),
      .r_data       (uart_data_rd)
    );

	debugger
	#(
		.UART_BUS_SIZE          (UART_DATA_BITS),
        .DATA_IN_BUS_SIZE       (UART_DATA_BITS * 4),
        .DATA_OUT_BUS_SIZE      (UART_DATA_BITS * 7),
		.REGISTER_SIZE          (MIPS_BUS_SIZE),
		.REGISTER_BANK_BUS_SIZE (MIPS_REGISTER_CONTETNT_BUS_SIZE),
		.MEMORY_SLOT_SIZE	   	(MIPS_BUS_SIZE),
		.MEMORY_DATA_BUS_SIZE	(MIPS_MEMORY_CONTETNT_BUS_SIZE)
	)
	debugger_unit
	(
		.i_clk           			(i_clk),
		.i_reset         			(i_reset),
		.i_uart_empty	 			(uart_rx_empty),
		.i_uart_full	 			(uart_tx_full),
		.i_instruction_memory_empty (mips_instruction_memory_empty),
		.i_instruction_memory_full  (mips_instruction_memory_full),
		.i_mips_end_program			(mips_end_program),
		.i_uart_data_rd				(uart_data_rd),
		.i_registers_conntent		(mips_registers_conntent),
		.i_memory_conntent			(mips_memory_conntent),
		.o_uart_wr					(uart_wr),
		.o_uart_rd					(uart_rd),
		.o_mips_instruction_wr		(mips_instruction_wr),
		.o_mips_flush				(mips_flush),
		.o_mips_clear_program		(mips_clear_program),
		.o_mips_enabled				(mips_enabled),
		.o_uart_data_wr				(uart_data_wr),
		.o_mips_instruction			(mips_instruction),
        .o_state                    (state)
	);

    mips
    #(
        .PC_BUS_SIZE                           (MIPS_BUS_SIZE),
        .DATA_BUS_SIZE                         (MIPS_BUS_SIZE),
        .INSTRUCTION_BUS_SIZE                  (MIPS_BUS_SIZE),
        .INSTRUCTION_MEMORY_WORD_SIZE_IN_BYTES (MIPS_INSTRUCTION_MEMORY_WORD_SIZE_IN_BYTES),
        .INSTRUCTION_MEMORY_SIZE_IN_WORDS      (MIPS_INSTRUCTION_MEMORY_SIZE_IN_WORDS),
        .REGISTERS_BANK_SIZE                   (MIPS_REGISTERS_BANK_SIZE),
        .DATA_MEMORY_ADDR_SIZE                 (MIPS_DATA_MEMORY_ADDR_SIZE)
    )
    mips_unit
    (
        .i_clk           (i_clk),
        .i_reset         (i_reset),
        .i_enable        (mips_enabled),
        .i_flush         (mips_flush),
        .i_clear_program (mips_clear_program),
        .i_ins_mem_wr    (mips_instruction_wr),
        .i_ins           (mips_instruction),
        .o_end_program   (mips_end_program),
        .o_ins_mem_full  (mips_instruction_memory_full),
        .o_ins_mem_empty (mips_instruction_memory_empty),
        .o_registers     (mips_registers_conntent),
        .o_mem_data      (mips_memory_conntent)
    );

    /*
    *   Status LED
    *   L1 (15) - MIPS enabled 
    *   P1 (14) - MIPS flush
    *   N3 (13) - MIPS clear program
    *   P3 (12) - MIPS instruction write
    *   U3 (11) - MIPS instruction memory full
    *   W3 (10) - MIPS instruction memory empty
    *   V3  (9) - MIPS end program
    *   V13 (8) - UART read
    *   V14 (7) - UART write
    *   U14 (6) - UART RX empty
    *   U15 (5) - UART TX full
    *   W18 (4) - state
    *   V19 (3) - state
    *   U19 (2) - state
    *   E19 (1) - state
    *   U16 (0) - state
    */

    assign o_status_led = { mips_enabled, mips_flush, mips_clear_program, mips_instruction_wr, mips_instruction_memory_full, mips_instruction_memory_empty, mips_end_program, uart_rd, uart_wr, uart_rx_empty, uart_tx_full, state };

endmodule