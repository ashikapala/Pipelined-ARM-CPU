// Ashika Palacharla
// 4/18/2025
// EE469
// Lab 2: 64-bit ALU

//Module zeroFlag, which uses multiple 4-input OR gates to create a 64-input OR gate
// to determine if the input is all 0's. 
`timescale 1ns/10ps

module zeroFlag(in, out); 
	input logic [63:0] in;
	output logic out;
	
	genvar i;
	
	logic [15:0] data16;
	logic [3:0] data4;
	logic orOut;
	
	generate
	
		//First layer has 16, 4-input OR gates
		//Convert 64 inputs to 16 inputs
		for(i = 0; i < 64; i += 4) begin : make16
			or  #(0.05) or16 (data16[i/4], in[i], in[i+1], in[i+2], in[i+3]);
		end
		
		//Second layer has 4, 4-input OR gates
		//Convert 16 inputs to 4 inputs
		for(i = 0; i < 16; i += 4) begin : make4
			or  #(0.05) or4 (data4[i/4], data16[i], data16[i+1], data16[i+2], data16[i+3]);
		end
		
		//Convert 4 inputs to 1 input
		or  #(0.05) or1(orOut, data4[0], data4[1], data4[2], data4[3]);
	endgenerate
	
	//Invert the output from the or gate, if orOut is 0, then input was all 0's, so out should be 1
	not  #(0.05) n1 (out, orOut);
	
endmodule 
 
//zeroFlag_tb testbench that tests all expected and unexpected behavior
module zeroFlag_tb(); 
	logic [63:0] in;
	logic out;
 
	//Instantiate an instance of zeroFlag, called dut
	zeroFlag dut (.*); 
 
	//Begin driving in values to the design
	initial begin 
		in = 64'd0;
		#100000;
		
		in = 64'hFFFF_FFFF_FFFF_FFFF;
		#100000;
		
		in = 64'h0111_1111_1111_1111;
		#100000;
		
		in = 64'h1111_1101_1111_1111;
		#100000;
		
		in = 64'h1111_1111_1011_1111;
		#100000;
		
		in = 64'h1111_1111_1111_1110;
		#100000;
		$stop; //End the simulation
	end 
endmodule