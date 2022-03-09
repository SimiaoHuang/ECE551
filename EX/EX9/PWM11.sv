module PWM11(clk, rst_n, duty, PWM_sig, PWM_sig_n);

input clk, rst_n;
input [10:0]duty;
output PWM_sig, PWM_sig_n;


logic [10:0]cnt;
logic d;
logic PWM_sig, PWM_sig_n;


always_ff @(posedge clk or negedge rst_n)begin
  if(!rst_n)
  cnt <= 11'b00000000000;
  else
  cnt <= cnt + 1;
end

assign d = (cnt < duty) ? 1 : 0;

always_ff @(posedge clk or negedge rst_n)begin
    if(!rst_n)
    PWM_sig <= 0;
    else
    PWM_sig <= d;
end


assign PWM_sig_n = ~PWM_sig;

endmodule
