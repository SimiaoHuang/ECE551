module Dterm_tb();


logic err_vld_tb, rst_n_tb, clk_tb;
logic [9:0]err_sat_tb;
logic [12:0]D_term_tb;

Dterm iDUT(.err_vld(err_vld_tb), .rst_n(rst_n_tb), .clk(clk_tb), .err_sat(err_sat_tb), .D_term(D_term_tb));

initial begin
    clk_tb = 1'b0;
    rst_n_tb = 1'b0;
    err_vld_tb = 1'b1;
    err_sat_tb[9:0] = 10'b0101010101;



    repeat(10) @(posedge clk_tb);

    if(D_term_tb == 13'b0001010110101)begin
        $display("Test pass!");
    end

    repeat(5000) @(posedge clk_tb);
    #10000 $stop();

end


endmodule