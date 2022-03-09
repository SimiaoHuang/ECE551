module RemoteComm(clk, rst_n, RX, TX, cmd, send_cmd, cmd_sent, resp_rdy, resp);

input clk, rst_n;		// clock and active low reset
input RX;				// serial data input
input send_cmd;			// indicates to tranmit 24-bit command (cmd)
input [15:0] cmd;		// 16-bit command

output TX;				// serial data output
output logic cmd_sent;		// indicates transmission of command complete
output resp_rdy;		// indicates 8-bit response has been received
output [7:0] resp;		// 8-bit response from DUT

wire [7:0] tx_data;		// 8-bit data to send to UART
wire tx_done;			// indicates 8-bit was sent over UART
wire rx_rdy;			// indicates 8-bit response is ready from UART

logic [7:0] low;
logic sel;
logic trmt;

///////////////////////////////////////////////
// Registers needed...state machine control //
/////////////////////////////////////////////
					// used to buffer low byte of cmd
always_ff @(posedge clk)begin
    if(send_cmd)
    low <= cmd[7:0];
    // else if (!send_cmd)
    // low <= 8'h00;
end

assign tx_data = (sel) ? cmd[15:8] : low;

///////////////////////////////
// state definitions for SM //
/////////////////////////////

typedef enum reg[1:0] {IDLE, HIGH, LOW} state_t;
state_t state, nxt_state;

always_ff@(posedge clk, negedge rst_n)
if(!rst_n)
state <= IDLE;
else state <= nxt_state;

always_comb begin
    sel = 0;
    trmt = 0;
    cmd_sent = 0;
    nxt_state = IDLE;

    case(state)
    IDLE : begin
        if(send_cmd)
        sel = 1;
        trmt = 1;
        nxt_state = HIGH;
    end

    HIGH : begin
        if(tx_done)begin
        sel = 0;
        trmt = 1;
        nxt_state = LOW;
        end
        else if (!tx_done)
        nxt_state = HIGH;
        
    end

    LOW : begin
        if(tx_done) begin
        cmd_sent = 1;
        nxt_state = IDLE;
        end
        else if (!tx_done)
        nxt_state = LOW;
        
    end

    default : nxt_state = IDLE;
    
    endcase
end


///////////////////////////////////////////////
// Instantiate basic 8-bit UART transceiver //
/////////////////////////////////////////////
UART iUART(.clk(clk), .rst_n(rst_n), .RX(RX), .TX(TX), .tx_data(tx_data), .trmt(trmt),
           .tx_done(tx_done), .rx_data(resp), .rx_rdy(resp_rdy), .clr_rx_rdy(resp_rdy));
		   
//<< your implementation here >>

endmodule	
