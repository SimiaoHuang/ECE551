module ex03(d, q, clk);

 input d, clk;
 output q;

 wire md, mq, sd;

 notif1 #1 ni1(md, d, clk);
 not n1(mq, md);
 not(weak1, weak0) n2(md, mq);

 notif1 #1 ni2(sd, mq, ~clk);
 not n3(q, sd);
 not(weak1, weak0) n4(sd, q);

endmodule

