// Ashika Palacharla
// 4/11/2025
// EE469
// Lab 1: 32X64 Register File

//Module mux32_1, which represents a 32:1 MUX with 32-bit input, 5-bit select, 1-bit output.
`timescale 1ns/10ps

module mux32_1(in, sel, out); 
	input logic [31:0] in;
	input logic [4:0] sel;
	output logic out;
	
	genvar i;
	
	logic [15:0] data16;
	logic [7:0] data8;
	logic [3:0] data4;
	logic [1:0] data2;
	
	generate
		//Convert 32 inputs to 16 inputs, using 16 muxes
		for(i = 0; i < 32; i += 2) begin : make16
			mux2_1 mux16 (.i0(in[i]), .i1(in[i + 1]),
							.sel(sel[0]), .out(data16[i / 2]));
		end
		
		//Convert 16 inputs to 8 inputs, using 8 muxes
		for(i = 0; i < 16; i += 2) begin : make8
			mux2_1 mux8 (.i0(data16[i]), .i1(data16[i + 1]),
							.sel(sel[1]), .out(data8[i / 2]));
		end
		
		//Convert 8 to 4 inputs, using 4 mux
		for(i = 0; i < 8; i += 2) begin : make4
			mux2_1 mux4 (.i0(data8[i]), .i1(data8[i + 1]),
							.sel(sel[2]), .out(data4[i / 2]));
		end
		
		//Convert 4 to 2 inputs, using 2 mux
		for(i = 0; i < 4; i += 2) begin : make2
			mux2_1 mux2 (.i0(data4[i]), .i1(data4[i + 1]),
							.sel(sel[3]), .out(data2[i / 2]));
		end
		
		//Convert 2 inputs to 1 input, using 1 mux based on MSB
		mux2_1 mux1(.i0(data2[0]), .i1(data2[1]),
							.sel(sel[4]), .out(out));
	endgenerate
	
endmodule 
 
//mux32_1_tb testbench that tests all expected and unexpected behavior
module mux32_1_tb(); 
	logic [31:0] in;
	logic [4:0] sel;
	logic out;
 
	//Instantiate an instance of mux32_1, called dut
	mux32_1 dut (.*); 
 
	//Begin driving in values to the design
	initial begin 
		in = 32'b10100101110011110001001101010110;
		for (int i = 0; i < 32; i++) begin
			sel = i;
			#10;
		end
		$stop; //End the simulation
	end 
endmodule