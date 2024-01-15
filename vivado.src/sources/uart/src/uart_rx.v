`timescale 1ns / 1ps

`include "common.vh"
`include "uart_tx_rx.vh"

module uart_rx
    #(
        parameter DATA_BITS  = `DEFAULT_UART_DATA_BITS,
        parameter SB_TICKS   = `DEFAULT_UART_SB_TICKS
    )
    (
        input  wire                     s_tick,     
        input  wire                     clk,
        input  wire                     reset,
        input  wire                     rx,
        output reg                      rx_done_tick,
        output wire [DATA_BITS - 1 : 0] dout
    );
    
    reg [`UART_STATE_REG_SIZE - 1 : 0] state_reg, state_next;
    reg [`S_REG_SIZE - 1 : 0]          s_reg, s_next;
    reg [`N_REG_SIZE - 1 : 0]          n_reg, n_next;
    reg [`B_REG_SIZE - 1 : 0]          b_reg, b_next;
    
    always @(posedge clk) 
    begin 
        if (reset)
            begin
                state_reg <= `UART_STATE_IDLE;
                s_reg     <= `CLEAR(`S_REG_SIZE);
                n_reg     <= `CLEAR(`N_REG_SIZE);
                b_reg     <= `CLEAR(`B_REG_SIZE);
            end
        else
            begin
                state_reg <= state_next;
                s_reg     <= s_next;
                n_reg     <= n_next;
                b_reg     <= b_next;
            end
    end
    
    always @(*) 
    begin
        rx_done_tick = `LOW;
        state_next   = state_reg;
        s_next       = s_reg;
        n_next       = n_reg;
        b_next       = b_reg;    

        case(state_reg)
            `UART_STATE_IDLE:
            begin
                if (~rx) 
                    begin
                        state_next = `UART_STATE_START;
                        s_next     = `CLEAR(`S_REG_SIZE);
                    end
            end
            
            `UART_STATE_START:
            begin
                if (s_tick)
                    if (s_reg == ((SB_TICKS / 2) - 1))
                        begin
                            state_next = `UART_STATE_DATA;
                            s_next     = `CLEAR(`S_REG_SIZE);
                            n_next     = `CLEAR(`N_REG_SIZE);
                        end
                    else
                        s_next = s_reg + 1;
            end
            
            `UART_STATE_DATA: 
            begin
                if (s_tick)
                    if (s_reg == (SB_TICKS - 1))
                        begin
                            s_next = `CLEAR(`S_REG_SIZE);
                            b_next = {rx, b_reg[`B_REG_SIZE - 1 : 1]};
                            
                            if(n_reg == (DATA_BITS - 1))
                                state_next = `UART_STATE_STOP;
                            else
                                n_next = n_reg + 1;
                        end
                    else
                        s_next = s_reg + 1;
            end
            
            `UART_STATE_STOP: 
            begin
                if (s_tick)
                    if (s_reg == (SB_TICKS - 1))
                        begin
                            state_next   = `UART_STATE_IDLE;
                            rx_done_tick = `HIGH;
                        end
                    else
                        s_next = s_reg + 1;
            end
        endcase
    end
    
    assign dout = b_reg;
    
endmodule
