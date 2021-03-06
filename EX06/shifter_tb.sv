module shifter_tb();

 logic [15:0] src, res;
 logic [3:0] amt;
 logic ars;
 reg clk;                        //system clock

 shifter iDUT (.src(src), .ars(ars), .amt(amt), .res(res));

 initial begin
  clk = 0; 
  src = 16'h0000;
  amt = 4'b0000;
  ars = 0;
  #1000 $stop;
 end

 always@(posedge clk)//the value will be random
    begin
        src[15:0] = $random;
        amt[3:0] = $random;
        ars = $random;
    end

 always
  #5 clk = ~clk;		
endmodule