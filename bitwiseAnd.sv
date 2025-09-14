// Ashika Palacharla
// 4/18/2025
// EE469
// Lab 2: 64-bit ALU

//Module bitwiseAnd, which
// represets a bitwise AND operation for each of the bits in 64-bit
// A and 64-bit B inputs.
`timescale 1ns/10ps

module bitwiseAnd(A, B, andResult); 
	input logic [63:0] A, B;
	output logic [63:0] andResult;
	
	genvar i;
	generate
		//64 bits, so generate 64 AND gates
		for(i = 0; i < 64; i ++) begin : make64
			and #(0.05) a(andResult[i], A[i], B[i]);
		end
	endgenerate
endmodule 
 
//bitwiseAnd_tb testbench that tests all expected and unexpected behavior
module bitwiseAnd_tb(); 
	logic [63:0] A, B;
	logic [63:0] andResult;
 
	//Instantiate an instance of bitwiseAnd, called dut
	bitwiseAnd dut (.*); 
 
	//Begin driving in values to the design
	initial begin 
		A = 64'd0;
		B = 64'd0;
		#1000;
		
		A = 64'd15;
		B = 64'd0;
		#1000;
		
		A = 64'd0;
		B = 64'd15;
		#1000;
		
		A = 64'hFFFFFFFFFFFFFFFF;
		B = 64'd0;
		#1000;
		
		A = 64'd0;
		B = 64'hFFFFFFFFFFFFFFFF;
		#1000;
		
		A = 64'h1010101010101010;
		B = 64'h0101010101010101;
		#1000;
		
		A = 64'h0101010101010101;
		B = 64'h0101010101010101;
		#1000;
		
		A = 64'h1111_1111_1111_1111;
		B = 64'h1111_1111_1111_1111;
		#1000;

		$stop; //End the simulation
	end 
endmodule