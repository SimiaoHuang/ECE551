module charge_tb();

logic clk, rst_n;
logic go;
logic piezo, piezo_n;
logic SCLK;

parameter FAST_SIM = 1;


charge #(FAST_SIM) iDUT(.clk(clk), .rst_n(rst_n), .go(go), .piezo(piezo), .piezo_n(piezo_n));

initial begin
    go = 0;
    clk = 0;
    rst_n = 0;
    SCLK = 0;
    

    @(posedge clk);
    @(negedge clk);
    rst_n = 1;
    go = 1;

    //@(posedge clk);
    //@(negedge clk);
    //go = 0;





    repeat(5000000)@(posedge clk);
    $stop;

end

always #5 clk = ~clk;



endmodule