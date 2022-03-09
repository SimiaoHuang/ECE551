module desiredDrive_tb();

 reg clk;
 logic [11:0] avg_torque_tb;//12bits
 logic [4:0] cadence_tb;//5bits
 logic not_pedaling_tb;
 logic signed [12:0] incline_tb;
 logic [2:0] scale_tb;//3bits
 logic [11:0] target_curr_tb;

 desiredDrive iDUT(.avg_torque(avg_torque_tb), .cadence(cadence_tb), .not_pedaling(not_pedaling_tb), .incline(incline_tb), .scale(scale_tb),
                   .target_curr(target_curr_tb));

  initial begin
  clk = 0;
  avg_torque_tb = 12'h000; 
  cadence_tb = 5'h00; 
  incline_tb = 13'h0000; 
  scale_tb = 3'h0; 
  not_pedaling_tb = 1'h0;

//TEST 1
 @(negedge clk);	
  avg_torque_tb = 12'h800; 
  cadence_tb = 5'h10; 
  incline_tb = 13'h0150; 
  scale_tb = 3'h3; 
  not_pedaling_tb = 1'h0;

 repeat (20)  @(negedge clk);
  if (target_curr_tb !== 12'hA1A) begin
   $display("ERR: target_curr_tb should be 12'hA1A, was %b",target_curr_tb);
   $stop();
  end else
   $display("Test 1 Passed ");

//TEST 2
 @(negedge clk);	
  avg_torque_tb = 12'h800; 
  cadence_tb = 5'h10; 
  incline_tb = 13'h1F22; 
  scale_tb = 3'h5; 
  not_pedaling_tb = 1'h0;

 repeat (20)  @(negedge clk);
  if (target_curr_tb !== 12'h11E) begin
   $display("ERR: target_curr_tb should be 12'h11E, was %b",target_curr_tb);
   $stop();
  end else
   $display("Test 2 Passed ");

//TEST 3
 @(negedge clk);	
  avg_torque_tb = 12'h360; 
  cadence_tb = 5'h10; 
  incline_tb = 13'h0C0; 
  scale_tb = 3'h5; 
  not_pedaling_tb = 1'h0;

 repeat (20)  @(negedge clk);
  if (target_curr_tb !== 12'h000) begin
   $display("ERR: target_curr_tb should be 12'h000, was %b",target_curr_tb);
   $stop();
  end else
   $display("Test 3 Passed ");

//TEST 4
 @(negedge clk);	
  avg_torque_tb = 12'h800; 
  cadence_tb = 5'h18; 
  incline_tb = 13'h1EF0; 
  scale_tb = 3'h5; 
  not_pedaling_tb = 1'h0;

 repeat (20)  @(negedge clk);
  if (target_curr_tb !== 12'h000) begin
   $display("ERR: target_curr_tb should be 12'h000, was %b",target_curr_tb);
   $stop();
  end else
   $display("Test 4 Passed ");

//TEST 5
 @(negedge clk);	
  avg_torque_tb = 12'h7E0; 
  cadence_tb = 5'h18; 
  incline_tb = 13'h0000; 
  scale_tb = 3'h7; 
  not_pedaling_tb = 1'h0;

 repeat (20)  @(negedge clk);
  if (target_curr_tb !== 12'hD66) begin
   $display("ERR: target_curr_tb should be 12'hD66, was %b",target_curr_tb);
   $stop();
  end else
   $display("Test 5 Passed ");

//TEST 6
 @(negedge clk);	
  avg_torque_tb = 12'h7E0; 
  cadence_tb = 5'h18; 
  incline_tb = 13'h0080; 
  scale_tb = 3'h7; 
  not_pedaling_tb = 1'h0;

 repeat (20)  @(negedge clk);
  if (target_curr_tb !== 12'hFFF) begin
   $display("ERR: target_curr_tb should be 12'hFFF, was %b",target_curr_tb);
   $stop();
  end else
   $display("Test 6 Passed ");

//TEST 7
 @(negedge clk);	
  avg_torque_tb = 12'h7E0; 
  cadence_tb = 5'h18; 
  incline_tb = 13'h0080; 
  scale_tb = 3'h7; 
  not_pedaling_tb = 1'h1;

 repeat (20)  @(negedge clk);
  if (target_curr_tb !== 12'h000) begin
   $display("ERR: target_curr_tb should be 12'h000, was %b",target_curr_tb);
   $stop();
  end else
   $display("Test 7 Passed ");
   $stop();
 end


 always
  #5 clk = ~clk; 

endmodule