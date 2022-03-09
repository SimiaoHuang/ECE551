module SPI_mnrch(clk, rst_n, SS_n, SCLK, MOSI, MISO, snd, cmd, done, resp);

input logic clk, rst_n;
output logic SS_n; //output
output logic SCLK; //output
output logic MOSI; //output
input logic MISO; //input 

input logic snd;
input logic [15:0] cmd;
output logic done;
output logic [15:0] resp;

//This part is shifter register
logic shft;
logic smpl;
logic MISO_smpl;
always_ff @( posedge clk ) begin
    if(!smpl) MISO_smpl <= MISO_smpl;
    else MISO_smpl <= MISO;
end
logic [15:0] shft_reg;
logic init;
always_ff @( posedge clk ) begin
    case ({init, shft}) inside
        2'b00 : shft_reg <= shft_reg;
        2'b01 : shft_reg <= {shft_reg[14:0], MISO_smpl};
        2'b1? : shft_reg <= cmd;
    endcase
end
assign MOSI = shft_reg[15];
assign resp = shft_reg;

//This part is sclk divider
logic [4:0] SCLK_div;
logic ld_SCLK;
always_ff @( posedge clk ) begin
    if(ld_SCLK) SCLK_div <= 5'b10111;
    else SCLK_div <= SCLK_div + 1;
end
assign SCLK = SCLK_div[4];
logic SCLK_fall; //shft_triggering signal
logic SCLK_rise; //smpl_triggering signal
assign SCLK_fall = (SCLK_div == 5'b11111) ? 1 : 0;
assign SCLK_rise = (SCLK_div == 5'b01111) ? 1 : 0;

// always_comb begin // This part is a shft/smpl signal decoder
//     if(SCLK_div == 5'b11111) SCLK_fall = 1; //31 in decimal, 32bits
////     else SCLK_fall = 0;

//     if(SCLK_div == 5'b01111) SCLK_rise = 1; //15 in decimal, 16 bits
////     else SCLK_rise = 0;
// end

//This part is bit counter
logic [3:0] bit_cntr;
always_ff @( posedge clk ) begin
    case ({init, shft}) inside
        2'b00 : bit_cntr <= bit_cntr;
        2'b01 : bit_cntr <= bit_cntr + 1;
        2'b1? : bit_cntr <= 4'b0000;
    endcase
end
logic done15;
always_comb begin
    if(bit_cntr == 4'b1111) done15 = 1'b1;
    else done15 = 1'b0;
end

//This part is State Machine
//SM inputs: snd, done15, [4:0]SCLK_div, SCLK_fall, SCLK_rise
//SM outputs: smpl, shft, ld_SCLK, init, set_done
//SM state: IDLE, WAIT, SHFT&SMPL, END

logic set_done;

typedef enum reg[1:0] { IDLE, WAIT, SHFT_SMPL, END } state_t;
state_t state, nxt_state;
always_ff @( posedge clk, negedge rst_n ) begin
    if(!rst_n) state <= IDLE;
    else state <= nxt_state;
end
always_comb begin
    smpl = 1'b0;
    shft = 1'b0;
    ld_SCLK = 1'b0;
    init = 1'b0;
    set_done = 1'b0;
    nxt_state = state;

    case(state)
        IDLE: begin
            ld_SCLK = 1'b1; //holding SCLK before the go into IDLE
            if(!snd) nxt_state = IDLE;
            else begin
                init = 1'b1;
                //ld_SCLK = 1'b1;
                nxt_state = WAIT;
            end
        end
        WAIT: begin
            if(SCLK_div != 5'b11111) 
                nxt_state = WAIT; //if SCLK_div does not count to 32 clk cycles, keep waiting
            else if(SCLK_div == 5'b11111) 
                nxt_state = SHFT_SMPL;
        end
        SHFT_SMPL: begin
            if(SCLK_fall) begin
                shft = 1'b1;
                //smpl = 1'b0;
                nxt_state = SHFT_SMPL;
            end
            else if(SCLK_rise) begin
                //shft = 1'b0;
                smpl = 1'b1;
                nxt_state = SHFT_SMPL;
            end
            else if(done15 == 1'b1) begin
                nxt_state = END;
            end
                
        end
        END: begin
            if(SCLK_rise) begin
                smpl = 1'b1;
                nxt_state = END;
            end
            else if(SCLK_fall) begin
                ld_SCLK = 1'b1;
                shft = 1'b1;
                set_done = 1'b1;
                nxt_state = IDLE;
            end
        end
        default : nxt_state = IDLE;
    endcase 
end

//This part is SR FFs
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
