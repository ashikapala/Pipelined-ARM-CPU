// Ashika Palacharla
// 4/11/2025
// EE469
// Lab 2: 64-bit ALU

//Module alu, which represents an Arithmetic Logic Unit with 8 ports.
//		- 2 input ports:
//				- 64-bit A, 64-bit B
//		- 3-bit cntrl
//		- 5 outputs:
//				- 64-bit result
//				- 1-bit zero, overflow, carry_out, negative

// Meaning of signals in and out of the ALU:

// Flags:
// negative: whether the result output is negative if interpreted as 2's comp.
// zero: whether the result output was a 64-bit zero.
// overflow: on an add or subtract, whether the computation overflowed if the inputs are interpreted as 2's comp.
// carry_out: on an add or subtract, whether the computation produced a carry-out.

// cntrl			Operation						Notes:
// 000:			result = B						value of overflow and carry_out unimportant
// 010:			result = A + B
// 011:			result = A - B
// 100:			result = bitwise A & B		value of overflow and carry_out unimportant
// 101:			result = bitwise A | B		value of overflow and carry_out unimportant
// 110:			result = bitwise A XOR B	value of overflow and carry_out unimportant

`timescale 1ns/10ps

module alu(A, B, cntrl, result, negative, zero, overflow, carry_out); 
	//Define input and output ports
	input logic	[63:0] A, B;
	input logic	[2:0] cntrl;
	output logic [63:0] result;
	output logic	negative, zero, overflow, carry_out;
	
	//Internal register to store 64-bit Sum from adder/subtractor
	logic [63:0] sumResult;
	adderSubtractor64 addsubALU(.A(A), .B(B), .subtract(cntrl[0]),
										.Cout(carry_out), .overflow(overflow), .Sum(sumResult));
	
	//Instantiate zeroFlag to have sumResult as the 64-bit input, and the zero flag as the output
	zeroFlag zeroALU(.in(sumResult), .out(zero));
	
	//Negative is assigned to MSB of the result, which will represent the sign of the value
	assign negative = result[63];
	
	//Internal registers to store bitwise gate results
	logic [63:0] andResult, orResult, xorResult;
	bitwiseAnd andALU(.A(A), .B(B), .andResult(andResult));
	bitwiseOr orALU(.A(A), .B(B), .orResult(orResult));
	bitwiseXor xorALU(.A(A), .B(B), .xorResult(xorResult));
	
	//Internal array to store all of the results, where each of the 64-bits maps to the 8 results from the 8:1 mux
	logic [63:0][7:0] resultArray;
	
	//Storing each of the results in the resultArray
	//Going by the i'th bit of the 64 bits, and each of the type of results maps to a different number 7-0
	//		- 0 in the 8:1 MUX: result = B
	//		- 2 in the 8:1 MUX: result = A + B
	//		- 3 in the 8:1 MUX: result = A - B
	//		- 4 in the 8:1 MUX: result = A AND B
	//		- 5 in the 8:1 MUX: result = A OR B
	//		- 6 in the 8:1 MUX: result = A XOR B
	genvar i;
	generate
		for(i = 0; i < 64; i++) begin : fillResultArray
				assign resultArray[i][0] = B[i]; //0 should have the value for B
				assign resultArray[i][2] = sumResult[i]; //2 should have the Sum, from A + B
				assign resultArray[i][3] = sumResult[i]; //3 should have the Sum, from A - B
				assign resultArray[i][4] = andResult[i]; //4 should have the bitwise AND result, from A AND B
				assign resultArray[i][5] = orResult[i]; //5 should have the bitwise OR result, from A OR B
				assign resultArray[i][6] = xorResult[i]; //6 should have the bitwise XOR result, from A XOR B
		end
	endgenerate
	
	//Based on which result of the 8 is selected (from cntrl),
	//		passing each bit of the 64-bit results stored in the array to the ALU's result
	//8:1 MUX to select which value is passed out to the result
	//Run for loop 64 times for the 64 bits,
	//		creating 8:1 mux for each loop to select which result bit will be used
	generate
		for(i = 0; i < 64; i++) begin : assignResult
				mux8_1 mux8 (.in(resultArray[i][7:0]), .sel(cntrl), .out(result[i]));
		end
	endgenerate
	
endmodule