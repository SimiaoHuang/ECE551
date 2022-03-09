module UART_wrapper(TX, RX, cmd, resp, trmt, tx_done, cmd_rdy, clr_cmd_rdy, clk, rst_n);
    input [7:0] resp;
    input RX, clk, rst_n, trmt, clr_cmd_rdy;
    output [15:0] cmd;
    output TX, tx_done;
    output logic cmd_rdy;

    typedef enum logic [1:0] { HIGH, LOW, RDY } state_t;
    logic mux_sel, set_rdy, clr_rx_rdy, rx_rdy;
    logic [7:0] rx_data, high;
    state_t state, nxt_state;

    UART uart(.clk(clk), .rst_n(rst_n), .RX(RX), .TX(TX), .rx_rdy(rx_rdy), .clr_rx_rdy(clr_rx_rdy),
        .rx_data(rx_data), .trmt(trmt), .tx_data(resp), .tx_done(tx_done));

    assign cmd = {high, rx_data};

// flipflop that stores high byte
    always_ff @(posedge clk) begin 
        high <= (mux_sel) ? rx_data : high;
    end



    always_ff @(posedge clk, negedge rst_n) begin
        if (!rst_n)
            cmd_rdy <= 0;
        else if (clr_cmd_rdy | rx_rdy)
            cmd_rdy <= 0;
        else if (set_rdy)
            cmd_rdy <= 1;
    end


// flipflop for state
    always_ff @(posedge clk, negedge rst_n) begin 
        if (!rst_n)
            state <= HIGH;
        else
            state <= nxt_state;
    end

//state transition
    always_comb begin 
        nxt_state = state;
        clr_rx_rdy = 0;
        mux_sel = 0;
        set_rdy = 0;
        case(state)
            HIGH: begin
                if (rx_rdy) begin
                    nxt_state = LOW;
                    mux_sel = 1;
                    clr_rx_rdy = 1;
                end
            end
            LOW: begin
                if (rx_rdy) begin
                    nxt_state = RDY;
                    clr_rx_rdy = 1;
                end
            end
            RDY: begin
                nxt_state = HIGH;
                set_rdy = 1;
            end
            default:
                nxt_state = HIGH;
        endcase
    end

endmodule
