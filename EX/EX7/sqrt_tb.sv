module sqrt_tb();

logic clk, rst_n;
logic [15:0]op;
logic go;
logic [7:0]sqrt;
logic err, done;

sqrt iDUT (.clk(clk), .rst_n(rst_n), .op(op), .go(go, .sqrt(sqrt), .err(err), .done(done));

always @(posedge clk, negedge rst_n)
initial begin
    clk = 0;
    rst_n = 1;
    go = 0;
    op = 0;


    #100;
    rst_n = 0;
end

always @(posedge clk, negedge rst_n) begin
    if(~op[15] && ~go) begin
        op = 8'h10
        go = 1;
        rst_n = 1;
        else error = 1;
    end
    if(done) begin
        go = 0;
        rst_n = 0;
    end

if (sqrt == 8'h4) begin
  $display("sqrt 16 completed!");
end

end


always #5 clk=~cls;

endmodule



