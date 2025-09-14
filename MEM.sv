//// Ashika Palacharla
//// 5/9/2025
//// EE469
//// Lab 3: Nonpipelined CPU
//
////Module MEM, which represents data memory stage of 5-stage nonpipelined CPU
//
//`timescale 1ns/10ps
//
//module MEM(clk, reset, MEM_ALUOp_Result, MEM_MemWrite, MEM_MemRead, MEM_Db, MEM_Dout); 
//
//	//Define input and output ports
//	input logic clk, reset;
//	input logic [63:0] MEM_ALUOp_Result, MEM_Db;
//	output logic [63:0] MEM_Dout;
//	input logic MEM_MemWrite, MEM_MemRead;
//	input logic MEM_MemToReg, BLBranch;
//	
//	//Instantiate Memory
//	//		- set Dout to be read data out from the data memory
//	//		- ALUOp_Result will be the address
//	datamem cpuDM(.address(MEM_ALUOp_Result), .write_enable(MEM_MemWrite),
//					.read_enable(MEM_MemRead), .write_data(MEM_Db), .clk,
//					.xfer_size(4'b1000), .read_data(MEM_Dout));
//	
//
//module WB(clk, reset, ALUOp_Result, Dout, MemToReg, BLBranch, Incr4, WriteData, WB_destReg, WB_opcode); 
//
//	//Define input and output ports
//	input logic clk, reset;
//	input logic [63:0] ALUOp_Result, Dout, Incr4;
//	input logic MemToReg, BLBranch;
//	output logic [63:0] WriteData;
//	output logic [4:0] WB_destReg;
//	input logic [31:0] WB_opcode;
//	
//	assign WB_destReg = WB_opcode[4:0];
//	
//	logic [63:0] InternalWriteData; //InternalWriteData is intermediate value, WriteData is final value to be written
//	
//	genvar i;
//	
//	//2:1 MUX MemToReg - to select DataMem or ALU value will be sent to InternalWriteData
//	//		- If MemToReg is 1, value from data memory will be passed through
//	//		- If MemToReg is 0, value from ALU will be passed through
//	generate
//		for(i = 0; i < 64; i++) begin : setIntermediateWriteData
//			mux2_1 memToRegMux(.i0(MEM_ALUOp_Result[i]), .i1(MEM_Dout[i]),
//								.sel(MemToReg), .out(InternalWriteData[i]));
//		end
//	endgenerate
//
//	//2:1 MUX BLBranch to select if X30 or DataMem/ALU value will be set to WriteData
//	//		- If BLBranch is 1, Incr4 (return address) will be written to the register X30
//	//		- If BLBranch 0, DataMem/ALU value (InternalWriteData) is passed to WriteData
//	generate
//		for(i = 0; i < 64; i++) begin : setWriteData
//			mux2_1 blbranchMux(.i0(InternalWriteData[i]), .i1(Incr4[i]),
//									.sel(BLBranch), .out(WB_WriteData[i]));
//		end
//	endgenerate	
//	
//endmodule