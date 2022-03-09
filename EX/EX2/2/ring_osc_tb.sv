module ring_osc_tb();

    reg en_tb, out_tb;

    ring_osc DUT(.en(en_tb), .out(out_tb))

    initial begin
        en_tb = 0;
        #15;
        en_tb = 1;
        #1000 $stop();
    end
endmodule