module desiredDrive (avg_torque, cadence, not_pedaling, incline, scale, target_curr);
 input [11:0] avg_torque;//12bits unsigned num
 input [4:0] cadence;//5bits unsigned num
 input not_pedaling;
 input [12:0] incline;//13 bits signed num
 input [2:0] scale;//3 bits unsigned num
 output [11:0] target_curr;//12 bits unsigned num

 logic [9:0] incline_sat; //10 bit signed num
 logic [10:0] incline_factor; //11 bit signed num
 logic [8:0] incline_lim; //9 bit unsigned num
 
 logic [5:0] cadence_factor;//6 bits 

 logic [12:0] torque_off; //13 bits signed num
 logic [11:0] torque_pos; //12 bits unsigned num
 localparam TORQUE_MIN = 12'h380;

 logic [29:0] assist_prod; //30 bits

 assign incline_sat = (incline[12] & ~&incline[11:9]) ? 10'b1000000000 :
                      (~incline[12] & |incline[11:9]) ? 10'b0111111111 :
                       incline[9:0];
 assign incline_factor = {incline_sat[9],incline_sat[9:0]} + 11'h0100; //sign extention of incline_sat and add a offset 256
 assign incline_lim = (incline_factor[10]) ? 9'b000000000 : //incline_factor is negtive
                      (~incline_factor[10] & incline_factor[9]) ? 9'b111111111 : //incline_factor is >511
                       incline_factor[8:0];

 assign cadence_factor = (cadence <= 1) ? 0: {1'b0, cadence[4:0]} + 6'b100000;

 assign torque_off = {1'b0, avg_torque} - {1'b0, TORQUE_MIN}; 
 assign torque_pos = (torque_off[12]) ? 12'b000000000 : //torque_off is negtive
                      torque_off[11:0];
 
 assign assist_prod = (not_pedaling)? 30'b0 : torque_pos * incline_lim * cadence_factor * scale;
 assign target_curr = ( |assist_prod[29:27] ) ? 12'hFFF : assist_prod[26:15];


endmodule