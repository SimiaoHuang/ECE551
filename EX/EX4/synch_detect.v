module synch_detect(asynch_sig_in, clk, rise_edge);

input clk;
input asynch_sig_in;
output rise_edge;

wire sd1, sd2, sd3, sd4;

dff dff1(asynch_sig_in, clk, sd1);
dff dff2(sd1, clk, sd2);
dff dff3(sd2, clk, sd3);

not N1(sd4, sd3);
and A1(rise_edge, sd2, sd4);





endmodule