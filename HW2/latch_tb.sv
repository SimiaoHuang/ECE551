module latch_tb();

logic d, clk;
logic q;

latch iDUT (.d(d), .clk(clk), .q(q));

initial begin
clk = 0;
d = 0;
q = 0;

#15 d = 1;
#20 d = 0;
#15 d = 1;
#10 d = 0;
$stop;
end

always
 #5 clk = ~clk;

endmodule
