module nonoverlap_tb();

 reg clk, rst_n;
 reg PWM;//the input from PWM
 wire highIn, lowIn;
 wire highOut, lowOut;
 reg [5:0] dead_t;

 nonoverlap iDUT(.clk(clk), .rst_n(rst_n), .highIn(highIn), .lowIn(lowIn), .highOut(highOut), .lowOut(lowOut));

 assign highIn = PWM;
 assign lowIn = ~PWM;

 initial begin
  clk = 0;
  rst_n = 0;
  PWM = 0;
  dead_t = 0;

  @(posedge clk);
  @(negedge clk);
   rst_n = 1;
   PWM = 1;

//output will be forced low for 32 clocks
  for (dead_t = 0; dead_t < 32; dead_t = dead_t + 1) begin
   @(posedge clk);
    if (highOut != 1'b0 || lowOut != 1'b0) begin
      $display("Error: outputs should be low for 32 clocks.");
      $stop();
    end
  end
	
   @(posedge clk);
     #5;
     if (highOut != highIn || lowOut != lowIn) begin
       $display("Error: output should be the same as input.");
		$stop();
     end else
       $display("Test passed!");
       $stop();
     end

  always
   #5 clk = ~clk;

endmodule
