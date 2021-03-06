module PWM_tb();
    reg clk, rst_n;
    reg [10:0] duty;

    logic PWM_sig;
    logic PWM_synch;

    PWM iDUT(.clk(clk), .rst_n(rst_n), .duty(duty), .PWM_sig(PWM_sig), .PWM_synch(PWM_synch));

        initial begin
            clk = 1'b0;
            rst_n = 1'b0;
            PWM_synch = 1'b0;
            duty = 10'h1FF;//first the duty is 511

            @(negedge clk)
            rst_n = 1'b1;
            repeat(2048)@(posedge clk);

            duty = 10'h3FF;//after 2048clk, the duty is changed to 1023
            repeat(2048)@(posedge clk);
            #5000 $stop();
        end
        
        always
        #5 clk = ~clk;

endmodule
