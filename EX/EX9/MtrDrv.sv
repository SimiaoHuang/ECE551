module MtrDrv(lft_spd, rght_spd, lftPWM1, lftPWM2, rghtPWM1, rghtPWM2, clk, rst_n);

input [10:0]lft_spd, rght_spd;
input clk, rst_n;
output lftPWM1, lftPWM2, rghtPWM1, rghtPWM2;

logic [10:0] accu_out1, accu_out2;
logic cout1, cout2;

assign {cout1, accu_out1[10:0]} = lft_spd[10:0] + 11'h400;
assign {cout2, accu_out2[10:0]} = rght_spd[10:0] + 11'h400;

PWM11 P1(.duty(accu_out1), .PWM_sig(lftPWM2), .PWM_sig_n(lftPWM1), .clk(clk), .rst_n(rst_n));
PWM11 P2(.duty(accu_out2), .PWM_sig(rghtPWM2), .PWM_sig_n(rghtPWM1), .clk(clk), .rst_n(rst_n));


endmodule

