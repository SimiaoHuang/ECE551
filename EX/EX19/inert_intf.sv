//////////////////////////////////////////////////////
// Interfaces with ST 6-axis inertial sensor.  In  //
// this application we only use Z-axis gyro for   //
// heading of robot.  Fusion correction comes    //
// from "gaurdrail" signals lftIR/rghtIR.       //
/////////////////////////////////////////////////
module inert_intf(clk,rst_n,strt_cal,cal_done,heading,rdy,lftIR,
                  rghtIR,SS_n,SCLK,MOSI,MISO,INT,moving);

  parameter FAST_SIM = 1;	// used to speed up simulation
  
  input clk, rst_n;
  input MISO;					// SPI input from inertial sensor
  input INT;					// goes high when measurement ready
  input strt_cal;				// initiate claibration of yaw readings
  input moving;					// Only integrate yaw when going
  input lftIR,rghtIR;			// gaurdrail sensors
  
  output cal_done;				// pulses high for 1 clock when calibration done
  output signed [11:0] heading;	// heading of robot.  000 = Orig dir 3FF = 90 CCW 7FF = 180 CCW
  output rdy;					// goes high for 1 clock when new outputs ready (from inertial_integrator)
  output SS_n,SCLK,MOSI;		// SPI outputs
  //output [7:0] LED;
  
 

  ////////////////////////////////////////////
  // Declare any needed internal registers   // Declare outputs of SM are of type logic ////
  //////////////////////////////////////////
  logic [15:0] wt_data;
  logic [15:0] rd_data;
  logic  wrt, done;
  logic C_Y_H, C_Y_L;
  logic [7:0] yawL, yawH;
  logic [15:0] timer;
  logic vld;
  logic [15:0]yaw_rt;
  logic INTff1, INTff2;


  always_ff @(posedge clk)
  if (C_Y_L) yawL <= rd_data[7:0];

  always_ff @(posedge clk)
  if (C_Y_H) yawH <= rd_data[7:0];

  assign yaw_rt = {yawH, yawL};

  always_ff@(posedge clk, negedge rst_n)begin
    if(!rst_n) timer <= 0;
    else timer <= timer + 1;
  end


  //double INT
  always_ff@(posedge clk, negedge rst_n)begin
    if(!rst_n) INTff1 <= 0;
    else INTff1 <= INT;
  end

  always_ff@(posedge clk, negedge rst_n)begin
    if(!rst_n) INTff2 <= 0;
    else INTff2 <= INTff1;
  end

  
  ///////////////////////////////////////
  // Create enumerated type for state //
  /////////////////////////////////////

typedef enum logic [3:0] {INIT1, INIT2, INIT3, WAIT, READ1, READ2, ASRT_VLD} state_t;
state_t state, nxt_state;

always_ff@(posedge clk, negedge rst_n)begin
  if(!rst_n) 
  state <= INIT1;
  else state <= nxt_state;
end


//state machine
always_comb begin
  wt_data = 0;
  wrt = 0;
  C_Y_H = 0;
  C_Y_L = 0;
  vld = 0;
  nxt_state = INIT1;

  case(state)

  INIT1 : begin
    wt_data = 16'h0D02;
    if(&timer)begin
      nxt_state = INIT2;
      wrt = 1;
    end
    else nxt_state = INIT1;
  end

  INIT2 : begin
    wt_data = 16'h1160;
    if(done)begin
      nxt_state = INIT3;
      wrt = 1;
    end
    else nxt_state = INIT2;
  end


  INIT3 : begin
    wt_data = 16'h1440;
    if(done)begin
    nxt_state = WAIT;
    wrt = 1;
    end
    else nxt_state = INIT3;
  end


  WAIT : begin
    wt_data = 16'hA600;
    if(INTff2)begin
      nxt_state = READ1;
      wrt = 1;
    end
    else nxt_state = WAIT;
  end


  READ1 : begin
    wt_data = 16'hA700;
    if(done)begin
      nxt_state = READ2;
      wrt = 1;
      C_Y_L = 1;
    end
    else nxt_state = READ1;
  end

  READ2 : begin
    if(done)begin
      nxt_state = ASRT_VLD;
      wrt = 0;
      C_Y_H = 1;
    end
    else nxt_state = READ2;
  end

  ASRT_VLD : begin
    vld = 1;
    nxt_state = WAIT;
  end

  default : nxt_state = INIT1;

  endcase
end

  ////////////////////////////////////////////////////////////
  // Instantiate SPI monarch for Inertial Sensor interface //
  //////////////////////////////////////////////////////////
  SPI_mnrch iSPI(.clk(clk),.rst_n(rst_n),.SS_n(SS_n),.SCLK(SCLK),
                 .MISO(MISO),.MOSI(MOSI),.wrt(wrt),.done(done),
				 .rd_data(rd_data),.wt_data(wt_data));
				  
  ////////////////////////////////////////////////////////////////////
  // Instantiate Angle Engine that takes in angular rate readings  //
  // and acceleration info and produces a heading reading         //
  /////////////////////////////////////////////////////////////////
  inertial_integrator #(FAST_SIM) iINT(.clk(clk), .rst_n(rst_n), .strt_cal(strt_cal),.vld(vld),
                           .rdy(rdy),.cal_done(cal_done), .yaw_rt(yaw_rt),.moving(moving),.lftIR(lftIR),
                           .rghtIR(rghtIR),.heading(heading));
	

  //<< fill in all your brilliance >>
 
endmodule
	  