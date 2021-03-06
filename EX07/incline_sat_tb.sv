module incline_sat_tb();

 reg clk; 
 logic signed [12:0] incline;
 logic signed [9:0] incline_sat;

 incline_sat iDUT(.incline(incline), .incline_sat(incline_sat));

initial begin
 clk = 0;
 incline = 13'b0000000000000;

 @(negedge clk);	
 incline = 13'b1101011000101; //too negetive
 repeat (20)  @(negedge clk);
  if (incline_sat !== 10'b1000000000) begin
   $display("ERR: incline_sat should still be 10'b1000000000, was %b",incline_sat);
   $stop();
  end else
   $display("GOOD: Passed first test");

 @(negedge clk);	
 incline = 13'b1111100101001; //negetive
 repeat (20)  @(negedge clk);
  if (incline_sat !== 10'b1100101001) begin
   $display("ERR: incline_sat should still be 10'b1100101001, was %b",incline_sat);
   $stop();
  end else
   $display("GOOD: Passed second test");

 @(negedge clk);	
 incline = 13'b0000010100101; //positive
 repeat (20)  @(negedge clk);
  if (incline_sat !== 10'b0010100101) begin
   $display("ERR: incline_sat should still be 10'b0010100101, was %b",incline_sat);
   $stop();
  end else
   $display("GOOD: Passed third test");

 @(negedge clk);	
 incline = 13'b0010100100100; //too positive
 repeat (20)  @(negedge clk);
  if (incline_sat !== 10'b0111111111) begin
   $display("ERR: incline_sat should still be 10'b0111111111, was %b",incline_sat);
   $stop();
  end else
   $display("GOOD: Passed fourth test");
   $stop();
end
  always
    #5 clk = ~clk;

endmodule
