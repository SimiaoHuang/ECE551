module ex3_tb();

reg d_tb, clk_tb, q_tb;

ex3 DUT(.d(d_tb), .clk(clk_tb), .q(q_tb));


initial begin
    clk_tb = 0;
    d_tb = 0;
    #1000 $stop();

end

 always begin
     @(posedge clk_tb);
     d_tb = 1;
     @(posedge clk_tb);

     @(posedge clk_tb);
     d_tb = 0;
     @(posedge clk_tb);
     
 end

always begin
 #5 clk_tb= ~clk_tb;
end

endmodule

        
    
