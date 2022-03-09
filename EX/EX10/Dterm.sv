module Dterm(err_sat, err_vld, rst_n, clk, D_term);

input [9:0] err_sat;
input err_vld, clk, rst_n;
output [12:0] D_term;

logic [9:0] sd1, sd3; // outputs of two mux
logic [9:0] sd2, prev_err; // outputs of two flip flop
logic [9:0] D_diff;
logic [6:0] err_sat2;

//mux1
assign  sd1[9:0] = (err_vld) ? err_sat : sd2;

//flip flop1
always_ff @(posedge clk , negedge rst_n)
    if (!rst_n)
    sd2[9:0] <= 9'b000000000;
    else
    sd2[9:0] <= sd1[9:0];

// mux2
assign sd3[9:0] = (err_vld) ? sd2 : prev_err;

// flip flop2
always_ff @(posedge clk, negedge rst_n)
if (!rst_n)
prev_err[9:0] <= 9'b000000000;
else
prev_err[9:0] <= sd3[9:0];


assign D_diff = err_sat - prev_err;

//sat to 7 bits
assign err_sat2[6:0] = (~D_diff[9] & |D_diff[8:6]) ? 7'b0111111 : (D_diff[9] & ~&D_diff[8:6]) ? 7'b1000000 : D_diff[6:0];

localparam D_COEFF = 6'h0B;
wire [11:0] temp;

// signed multiply
assign temp = err_sat2[5:0] * D_COEFF;
assign D_term = {err_sat2[6],temp};

endmodule

