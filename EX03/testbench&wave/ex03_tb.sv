module ex03_tb();

 reg d, clk, q;
 
 ex03 iDUT(.d(d), .q(q), .clk(clk));

 initial begin
   clk = 0;
   d = 0;
   #100 $stop();
 end

 always begin
   @(posedge clk);
   d = 1;
   @(posedge clk);
   d = 0;
 end

 always
  #5 clk = ~clk;

endmodule
