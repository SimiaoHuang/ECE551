module I_term_tb();

logic clk_tb, rst_n_tb;
logic err_vld_tb;
logic moving_tb;
logic [9:0]err_sat_tb;
logic [8:0]I_term_tb;
logic [8:0]I_term_tb_test;
logic [8:0]I_term_tb_ovtest1, I_term_tb_ovtest2;

I_term iDUT (.clk(clk_tb), .rst_n(rst_n_tb), .err_vld(err_vld_tb), .moving(moving_tb), .err_sat(err_sat_tb), .I_term(I_term_tb));

initial begin
    clk_tb = 0;
    rst_n_tb = 0;
    moving_tb = 1;
    err_vld_tb = 1;
    err_sat_tb = 10'h1FF;
    @(posedge clk_tb);
    @(negedge clk_tb);
    rst_n_tb = 1;

    repeat(10)@(posedge clk_tb);
    moving_tb = 0;
    if (I_term_tb == 9'b000000000) begin
        $display("not moving, this part works!");
    end

    repeat(10)@(posedge clk_tb);
    moving_tb = 1;
    err_vld_tb = 0;
    I_term_tb_test = I_term_tb;
    @(posedge clk_tb);
    if(I_term_tb_test == I_term_tb)begin
        $display("error control is working")
        rst_n_tb = 0;
        @(negedge clk_tb);
        rst_n_tb = 1;
    end

repeat(10)@(posedge clk_tb);
moving_tb = 1;
err_vld_tb = 1;
I_term_tb_temp = I_term_tb;
@(posedge clk_tb);
if(I_term_tb == I_term_tb_test *2)begin
    $display("the Integrator works!");
    rst_n_tb = 0;
    @(negedge clk_tb);
    rst_n_tb = 1;
end


repeat(32)@(posedge clk_tb);
I_term_tb_ovtest1 = I_term_tb;
repeat(1)@(posedge clk_tb);
I_term_tb_ovtest2 = I_term_tb;
if(I_term_tb_ovtest1 == I_term_tb_ovtest2)begin
    $display("the ov cobtrol works!");
end



repeat(100)@(posedge clk_tb);
#2000 $stop();

end



always 
#5 clk_tb = ~clk_tb;

endmodule
    

