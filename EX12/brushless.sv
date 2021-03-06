module brushless(clk, rst_n, drv_mag, hallGrn, hallYlw, hallBlu, break_n, PWM_synch, duty, selGrn, selYlw, selBlu);

 input logic clk, rst_n;
 input logic [11:0]drv_mag;//unsigned
 input logic hallGrn, hallYlw, hallBlu;
 input logic break_n;
 input logic PWM_synch;
 output logic [10:0]duty;
 output logic [1:0]selGrn, selYlw, selBlu;

 reg Grn0, Grn1, synchGrn;
 reg Ylw0, Ylw1, synchYlw;
 reg Blu0, Blu1, synchBlu;
 wire [2:0]rotation_state;

//-------------double synch---------------------------------------------------------
always_ff @(posedge clk, negedge rst_n) begin
 //green
   Grn0 <= hallGrn;
   Grn1 <= Grn0;//2 flip-flop
   if (!rst_n)
    synchGrn <= 1'b0;
   else if ( PWM_synch )
    synchGrn <= Grn1;
   else
    synchGrn <= synchGrn;//or it will keep the prior value
 //yellow
   Ylw0 <= hallYlw;
   Ylw1 <= Ylw0;//2 flip-flop
   if (!rst_n)
    synchYlw <= 1'b0;
   else if ( PWM_synch )
    synchYlw <= Ylw1;
   else
    synchYlw <= synchYlw;//or it will keep the prior value
 //blue
   Blu0 <= hallBlu;
   Blu1 <= Blu0;//2 flip-flop
   if (!rst_n)
    synchBlu <= 1'b0;
   else if ( PWM_synch )
    synchBlu <= Blu1;
   else
    synchBlu <= synchBlu;//or it will keep the prior value
 end

 assign rotation_state = {synchGrn, synchYlw, synchBlu};

//----------operation--------------------------------------------------------
//HIGH_Z=00, rev_curr=01, frwd_curr=10, regen breaking=11}
always_comb begin
selGrn = 2'b00;
selYlw = 2'b00;
selBlu = 2'b00;
//break_n = 1'b1;
 case(rotation_state)
   3'b101: if (break_n) begin
           selGrn = 2'b10;
           selYlw = 2'b01;
           selBlu = 2'b00;
           end else begin
           selGrn = 2'b11;
           selYlw = 2'b11;
           selBlu = 2'b11;
           end
 endcase
end
endmodule
