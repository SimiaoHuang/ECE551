module shifter (src, ars, amt, res);

//input and output
 input [15:0] src;//input vector to be right shift
 input ars;//ars=0, logic; ars=1, arithmetic
 input [3:0] amt;//shift 0 to 15
 output [15:0] res;

 logic [15:0] stg1, stg2, stg4;//the output of shift1/2/4 stage, also the input of stage 2/4/8
 logic shift1;
 logic [1:0] shift2;
 logic [3:0] shift4;
 logic [7:0] shift8;//shift1/2/4/8 are used to pad the part on the left of the output of that stage

//shift by 1
 assign shift1 = ars & src[15];//if ars=0, it will be zero extention; if ars=1, it will be sign extention
 assign stg1 = (amt[0]) ? {shift1,src[15:1]} : src;//if amt[0]=0, no shift operation; if amt[0]=1, shift right by 1

//shift by 2
 assign shift2 = {2{ars & stg1[15]}};
 assign stg2 = (amt[1]) ? {shift2,stg1[15:2]} : stg1;//if amt[1]=0, no shift operation; if amt[1]=1, shift right by 2

//shift by 4
 assign shift4 = {4{ars & stg2[15]}};
 assign stg4 = (amt[2]) ? {shift4,stg2[15:4]} : stg2;//if amt[2]=0, no shift operation; if amt[2]=1, shift right by 4

//shift by 8
 assign shift8 = {8{ars & stg4[15]}};
 assign res = (amt[3]) ? {shift8,stg4[15:8]} : stg4;//if amt[3]=0, no shift operation; if amt[3]=1, shift right by 8

endmodule