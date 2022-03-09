module inert_intf_test(clk, RST_n, LED, SS_n, SCLK, MOSI,
                         MISO, INT);

parameter moving_val = 1'b1;
parameter lftIR_val = 1'b0;
parameter rghtIR_val = 1'b0;

input clk;
input RST_n;
// input moving, lftIR, rghtIR;
input MISO, INT;
output logic SS_n, SCLK, MOSI;
output logic [7:0]LED;

logic rst_n;
logic cal_done;
logic strt_cal;
logic signed [11:0]heading;
logic sel;

typedef enum logic[1:0] {IDLE, CAL, DISP} state_t;
state_t state, nxt_state;


always_ff@(posedge clk, negedge rst_n)begin
    if(!rst_n)
    state <= IDLE;
    else state <= nxt_state;
end

always_comb begin
    sel = 0;
    strt_cal = 0;
    nxt_state = IDLE;

case(state)
    IDLE : begin
        sel = 0;
        strt_cal = 1;
        nxt_state = CAL;
    end


    CAL : begin
        sel = 1;
        if(cal_done)
        nxt_state = DISP;
        else nxt_state = CAL;
    end

    DISP : begin
        sel = 0;
        if(!rst_n)
        nxt_state = IDLE;
        else nxt_state = DISP;
    end


    default : nxt_state = IDLE;

endcase

end

assign LED = (sel) ? 8'hA5 : heading[11:4];

rst_synch iDUT1(.rst_n(rst_n), .RST_n(RST_n), .clk(clk));
inert_intf	#(0) iDUT2(.clk(clk), .rst_n(rst_n), .moving(moving_val), .heading(heading),
			  .SS_n(SS_n), .SCLK(SCLK), .MOSI(MOSI), .MISO(MISO), .INT(INT), .lftIR(lftIR_val),
               .rghtIR(rghtIR_val), .cal_done(cal_done), .strt_cal(strt_cal), .rdy());



endmodule













