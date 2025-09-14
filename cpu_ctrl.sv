// Ashika Palacharla
// 5/26/2025
// EE469
// Lab 4: Pipelined CPU

//Module cpu_ctrl, which determines the control signals based on the instruction's op code.

`timescale 1ns/10ps

module cpu_ctrl(instruction, Reg2Loc, UncondBr, BrTaken, MemRead, MemToReg,
			MemWrite, RegWrite, ALUSrc, Immediate, SetFlags, ALUOp,
			CBZBranch, BLTBranch, BRBranch, BLBranch, BBranch, negativeFlag, overflowFlag, ForwardFlags,
			zeroFlagCTRL);

	output logic Reg2Loc, UncondBr, BrTaken, MemRead, MemToReg,
			MemWrite, RegWrite, ALUSrc, Immediate, SetFlags;
	input logic [31:0] instruction;
	output logic [2:0] ALUOp;
	output logic CBZBranch;
	input logic negativeFlag, overflowFlag, zeroFlagCTRL;
	output logic BLTBranch, BLBranch, BBranch, BRBranch;
	input logic ForwardFlags;

	enum logic [10:0] {	ADDI = 		11'b1001000100X,
								ADDS = 		11'b10101011000,
								B = 			11'b000101XXXXX,
								BLT = 		11'b01010100XXX,
								BL = 			11'b100101XXXXX,
								BR = 			11'b11010110000,
								CBZ = 		11'b10110100XXX,
								LDUR = 		11'b11111000010,
								STUR = 		11'b11111000000,
								SUBS = 		11'b11101011000} allOpCodes;
	
	always_comb begin
		//When reset is true, set everything to 0s
		casex(instruction[31:21])
			ADDI: begin
				Reg2Loc = 1; 
				ALUSrc = 1; //Constant will be ALUOp input
				MemToReg = 0;
				RegWrite = 1; //write to Rd
				MemWrite = 0;
				BrTaken = 0;
				Immediate = 1; //using immediate
				ALUOp = 3'b010;
				SetFlags = 1'b0;
				MemRead = 0;
				UncondBr = 1'b0; //added
				BBranch = 0;
				BRBranch = 0;
				BLTBranch = 0;
				BLBranch = 0;
			end
			
			ADDS: begin
				Reg2Loc = 1; //Use Rm
				ALUSrc = 0;
				MemToReg = 0;
				RegWrite = 1; //write to Rd
				MemWrite = 0;
				BrTaken = 0;
				ALUOp = 3'b010;
				SetFlags = 1'b1;
				MemRead = 0;
				Immediate = 1'b0;
				UncondBr = 1'b0;
				BBranch = 0;
				BRBranch = 0;
				BLTBranch = 0;
				BLBranch = 0;
			end
			
			SUBS: begin
				Reg2Loc = 1; //using Rm
				ALUSrc = 0;
				MemToReg = 0;
				RegWrite = 1; //writing to Rd
				MemWrite = 0;
				BrTaken = 0;
				ALUOp = 3'b011;
				SetFlags = 1'b1;
				MemRead = 0;
				Immediate = 1'b0;
				UncondBr = 1'b0;
				BBranch = 0;
				BRBranch = 0;
				BLTBranch = 0;
				BLBranch = 0;
			end
			
			B: begin
				RegWrite = 0;
				MemWrite = 0;
				BBranch = 1;
				UncondBr = 1; //not conditional, but is branching
				SetFlags = 1'b0;
				MemRead = 0;
				ALUOp = 3'b0; //added this and below
				Reg2Loc = 1'b0;
				ALUSrc = 1'b0;
				MemToReg = 1'b0;
				Immediate = 1'b0;
				BRBranch = 0;
				BLTBranch = 0;
				BLBranch = 0;
				//BrTaken = 1;
				BrTaken = BBranch;
			end
			
			BLT: begin
				Reg2Loc = 0;
				ALUSrc = 0;
				RegWrite = 0;
				MemWrite = 0;
				BLTBranch = (negativeFlag != overflowFlag);
				UncondBr = 0; //conditional branch
				ALUOp = 3'b000;
				SetFlags = 1'b0;
				MemRead = 0;
				MemToReg = 1'b0; //added this and below
				Immediate = 1'b0;
				BBranch = 0;
				BRBranch = 0;
				//BLTBranch = 1;
				BLBranch = 0;
				BrTaken = BLTBranch;
			end
			
			BL: begin
				RegWrite = 1;
				MemWrite = 0;
				//BrTaken = 1;
				UncondBr = 1; //not conditional, but is branching
				SetFlags = 1'b0;
				ALUOp = 3'b0;
				Reg2Loc = 1'b0;
				ALUSrc = 1'b0;
				MemToReg = 1'b0;
				Immediate = 1'b0;
				MemRead = 1'b0;
				BBranch = 0;
				BRBranch = 0;
				BLTBranch = 0;
				BLBranch = 1;
				BrTaken = BLBranch;
			end
			
			BR: begin
				Reg2Loc = 0; //Use Rd
				RegWrite = 0;
				MemWrite = 0;
				MemRead = 0;
				//BRBranch = 1;
				//BrTaken = 1;
				UncondBr = 1; //not conditional
				ALUOp = 3'b000;
				SetFlags = 1'b0;
				ALUSrc = 1'b0; //added this and below
				MemToReg = 1'b0;
				Immediate = 1'b0;
				BBranch = 0;
				BRBranch = 1;
				BLTBranch = 0;
				BLBranch = 0;
				BrTaken = BRBranch;	
			end
			
			CBZ: begin
				Reg2Loc = 0;
				ALUSrc = 0;
				RegWrite = 0;
				MemWrite = 0;
				MemRead = 0;
				CBZBranch = zeroFlagCTRL;
				UncondBr = 0; //is conditional
				ALUOp = 3'b000;
				SetFlags = 1'b0;
				MemToReg = 1'b0; //added this and below
				Immediate = 1'b0;
				BBranch = 0;
				BRBranch = 0;
				BLTBranch = 0;
				BLBranch = 0;
				BrTaken = CBZBranch;
			end
			
			LDUR: begin
				ALUSrc = 1; //Constant DAddr9 will be ALUOp input
				MemToReg = 1;
				RegWrite = 1; //write into reg
				MemWrite = 0; //load FROM mem
				BrTaken = 0;
				Immediate = 0; //needs to use DAddr9
				ALUOp = 3'b010;
				MemRead = 1;
				SetFlags = 1'b0;
				Reg2Loc = 1'b0; //added this and below
				UncondBr = 1'b0;
				BBranch = 0;
				BRBranch = 0;
				BLTBranch = 0;
				BLBranch = 0;
			end
			
			STUR: begin
				Reg2Loc = 0;
				ALUSrc = 1; //Constant DAddr9 will be ALUOp input
				RegWrite = 0; //no write to reg
				BrTaken = 0;
				UncondBr = 1;
				MemRead = 0;
				MemWrite = 1; //write to mem
				Immediate = 0; //needs to use DAddr9
				ALUOp = 3'b010;
				SetFlags = 1'b0;
				MemToReg = 1'b0;
				BBranch = 0;
				BRBranch = 0;
				BLTBranch = 0;
				BLBranch = 0;
			end
			
			default: begin
				ALUOp = 3'b0;
				Reg2Loc = 1'b0;
				ALUSrc = 1'b0;
				MemToReg = 1'b0;
				Immediate = 1'b0;
				RegWrite = 1'b0;
				MemWrite = 1'b0;
				BrTaken = 1'b0;
				UncondBr = 1'b0;
				SetFlags = 1'b0;
				MemRead = 1'b0;
				BBranch = 0;
				BRBranch = 0;
				BLTBranch = 0;
				BLBranch = 0;
			end
		endcase
	end

endmodule