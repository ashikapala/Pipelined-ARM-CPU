// Ashika Palacharla
// 4/11/2025
// EE469
// Lab 1: 32X64 Register File

//Module D_FF that was provided. Represents a D-Flip Flop with
// d as input, q as output, and reset and clk inputs.
`timescale 1ps/1ps
module D_FF (q, d, reset, clk);
	output reg q;
	input d, reset, clk;
	
	always_ff @(posedge clk)
		if (reset)
			q <= 0; // On reset, set to 0
		else
			q <= d; // Otherwise out = d
endmodule

//D_FF testbench that tests all expected and unexpected behavior
module D_FF_tb();
	logic q, d, reset, clk;
	
	//Instantiates an instance of D_FF, called dut
	D_FF dut (.*);
	
	// Set up a simulated clock.
	parameter CLOCK_PERIOD=100;
	initial begin
		clk <= 0;
		forever #(CLOCK_PERIOD/2) clk <= ~clk; // Forever toggle the clock
	end

	//Drive inputs to the testbench
	integer i;
	initial begin
		//Turn on reset for a few clock cycles
		// reset is ON
		reset <= 1;
		repeat(2) @(posedge clk);
		 
		// reset is OFF, test 0 and 1 for d
		reset <= 0;
		for(i = 0; i <2; i++) begin
				 d = i; @(posedge clk);
		end
		
		//q will be 1 for a few clock cycles
		repeat(4) @(posedge clk);
		
		//reset is ON, which makes q go to 0
		reset <= 1;
		repeat(2) @(posedge clk);
		
		$stop; //End the simulation
	end
endmodule