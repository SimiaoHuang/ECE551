module ex03_as(d, q, clk, rst);

 input d, clk, rst;
 output q;

 wire md, mq, sd;
 wire n1, n2;
 wire rst_n; 

 not nt5(rst_n, rst);

 notif1 #1 ni1(md, d, clk);
 or (n1, md, rst_n);
 not nt1(mq, n1);
 not(weak1, weak0) nt2(md, mq);

 notif1 #1 ni2(sd, mq, ~clk);
 or (n2, sd, rst_n);
 not nt3(q, n2);
 not(weak1, weak0) nt4(sd, q);

endmodule

