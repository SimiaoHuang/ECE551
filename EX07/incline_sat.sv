module incline_sat(incline, incline_sat);

 input [12:0] incline;
 output [9:0] incline_sat;

 assign incline_sat = (incline[12] & ~&incline[11:9]) ? 10'b1000000000 ://when the incline is too negetive, it will be saturated to 10'b1000000000
                      (~incline[12] & |incline[11:9]) ? 10'b0111111111 ://when the incline is too positive, it will be saturated to 10'b0111111111
                       incline[9:0];//just keep the [9:0] of the incline

endmodule