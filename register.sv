// Ashika Palacharla
// 4/11/2025
// EE469
// Lab 4: Pipelined CPU

//Module register, which represents a register with customizable width.
// Each register is an array of D-flip flops with enables.
//
// Module inputs are:
//		- 1-bit enable as input, 1-bit clk as input,
//		- 64-bit DataIn as input
// Module outputs are:
//		- 64-bit DataOut as output
`timescale 1ns/10ps

module register #(parameter WIDTH = 64)(DataIn, enable, DataOut, clk, reset); 
	input logic [WIDTH-1:0] DataIn;
	output logic [WIDTH-1:0] DataOut;
	input enable, clk, reset;
	
	logic [WIDTH-1:0] muxData;
	
	// Register contains 64 D-flip flops with enables
	// 2:1 mux is used for each flip flop, to determine whether new write value should be loaded
	// (enable is true) or old value should be kept
	genvar i; 
	generate 
		for (i = 0; i < WIDTH; i++) begin : dffwidth
			//2:1 mux to pick between data in (new value) or data out(old value)
			//Send value to muxData
			mux2_1 wren (.i0(DataOut[i]), .i1(DataIn[i]),
							.sel(enable), .out(muxData[i]));
			//Pass muxData value into flip flop d-input
			D_FF flipflop (.q(DataOut[i]), .d(muxData[i]),
							.reset(reset), .clk(clk));
		end
	endgenerate 
	
endmodule 