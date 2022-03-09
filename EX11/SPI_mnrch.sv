module SPI_mnrch(clk, rst_n, SS_n, SCLK, MOSI, MISO, snd, cmd, done, resp);

input logic clk, rst_n;
input logic snd;
input logic MISO;
input logic [15:0] cmd;
output logic SS_n, SCLK, MOSI;
output logic done;
output logic [15:0] resp;

//---------SCLK_div counter-----------------------------------------------------
logic [4:0] SCLK_div;//the counter reg
logic ld_SCLK;//when ld was set, 10111
logic full; //SCLK was full
logic SCLK_rise; //shft the command reg after 2 clk

always_ff @( posedge clk ) begin
    if(ld_SCLK) SCLK_div <= 5'b10111;
    else SCLK_div <= SCLK_div + 1;
end
assign SCLK = SCLK_div[4];//SCLK is the MSB of this reg

assign full = (SCLK_div == 5'b11111) ? 1 : 0;//SCLK fall
assign SCLK_rise = (SCLK_div == 5'b10001) ? 1 : 0;//2 clock after the SCLK rise

//-------shifter register--------------------------------------------------------
logic [15:0] shft_reg;
logic shft;//come from the SCLK, when SCLK_div = 10001
logic init;//come from SM, load the cmd when init was set

always_ff @( posedge clk ) begin
    case ({init, shft}) inside
        2'b00 : shft_reg <= shft_reg;//just hold
        2'b01 : shft_reg <= {shft_reg[14:0], MISO};//shift by 1
        2'b1? : shft_reg <= cmd;
    endcase
end
assign MOSI = shft_reg[15];//MOSI is the MSB of shift_reg
assign resp = shft_reg;

//------bit counter--------------------------------------------------------------
logic [4:0] bit_cntr;
logic done16;

always_ff @( posedge clk ) begin
    case ({init, shft}) inside
        2'b00 : bit_cntr <= bit_cntr;
        2'b01 : bit_cntr <= bit_cntr + 1;
        2'b1? : bit_cntr <= 5'b00000;
    endcase
end
always_comb begin
    if(bit_cntr == 5'b10000) 
       done16 = 1'b1;
    else 
       done16 = 1'b0;
end

//------SM-------------------------------------------------------------------------
logic set_done;

typedef enum reg[1:0] { IDLE, SHFT, BPRCH } state_t;
state_t state, nxt_state;
//the reset
always_ff @( posedge clk, negedge rst_n ) begin
    if(!rst_n) state <= IDLE;
    else state <= nxt_state;
end

always_comb begin
    shft = 1'b0;
    ld_SCLK = 1'b0;
    init = 1'b0;
    set_done = 1'b0;
    nxt_state = state;

case(state)
        IDLE: begin
           ld_SCLK = 1'b1; //assert ld_SCLK all the time to kep SCLK high
           if(!snd) 
             nxt_state = IDLE;
           else begin
             init = 1'b1;
             nxt_state = SHFT;//if snd was assert, shift reg get cmd
            end
        end

        SHFT: begin
            if(done16 == 1'b1)
                nxt_state = BPRCH;
            else if(SCLK_rise) begin
                shft = 1'b1;//shift the shifter counter
                nxt_state = SHFT;
            end
        end

        BPRCH: begin
            if(full) begin
                set_done = 1'b1;
                nxt_state = IDLE;
            end else
                nxt_state = BPRCH;
        end
        default: nxt_state = IDLE;  
endcase
end

always_ff @( posedge clk, negedge rst_n ) begin
    if (!rst_n) done <= 1'b0; //This is reset
    else if (set_done) done <= 1'b1;
    else if (init) done <= 1'b0;
end
always_ff @( posedge clk, negedge rst_n ) begin
    if (!rst_n) SS_n <= 1'b1; //This is preset
    else if (set_done) SS_n <= 1'b1;
    else if (init) SS_n <= 1'b0;
end

endmodule
