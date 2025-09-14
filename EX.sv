// Ashika Palacharla
// 5/26/2025
// EE469
// Lab 4: Pipelined CPU

//Module EX, which represents execute stage of 5-stage nonpipelined CPU

`timescale 1ns/10ps

module EX(clk, reset, EX_opcode, EX_Immediate, ALUSrc, SetFlags, ALUOp, Da, Db,
			EX_ALUOp_Result, negative, zero, overflow, carryout,
			MEM_opcode, ID_opcode, MEM_ALUOp_Result, WB_ALUOp_Result, Ab, ID_Immediate,
			EX_srcReg1, EX_srcReg2, WB_RegWrite, MEM_RegWrite, WB_opcode, A, B); 

	//Define input and output ports
	input logic clk, reset;
	input logic [31:0] EX_opcode, ID_opcode, MEM_opcode, WB_opcode;
	input logic EX_Immediate, ALUSrc, SetFlags, ID_Immediate;
	input logic MEM_RegWrite, WB_RegWrite;
	input logic [4:0] Ab, EX_srcReg1, EX_srcReg2;
	input logic [2:0] ALUOp;
	input logic [63:0] Da, Db;
	input logic [63:0] MEM_ALUOp_Result, WB_ALUOp_Result;
	output logic [63:0] EX_ALUOp_Result; //Result from ALU operation
	output logic negative, zero, overflow, carryout;
	input logic [63:0] A, B;
	genvar i;
	
	// CREATING THE ALU 
	
	//Instantiate ALU
	//		- Da is A, B is ALUOp_B (either from ALUSrc or Db), cntrl is ALUOp
	alu cpuALU(.A(A), .B(B), .cntrl(ALUOp), .result(EX_ALUOp_Result),
					.negative(negative), .zero(zero), .overflow(overflow), .carry_out(carryout));
	
endmodule