module charge_test(GO, clk, RST_n, piezo, piezo_n);

input GO;
input clk;
input RST_n;
output piezo, piezo_n;


logic go;
logic rst_n;

PB_release iDUT1(.clk(clk), .GO(GO), .rst_n(rst_n), .go(go));

rst_synch iDUT2(.RST_n(RST_n), .clk(clk), .rst_n(rst_n));

charge iDUT3(.clk(clk), .rst_n(rst_n), .go(go), .piezo(piezo), .piezo_n(piezo_n));

endmodule