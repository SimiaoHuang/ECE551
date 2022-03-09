module ex03_as(d, q, clk, rst);

 input d, clk, rst;
 output q;

 wire md, mq, sd;
 wire n1, n2;
 wire rst_n; 

 not nt5(rst_n, rst);

 notif1 #1 ni1(n1, d, clk);
 or (md, n1, rst_n);
 not nt1(mq, md);
 not(weak1, weak0) nt2(md, mq);

 notif1 #1 ni2(n2, mq, ~clk);
 or (sd, n2, rst_n);
 not nt3(q, sd);
 not(weak1, weak0) nt4(sd, q);

endmodule

