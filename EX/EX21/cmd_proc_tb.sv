
// MIFF

module cmd_proc_tb();

	logic clk, rst_n;
	logic [15:0]cmd; // cmd sent to RemoteComm
	logic [15:0]cmd_in;// cmd sent to cmd_proc
	logic snd_cmd;
	logic cmd_sent;
	logic resp_rdy;
	logic [7:0]resp;
	logic TX_RX, RX_TX;
	logic cmd_rdy, clr_cmd_rdy;
	logic send_resp;
	logic tour_go;
	logic lftIR, rghtIR, cntrIR;
	logic fanfare_go;
	logic [9:0] frwrd;
	logic [11:0]error;
	logic [11:0]heading;
	logic heading_rdy, strt_cal, cal_done, moving;
	logic INT, SS_n, SCLK, MOSI, MISO;
	logic [11:0] error_check1, error_check2; // for further check

	RemoteComm iDUT1(.cmd(cmd), .snd_cmd(snd_cmd), .resp(resp), .clk(clk),
	 .rst_n(rst_n), .TX(TX_RX), .RX(RX_TX), .resp_rdy(resp_rdy), .cmd_snt(cmd_sent));

	UART_wrapper iDUT2(.clk(clk), .rst_n(rst_n), .cmd(cmd_in), .cmd_rdy(cmd_rdy),
	  .clr_cmd_rdy(clr_cmd_rdy), .tx_done(), .resp(8'hA5), .RX(TX_RX), .TX(RX_TX), .trmt(send_resp));

	cmd_proc #(1) iDUT3(.clk(clk), .rst_n(rst_n), .cmd(cmd_in), .cmd_rdy(cmd_rdy), .clr_cmd_rdy(clr_cmd_rdy),
	.send_resp(send_resp), .tour_go(tour_go), .heading(heading), .heading_rdy(heading_rdy),
	.strt_cal(strt_cal), .cal_done(cal_done), .moving(moving), .lftIR(lftIR), .cntrIR(cntrIR), .rghtIR(rghtIR),
	.fanfare_go(fanfare_go), .frwrd(frwrd), .error(error));

	inert_intf #(1) iDUT4(.clk(clk), .rst_n(rst_n), .INT(INT), .SS_n(SS_n), .SCLK(SCLK), .MOSI(MOSI), .MISO(MISO),
	.lftIR(lftIR), .rghtIR(rghtIR), .heading(heading), .rdy(heading_rdy), .strt_cal(strt_cal), .cal_done(cal_done),
	.moving(moving));

	SPI_iNEMO3 iDUT5(.SS_n(SS_n), .INT(INT), .SCLK(SCLK), .MOSI(MOSI), .MISO(MISO));

	initial begin
		clk = 1'b0;
		rst_n = 1'b0;
		lftIR = 1'b0;
		rghtIR = 1'b0;
		cmd = 16'b0;
		
		cntrIR = 1'b0;
		lftIR = 1'b0;
		rghtIR = 1'b0;
		
		@(posedge clk);
		@(negedge clk);
		rst_n = 1'b1;
		cmd = 16'b0; // calibrate command
		snd_cmd = 1'b1;
		@(posedge clk);
		snd_cmd = 1'b0;


		// check for cal_done
		fork
			begin : timeout1
				repeat(1000000) @(posedge clk);
				$display("ERROR: time out waiting for cal_done to complete");
				$stop;
			end
			begin
				@(posedge cal_done) begin
					disable timeout1;
					$display("cal_done occur!");
				end
			end
		join


		//check for resp_rdy
		fork
			begin : timeout2
				repeat(100000) @(posedge clk);
				$display("ERROR: time out waiting for resp_rdy to complete");
				$stop;
			end
			begin
				@(posedge resp_rdy)begin
					disable timeout2;
					$display("resp_rdy occur!");
				end
			end
		join

		//begin to test for move "north" 1       
		@(posedge clk);
		@(negedge clk);
		cmd = 16'h2001; //move "north" 1
		snd_cmd = 1'b1;
		@(posedge clk);
		snd_cmd = 1'b0;

		//check if frwrd equal to 0 when cmd_sent
		fork
			begin : timeout3
				repeat(100000) @(posedge clk);
				$display("ERROR: time out waiting for frwrd");
				$stop;
			end
			begin
				@(posedge cmd_sent)begin
					if(frwrd == 10'h000)
					disable timeout3;
					$display("frwrd begin to work!");
				end
			end
		join

		//wait for 10 positive edges for heading_rdy and check frwrd
		repeat(10)@(posedge heading_rdy);
		if(frwrd == 10'h140)   //after 10 heading_rdy, the frwrd should be incremented to 10'h140.
			$display("the frwrd works as expected!");
		else
			$display("frwrd works error");

		//check if moving or not
		@(posedge clk);
		@(negedge clk);
		if(moving)
			$display(" moving asserted successfully");
		else 
			$display (" not moving here...");

		// wait and check for frwrd speed up to max
		repeat(20)@(posedge heading_rdy);
		if(&frwrd[9:8] == 1'b1)
			$display("frwrd has ramped up to max speed");
		else
			$display("frwrd error to max speed");   
		error_check1 = error;

		//give the first pulse on cntrIR
		@(posedge clk);
		@(negedge clk);
		cntrIR = 1'b1;
		@(posedge clk);
		@(negedge clk);
		cntrIR = 1'b0;

		//check if frwrd remain max speed or not
		repeat(5)@(posedge clk);
		if(&frwrd[9:8] == 1'b1)
			$display("first line crossed successfully");
		else
			$display("error to cross first line");   
			
		//give the second pulse on cntrIR
		@(posedge clk);
		@(negedge clk);
		cntrIR = 1'b1;
		@(posedge clk);
		@(negedge clk);
		cntrIR = 1'b0;

		//check if frwrd ramp down to 0 and if resp_rdy asserted
		fork
			begin : timeout4
				repeat(200000) @(posedge clk);
				$display("ERROR for resp_rdy");
				$stop;
			end
			begin
				@(posedge resp_rdy)begin
					if(frwrd == 10'h000)
						disable timeout4;
					$display("Yahooo, test pass successfully!");
				end
			end
		join

		//This is the further test: would a lftIR pulse cause a disturbance in error
		repeat(100)@(posedge clk);
		cmd = 16'h2001;
		snd_cmd = 1'b1;
		@(posedge clk);
		snd_cmd = 1'b0;
		repeat(30)@(posedge heading_rdy);
		lftIR = 1'b1;
		@(posedge clk);
		@(negedge clk);
		error_check2 = error;
		if(error_check1 !== error_check2)
			$display("further test complete!");
		else
			$display("further test failed");

		repeat(100000)@(posedge clk);
		$stop;

	end

	always #5 clk = ~clk;

endmodule
