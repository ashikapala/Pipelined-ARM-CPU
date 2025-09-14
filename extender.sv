// Ashika Palacharla
// 5/9/2025
// EE469
// Lab 3: Nonpipelined CPU

//Module extender, which extends a smaller number of bits to a 64-bit number
// Number of input (smaller) number is specified by the parameter

`timescale 1ns/10ps

module extender #(parameter LENGTH = 16)(in, out, sign); 
	input logic [LENGTH-1:0] in;
	input logic sign;
	output logic [63:0] out;
	
	logic internalBit;
	
	//If not signed, then zero extend so internalBit will be 0
	mux2_1 ext(.i0(1'b0), .i1(in[LENGTH-1]), .sel(sign), .out(internalBit));

	//Set lower bits out output to the existing input
	assign out[LENGTH-1:0] = in[LENGTH-1:0];
	
	genvar i;
	generate
		//Run for loop to pad the value the smaller number's length to reach 64 bits max
		for(i = LENGTH; i < 64; i ++) begin : extendBits
			assign out[i] = internalBit;
		end

	endgenerate
	
endmodule 
 
//extender_tb testbench that tests all expected and unexpected behavior
module extender_tb(); 
	 logic [15:0] in;
	 logic sign;
	 logic [63:0] out;
 
	//Instantiate an instance of zeroFlag, called dut
	extender dut (.in(in), .out(out), .sign(sign)); 
	
	// Set up a simulated clock.
	logic clk;
	parameter CLOCK_PERIOD=5;
	initial begin
		 clk <= 0;
		 forever #(CLOCK_PERIOD/2) clk <= ~clk; // Forever toggle the clock
	end
 
	//Begin driving in values to the design
	initial begin 
		in = 3; sign = 0;
		@(posedge clk);
		in = -3; sign = 0;
		@(posedge clk);
		in = -3; sign = 1;
		@(posedge clk);
		
		in = 10; sign = 1;
		@(posedge clk);
		in = -10; sign = 1;
		@(posedge clk);
		
		in = 244; sign = 1;
		@(posedge clk);
		in = -244; sign = 1;
		@(posedge clk);
		
		$stop; //End the simulation
	end 
endmodule