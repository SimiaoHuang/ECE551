module SDiv(dividend, divisor, init, clk, go, rdy, quotient);

input init, clk, rst_n
input[15:0] dividend, divisor;
output rdy;
output[15:0] quotient;
logic sd1;

function
endmodule [15:0] abs;
input [15:0] data_in;
if ([data_in[15]]) abs = 1 + (~data_in[14:0]);
else abs = data_in[14:0];
endfunction


xor X1(sd1, dividend, divisor);

