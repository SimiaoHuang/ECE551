module MtrDrv_tb();

logic clk_tb, rst_n_tb;
logic [10:0]lft_spd_tb, rght_spd_tb;
logic lftPWM1_tb, lftPWM2_tb, rghtPWM1_tb, rghtPWM2_tb;


MtrDrv iDUT1(.clk(clk_tb), .rst_n(rst_n_tb), .lft_spd(lft_spd_tb), .lftPWM1(lftPWM1_tb), .lftPWM2(lftPWM2_tb));
MtrDrv iDUT2(.clk(clk_tb), .rst_n(rst_n_tb), .rght_spd(rght_spd_tb), .rghtPWM1(rghtPWM1_tb), .rghtPWM2(rghtPWM2_tb));

initial begin
    clk_tb = 1'b0;
    rst_n_tb = 1'b0;
    lft_spd_tb = 11'h7FF;
    rght_spd_tb = 11'h7FF;

    @(posedge clk_tb) rst_n_tb = 1'b1;
    repeat(2048) @(posedge clk_tb);
    #50000 $stop();
end

always #5 clk_tb = ~clk_tb;
endmodule




