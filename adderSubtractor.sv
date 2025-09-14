// Ashika Palacharla
// 4/18/2025
// EE469
// Lab 2: 64-bit ALU

//Module adderSubtractor, which represents a 1-bit adder/subtractor:
//	Module inputs are:
//			- 1-bit A, B (values being added or subtracted)
//			- 1-bit Cin (carry in)
//			- 1-bit subtract (to select whether to add or subtract)
//					- high when subtracting, low when adding
// Module outputs are:
//			- 1-bit Cout (carry out)
//			- 1-bit Sum
//			- 1
`timescale 1ns/10ps

module adderSubtractor(A, B, Cin, subtract, Cout, Sum); 
	input logic A, B;
	input logic Cin, subtract;
	output logic Cout, Sum;
	
	//Internal logic to store value of B from mux
	logic muxB;
	//Invert B, to be input for '1' on 2:1 mux
	logic notB;
	not #(0.05) n1(notB, B);
	//2:1 mux will determine whether to pass B or ~B, based on subtract as select
	//		- when subtract is high, inverted B is sent to output of mux
	mux2_1 mux2(.i0(B), .i1(notB), .sel(subtract), .out(muxB));
	
	//Internal logic to store outputs from fullAdder gates
	logic xor1, and1, and2;
	
	//Building fullAdder using gates
	//XOR1 = A XOR B
	xor #(0.05) x1(xor1, A, muxB);
	
	//AND1 = A AND B
	and #(0.05) a1(and1, A, muxB);
	
	//Sum = XOR2 = XOR1 XOR Cin
	xor #(0.05) x2(Sum, xor1, Cin);
	
	//AND2 = XOR1 AND Cin
	and #(0.05) a2(and2, xor1, Cin);
	
	//Cout = OR1 = AND1 OR AND2
	or #(0.05) o1(Cout, and1, and2);
	
endmodule 
 
//adderSubtractor_tb testbench that tests all expected and unexpected behavior
module adderSubtractor_tb(); 
	 logic A, B;
	 logic Cin;
	 logic Cout, Sum;
	 logic subtract;
 
	//Instantiate an instance of adderSubtractor, called dut
	adderSubtractor dut (.*); 
 
	//Begin driving in values to the design
	initial begin 
		// Testing adder, when subtract is 0
		subtract = 0;
		for (int i = 0; i < 8; i++) begin
			{A, B, Cin} = i;
			#500;
		end
		#20
		
		//Testing subtractor, when subtract is 1 and Cin is 1
		subtract = 1;
		Cin = 1;
		for (int i = 0; i < 4; i++) begin
			{A, B} = i;
			#500;
		end
		
		//Testing all possible combos with subtractor, when Cin is 1 or 0
		subtract = 1;
		for (int i = 0; i < 8; i++) begin
			{A, B, Cin} = i;
			#500;
		end
		$stop; //End the simulation
	end 
endmodule