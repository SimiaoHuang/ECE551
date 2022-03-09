module I_term(clk, rst_n, err_vld, moving, err_sat, I_term);

input clk, rst_n, err_vld, moving;
input [9:0]err_sat;
output [8:0]I_term;

logic signed [14:0]sd1, sd2, sd3, sd4, sd5;
logic md1, md2;

//sign extend 15-bits
assign sd1[14:0] = {{5{err_sat[9]}} , err_sat[9:0]};


// accumulate
assign sd2[14:0] = sd1[14:0] + sd5[14:0];

// mux1
assign sd3[14:0] = (md1)? sd2 : sd5;

// mux2
assign sd4[14:0] = (moving)? sd3 : 15'h0000;

//FF
always_ff @(posedge clk, negedge rst_n)
        if (!rst_n)
            sd5[14:0] <= 15'h0000;
        else
            sd5[14:0] <= sd4[14:0];

// I_term assignment
assign I_term[8:0] = sd5[14:6];

and A1(md1, err_vld, !md2);

//overflow
assign md2 = (sd1[14] & sd5[14]) ? ((sd1[14] & sd5[14] & !sd2[14]) ? 1'b1 : 1'b0) : 1'b0;


endmodule