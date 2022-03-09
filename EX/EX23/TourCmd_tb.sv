module TourCmd_tb();

logic [7:0]move;
logic [4:0]mv_indx;
logic clk, rst_n;
logic start_tour, send_resp;
logic [15:0]cmd_UART;
logic cmd_rdy_UART;
logic [15:0]cmd;
logic cmd_rdy;
logic clr_cmd_rdy;
logic [7:0]resp;

TourCmd iDUT(.clk(clk), .rst_n(rst_n), .start_tour(start_tour), .move(move), .mv_indx(mv_indx),
            .cmd_UART(cmd_UART), .cmd_rdy_UART(cmd_rdy_UART), .send_resp(send_resp), .cmd(cmd),
            .cmd_rdy(cmd_rdy), .clr_cmd_rdy(clr_cmd_rdy), .resp(resp));

initial begin
    clk = 0;
    rst_n = 0;
    cmd_UART = 16'h000;
    cmd_rdy_UART = 0;
    send_resp = 0;
    clr_cmd_rdy = 0;
    move = 8'h0;

    @(posedge clk);
    @(negedge clk);
    rst_n = 1;


    // 1st test : move = 8'b00000001
    start_tour = 1;
    move = 8'b00000001;
    @(posedge clk);
    @(negedge clk);
    start_tour = 0;
    @(posedge clk);
    @(negedge clk);
    $display("cmd is %h ", cmd);
    @(posedge clk);
    @(negedge clk);
    clr_cmd_rdy = 1;        //assert the 1st clr_cmd_rdy to change state
    repeat(5)@(posedge clk);
    clr_cmd_rdy = 0;
    send_resp = 1;          //assert the 1st send_resp to change state
    @(posedge clk);
    @(negedge clk);
    send_resp = 0;
    $display("cmd is %h ", cmd);
    @(posedge clk);
    @(negedge clk);
    clr_cmd_rdy = 1;        //assert the 2nd clr_cmd_rdy to change state
    repeat(5)@(posedge clk);
    clr_cmd_rdy = 0;
    send_resp = 1;           //assert the 2nd send_resp to change state
    move = 8'b00000010;
    @(posedge clk);
    @(negedge clk);
    send_resp = 0;
    repeat(5)@(posedge clk);


    //2nd test move = 8'b00000010
    @(posedge clk);
    @(negedge clk);
    $display("cmd is %h ", cmd);
    @(posedge clk);
    @(negedge clk);
    clr_cmd_rdy = 1;
    repeat(5)@(posedge clk);
    clr_cmd_rdy = 0;
    send_resp = 1;
    @(posedge clk);
    @(negedge clk);
    send_resp = 0;
    $display("cmd is %h ", cmd);
    @(posedge clk);
    @(negedge clk);
    clr_cmd_rdy = 1;
    repeat(5)@(posedge clk);
    clr_cmd_rdy = 0;
    send_resp = 1;
    move = 8'b00000100;
    @(posedge clk);
    @(negedge clk);
    send_resp = 0;
    repeat(5)@(posedge clk);

    
    //3rd test move = 8'b00000100
    @(posedge clk);
    @(negedge clk);
    $display("cmd is %h ", cmd);
    @(posedge clk);
    @(negedge clk);
    clr_cmd_rdy = 1;
    repeat(5)@(posedge clk);
    clr_cmd_rdy = 0;
    send_resp = 1;
    @(posedge clk);
    @(negedge clk);
    send_resp = 0;
    $display("cmd is %h ", cmd);
    @(posedge clk);
    @(negedge clk);
    clr_cmd_rdy = 1;
    repeat(5)@(posedge clk);
    clr_cmd_rdy = 0;
    send_resp = 1;
    move = 8'b10000000;
    @(posedge clk);
    @(negedge clk);
    send_resp = 0;
    repeat(5)@(posedge clk);

    //4th test move = 8'b10000000
    @(posedge clk);
    @(negedge clk);
    $display("cmd is %h ", cmd);
    @(posedge clk);
    @(negedge clk);
    clr_cmd_rdy = 1;
    repeat(5)@(posedge clk);
    clr_cmd_rdy = 0;
    send_resp = 1;
    @(posedge clk);
    @(negedge clk);
    send_resp = 0;
    $display("cmd is %h ", cmd);
    @(posedge clk);
    @(negedge clk);
    clr_cmd_rdy = 1;
    repeat(5)@(posedge clk);
    clr_cmd_rdy = 0;
    send_resp = 1;
    move = 8'b00001000;
    @(posedge clk);
    @(negedge clk);
    send_resp = 0;
    repeat(5)@(posedge clk);

  //5th test move = 8'b00001000
    @(posedge clk);
    @(negedge clk);
    $display("cmd is %h ", cmd);
    @(posedge clk);
    @(negedge clk);
    clr_cmd_rdy = 1;
    repeat(5)@(posedge clk);
    clr_cmd_rdy = 0;
    send_resp = 1;
    @(posedge clk);
    @(negedge clk);
    send_resp = 0;
    $display("cmd is %h ", cmd);
    @(posedge clk);
    @(negedge clk);
    clr_cmd_rdy = 1;
    repeat(5)@(posedge clk);
    clr_cmd_rdy = 0;
    send_resp = 1;
    @(posedge clk);
    @(negedge clk);
    send_resp = 0;
    repeat(5)@(posedge clk);

    repeat(60)@(posedge clk);
    $stop;
end



always #5 clk = ~clk;

endmodule