// Ashika Palacharla
// 5/26/2025
// EE469
// Lab 4: Pipelined CPU

//Module ID, which represents instruction decode stage of 5-stage nonpipelined CPU

`timescale 1ns/10ps

module ID(clk, reset, IF_opcode, ID_opcode,
				PC, Da, Db, WriteData, ALUOp, Reg2Loc, UncondBr, BrTaken, MemRead, MemToReg,
					MemWrite, RegWrite, ALUSrc, Immediate, SetFlags,
					CBZBranch, BLTBranch, BRBranch, BLBranch, BBranch,
					negative, overflow, negativeFlag, overflowFlag, EX_negativeFlag, EX_overflowFlag, IncrBr, WB_RegWrite,
					Ab, ID_srcReg1, ID_srcReg2, WB_destReg, EX_opcode, MEM_opcode, EX_RegWrite, MEM_RegWrite, MEM_ALUOp_Result, EX_ALUOp_Result,
					A, B, ALUOp_B, MEM_WriteData, ID_Aw); 
	//Define input and output ports
	input logic clk, reset;
	input logic [31:0] IF_opcode, ID_opcode, EX_opcode, MEM_opcode;
	output logic [63:0] IncrBr; //Branch update to PC, produced from adder
	output logic [2:0] ALUOp;
	input logic [4:0] WB_destReg;
	output logic [63:0] ALUOp_B;
	input logic [63:0] MEM_WriteData;
	output logic [4:0] ID_Aw; //register write address, X30 if BL is true, pass in Rd if not
	
	input logic EX_RegWrite, MEM_RegWrite;
	input logic [63:0] MEM_ALUOp_Result, EX_ALUOp_Result;
	output logic [4:0] ID_srcReg1, ID_srcReg2;
	
	input logic [63:0] PC;
	input logic negative, overflow; //negative and overflow produced by ALU
	input logic EX_negativeFlag, EX_overflowFlag; //not needed TODO: comment out
	input logic negativeFlag, overflowFlag; 
	output logic Reg2Loc, UncondBr, BrTaken, MemRead, MemToReg,
					MemWrite, RegWrite, ALUSrc, Immediate, SetFlags;
	output logic CBZBranch;
	output logic BLTBranch, BRBranch, BLBranch, BBranch;
	input logic WB_RegWrite;
	
	
	
	//CREATING INCRBR - BRANCH UPDATE TO PC 
	
	//64-bit registers to hold the addresses
	logic [63:0] CondAddr64, BrAddr64, Addr64, ShiftAddr64, NextAddr64;
	
	//Assign conditional address to bits 23 to 5, then extend
	logic [18:0] CondAddr19;
	assign CondAddr19 = ID_opcode[23:5];
	extender #(.LENGTH(19)) condExt(.in(CondAddr19), .out(CondAddr64), .sign(1'b1));

	//Assign branch address to bits 25 to 0, then extend
	logic [25:0] BrAddr26;
	assign BrAddr26 = ID_opcode[25:0];
	extender #(.LENGTH(26)) brExt(.in(BrAddr26), .out(BrAddr64), .sign(1'b1));
	
	//2:1 MUX - UncondBr
	//Choose between CondAddr64 or BrAddr64 to set as Addr64
	genvar i;
	generate
		for(i = 0; i < 64; i++) begin : setAddr64
			mux2_1 uncondBrMux(.i0(CondAddr64[i]), .i1(BrAddr64[i]),
										.sel(UncondBr), .out(Addr64[i]));
		end
	endgenerate
	
	//Shift Addr64 selected address by 2
	assign ShiftAddr64 = {Addr64[61:0], 2'b00};
	
	//Add Addr64 to the current PC, get IncrBr value, which is PC updated by branch
	// PC + ShiftAddr64 = IncrBr (PC update for branch)
	adderSubtractor64 addBrPC (.A(ShiftAddr64), .B(PC), .subtract(1'b0),
								.Cout(), .overflow(), .Sum(IncrBr));
	

	
	//REGISTER FILE
	
	output logic [63:0] Da, Db;
	input logic [63:0] WriteData;
	output logic [4:0] Ab; //Rd or Rm based on Reg2Loc
	
	//Set Rd to opcode 4 to 0 bits
	logic [4:0] Rd;
	assign Rd = ID_opcode[4:0];
	
	//Set Rm to opcode 20 to 16 bits
	logic [4:0] Rm;
	assign Rm = ID_opcode[20:16];
	
	//Set Rn to opcode 9 to 5 bits
	logic [4:0] Rn;
	assign Rn = ID_opcode[9:5];
	assign ID_srcReg1 = ID_opcode[9:5];

	//2:1 MUX Reg2Loc to RegFile, sets Ab (the address for second read register)
	//When Reg2Loc is true, pass Rm for Ab. When false, pass Rd
	generate
		for(i = 0; i < 5; i++) begin : setAb
			mux2_1 reg2LocMux (.i0(Rd[i]), .i1(Rm[i]), .sel(Reg2Loc), .out(ID_srcReg2[i]));
		end
	endgenerate
	
	//Set WriteReg to Rd or X30 depending on BLBranch
	//		- X30 will be Aw if BLBranch is true, to store return addr in X30 later
	logic [4:0] X30;
	assign X30 = 5'b11110;
	generate
		 for (i = 0; i < 5; i++) begin : setWriteReg
			  mux2_1 regDestMux(.i0(Rd[i]), .i1(X30[i]), .sel(BLBranch), .out(ID_Aw[i]));
		 end
	endgenerate
	
	logic nClk;
	not #(0.05) notClock1 (nClk, clk);

	//Instantiate regFile
	//		- Read Reg 2 will be Ab, depending on Reg2Loc will pass in Rd or Rm
	//		- Write Reg will be Rd - only written to based on RegWrite
	regfile cpuRF (.ReadData1(Da), .ReadData2(Db), .WriteData(WriteData), .ReadRegister1(Rn), .ReadRegister2(ID_srcReg2),
							.WriteRegister(WB_destReg), .RegWrite(WB_RegWrite), .clk(nClk), .reset(reset));
	
	
	
	//FORWARDING SIGNALS FOR A,B INPUTS TO ALU
	
	logic ForwardFlags;
	logic [1:0] ForwardA, ForwardB; //forwarding for Da and Db
	
	//produces ForwardFlags
	forwardingUnit ex_fwdUnit (.ID_opcode(IF_opcode),
										.EX_opcode(ID_opcode),
										.MEM_opcode(EX_opcode),
										.WB_opcode(MEM_opcode),
										.EX_MEM_RegWrite(EX_RegWrite),
										.MEM_WB_RegWrite(MEM_RegWrite),
										.ForwardA(ForwardA), .ForwardB(ForwardB),
										.ForwardFlags, .Ab(Ab), .EX_Immediate(Immediate),
										.srcReg1(ID_srcReg1), .srcReg2(ID_srcReg2));
	
	
	
	//FORWARDING NEGATIVE, OVERFLOW FLAGS
		
	logic ctrlNegativeFlag, ctrlOverflowFlag; //negative flag and overflow flag to be used by control unit
	
	//When ForwardFlags is true, then forward ALU negative and overflow to the control unit
	//When ForwardFlags is false, then forward the negativeFlag back to negativeFlag
	mux2_1 fwdFlagsNegative(.i0(negativeFlag), .i1(negative), .sel(ForwardFlags), .out(ctrlNegativeFlag));
	mux2_1 fwdFlagsOverflow(.i0(overflowFlag), .i1(overflow), .sel(ForwardFlags), .out(ctrlOverflowFlag));
	
	
	
	//FORWARDING ZERO FLAG
	
	logic [63:0] ID_valueCBZ; //output from the forwardingCBZ unit
	logic zeroFlagCTRL;
	
	forwardingCBZ forwardValueCBZ (.ID_opcode(ID_opcode),
												.EX_opcode(EX_opcode),
												.MEM_opcode(MEM_opcode),
												.EX_MEM_RegWrite(EX_RegWrite),
												.MEM_WB_RegWrite(MEM_RegWrite),
												.ID_Db(Db),
												.ID_valueCBZ(ID_valueCBZ),
												.MEM_ALUOp_Result(MEM_ALUOp_Result),
												.EX_ALUOp_Result(EX_ALUOp_Result)); 
								
	zeroFlag checkCBZ(.in(ID_valueCBZ), .out(zeroFlagCTRL)); //if the input is 0, then set zero flag
	

	
	// FORWARDING A,B INPUTS TO ALU
	
	output logic [63:0] A, B;	
	
	//	4:1 MUX based on ForwardA, ForwardB control signals:
	//			- data from reg (Da/Db)
	//			- forward from MEM/WB - Dout from data mem or ALUOp_Result from MEM/WB stage (2 instructions prior)
	//			- forward from EX/MEM - ALUOp_Result from EX/MEM stage (1 instruction prior)				
	generate
		for(i = 0; i < 64; i++) begin : setMuxALUA
			mux4_1 muxALU_A (.out(A[i]), .i00(Da[i]), .i01(MEM_WriteData[i]), .i10(EX_ALUOp_Result[i]), .i11(), .sel0(ForwardA[0]), .sel1(ForwardA[1])); 
		end
	endgenerate
	
	generate
		for(i = 0; i < 64; i++) begin : setMuxALUB
			mux4_1 muxALU_B (.out(B[i]), .i00(Db[i]), .i01(MEM_WriteData[i]), .i10(EX_ALUOp_Result[i]), .i11(), .sel0(ForwardB[0]), .sel1(ForwardB[1])); 
		end
	endgenerate
	
	
	
	// USE IMMEDIATE (Imm12) OR BYTE OFFSET (DAddr9) AS B INPUT FOR ALU
	
	//2:1 MUX FOR IMMEDIATE, 2:1 MUX FOR ALUSRC
	logic [63:0] DAddr64, Imm64; //Extend DAddr9, extend Imm12
	//logic [63:0] ALUOp_B; //Value for B sent to ALU
	logic [63:0] ALUSrc_Input; //Immediate input to ALUSrc MUX, either DAddr64 (0) or Imm64 (1), based on if instr is immediate 
							
	//Set DAddr9 to opcode 20 to 12 bits, and extend
	logic [8:0] DAddr9;
	assign DAddr9 = ID_opcode[20:12];
	extender #(.LENGTH(9)) daExt(.in(DAddr9), .out(DAddr64), .sign(1'b1));
	
	//Set Imm12 to opcode 21 to 10 bits, and extend (not signed immediate)
	logic [11:0] Imm12; //ALU immediate 12 bits
	assign Imm12 = ID_opcode[21:10];
	extender #(.LENGTH(12)) imExt(.in(Imm12), .out(Imm64), .sign(1'b0));
						
	//2:1 MUX Immediate to select if input to ALUSrc MUX will be DAddr64 (0) or Imm12(1) - setting constant
	//2:1 MUX ALUSrc to select if B-input to ALUOp ALU will be the reg/Db (0) or the constant/ALUSrc_Input (1)
	// 	- Changed input 0 to ALUSrc mux to B (so it's after forwarding, was previously Db)
	generate
		for(i = 0; i < 64; i++) begin : setALUB
			mux2_1 immMux (.i0(DAddr64[i]), .i1(Imm64[i]), .sel(Immediate), .out(ALUSrc_Input[i]));
			mux2_1 aluSrcMux (.i0(B[i]), .i1(ALUSrc_Input[i]), .sel(ALUSrc), .out(ALUOp_B[i]));
		end
	endgenerate
	
	
	
	//CONTROL SIGNALS GENERATION
	
	cpu_ctrl cpuCTRL (.instruction(ID_opcode), .Reg2Loc, .UncondBr, .BrTaken,
							.MemRead, .MemToReg, .MemWrite, .RegWrite, .ALUSrc,
							.Immediate, .SetFlags, .ALUOp, .CBZBranch, .BLTBranch, .BRBranch, .BLBranch, .BBranch,
							.ForwardFlags,
							.negativeFlag(ctrlNegativeFlag),
							.overflowFlag(ctrlOverflowFlag),
							.zeroFlagCTRL(zeroFlagCTRL));
	
endmodule