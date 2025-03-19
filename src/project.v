/*
 * Copyright (c) 2024 Your Name
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module tt_um_fsm (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // always 1 when the design is powered, so you can ignore it
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);

	traffic u1(.clk(clk),.reset(rst_n),.north(uo_out[7:6]),.east(uo_out[5:4]),.south(uo_out[3:2]),.west(uo_out[1:0]));

  // All output pins must be assigned. If not used, assign to 0.
 // assign uo_out  = ui_in + uio_in;  // Example: ou_out is the sum of ui_in and uio_in
  assign uio_out = 0;
  assign uio_oe  = 0;

  // List all unused inputs to prevent warnings
	wire _unused = &{ena,ui_in,uio_in, 1'b0};

endmodule




module traffic(
    input  clk,
    input reset,
    output reg [1:0] north,
    output reg [1:0] east,
    output reg [1:0] south,
    output reg [1:0] west
);
parameter yellow = 2'b01;
    parameter green = 2'b10;
    parameter red = 2'b00;
    parameter RST = 4'b0000;
    parameter s0 = 4'b0001;
    parameter s1 = 4'b0010;
    parameter s2 = 4'b0011;
    parameter s3 = 4'b0100;
    parameter s4 = 4'b0101;
    parameter s5 = 4'b0110;
    parameter s6 = 4'b0111;
    parameter s7 = 4'b1000;
	 reg [3:0] state;
    reg [3:0] nextstate; 
	wire [4:0]sec_timer;
	timer sec_time(.clk(clk),.reset(!reset),.sec_timer(sec_timer));
	always @(posedge clk or negedge reset) begin
		 if (!reset) begin
            state <= RST;
        end else begin
                state <= nextstate;
					  end
    end

  always @(state,sec_timer) begin
  nextstate = state;
        case (state)
            RST  : begin
                north = yellow;
                east = yellow;
                south = yellow;
                west = yellow;
		          if(sec_timer==5'd0)
							nextstate = s0;
							else 
								nextstate=nextstate;
           end
            s0: begin
                north = green;
                east = red;
                south = red;
                west = red;
					 if(sec_timer==5'd5)
						nextstate = s1;
							else 
								nextstate=nextstate;
						end
            s1: begin
                north = yellow;
                east = yellow;
                south = red;
					 west = red;
				    if(sec_timer==5'd6)
						nextstate = s2;
						else 
						nextstate=nextstate;
                end
            s2: begin
                north = red;
                east = green;
                south = red;
					 west = red;
				if(sec_timer==5'd11)
					nextstate = s3;
					else 
					nextstate =nextstate;
					end
            s3: begin
                north = red;
                east = yellow;
                south = yellow;
					 west = red;
					if(sec_timer==5'd12)
						nextstate = s4;
						else 
						nextstate=nextstate;
					end
            s4: begin
                north = red;
                east = red;
                south = green;
					 west = red;
					if(sec_timer==5'd17)
						nextstate = s5;
						else 
						nextstate=nextstate;
					end
            s5: begin
                north = red;
                east = red;
                south = yellow;
					 west = yellow;
				    if(sec_timer==5'd18)
						nextstate = s6;
					else 
						nextstate=nextstate;
					end
            s6: begin
                north = red;
                east = red;
                south = red;
					 west = green;
					if(sec_timer==5'd23)
						nextstate = s7;
						else 
						nextstate=nextstate;
					end
            s7: begin
                north = yellow;
                east = red;
                south = red;
					 west = yellow;
					if(sec_timer==5'd24)
						nextstate = s0;
					else 
						nextstate =nextstate;
					end
            default: begin
                north = red;
                east = red;
                south= red;
					 west = red;
				if(sec_timer==5'd0)
					nextstate = RST;
				else 
					nextstate =nextstate;
            end
        endcase
    end
endmodule



module timer (
    input clk,
    input reset,
    output reg [4:0] sec_timer
);

    localparam FREQ = 50*1000*1000; // Adjust this for actual usage, here it's for simulation

    reg [25:0] count;

    always @(posedge clk) begin
	    if (!reset) begin
            count <= 26'd0;
            sec_timer <= 5'd0;
        end else begin
            if (count == FREQ-1 ) begin
                count <= 26'd0;
                if (sec_timer == 5'd24) // Max value for sec_timer to reset at 25
                    sec_timer <= 5'd0;
                else
                    sec_timer <= sec_timer + 1'b1;
						  end else begin
                count <= count + 1'b1;
            end
        end
    end
endmodule

