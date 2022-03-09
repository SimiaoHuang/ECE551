module inert_intf_tb();

logic strt_cal;
logic rdy;
logic cal_done;
logic signed [11:0]heading;
logic INT;
logic SS_n, SCLK;
logic MOSI, MISO;
logic moving, lftIR, rghtIR;
logic rst_n, clk;
//logic [7:0] LED;

inert_intf iDUT1(.SS_n(SS_n), .SCLK(SCLK), .rst_n(rst_n), .MOSI(MOSI), .MISO(MISO),
         .moving(moving), .lftIR(lftIR), .rghtIR(rghtIR), .rdy(rdy), .cal_done(cal_done), 
         .heading(heading), .INT(INT), .strt_cal(strt_cal), .clk(clk));

SPI_iNEMO2 iDUT2(.SS_n(SS_n), .SCLK(SCLK), .MOSI(MOSI), .MISO(MISO), .INT(INT));


initial begin
    clk = 0;
    rst_n = 0;
    strt_cal = 0;
    moving = 1;
    lftIR = 0;
    rghtIR = 0;

    @(posedge clk);
    @(negedge clk);
    rst_n = 1;


    fork
			begin: timeout1
				repeat (100000) @(posedge clk); 
				$display("NEMO ERROR!");
				$stop();
			end
			begin
				@(posedge iDUT2.NEMO_setup)
				disable timeout1;
			end
		join

    @(posedge clk);
    @(negedge clk);
    strt_cal = 1;
    @(posedge clk);
    @(negedge clk);
    strt_cal = 0;

    
    fork
			begin: timeout2
				repeat (1000000) @(posedge clk); 
				$display("cal_done ERROR!");
				$stop();
			end
			begin
				@(posedge cal_done)
				disable timeout2;
			end
		join


    repeat(8000000)@(posedge clk);
        $stop;   
end


always #5 clk = ~clk;

endmodule

