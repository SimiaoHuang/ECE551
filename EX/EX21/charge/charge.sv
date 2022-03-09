module charge(clk, rst_n, go, piezo, piezo_n);
    input clk;
    input rst_n;
    input go;
    output logic piezo, piezo_n;

    logic disable_freq_gen; //SM output, in IDLE state, set it to 1 to reset freq_cnt
    logic disable_dura_gen; //SM output, in IDLE state, set it to 1 to reset dura_cnt
    
    parameter FAST_SIM = 1; 


    /*
    G6, Freq = 1568, 2^23 clocks, 31888/2 = 15944
    C7, Freq = 2093, 2^23 clocks, 23889/2 = 11945
    E7_1, Freq = 2637, 2^23 clocks, 18961/2 = 9481
    G7_1, Freq = 3136, 2^23 + 2^22 clocks, 15944/2 = 7972
    E7_2, Freq = 2637, 2^22 clocks, 18961/2 = 9481
    G7_2, Freq = 3136, 2^24 clocks, 15944/2 = 7972
    */

    //50% duty, system freq/freq, then divided by 2
    localparam G6 = 14'd15944;
    localparam C7 = 14'd11945;
    localparam E7_1 = 14'd9481;
    localparam G7_1 = 14'd7972;
    localparam E7_2 = 14'd9481;
    localparam G7_2 = 14'd7972;

    ////This part is freq counter////
    logic [13:0] cnt_freq, cnt_freq_end; //14 bits
    logic start_freq_cnt;
    logic cnt_freq_done;


    // frequency counter here
    assign cnt_freq_done = (cnt_freq == cnt_freq_end)? 1'b1 : 1'b0;
    always @(posedge clk, negedge rst_n) begin
        if(!rst_n)
            cnt_freq <= 0;
        else if (cnt_freq_done | disable_freq_gen) //reset
            cnt_freq <= 0;
        else
            cnt_freq <= cnt_freq + 1'b1;
    end


    //assign piezo and piezo_n
    always @(posedge clk, negedge rst_n) begin
        if(!rst_n) begin
            piezo <= 1'b1;
            piezo_n <= 1'b0;
        end
        else if(cnt_freq_done) begin
            piezo <= piezo_n;
            piezo_n <= piezo;
        end
    end


    ////This part is duration counter////
    localparam G6_dura = 24'd8388608;
    localparam C7_dura = 24'd8388608;
    localparam E7_1_dura = 24'd8388608;
    localparam G7_1_dura = 24'd12582912;
    localparam E7_2_dura = 24'd4194304;
    localparam G7_2_dura = 24'd16777215; //2^24
    
    logic [23:0] cnt_dura, cnt_dura_end; 
    logic start_dura_cnt;
    logic cnt_dura_done;


    //FAST_SIM
    logic enough_cnt_dura;
    generate
        if (FAST_SIM)
            assign enough_cnt_dura = (cnt_dura == cnt_dura_end/16) ? 1'b1 : 1'b0;
        else
            assign enough_cnt_dura = (cnt_dura == cnt_dura_end) ? 1'b1 : 1'b0;
    endgenerate

    assign cnt_dura_done = enough_cnt_dura? 1'b1 : 1'b0; 


    //duration counter here
    always @(posedge clk, negedge rst_n) begin
        if(!rst_n)
            cnt_dura <= 24'b0;
        else if(cnt_dura_done | disable_dura_gen)
            cnt_dura <= 24'b0;
        else
            cnt_dura <= cnt_dura + 1'b1;
    end

   
    //SM here
    typedef enum logic [3:0] { IDLE, state_G6, state_C7, state_E7_1, state_G7_1, state_E7_2, state_G7_2 } state_t;
    state_t state, nxt_state;

    always_ff @(posedge clk, negedge rst_n) begin
        if(!rst_n)
            state <= IDLE;
        else
            state <= nxt_state;
    end

    // 6 states for 6 notes
    always_comb begin
        cnt_freq_end = 12'b0;
        cnt_dura_end = 24'b0;
        disable_freq_gen = 1'b0;
        disable_dura_gen = 1'b0;
        nxt_state = IDLE;

        case(state)
            IDLE: begin
                if(!go)begin
                    disable_freq_gen = 1'b1; 
                    disable_dura_gen = 1'b1; 
                    nxt_state = IDLE;
                end
                else begin
                    cnt_freq_end = G6;
                    nxt_state = state_G6;
                end
            end

            state_G6: begin
                cnt_dura_end = G6_dura;
                if(cnt_dura_done) begin
                    disable_freq_gen = 1'b1; 
                    disable_dura_gen = 1'b1; 
                    nxt_state = state_C7;
                end
                else begin
                    cnt_freq_end = G6;
                    nxt_state = state_G6;
                end

                    
            end

            state_C7: begin
                cnt_dura_end = C7_dura;
                if(cnt_dura_done) begin
                    
                    disable_freq_gen = 1'b1; 
                    disable_dura_gen = 1'b1; 
                    nxt_state = state_E7_1;
                end
                else begin
                    cnt_freq_end = C7;
                    nxt_state = state_C7;
                end
                    
            end

            state_E7_1: begin
                cnt_dura_end = E7_1_dura;
                if(cnt_dura_done) begin
                    disable_freq_gen = 1'b1;
                    disable_dura_gen = 1'b1; 
                    nxt_state = state_G7_1;
                end
                else begin
                    cnt_freq_end = E7_1;
                    nxt_state = state_E7_1;
                end
                    
            end

            state_G7_1: begin
                cnt_dura_end = G7_1_dura;
                if(cnt_dura_done) begin
                    disable_freq_gen = 1'b1; 
                    disable_dura_gen = 1'b1; 
                    nxt_state = state_E7_2;
                end
                else begin
                    cnt_freq_end = G7_1;
                    nxt_state = state_G7_1;
                end
                    
            end

            state_E7_2: begin
                cnt_dura_end = E7_2_dura;
                if(cnt_dura_done) begin
                    disable_freq_gen = 1'b1; 
                    disable_dura_gen = 1'b1; 
                    nxt_state = state_G7_2;
                end
                else begin
                    cnt_freq_end = E7_2;
                    nxt_state = state_E7_2;
                end
                    
            end

            state_G7_2: begin
                cnt_dura_end = G7_2_dura;
                if(cnt_dura_done) begin
                    disable_freq_gen = 1'b1; 
                    disable_dura_gen = 1'b1; 
                    nxt_state = IDLE;
                end
                else begin
                    cnt_freq_end = G7_2;
                    nxt_state = state_G7_2;
                end
                    
            end

            default : nxt_state = IDLE;
        endcase
    end

endmodule