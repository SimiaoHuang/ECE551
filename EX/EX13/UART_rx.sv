module UART_rx(RX, clk, rst_n, clr_rdy, rdy, rx_data);


    input RX, clk, rst_n, clr_rdy;
    output logic rdy;
    output [7:0] rx_data;

    logic [8:0] rx_shft_reg;
    logic [3:0] bit_cnt;
    logic [11:0] baud_cnt;
    logic shift, receiving, set_rdy, start;
    logic data, d;

    // RX metastability  
    always_ff @(posedge clk) begin
        data <= d;
        d <= RX;
    end

    // rx_shft_reg;
    always_ff @(posedge clk) begin 
        if (shift)
            rx_shft_reg <= {data, rx_shft_reg[8:1]};
    end
     assign rx_data = rx_shft_reg[7:0];


    // bit_cnt
    always_ff @(posedge clk) begin 
        casex ({start, shift})
            2'b1x: bit_cnt = 1'b0; 
            2'b01: bit_cnt = bit_cnt + 1;
            2'b00: bit_cnt = bit_cnt;
        endcase
    end

    // baud_cnt 
    always_ff @(posedge clk) begin 
        casex ({start | shift, receiving})
            2'b1x: baud_cnt = (start)? 12'h516 : 12'hA2C;  
            2'b01: baud_cnt = baud_cnt - 1;
            2'b00: baud_cnt = baud_cnt;
        endcase
    end
    assign shift = (baud_cnt[11:0] == 12'h000) ? 1'b1 : 1'b0;

    // state machine;
    typedef enum logic { IDLE, RECEIVE } state_t;
    state_t state, nxt_state;

    always_ff @(posedge clk, negedge rst_n) begin 
        if (!rst_n)
            state <= IDLE;
        else
            state <= nxt_state;
    end

    always_comb begin 
        nxt_state = state;
        start = 0;
        receiving = 0;
        set_rdy = 0;
        case (state)
            IDLE: begin
                if (!data) begin
                    nxt_state = RECEIVE;
                    start = 1;
                end
            end
            RECEIVE: begin
                if (bit_cnt >= 4'h9) begin
                    nxt_state = IDLE;
                    set_rdy = 1;
                end
                else
                    receiving = 1;
            end
              default nxt_state = IDLE;
        endcase
       
    end
    
    always_ff @(posedge clk, negedge rst_n) begin 
        if (!rst_n)
            rdy <= 0;
        else if (set_rdy)
            rdy <= 1;
        else if (start | clr_rdy)
            rdy <= 0;
    end

endmodule
