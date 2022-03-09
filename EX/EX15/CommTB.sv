module CommTB();
    logic clk, rst_n;
    logic send_cmd;
    logic [15:0] cmd_in; //cmd should be sent into RemoteComm
    logic clr_cmd_rdy;

    logic cmd_sent;
    logic resp_rdy; //rx_rdy from UART
    logic [7:0] resp; //rx_data from UART

    logic [15:0] cmd_out;
    logic cmd_rdy;

    logic TX2RX;
    logic RX2TX;

    RemoteComm iDUT_T(.clk(clk), .rst_n(rst_n), .RX(RX2TX), .send_cmd(send_cmd),
    .cmd(cmd_in), .TX(TX2RX), .cmd_sent(cmd_sent), .resp_rdy(resp_rdy), .resp(resp));
    UART_wrapper iDUT_R(.clk(clk), .rst_n(rst_n), .RX(TX2RX), .TX(RX2TX), 
    .clr_cmd_rdy(clr_cmd_rdy), .cmd_rdy(cmd_rdy), .cmd(cmd_out), .trmt(1'b0), .resp(8'h00), .tx_done()); 

    initial begin
        clk = 1'b0;
        rst_n = 1'b0;
        send_cmd = 1'b0;
        cmd_in = 16'b0;

        //test1
        @(posedge clk);
        @(negedge clk);
        rst_n = 1'b1;
        cmd_in = 16'hAABB; //16'b1010 1010 1011 1011
        send_cmd = 1'b1;
        @(negedge clk);
        send_cmd = 1'b0;
        @(posedge cmd_rdy) //check the ready signal
        if(cmd_out === 16'hAABB) 
            $display("Test1 passed!");
        

        //test2
        @(posedge cmd_sent) 


        rst_n = 1'b0;
        @(posedge clk);
        @(negedge clk);
        rst_n = 1'b1;
        cmd_in = 16'hBBAA;
        send_cmd = 1'b1;
        @(negedge clk);
        send_cmd = 1'b0;
        @(posedge cmd_rdy)
        if(cmd_out === 16'hBBAA) 
            $display("Test2 passed!");

        repeat(10000)@(posedge clk);
        $stop;
    end

    always
        #5 clk = ~clk;

endmodule
