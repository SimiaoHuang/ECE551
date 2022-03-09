
// MIFF

module TourLogic_tb();

	// DUT signals
	logic clk, rst_n;
	logic [2:0] x_start,y_start;
	logic go,done;
	logic [4:0] indx;
	logic [7:0] move;
			
	TourLogic iDUT(.clk(clk),.rst_n(rst_n),.x_start(x_start),.y_start(y_start),.go(go),.done(done),.indx(indx),.move(move));
	
	// Interna TB signals
	logic [2:0] x,y;
	logic [4:0] board[0:4][0:4];
	logic error, print;
	
	initial begin
		clk = 0;
		go = 0;
		error = 0; // Innocent until proven guilty.
		
		rst_n = 0;
		@(posedge clk);
		@(negedge clk);
		rst_n = 1;
		
		for(int xx=0;xx<=4;xx++)	// Exhaustively tests all possible tours from any 
									// given valid starting position on a 5x5 chess board.
			for(int yy=0;yy<=4;yy++) begin
				print = 0;
				if ((xx + yy) % 2 != 0) // Skips 'red' squares
					continue;
				else begin
					// check for cal_done
					$display("x:%d y:%d\n",xx,yy);
					x_start = xx;
					y_start = yy;
					
					// Sets initial values for this iteration
					x = xx;
					y = yy;
					board = '{'{0, 0, 0, 0, 0}, '{0, 0, 0, 0, 0}, '{0, 0, 0, 0, 0}, '{0, 0, 0, 0, 0}, '{0, 0, 0, 0, 0}};
							
					@(posedge clk);
					
					go = 1;
					@(posedge clk);
					@(negedge clk);
					go = 0;
					
					fork
						begin : timeout
							repeat(10000000) @(posedge clk); // Times out after 10M clock cycles.
							$display("ERROR: time out waiting for done to be asserted at start position (%d, %d)",xx,yy);
							error = 1;
							$stop;
						end
						begin
							@(posedge done) begin
								disable timeout;
								@(negedge done);
								for(indx = 0; indx < 25; indx++) begin // Checks if calculated result is valid.
									@(posedge clk);
									if(board[x][y] === 0)
										board[x][y] = indx + 1;
									else begin // If the square has already been visited, invalid result found.
										$display("ERROR: invalid result at starting position (%d, %d)",xx,yy);
										error = 1;
										$stop;
									end
									if(indx === 24)
										break;
									x = x + iDUT.off_x(move);
									y = y + iDUT.off_y(move);
								end
								
								print = 1; 	// Print resulting board, which shows the sequence moves are taken.
											// NOTE: this is not the same as the internal board within TourLogic. That board
											//       is binary.
								@(posedge clk);
							end
						end
					join
					
				end
			end
		
		if(error)
			$display("Test bench failed D:\n");
		else
			$display("Test bench passed!!!\n");
		
		$stop;
	end
	
	always #5 clk = ~clk;
	
	always @(posedge print) begin: disp
		integer x,y;
		for(y = 4; y >= 0; y--) begin
			$display("%2d  %2d  %2d  %2d %2d\n", board[0][y], board[1][y], board[2][y], board[3][y], board[4][y]);
		end
		$display("---------------------\n");
		$display("%i\n",$time);
	end
	
endmodule
