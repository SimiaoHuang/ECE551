module PWM11_tb();

logic clk_tb, rst_n_tb;
logic [10:0]duty_tb;
logic PWM_sig_n_tb;
logic PWM_sig_tb;


PWM11 iDUT(.clk(clk_tb), .rst_n(rst_n_tb), .duty(duty_tb), .PWM_sig(PWM_sig_tb), .PWM_sig_n(PWM_sig_n_tb));

initial begin
    clk_tb = 1'b0;
    rst_n_tb = 1'b0;
    duty_tb = 11'h7FF;
    
    @(posedge clk_tb) rst_n_tb = 1'b1;

    repeat(2048)@(posedge clk_tb);
    #50000 $stop();
end

always #5 clk_tb = ~clk_tb;

endmodule
