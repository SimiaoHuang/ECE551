module ex3(d, clk, q);


    input d, clk;
    output q;

    wire md, mq, sd;
    

    notif1 #1 T1(md, d, ~clk);
    not N1 (mq, md);
    
    

    notif1 #1 T2(sd, mq, clk);
    not N2 (q, sd);
   
    not(weak1, weak0) N3 (md, mq);
    not(weak1, weak0) N4 (sd, q);
    



    
endmodule
