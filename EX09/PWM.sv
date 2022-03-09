module PWM(clk, rst_n, duty, PWM_sig, PWM_synch);

    input clk, rst_n;
    input [10:0]duty;
    output reg PWM_sig, PWM_synch;

    reg [10:0] cnt;
    wire comp_out;//the result of the comparation

    //asynchronized reset counter
    always_ff @ (posedge clk, negedge rst_n)begin
        if(!rst_n)
            cnt <= 11'b00000000000;
        else
            cnt <= cnt + 1;
    end

    assign PWM_synch = (cnt == 11'h001)? 1 : 0;//when cnt=1, the synch signal will be set
    assign comp_out = (cnt <= duty)?  1 : 0;

    //compare
    always_ff @(posedge clk, negedge rst_n) begin
        if(!rst_n)
            PWM_sig <= 0;
        else
            PWM_sig <= comp_out;
    end


endmodule
