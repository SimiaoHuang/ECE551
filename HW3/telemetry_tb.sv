module telemetry_tb();

 logic [11:0] batt_v;
 logic [11:0] avg_curr;
 logic [11:0] avg_torque;
 logic clk, rst_n;
 logic TX;

//initialize
 logic [7:0] rx_data;
 logic rx_rdy;
 telemetry iDUT(.batt_v(batt_v), .avg_curr(avg_curr), .avg_torque(avg_torque), .clk(clk), .rst_n(rst_n), .TX(TX));
 UART_rcv U_rcv(.clk(clk),.rst_n(rst_n),.RX(TX),.rdy(rx_rdy),.rx_data(rx_data), .clr_rdy(rx_rdy));

//packet
 logic [7:0] delim1, delim2;
 logic [7:0] payload1, payload2, payload3, payload4, payload5, payload6;
 assign delim1 = 8'hAA;
 assign delim2 = 8'h55;
 assign payload1 = {4'h0, batt_v[11:8]};
 assign payload2 = batt_v[7:0];
 assign payload3 = {4'h0, avg_curr[11:8]};
 assign payload4 = avg_curr[7:0];
 assign payload5 = {4'h0, avg_torque[11:8]};
 assign payload6 = avg_torque[7:0];

initial begin
 clk = 0;
 rst_n = 0;
 batt_v[11:0] = $random;
 avg_curr[11:0] = $random;
 avg_torque[11:0] = $random;
	
 @(posedge clk);
 @(negedge clk);
 rst_n = 1;
	
//test delim1
 @(posedge rx_rdy);
  if (rx_data != delim1) begin
   $display("Error: delim1 not match");
   $stop();
  end else
   $display("delim1 received correctly");

//test delim2
 @(posedge rx_rdy);
  if (rx_data != delim2) begin
   $display("Error: delim2 not match");
   $stop();
  end else
   $display("delim2 received correctly");

//test payload1
 @(posedge rx_rdy);
  if (rx_data != payload1) begin
   $display("Error: payload1 not match");
   $stop();
  end else
   $display("payload1 received correctly");

//test payload2
 @(posedge rx_rdy);
  if (rx_data != payload2) begin
   $display("Error: payload2 not match");
   $stop();
  end else
   $display("payload2 received correctly");

//test payload3
 @(posedge rx_rdy);
  if (rx_data != payload3) begin
   $display("Error: payload3 not match");
   $stop();
  end else
   $display("payload3 received correctly");

//test payload4
 @(posedge rx_rdy);
  if (rx_data != payload4) begin
   $display("Error: payload4 not match");
   $stop();
  end else
   $display("payload4 received correctly");

//test payload5
 @(posedge rx_rdy);
  if (rx_data != payload5) begin
   $display("Error: payload5 not match");
   $stop();
  end else
   $display("payload5 received correctly");

//test payload6
 @(posedge rx_rdy);
  if (rx_data != payload6) begin
   $display("Error: payload6 not match");
   $stop();
  end else
   $display("payload6 received correctly");
   $display("Tests passed!!!");
   $stop();
end

always 
 #5 clk = ~clk;

endmodule
