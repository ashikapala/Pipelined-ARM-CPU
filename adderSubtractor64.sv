// Ashika Palacharla
// 4/18/2025
// EE469
// Lab 2: 64-bit ALU

//Module adderSubtractor64, which represents a 64-bit adder/subtractor:
//	Module inputs are:
//			- 64-bit A, B (values being added or subtracted)
//			- 1-bit subtract (to select whether to add or subtract)
//					- high when subtracting, low when adding
//					- this is the carry in to the first bit adder/subtractor
// Module outputs are:
//			- 1-bit Cout (carry out)
//			- 64-bit Sum
//			- 1-bit overflow
`timescale 1ns/10ps

module adderSubtractor64(A, B, subtract, Cout, overflow, Sum); 
	input logic [63:0] A, B;
	input logic subtract;
	output logic Cout, overflow;
	output logic [63:0] Sum;
	
	//Internal logic to store all of the carry out's from each 1-bit adder/subtractor
	logic [63:0] allCout;
	
	//MSB of all carryout's is the overall Cout of the module
	assign Cout = allCout[63];
	
	//Overflow is XOR of the last two carry out bits
	xor #(0.05) x1(overflow, allCout[63], allCout[62]);
	
	//Do first 1-bit adder/subtractor separately, to make sure the subtraction occurs
	//		- subtract will map to the Cin and the subtract
	adderSubtractor as1 (.A(A[0]), .B(B[0]), .Cin(subtract), .subtract(subtract),
								.Cout(allCout[0]), .Sum(Sum[0])); 
	
	//Do the other 63 adder/subtractors for the other 63 bits
	genvar i;
	generate
		for(i = 1; i < 64; i ++) begin : adderSubtractor63
			adderSubtractor as (.A(A[i]), .B(B[i]), .Cin(allCout[i-1]),
								.subtract(subtract), .Cout(allCout[i]), .Sum(Sum[i])); 
		end
	endgenerate 
	
endmodule 
 
//adderSubtractor_tb testbench that tests all expected and unexpected behavior
module adderSubtractor64_tb(); 
	 logic [63:0] A, B;
	 logic subtract;
	 logic Cout, overflow;
	 logic [63:0] Sum;
 
	//Instantiate an instance of adderSubtractor64, called dut
	adderSubtractor64 dut (.*); 

   // Begin driving in values to the design
   initial begin
        // Test 0 + 0
        A = 64'd0; B = 64'd0; subtract = 0;
        #100000;

        // Test 10 + 5
        A = 64'd10; B = 64'd5; subtract = 0;
        #100000;

        // Test 10 - 5
        A = 64'd10; B = 64'd5; subtract = 1;
        #100000;

        // Test 5 - 10
        A = 64'd5; B = 64'd10; subtract = 1;
        #100000;

        // Overflow case for adding to largest pos number: (2^63 - 1) + 1
        A = 64'h7FFFFFFFFFFFFFFF; B = 64'd1; subtract = 0;
        #100000;

        // Overflow case for subtracting from largest neg number: -2^63 - 1
        A = 64'h8000000000000000; B = 64'd1; subtract = 1;
        #100000;

        $stop; //End the simulation
    end
endmodule