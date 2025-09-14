// Ashika Palacharla
// 4/18/2025
// EE469
// Lab 2: 64-bit ALU

//Module mux8_1, which represents a 8:1 MUX with 8-bit input, 3-bit select, 1-bit output.
`timescale 1ns/10ps

module mux8_1(in, sel, out); 
	input logic [7:0] in;
	input logic [2:0] sel;
	output logic out;
	
	genvar i;
	
	logic [3:0] data4;
	logic [1:0] data2;
	
	generate
	
		//Convert 8 to 4 inputs, using 4 mux
		for(i = 0; i < 8; i += 2) begin : make4
			mux2_1 mux4 (.i0(in[i]), .i1(in[i + 1]),
							.sel(sel[0]), .out(data4[i / 2]));
		end
		
		//Convert 4 to 2 inputs, using 2 mux
		for(i = 0; i < 4; i += 2) begin : make2
			mux2_1 mux2 (.i0(data4[i]), .i1(data4[i + 1]),
							.sel(sel[1]), .out(data2[i / 2]));
		end
		
		//Convert 2 inputs to 1 input, using 1 mux based on MSB
		mux2_1 mux1(.i0(data2[0]), .i1(data2[1]),
							.sel(sel[2]), .out(out));
	endgenerate
	
endmodule 
 
//mux8_1_tb testbench that tests all expected and unexpected behavior
module mux8_1_tb(); 
	logic [7:0] in;
	logic [2:0] sel;
	logic out;
 
	//Instantiate an instance of mux8_1, called dut
	mux8_1 dut (.*); 
 
	//Begin driving in values to the design
	initial begin 
		//in = 8'b10100101;
		in = 8'b10101010;
		for (int i = 0; i < 8; i++) begin
			sel = i;
			#300;
		end
		$stop; //End the simulation
	end 
endmodule