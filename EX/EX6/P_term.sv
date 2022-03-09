module P_term(P_term, error, cout);

input [11:0]error;
output [13:0]P_term;
output cout;

wire [9:0]error_sat;

assign error_sat[9:0] = (~error[11] & |error[10:9]) ? 10'b0111111111 : (error[11] & ~&error[10:9]) ? 10'b1000000000 : error[9:0];
//assign error_sat[9:0] = error[11] ? (error[10] && error[9] ? 10'b01111111111 : error[9:0]) : (error[10] && error[9] ? error[9:0] : 10'b1000000000);

assign {cout, P_term[13:0]} = 5'b01000 * error_sat[9:0];

endmodule
