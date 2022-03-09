module shifter (src, ars, amt, res);

 input [15:0] src;//input vector to be right shift
 input ars;//ars=0, logic; ars=1, arithmetic
 input [3:0] amt;//shift 0 to 15
 output [15:0] res;

// logic [15:0] shift1_log, shift1_ari, stg1;
 logic [15:0] stg1;
 logic shift1;
 logic [15:0] shift2_log, shift2_ari, stg2;
 logic [15:0] shift4_log, shift4_ari, stg4;
 logic [15:0] shift8_log, shift8_ari;

//shift by 1
 assign shift1 = (~ars & 1'b0)|(ars & src[15]);
// assign shift1_log = (amt[0]) ? {1'b0,src[15:1]} : src;
// assign shift1_ari = (amt[0]) ? {src[15],src[15:1]} : src;
// assign stg1 = ars ? shift1_ari : shift1_log;
 assign stg1 = (amt[0]) ? {shift1,src[15:1]} : src;
//shift by 2
 assign shift2_log = (amt[1]) ? {2'b00,stg1[15:2]} : stg1;
 assign shift2_ari = (amt[1]) ? {{2{stg1[15]}},stg1[15:2]} : stg1;
 assign stg2 = ars ? shift2_ari : shift2_log;

//shift by 4
 assign shift4_log = (amt[2]) ? {4'b0000,stg2[15:4]} : stg2;
 assign shift4_ari = (amt[2]) ? {{4{stg2[15]}},stg2[15:4]} : stg2;
 assign stg4 = ars ? shift4_ari : shift4_log;

//shift by 8
 assign shift8_log = (amt[3]) ? {8'b00000000,stg4[15:8]} : stg4;
 assign shift8_ari = (amt[3]) ? {{8{stg4[15]}},stg4[15:8]} : stg4;
 assign res = ars ? shift8_ari : shift8_log;

endmodule