module UART_tx(clk, rst_n, trmt, tx_data, TX, tx_done);
    input clk, rst_n, trmt;
    input [7:0] tx_data;
    output TX;
    output logic tx_done;

    logic [8:0] tx_shft_reg;
    logic [11:0] baud_cnt;
    logic [3:0] bit_cnt;
    logic init, transmitting, shift, set_done;

  
  
//shift
    always_ff @(posedge clk, negedge rst_n) begin 
        if (!rst_n)
            tx_shft_reg <= 9'b000000000;
        else
            casex ({init, shift})
                2'b1x: tx_shft_reg <= {tx_data, 1'b0};
                2'b01: tx_shft_reg <= {1'b1, tx_shft_reg[8:1]};
                2'b00: tx_shft_reg <= tx_shft_reg;
            endcase
    end
    assign TX = tx_shft_reg[0];

//baud
    always_ff @(posedge clk) begin
        casex ({init|shift, transmitting}) 
            2'b1x: baud_cnt <= 12'b0;
            2'b01: baud_cnt <= baud_cnt + 1;
            2'b00: baud_cnt <= baud_cnt;
        endcase
    end
    assign shift = (baud_cnt[11:0] == 12'hA2C) ? 1'b1 : 1'b0;  
        
//bit count
    always_ff @(posedge clk)begin
        casex ({init, shift}) 
            2'b1x: bit_cnt <= 4'b0;
            2'b01: bit_cnt <= bit_cnt + 1;
            2'b00: bit_cnt <= bit_cnt;
        endcase
    end

//state machine    
    typedef enum logic {IDLE, TRANS} state_t;
    state_t state, nxt_state;

    always_ff @(posedge clk, negedge rst_n) begin 
        if (!rst_n) 
            state <= IDLE;
        else 
            state <= nxt_state;
    end


    always_comb begin
        nxt_state = state;
        init = 0;
        set_done = 0;
        transmitting = 0;
        case (state) 

            IDLE: begin
                if (trmt) begin
                    nxt_state = TRANS;
                    init = 1;
                end
            end

            TRANS: begin
                transmitting = 1;
                if (bit_cnt >= 4'h9) begin 
                    nxt_state = IDLE;
                    set_done = 1;
                end
            end
            default nxt_state = IDLE;
        endcase
    end


    always_ff @(posedge clk, negedge rst_n) begin 
        if (!rst_n)
            tx_done <= 0;
        else if (set_done)
            tx_done <= 1;
        else if (init)
            tx_done <= 0;
    end

endmodule