// Ashika Palacharla
// 5/9/2025
// EE469
// Lab 3: Nonpipelined CPU

//Module flagRegister, which will set the zero, negative, carryout, and overflow flags.

`timescale 1ns/10ps

module flagRegister (SetFlags, inVals, outFlags, clk, reset); 

	input logic SetFlags;
	output logic [3:0] outFlags;
	input logic [3:0] inVals;
	input logic clk, reset;
	
	//when setFlags is true, set the new values to the flags
	//when setFlags is false, carry over the old value using the D_FF to store
	
	logic [3:0] muxData;
	
	//4 values to set
	// 2:1 mux is used for each flip flop, to determine whether new write value should be loaded
	// (enable is true) or old value should be kept
	genvar i; 
	generate 
		for (i = 0; i < 4; i++) begin : flags4
			//2:1 mux to pick between data in (new value) or data out(old value)
			//Send value to muxData
			mux2_1 wren (.i0(outFlags[i]), .i1(inVals[i]),
							.sel(SetFlags), .out(muxData[i]));
			//Pass muxData value into flip flop d-input
			D_FF flipflop (.q(outFlags[i]), .d(muxData[i]),
							.reset(reset), .clk(clk));
		end
	endgenerate 
	
endmodule 