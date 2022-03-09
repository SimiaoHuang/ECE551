module mult_accum_gated(clk,clr,en,A,B,accum);

	input clk,clr,en;
	input [7:0] A,B;
	output reg [63:0] accum;

	logic [15:0] prod_reg;
	logic en_stg2;


	logic clk_en_lat1, clk_en_lat2;
	logic gclk1, gclk2;

	//and gate
	and and1(gclk1, clk, clk_en_lat1),
		and2(gclk2, clk, clk_en_lat2);
		
	///////////////////////////////////////////
	// Generate and flop product if enabled //
	/////////////////////////////////////////
	always_ff @(posedge gclk1) begin
		  prod_reg <= A*B;
	end
	/////////////////////////////////////////////////////
	// Pipeline the enable signal to accumulate stage //
	///////////////////////////////////////////////////
	always_ff @(posedge clk)
		en_stg2 <= en;
		
		
	//first gated clk
	always @(clk, en) begin
		if (!clk) clk_en_lat1 <= en;
	end

	//second gated clk
	always @(clk, en_stg2) begin
		if (!clk) clk_en_lat2 <=  (en_stg2 | clr); 
	end

	always_ff @(posedge gclk2) begin
		if (clr)
		  accum <= 64'h0000000000000000;
		else
		  accum <= accum + prod_reg;
	end
	
endmodule
