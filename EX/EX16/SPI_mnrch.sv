module SPI_mnrch(clk, rst_n, SS_n, SCLK, MOSI, MISO, wrt, wt_data, done, rd_data);


input clk, rst_n;
input wrt;
input [15:0]wt_data;
input MISO;

output logic [15:0] rd_data;
output logic SS_n;
output logic SCLK;
output logic MOSI, done;


logic init;
logic set_done;
logic smpl;
logic shft;
logic ld_SCLK;
logic [4:0]SCLK_div;
logic MISO_smpl;
logic [15:0]shft_reg;
logic [3:0]bit_cntr;
logic done16;
logic SCLK_fall; 
logic SCLK_rise; 


//SCLK_div counter
always@(posedge clk)begin
	if(ld_SCLK)begin
		SCLK_div <= 5'b10111;
	end
	else begin
		SCLK_div <= SCLK_div + 1;
	end
end
assign SCLK = SCLK_div[4];



// shift counter
always_ff@(posedge clk)begin
	if(init)
	bit_cntr <= 4'b0000;
	else if(shft) bit_cntr <= bit_cntr + 1;
	else bit_cntr <= bit_cntr;
end 
assign done16 = &bit_cntr[3:0];


//sample
always_ff@( posedge clk )begin
	if (smpl) 
		MISO_smpl <= MISO;
		else MISO_smpl <= MISO_smpl;
end

//MOSI shift
always_ff@(posedge clk)begin
	casex ({init, shft})
	2'b1x : shft_reg <= wt_data;
	2'b01 : shft_reg <= {shft_reg[14:0], MISO_smpl};
	default : shft_reg <= shft_reg;
	endcase
end
assign MOSI = shft_reg[15];
assign rd_data = shft_reg;

//state machine
typedef enum reg[1:0] {IDLE, SAMPLE, SHIFT, FINAL} state_t;
state_t state, nxt_state;


always_ff@(posedge clk, negedge rst_n)begin
	if(!rst_n) state <= IDLE;
	else state <= nxt_state;
end


always_comb begin
	ld_SCLK = 1'b0;
	set_done = 1'b0;
	init = 1'b0;
	smpl = 1'b0;
	shft = 1'b0;
	nxt_state = IDLE;

case(state)
	IDLE : begin
			ld_SCLK = 1'b1;
		if(wrt)begin
			init = 1'b1;
			nxt_state = SAMPLE;
			end
		end




	SAMPLE : begin
		if(SCLK_div == 5'b01111)begin
			smpl = 1'b1;
			if(done16)begin
				nxt_state = FINAL;
			end
			else nxt_state = SHIFT;
		end
		else nxt_state = SAMPLE;
	end


	SHIFT : begin
		if(SCLK_div == 5'b11111)begin
			shft = 1'b1;
			nxt_state = SAMPLE;
		end
		else begin
			nxt_state = SHIFT;
		end
	end


	FINAL : begin
			if(SCLK_div == 5'b11111)begin
				nxt_state = IDLE;
				ld_SCLK = 1'b1;
				set_done = 1'b1;
				shft = 1'b1;
			end
			else  begin
                nxt_state = FINAL;
			end
		end

	default : nxt_state = IDLE;

endcase

end

//output SS_n
always@(posedge clk, negedge rst_n)begin
	if(!rst_n) SS_n <= 1;
	else if(init) SS_n <= 0;
	else if(set_done) SS_n <= 1;
end



//output done
always@(posedge clk, negedge rst_n)begin
	if(!rst_n) done <= 0;
	else if(init) done <= 0;
	else if (set_done) done <= 1;
end



endmodule


