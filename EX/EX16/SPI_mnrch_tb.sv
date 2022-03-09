module SPI_mnrch_tb();
    reg clk, rst_n;
    reg [15:0] wt_data;
    reg wrt;
    
    wire [15:0] rd_data;
    wire INT;
    wire done;

    logic SS_n;
    logic SCLK;
    logic MOSI;
    logic MISO;
    
    SPI_mnrch imnrch(.clk(clk), .rst_n(rst_n), .wt_data(wt_data), .wrt(wrt), .rd_data(rd_data), 
    .SS_n(SS_n), .SCLK(SCLK), .MOSI(MOSI), .MISO(MISO), .done(done));
    SPI_iNEMO1 iNEMO1(.SS_n(SS_n), .SCLK(SCLK), .MOSI(MOSI), .MISO(MISO), .INT(INT));

    initial begin
        clk = 1'b0;
        rst_n = 1'b0;   //assert
        wt_data = 16'b0;
        wrt = 1'b0;

        @(posedge clk);
        @(negedge clk);
	    rst_n = 1'b1;   //deassert, reset all signals
        wt_data = 16'h8F00;
        wrt = 1'b1;
        @(posedge clk);
        wrt = 1'b0;

        fork
            begin : timeout1
                repeat(100000) @(posedge clk);
                $display("ERROR: time out waiting for transmission to complete");
                $stop;
            end
            begin
                @(posedge done)begin
                if(rd_data[7:0] == 8'h6A)
                    disable timeout1;
                    $display("Transaction succeed!");
                end
            end
        join

    
        @(posedge clk);
        @(negedge clk);

        wt_data = 16'h0D02; //writing 0x02 to the register at address 0x0D
        wrt = 1'b1;
        @(posedge clk);
        wrt = 1'b0;

        fork
            begin : timeout2
                repeat(100000) @(posedge clk);
                $display("ERROR: time out waiting for NEMO_setup");
                $stop;
            end
            begin
                @(posedge iNEMO1.NEMO_setup);
                disable timeout2;
                $display("NEMO detection succeed!");
            end
        join

        repeat(100000)@(posedge clk);
        $stop;
    end

    always
        #5 clk = ~clk;

endmodule
