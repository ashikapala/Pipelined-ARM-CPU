// Ashika Palacharla
// 4/11/2025
// EE469
// Lab 1: 32X64 Register File

//Module register, which represents a 64-bit wide register.
// Each register is an array of 64 D-flip flops with enables.
//
// Module inputs are:
//		- 1-bit WriteEnable as input, 1-bit clk as input,
//		- 64-bit DataIn as input
// Module outputs are:
//		- 64-bit DataOut as output
`timescale 1ns/10ps

module register64(DataIn, WriteEnable, DataOut, clk, reset); 
	input logic [63:0] DataIn;
	output logic [63:0] DataOut;
	input WriteEnable, clk, reset;
	
	logic [63:0] muxData;
	
	// Register contains 64 D-flip flops with enables
	// 2:1 mux is used for each flip flop, to determine whether new write value should be loaded
	// (enable is true) or old value should be kept
	genvar i; 
	generate 
		for (i = 0; i < 64; i++) begin : dff64
			//2:1 mux to pick between data in (new value) or data out(old value)
			//Send value to muxData
			mux2_1 wren (.i0(DataOut[i]), .i1(DataIn[i]),
							.sel(WriteEnable), .out(muxData[i]));
			//Pass muxData value into flip flop d-input
			D_FF flipflop (.q(DataOut[i]), .d(muxData[i]),
							.reset(reset), .clk(clk));
		end
	endgenerate 
	
endmodule 
 
//mux2_1_tb testbench that tests all expected and unexpected behavior
module register64_tb(); 
	logic clk;
	logic WriteEnable;
	logic [63:0] DataIn;
	wire [63:0] DataOut;
	logic reset;
	
	// Set up a simulated clock.
	parameter ClockDelay = 5000;
	initial begin
		clk <= 0;
		forever #(ClockDelay / 2) clk <= ~clk;// Forever toggle the clock
	end
 
	//Instantiate an instance of mux2_1, called dut
	register64 dut (.*); 
 
	//Begin driving in values to the design
	initial begin
		// initialize to all 0s
		WriteEnable <= 0;
		DataIn <= 64'h0000_0000_0000_0000;
		@(posedge clk);
		
		// try write with WriteEnable = 0
		DataIn <= 64'hAAAAAAAA_AAAAAAAA;
		WriteEnable <= 0;
		@(posedge clk);
		
		// write data with WriteEnable = 1
		WriteEnable <= 1;
		DataIn <= 64'h12345678_ABCDEF01;
		@(posedge clk);
		
		//turn off write enable, try to write data
		WriteEnable <= 0;
		DataIn <= 64'hFFFFFFFF_FFFFFFFF;
		@(posedge clk);
		
		//turn on write enable and do a new value
		WriteEnable <= 1;
		DataIn <= 64'hDEADBEEF_CAFEFADE;
		@(posedge clk);
		@(posedge clk);
		
		$stop; //End the simulation
	end
		
endmodule