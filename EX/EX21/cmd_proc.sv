
// MIFF

module cmd_proc(clk,rst_n,cmd,cmd_rdy,clr_cmd_rdy,send_resp,strt_cal,
			cal_done,heading,heading_rdy,lftIR,cntrIR,rghtIR,error,
			frwrd,moving,tour_go,fanfare_go);
				
	parameter FAST_SIM = 1;			// speeds up incrementing of frwrd register for faster simulation
				
	input clk,rst_n;				// 50MHz clock and asynch active low reset
	input [15:0] cmd;				// command from BLE
	input cmd_rdy;					// command ready
	output logic clr_cmd_rdy;		// mark command as consumed
	output logic send_resp;			// command finished, send_response via UART_wrapper/BT
	output logic strt_cal;			// initiate calibration of gyro
	input cal_done;					// calibration of gyro done
	input signed [11:0] heading;	// heading from gyro
	input heading_rdy;				// pulses high 1 clk for valid heading reading
	input lftIR;					// nudge error +
	input cntrIR;					// center IR reading (have I passed a line)
	input rghtIR;					// nudge error -
	output reg signed [11:0] error;	// error to PID (heading - desired_heading)
	output reg [9:0] frwrd;			// forward speed register
	output logic moving;			// asserted when moving (allows yaw integration)
	output logic tour_go;			// pulse to initiate TourCmd block
	output logic fanfare_go;		// kick off the "Charge!" fanfare on piezo
	
	// Declare SM Types
	typedef enum logic [2:0] {IDLE,CMD,CAL,TOUR,MV_INIT,MV_INC,MV_MAX,MV_DEC} state_t;
	state_t state, nxt_state;
	
	// Declare Internal Signals
	logic error_rdy,max_spd,zero;
	logic move_cmd,move_done;
	logic fanfare_en,fanfare_op;
	logic inc_frwd,dec_frwd;
	logic [9:0] inc_amt,inc_amt_dec,inc_amt_inc;
	logic frwrd_en,prev_cntrIR,edge_detected;
	logic [3:0] num_sqrs, line_cnt;
	logic [2:0] num_sqrs_cmd;
	logic [11:0] desired_heading,err_nudge,rght_nudge,lft_nudge;
	
	/******************frwrd Register******************/
	
	// Signals which indicate whether the forward speed is at its max or zero value.
	assign max_spd = &frwrd[9:8];
	assign zero = ~(|frwrd);
	
	assign inc_amt_inc = FAST_SIM ? 10'h020 : 10'h004;	// Determines which value to increment/decrement frwrd by.
	assign inc_amt_dec = FAST_SIM ? 10'h040 : 10'h008;
	assign inc_amt = inc_frwd ? inc_amt_inc : inc_amt_dec; 	// Selects the increment amount to reflect which mode the SM
															// is in.
	
	// Signal which enables the frwrd register.
	assign frwrd_en = ~(inc_frwd & max_spd) & ~(dec_frwd & zero) & heading_rdy & (inc_frwd | dec_frwd);
	
	// frwrd incrementer
	always_ff @(posedge clk, negedge rst_n) begin
		if(!rst_n)
			frwrd = 10'h000;
		else if(frwrd_en)
			frwrd = frwrd + inc_amt;
	end
	
	/******************Fanfare Logic*****************/
	
	// Store fanfare_op(code)
	always_ff @(posedge clk, negedge rst_n) begin
		if(!rst_n)
			fanfare_op <= 1'b0;
		else if(move_cmd)
			fanfare_op <= cmd[12];
	end
	
	assign fanfare_go = fanfare_en & fanfare_op; 	// Output signal which indicates whether the the fanfare
													// unit should be activated.
	
	/*****************logic for counting squares****************/
	
	// flop to grab cmd[2:0] -- the number of squares to move
	always_ff @ (posedge clk, negedge rst_n) begin
		if (!rst_n)
			num_sqrs_cmd <= 3'b000;
		else if (move_cmd)
			num_sqrs_cmd <= cmd[2:0];
	// else -- hold value
	end

	// multiply num_sqrs by 2 (since there are two detections of a line for each square moved)
	assign num_sqrs = {num_sqrs_cmd, 1'b0};

	// counter for number of lines detected
	always_ff @ (posedge clk, negedge rst_n) begin
		if (!rst_n)
			line_cnt <= 4'b0000;
		else if (move_cmd)
			line_cnt <= 4'b0000;
		else if (edge_detected)
			line_cnt <= line_cnt + 1;
		// else -- hold value
	end

	// flop to store previous value of cntrIR
	always_ff @ (posedge clk, negedge rst_n) begin
		if (!rst_n)
			prev_cntrIR <= 1'b0;
		else 
			prev_cntrIR <= cntrIR;
	end

	// detect if there was a positive edge of cntrIR
	always_ff @(posedge clk, negedge rst_n) begin
		if (!rst_n)
			edge_detected <= 1'b0;
		else 
			edge_detected <= (~prev_cntrIR & cntrIR) ? 1'b1 : 1'b0;
	end

	// detect if move_done
	assign move_done = (num_sqrs == line_cnt) ? 1'b1 : 1'b0;
	
	/**********************PID Interface********************/
	
	// Store desired_heading
	always_ff @(posedge clk, negedge rst_n) begin
		if(!rst_n)
			desired_heading <= 12'h000;
		else if(move_cmd)
			desired_heading <= (cmd[11:4] == 8'h00) ? 12'h000 : {cmd[11:4],4'hf};
	end
	
	// Indicate which value(s) to nudge the error value by, depending on whether or
	// not FAST_SIM is asserted.
	assign rght_nudge = FAST_SIM ? 12'h1FF : 12'h05F;
	assign lft_nudge = FAST_SIM ? 12'hE00 : 12'hFA1;
	assign err_nudge = lftIR ? lft_nudge : (rghtIR ? rght_nudge : 12'h000);
	
	assign error = heading - desired_heading + err_nudge;
	
	/********************SM**********************/
	
	// Checks if the error signal is within the given allowable threshold.
	assign error_rdy = (error <= $signed(12'h030)) & (error >= $signed(12'hfd0));
	
	// SM FF
	always_ff @(posedge clk, negedge rst_n) begin
		if(!rst_n)
			state <= IDLE;
		else
			state <= nxt_state;
	end
	
	always_comb begin
		
		// Declare Default Output Values
		strt_cal = 1'b0;
		send_resp = 1'b0;
		tour_go = 1'b0;
		fanfare_en = 1'b0;
		move_cmd = 1'b0;
		inc_frwd = 1'b0;
		dec_frwd = 1'b0;
		moving = 1'b0;
		clr_cmd_rdy = 1'b0;
		nxt_state = state;
		
		case(state)
			IDLE: begin	// Wait for valid command
				if(cmd_rdy) begin
					clr_cmd_rdy = 1'b1;
					nxt_state = CMD;
				end
			end
			CMD: begin	// Decode Signal
				if(~(|cmd[15:12])) begin
					strt_cal = 1'b1;
					nxt_state = CAL;
				end else if(cmd[13]) begin
					move_cmd = 1'b1;
					nxt_state = MV_INIT;
				end else if(cmd[14]) begin
					tour_go = 1'b1;
					nxt_state = TOUR;
				end
			end
			CAL: begin	// Calibrate the inertial interface
				if(cal_done) begin
					send_resp = 1'b1;
					nxt_state = IDLE;
				end
			end
			TOUR: begin	// Transfer control to the TourCmd block
				nxt_state = IDLE;
			end
			MV_INIT: begin	// Initialize a move...wait for the error to 
							// fall below the threshold.
				moving = 1'b1; // Considered moving while heading is changed
				if(error_rdy)
					nxt_state = MV_INC;
			end
			MV_INC: begin	// Ramp up speed until it reaches the maximum speed.
				inc_frwd = 1'b1;
				moving = 1'b1;
				if(max_spd)
					nxt_state = MV_MAX;
			end
			MV_MAX: begin	// Remain at the max speed until the unit moves
							// the required amount of spaces
				moving = 1'b1;
				if(move_done) begin
					fanfare_en = 1'b1; 	// Enable the fanfare: fanfare_go will only be asserted
										// if it was indicated to by the original cmd.
					nxt_state = MV_DEC;
				end
			end
			MV_DEC: begin	// Ramp speed back down to zero. Return to idle after speed has reached 0.
				dec_frwd = 1'b1;
				moving = 1'b1;
				if(zero) begin
					send_resp = 1'b1; // Send response to indicate successful movement.
					nxt_state = IDLE;
				end
			end
		endcase	
	
	end

endmodule
