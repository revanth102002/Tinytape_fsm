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
	wire [1:0] north;
	wire [1:0]east;
	wire [1:0]south;
	wire [1:0]west;

	traffic u1(.clk(clk),.reset(rst_n),.north(north),.east(east),.south(south),.west(west));
	assign uo_out={north,east,south,west};

  // All output pins must be assigned. If not used, assign to 0.
 // assign uo_out  = ui_in + uio_in;  // Example: ou_out is the sum of ui_in and uio_in
  assign uio_out = 0;
  assign uio_oe  = 0;

  // List all unused inputs to prevent warnings
	wire _unused = &{ui_in,uio_in, 1'b0};

endmodule




module timer #(parameter FREQ = 50*1000*1000, parameter MAX_TIME = 25) (
    input clk,
    input reset,
    output reg [$clog2(MAX_TIME)-1:0] sec_timer
);

    reg [$clog2(FREQ)-1:0] count;

    always @(posedge clk or negedge reset) begin
        if (!reset) begin
            count <= 0;
            sec_timer <= 0;
        end else begin
            if (count == FREQ-1) begin
                count <= 0;
                if (sec_timer == MAX_TIME-1)
                    sec_timer <= 0;
                else
                    sec_timer <= sec_timer + 1;
            end else begin
                count <= count + 1;
            end
        end
    end
endmodule

module traffic(
    input clk,
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
    wire [$clog2(25)-1:0] sec_timer; // Updated bit-width
    
    timer sec_time(.clk(clk), .reset(reset), .sec_timer(sec_timer)); // Reset is now active-high

    always @(posedge clk or negedge reset) begin
        if (!reset) begin
            state <= RST;
        end else begin
            state <= nextstate;
        end
    end

    always @(*) begin
        nextstate = state;
        case (state)
            RST  : begin
                north = yellow;
                east = yellow;
                south = yellow;
                west = yellow;
                if(sec_timer == 5'd0)
                    nextstate = s0;
            end
            s0: begin
                north = green;
                east = red;
                south = red;
                west = red;
		    if(sec_timer == 5'd1)
                    nextstate = s1;
            end
            s1: begin
                north = yellow;
                east = yellow;
                south = red;
                west = red;
		    if(sec_timer == 5'd5)
                    nextstate = s2;
            end
            s2: begin
                north = red;
                east = green;
                south = red;
                west = red;
                if(sec_timer == 5'd11)
                    nextstate = s3;
            end
            s3: begin
                north = red;
                east = yellow;
                south = yellow;
                west = red;
                if(sec_timer == 5'd12)
                    nextstate = s4;
            end
            s4: begin
                north = red;
                east = red;
                south = green;
                west = red;
                if(sec_timer == 5'd17)
                    nextstate = s5;
            end
            s5: begin
                north = red;
                east = red;
                south = yellow;
                west = yellow;
                if(sec_timer == 5'd18)
                    nextstate = s6;
            end
            s6: begin
                north = red;
                east = red;
                south = red;
                west = green;
                if(sec_timer == 5'd23)
                    nextstate = s7;
            end
            s7: begin
                north = yellow;
                east = red;
                south = red;
                west = yellow;
                if(sec_timer == 5'd24)
                    nextstate = s0;
            end
            default: begin
                north = red;
                east = red;
                south = red;
                west = red;
                if(sec_timer == 5'd0)
                    nextstate = RST;
            end
        endcase
    end
endmodule
