module cadence_filt(clk, rst_n, cadence, cadence_filt, cadence_rise);

//the input and the output
 input logic clk, rst_n, cadence;
 output logic cadence_filt, cadence_rise;

//other
 reg c0, c1, c2;//used for the 3 filp-flops
 reg [15:0] stbl_cnt;//the maximum value of the counter should be greater than 50000, so the counter will be 16 bits wide
 reg chngd_n;//the XNOR of the prior value and the current value

//the ff part and the mux
 always_ff @(posedge clk, negedge rst_n) begin
   c0 <= cadence;
   c1 <= c0;//2 flip-flop used to eliminate metastability
   c2 <= c1;//used to delay the input for a clk

   if (!rst_n)
    cadence_filt <= 1'b0;
   else if ( &stbl_cnt )
    cadence_filt <= c2;//if the counter was full, &stbl_cnt will be 1, then it will sample the value of the input
   else
    cadence_filt <= cadence_filt;//or it will keep the prior value
 end

//the combinational logic part
 always_comb begin 
  cadence_rise = c1 & ~c2;//rise edge detect
  chngd_n = ~ c1 ^ c2;//if c1 and c2 are different, chngd_n will be 0
 end

//the counter
 always_ff @(posedge clk, negedge rst_n) begin
  if (!rst_n)
   stbl_cnt <= 16'h0000;
  else if (!chngd_n)
   stbl_cnt <= 16'h0000; //if chngd_n is 0, which means the input is not stable, the counter will be knocked down to zero
  else
   stbl_cnt <= stbl_cnt + 1;
 end

endmodule

