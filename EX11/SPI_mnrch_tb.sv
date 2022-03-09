module SPI_mnrch_tb();

 logic clk, rst_n;
 logic snd;
 logic MISO;
 logic [15:0] cmd;
 logic SS_n, SCLK, MOSI;
 logic done;
 logic [15:0] resp;

//initialize iDUT
 SPI_mnrch SPI_tb(.clk(clk), .rst_n(rst_n), .SS_n(SS_n), .SCLK(SCLK), .MOSI(MOSI), .MISO(MISO), .snd(snd), .cmd(cmd), .done(done), .resp(resp));
 ADC128S ADC128S_tb(.clk(clk), .rst_n(rst_n), .SS_n(SS_n), .SCLK(SCLK), .MOSI(MOSI), .MISO(MISO));

 initial begin
  clk = 1'b0;
  rst_n = 1'b0;
  snd = 1'b0;
//----test 1--read channel 1-------------------------------
 cmd = {2'b00,3'b001,11'h000};
 @(posedge clk);
 @(negedge clk);
   rst_n = 1'b1;   //deassert, reset all signals

 @(negedge clk);
   snd = 1'b1;
 @(negedge clk);
   snd = 1'b0;
 @(posedge done);
   if (resp !== 16'h0C00) begin
    $display("ERR: resp should be 16'h0c00, was %b",resp);
    $stop();
   end else
    $display("Test 1 Passed ");

//----test 2--read channel 1--------------------------------
 cmd = {2'b00,3'b001,11'h000};
 @(posedge clk);
 @(negedge clk);
   snd = 1'b1;
 @(negedge clk);
   snd = 1'b0;
 @(posedge done);
   if (resp !== 16'h0C01) begin
    $display("ERR: resp should be 16'h0c01, was %b",resp);
    $stop();
   end else
    $display("Test 2 Passed ");

//----test 3--read channel 4---------------------------------
 cmd = {2'b00,3'b100,11'h000};
 @(posedge clk);
 @(negedge clk);
   snd = 1'b1;
 @(negedge clk);
   snd = 1'b0;
 @(posedge done);
   if (resp !== 16'h0BF1) begin
    $display("ERR: resp should be 16'h0BF1, was %b",resp);
    $stop();
   end else
    $display("Test 3 Passed ");

//----test 4--read channel 4----------------------------------
 cmd = {2'b00,3'b100,11'h000};
 @(posedge clk);
 @(negedge clk);
   snd = 1'b1;
 @(negedge clk);
   snd = 1'b0;
 @(posedge done);
   if (resp !== 16'h0BF4) begin
    $display("ERR: resp should be 16'h0BF4, was %b",resp);
    $stop();
   end else
    $display("Test 4 Passed ");
    $stop();
   end

 always
  #5 clk = ~clk; 

endmodule