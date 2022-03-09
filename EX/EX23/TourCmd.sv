module TourCmd(clk,rst_n,start_tour,move,mv_indx,
               cmd_UART,cmd,cmd_rdy_UART,cmd_rdy,
			   clr_cmd_rdy,send_resp,resp);

  input clk,rst_n;			// 50MHz clock and asynch active low reset
  input start_tour;			// from done signal from TourLogic
  input [7:0] move;			// encoded 1-hot move to perform
  output reg [4:0] mv_indx;	// "address" to access next move
  input [15:0] cmd_UART;	// cmd from UART_wrapper
  input cmd_rdy_UART;		// cmd_rdy from UART_wrapper
  output [15:0] cmd;		// multiplexed cmd to cmd_proc
  output cmd_rdy;			// cmd_rdy signal to cmd_proc
  input clr_cmd_rdy;		// from cmd_proc (goes to UART_wrapper too)
  input send_resp;			// lets us know cmd_proc is done with command
  output [7:0] resp;		// either 0xA5 (done) or 0x5A (in progress)
  
// internal signals
logic cmd_sel;       // comes from SM, use to choose who control the command
logic mv_v;          //control the vertical move 
logic mv_h;          // control the horizontal move
logic cnt_inc;       // make mv_indx counter +1 when finish one L move
logic cnt_zero;      // zero mv_indx in IDLE
logic cmd_rdy_sm;    // cmd_rdy from SM
logic [15:0]cmd_sm;  // cmd after move decompose
logic cnt_done;      // detect whether knight is totally done


//declare SM 
typedef enum logic [2:0] {IDLE, VERTICAL, WAIT1, HORIZONTAL, WAIT2} state_t;
state_t state, nxt_state;


//mv_indx counter
assign mv_indx = (cnt_zero) ? 0 : ((cnt_inc) ? (mv_indx + 1'b1) : mv_indx);

//test whether mv_indx less than 24, if not means the Knight have not moved 24times.
assign cnt_done = (mv_indx < 5'd23) ? 1'b0 : 1'b1;

//TourCmd should usurp control of command if start_tour asserted
assign cmd = (cmd_sel) ? cmd_sm : cmd_UART;
assign cmd_rdy = (cmd_sel) ? cmd_rdy_sm : cmd_rdy_UART;


//decompose the move code from TourLogic
always_comb begin
   // decompose vertical move 
   if(mv_v)begin
      case(move)
         8'b00000001 : cmd_sm = 16'h2002;    //00000001 represent [0] type move
         8'b00000010 : cmd_sm = 16'h2002;    //00000010 represent [1] type move
         8'b00000100 : cmd_sm = 16'h2001;    //00000100 represent [2] type move
         8'b00001000 : cmd_sm = 16'h27F1;    //00001000 represent [3] type move
         8'b00010000 : cmd_sm = 16'h27F2;    //00010000 represent [4] type move
         8'b00100000 : cmd_sm = 16'h27F2;    //00100000 represent [5] type move
         8'b01000000 : cmd_sm = 16'h27F1;    //01000000 represent [6] type move
         8'b10000000 : cmd_sm = 16'h2001;    //10000000 represent [7] type move
         default : cmd_sm = 16'h0;
      endcase
   end
   // decompose horizontal move
   else if(mv_h)begin
      case(move)
         8'b00000001 : cmd_sm = 16'h33F1;
         8'b00000010 : cmd_sm = 16'h3BF1;
         8'b00000100 : cmd_sm = 16'h33F2;
         8'b00001000 : cmd_sm = 16'h33F2;
         8'b00010000 : cmd_sm = 16'h33F1;
         8'b00100000 : cmd_sm = 16'h3BF1;
         8'b01000000 : cmd_sm = 16'h3BF2;
         8'b10000000 : cmd_sm = 16'h3BF2;
         default : cmd_sm = 16'h0;
      endcase
   end  
end

// send A5 if it is totally done or send 5A if it is intermediate move
assign resp = (cnt_done && ~cmd_sel) ? 8'hA5 : 8'h5A;


//SM FF
always_ff @(posedge clk, negedge rst_n) begin
		if(!rst_n)
			state <= IDLE;
		else
			state <= nxt_state;
	end


always_comb begin
   // default output values
   mv_v = 0;
   mv_h = 0;
   cnt_inc = 0;
   cnt_zero = 0;
   cmd_sel = 0;
   cmd_rdy_sm = 0;
   nxt_state = state;

   case(state)

      IDLE : begin //wait for start_tour signal
         if(start_tour)begin
            cnt_zero = 1;
            cmd_sel = 1;
            nxt_state = VERTICAL;
         end
      end

      VERTICAL : begin //Every L move is composed of a vertical and a horizontal move,                   
         cmd_sel = 1;  //make the knight vertical move first in every L move to avoid 180° heading change.
         mv_v = 1;
         cmd_rdy_sm = 1;
         if(clr_cmd_rdy)
         nxt_state = WAIT1;
      end

      WAIT1 : begin  // wait for the knight move
         cmd_sel = 1;
         if(send_resp)
         nxt_state = HORIZONTAL;
      end

      HORIZONTAL : begin // after vertical move , the knight can start horizontal move
         cmd_sel = 1;
         mv_h = 1;
         cmd_rdy_sm = 1;
         if(clr_cmd_rdy)
         nxt_state = WAIT2;
      end

      WAIT2 : begin  // wait for knight move, if the move is totally done, return to IDLE, else return to VERTICAL to continue move
         cmd_sel = 1;
         if(send_resp)begin
            if(!cnt_done)begin
               cnt_inc = 1;
               cmd_sel = 1;
               nxt_state = VERTICAL;
            end
            else if(cnt_done)begin
               cmd_sel = 0;
               nxt_state = IDLE;
            end
         end
      end
   endcase    
end
  
endmodule