
// MIFF

module TourLogic(clk,rst_n,x_start,y_start,go,done,indx,move);

	input clk,rst_n;				// 50MHz clock and active low asynch reset
	input [2:0] x_start, y_start;	// starting position on 5x5 board
	input go;						// initiate calculation of solution
	input [4:0] indx;				// used to specify index of move to read out
	output logic done;			// pulses high for 1 clock when solution complete
	output [7:0] move;			// the move addressed by indx (1 of 24 moves)

	////////////////////////////////////////
	// Declare needed internal registers //
	//////////////////////////////////////
	
	logic board[0:4][0:4]; // Squares already visited
	logic [7:0] last_moves[0:23]; // Vector of one-hot move vectors
	
	logic [7:0] mv_try;
	logic [4:0] mv_num;
	logic [2:0] xx,yy,nxt_xx,nxt_yy;
	
	logic zero, set_first, forward, backward, inc, dec;
	
	logic update_frwd;
	
	logic [3:0] loop_var, loop_start, ignore_moves;
	logic [2:0] new_x[0:7],new_y[0:7];
	
	// Declare SM Types
	typedef enum logic [1:0] {IDLE, CALC, FRWRD, BKWRD} state_t;
	state_t state, nxt_state, last_state;
	
	////////////////////////////////
	// Implementation starts here //
	////////////////////////////////
	
	assign move = last_moves[indx]; // The calling block can access each individual move by index in the sequence.
	
	// logic to update the board
	always_ff @(posedge clk) begin
		if (set_first)
			board[x_start][y_start] <= 1'b1;
		else if (update_frwd)
			board[nxt_xx][nxt_yy] <= 1'b1;
		else if (backward)
			board[xx][yy] <= 1'b0;
		else if (zero)
			board <= '{'{0, 0, 0, 0, 0}, '{0, 0, 0, 0, 0}, '{0, 0, 0, 0, 0}, '{0, 0, 0, 0, 0}, '{0, 0, 0, 0, 0}};
		// else -- hold value
	end
	
	// logic to store the sequence of moves that will eventually be the correct knight's tour.
	always_ff @(posedge clk, negedge rst_n) begin
		if(!rst_n)
			last_moves <= '{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0};
		else if(forward)
			last_moves[mv_num] <= mv_try;
	end
	
	// logic to keep track of what move the algorithm is currently on.
	always_ff @(posedge clk, negedge rst_n) begin
		if(!rst_n)
			mv_num <= 5'b00000;
		else if(go)
			mv_num <= 5'b00000;
		else if(inc)
			mv_num <= mv_num + 1;
		else if(dec)
			mv_num <= mv_num - 1;
	end
	
	// logic to calculate the next grid position. 
	always_ff @(posedge clk, negedge rst_n) begin
		if(!rst_n) begin
			nxt_xx <= 3'h0;
			nxt_yy <= 3'h0;
		end else if(set_first) begin
			nxt_xx <= x_start;
			nxt_yy <= y_start;
		end else if(forward) begin	// If moving forward, calculate the next position from
									// the next move that will be attempted.
			nxt_xx <= nxt_xx + off_x(mv_try);
			nxt_yy <= nxt_yy + off_y(mv_try);
		end else if(backward) begin // If backtracing, calcualte the next position by
									// subtracting the offsets from the previous move
			nxt_xx <= nxt_xx - off_x(last_moves[mv_num-1]);
			nxt_yy <= nxt_yy - off_y(last_moves[mv_num-1]);
		end
	end
	
	// Store the current x and y position (delaying one clock cycle)
	always_ff @(posedge clk, negedge rst_n) begin
		if(!rst_n) begin
			xx <= 3'h0;
			yy <= 3'h0;
		end else if(set_first) begin
			xx <= x_start;
			yy <= y_start;
		end else begin
			xx <= nxt_xx;
			yy <= nxt_yy;
		end
	end
	
	// Store previous state.
	always_ff @(posedge clk, negedge rst_n) begin
		if(!rst_n)
			last_state <= IDLE;
		else
			last_state <= state;
	end
	
	 // SM FF
	always_ff @(posedge clk, negedge rst_n) begin
		if(!rst_n)
			state <= IDLE;
		else
			state <= nxt_state;
	end
	
	// logic to generate output and next state of the SM
	always_comb begin
	
		// default all output values
		zero = 1'b0;
		set_first = 1'b0;
		forward = 1'b0;
		backward = 1'b0;
		update_frwd = 1'b0;
		done = 1'b0;
		inc = 1'b0;
		dec = 1'b0;
		mv_try = 8'hxx;
		
		// default next state
		nxt_state = state;
		
		case(state)
			IDLE: begin
				// if go asserted -- assert set_first and transition to CALC
				if (go) begin
					set_first = 1'b1;
					nxt_state = CALC;
				end
				// always assert zero while in IDLE
				zero = 1'b1;
			end
			
			CALC: begin
				// get the move to try
				mv_try = find_mv(calc_poss(xx, yy), ((last_state == BKWRD) ? 1'b1 : 1'b0));
				// if tour solved -- transition back to idle and assert done
				if (mv_num == 5'b11000) begin
					done = 1'b1;
					nxt_state = IDLE;
				end
				// else if an empty move returned, no moves are possible -- must backtrace
				else if (mv_try == 8'h00) begin
					backward = 1'b1;
					nxt_state = BKWRD;
				end
				// else -- transition to FRWRD
				else begin
					forward = 1'b1;
					nxt_state = FRWRD;
				end
			end
			
			FRWRD: begin
				// update xx, yy
				// update_position(mv_try);
				
				// if xx has updated to nxt_xx -- assert inc and transition to CALC
				if(nxt_xx == xx) begin
					inc = 1'b1;
					nxt_state = CALC;
				end
				// else -- assert update_frwd and stay in FRWRD
				else 
					update_frwd = 1'b1;
					
				// note -- this is more complex than just an unconditional transition because we must delay a clock cycle before
				// updating the board at board[nxt_xx][nxt_yy] (so that nxt_xx and nxt_yy are actually the new values)s
			end
			
			BKWRD: begin
				// update xx, yy
				
				// transition back to BKWRD and assert dec
				dec = 1'b1;
				nxt_state = CALC;
			end
	
		endcase
		
	end

	// Calculate possible moves from any given (x,y) on the board.
	function [7:0] calc_poss(input [2:0] xpos,ypos);
		
		calc_poss = 8'h00;
		
		for(loop_var = 0; loop_var < 8; loop_var++) begin 	// Check every possible move that
															// a knight can take.
			new_x[loop_var] = xpos + off_x(get_mv(loop_var));
			new_y[loop_var] = ypos + off_y(get_mv(loop_var));
			calc_poss[loop_var] = 
				~((new_x[loop_var] <= 4) & (new_y[loop_var] <= 4)) ? 1'b0 : // Mark move as invalid if the move is outside
																			// of the bounds of the board.
				board[new_x[loop_var]][new_y[loop_var]] ? 1'b0 : 1'b1;	// Mark move as invalid if it would result in moving to
																		// a position which has already been visited.
		end
	
	endfunction

	// Convert one-hot move code into its corresponding x offset.
	function signed [2:0] off_x(input [7:0] try);
	
		off_x = try[0] ? 3'b111 :
				try[1] ? 3'b001 :
				try[2] ? 3'b110 :
				try[3] ? 3'b110 :
				try[4] ? 3'b111 :
				try[5] ? 3'b001 :
				try[6] ? 3'b010 : 3'b010;
				
	endfunction

	// Convert one-hot move code into its corresponding y offset.
	function signed [2:0] off_y(input [7:0] try);
	
		off_y = try[0] ? 3'b010 :
				try[1] ? 3'b010 :
				try[2] ? 3'b001 :
				try[3] ? 3'b111 :
				try[4] ? 3'b110 :
				try[5] ? 3'b110 :
				try[6] ? 3'b111 : 3'b001;
				
	endfunction
	
	// Convert from 3-bit encoding to a one-hot byte encoding.
	function [7:0] get_mv(input [2:0] mv_num);
	
		get_mv =
			mv_num == 3'b000 ? 8'h01 :
			mv_num == 3'b001 ? 8'h02 :
			mv_num == 3'b010 ? 8'h04 :
			mv_num == 3'b011 ? 8'h08 :
			mv_num == 3'b100 ? 8'h10 :
			mv_num == 3'b101 ? 8'h20 :
			mv_num == 3'b110 ? 8'h40 : 8'h80;
			
	endfunction
	
	// Convert from a one-hot byte encoding to 3-bit encoding.
	function [7:0] get_mv_op(input [7:0] mv_cmd);
	
		get_mv_op =
			mv_cmd == 8'h01 ? 3'b000 :
			mv_cmd == 8'h02 ? 3'b001 :
			mv_cmd == 8'h04 ? 3'b010 :
			mv_cmd == 8'h08 ? 3'b011 :
			mv_cmd == 8'h10 ? 3'b100 :
			mv_cmd == 8'h20 ? 3'b101 :
			mv_cmd == 8'h40 ? 3'b110 : 3'b111;
			
	endfunction
	
	// Calculate the next move to be attempted based on a a packed byte of all possible moves.
	function [7:0] find_mv(input [7:0] poss_mv, input back);
	
		// Ignores all moves before and including this index if the previous state was BKWRD.
		// This avoids executing a move which has just been tried, and failed (which would result
		// in an infinte loop).
		ignore_moves = back ? {1'b0,get_mv_op(last_moves[mv_num])} : 4'b1xxx;
		
		for(loop_var = 0; loop_var < 8; loop_var++) 
			if(loop_var > ignore_moves[2:0] | ignore_moves[3]) // Ignores moves...
				if(poss_mv[loop_var])
					return get_mv(loop_var); // Returns the first valid move in the packed byte.
		
		return 8'h00; // No valid moves possible from this position
	
	endfunction
	
endmodule
