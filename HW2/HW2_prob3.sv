//prob3
//a. Is this code correct? If so why does it correctly infer and model a latch? If not, what is wrong with it?
module latch(d,clk,q);
 input d, clk;
 output reg q;

 always @(clk)
  if (clk)
   q <= d;
endmodule
//b. This is correct because latch is level triggered. In this case, when clk is high, latch will sample d.

//c.  a D-FF with an active high synchronous set and an enable
module ff_c(d, clk, set, en, q);

 input logic d, clk, set, en;
 output logic q;

 always_ff @(posedge clk)begin
   if (set)//active high synchronous set
     q <= 1'b1;
   else if (en)//enable
     q <= d;//q gets the value
   else 
     q <= q;//q hold the value
 end

endmodule

//d. a D-FF with asynchronous active low reset and an active high enable
module ff_d(d, clk, rst_n, en, q);

 input logic d, clk, rst_n, en;
 output logic q;

 always_ff @(posedge clk, negedge rst_n)begin
   if (!rst_n)//asynchronous active low reset
     q <= 1'b0;
   else if (en)//active high enable
     q <= d;//q gets the value
   else 
     q <= q;//q hold the value
 end

endmodule

//e. a set/reset FF with active low synchronous reset
module SR_ff(clk, rst_n, set, clr, q);

 input logic clk, rst_n, set, clr;
 output logic q;

 always_ff @(posedge clk)begin
   if (!rst_n)//synchronous active low reset
     q <= 1'b0;
   else if (set)//if set is high, q will be setted
     q <= 1'b1;
   else if (clr)//if clr is high, q will be cleared
     q <= 1'b0;
   else if (!set & !clr)//if neither set or clr are high, q will maintain the state
     q <= q;
 end

endmodule