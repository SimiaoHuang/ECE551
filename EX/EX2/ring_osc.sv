module ring_osc(en, out);

    input en;
    output out;

    wire n1, n2;
    
    nand #5 (n1,en,out);
    not #5 (n2,n1);
    not #5 (out,n2);

endmodule
 

