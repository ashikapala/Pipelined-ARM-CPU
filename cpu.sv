// Ashika Palacharla
// 5/9/2025
// EE469
// Lab 4: Pipelined CPU

//Module cpu, which represents a pipelined CPU.
//Has capabilities for the following instructions:
//		- ADDI (add immediate)
//		- ADDS (add and set flags)
//		- B (branch to mem label)
//		- B.LT (branch if less than, uses CondAddr) - BLT CondAddr19 Rd
//		- BL (branch, and store return address in reg X30)
//		- BR (branch to address stored in reg Rd) --> when BR X30, branching to return address
//		- CBZ (branch if reg Rd value is 0, uses CondAddr)
//		- LDUR (load FROM mem)
//		- STUR (store TO mem)
//		- SUBS (subtract and set flags)

`timescale 1ns/10ps

module cpu(clk, reset); 

	genvar i;
	
	//Define input and output ports
	input logic clk, reset;
	
	//Control signals
	logic Reg2Loc, UncondBr, BrTaken, MemRead, MemToReg,
			MemWrite, RegWrite, ALUSrc, Immediate, SetFlags;
			
	//32-bit instruction, produced by instructmem
	logic [31:0] IF_opcode, ID_opcode, EX_opcode, MEM_opcode, WB_opcode;
	
	//Branch flags
	logic CBZBranch, ID_BLTBranch, ID_BLBranch, ID_BRBranch, ID_BBranch;
	
	//ALU Flags - zero, negative, overflow, carryout
	logic zeroFlagTLM, negativeFlag, overflowFlag, carryoutFlag;
	logic negative, zero, overflow, carryout;
	
	//Program Counter value
	logic [63:0] IF_PC, ID_PC, EX_PC, MEM_PC;
	
	//64-bit registers to hold the next address for the PC
	logic [63:0] NextAddr64;
	
	//Da and Db values to the ALU, out from register file
	logic [63:0] ID_Da, ID_Db, EX_Da_in, EX_Db_in, MEM_Db;
	logic [63:0] EX_Da_out, EX_Db_out;
	
	//WriteData inputted to Register File
	logic [63:0] WriteData;
	
	//Result from ALU operation
	logic [63:0] ALUOp_Result;
	
	//Pipelined ALUOp_Results
	logic EX_negativeFlag, EX_overflowFlag;
	logic [63:0] EX_ALUOp_Result, MEM_ALUOp_Result, WB_ALUOp_Result;
	
	//Declare pipelined control signals
	logic [63:0] IF_Incr4;
	logic [2:0] ID_ALUOp, EX_ALUOp; //3-bit ALU Operation code
	logic ID_ALUSrc, EX_ALUSrc;
	logic ID_MemRead, EX_MemRead, MEM_MemRead, WB_MemRead;
	logic ID_MemWrite, EX_MemWrite, MEM_MemWrite, WB_MemWrite;
	logic ID_MemToReg, EX_MemToReg, MEM_MemToReg, WB_MemToReg;
	logic ID_RegWrite, EX_RegWrite, MEM_RegWrite, WB_RegWrite;
	logic ID_SetFlags, EX_SetFlags;
	logic ID_Immediate, EX_Immediate;
	logic ID_BrTaken;
	logic [63:0] ID_Incr4, EX_Incr4, MEM_Incr4, WB_Incr4;
	logic [63:0] ID_IncrBr;
	logic EX_BLBranch;
	
	logic [4:0] ID_srcReg1, ID_srcReg2, EX_srcReg1, EX_srcReg2;
	logic [4:0] ID_Aw, EX_Aw, MEM_Aw, WB_destReg;
	
	
	
	
	//INSTRUCTION FETCH - STAGE 1
	
	IF cpu_IF(.clk(clk),
					.reset(reset),
					.opcode(IF_opcode),
					.BRBranch(ID_BRBranch),
					.Db(ID_Db),
					.BrTaken(ID_BrTaken),
					.Incr4(IF_Incr4),
					.IncrBr(ID_IncrBr),
					.PC_out(IF_PC));
	
	//IF/ID PIPELINE REGISTER
	register #(32) opcodePipReg_IFID (.DataIn(IF_opcode), .enable(1'b1), .DataOut(ID_opcode), .clk, .reset);
	register #(64) pcPipReg_IFID (.DataIn(IF_PC), .enable(1'b1), .DataOut(ID_PC), .clk, .reset);
	register #(64) incr4_PipReg_IFID (.DataIn(IF_Incr4), .enable(1'b1), .DataOut(ID_Incr4), .clk, .reset);
	
	
	
	
	//INSTRUCTION DECODE - STAGE 2
	
	logic [63:0] ID_WriteData, EX_WriteData, MEM_WriteData, WB_WriteData;
	logic ID_negativeFlag;
	logic ID_overflowFlag;
	logic [4:0] Ab;
	logic [63:0] ID_A, ID_B, EX_A, EX_B, ID_ALUOp_B, EX_ALUOp_B;
	
	ID cpu_ID (.clk,
				.reset,
				.IF_opcode(IF_opcode),
				.ID_opcode(ID_opcode),
				.PC(ID_PC),
				.Da(ID_Da),
				.Db(ID_Db),
				.Ab(Ab),
				.WriteData(WB_WriteData),
				.ALUOp(ID_ALUOp),
				.Reg2Loc(Reg2Loc),
				.UncondBr(UncondBr),
				.BrTaken(ID_BrTaken),
				.MemRead(ID_MemRead),
				.MemToReg(ID_MemToReg),
				.MemWrite(ID_MemWrite),
				.RegWrite(ID_RegWrite),
				.ALUSrc(ID_ALUSrc),
				.Immediate(ID_Immediate),
				.SetFlags(ID_SetFlags),
				.CBZBranch(CBZBranch),
				.BLTBranch(ID_BLTBranch),
				.BRBranch(ID_BRBranch),
				.BLBranch(ID_BLBranch),
				.BBranch(ID_BBranch),
				.negative(negative),
				.overflow(overflow),
				.negativeFlag(negativeFlag),
				.overflowFlag(overflowFlag),
				.EX_negativeFlag(EX_negativeFlag),
				.EX_overflowFlag(EX_overflowFlag),
				.IncrBr(ID_IncrBr),
				.WB_RegWrite(WB_RegWrite),
				.ID_srcReg1(ID_srcReg1), .ID_srcReg2(ID_srcReg2),
				.WB_destReg(WB_destReg),
				.EX_opcode,
				.MEM_opcode,
				.EX_RegWrite,
				.MEM_RegWrite,
				.MEM_ALUOp_Result,
				.EX_ALUOp_Result,
				.A(ID_A), .B(ID_B),
				.ALUOp_B(ID_ALUOp_B),
				.MEM_WriteData(MEM_WriteData),
				.ID_Aw(ID_Aw)); 
	
	//ID/EX PIPELINE REGISTER
	
	register #(32) opcode_PipReg_IDEX (.DataIn(ID_opcode), .enable(1'b1), .DataOut(EX_opcode), .clk, .reset);
	register #(64) PC_PipReg_IDEX (.DataIn(ID_PC), .enable(1'b1), .DataOut(EX_PC), .clk, .reset);
	register #(64) Da_PipReg_IDEX (.DataIn(ID_Da), .enable(1'b1), .DataOut(EX_Da_in), .clk, .reset);
	register #(64) Db_PipReg_IDEX (.DataIn(ID_B), .enable(1'b1), .DataOut(EX_Db_in), .clk, .reset);
	register #(3) aluop_PipReg_IDEX (.DataIn(ID_ALUOp), .enable(1'b1), .DataOut(EX_ALUOp), .clk, .reset);
	register #(5) Aw_PipReg_IDEX (.DataIn(ID_Aw), .enable(1'b1), .DataOut(EX_Aw), .clk, .reset);
	
	register #(64) A_PipReg_IDEX (.DataIn(ID_A), .enable(1'b1), .DataOut(EX_A), .clk, .reset);
	register #(64) B_PipReg_IDEX (.DataIn(ID_B), .enable(1'b1), .DataOut(EX_B), .clk, .reset);
	register #(64) ALUOp_B_PipReg_IDEX (.DataIn(ID_ALUOp_B), .enable(1'b1), .DataOut(EX_ALUOp_B), .clk, .reset);
	
	//srcReg1 and srcReg2 - to be used in forwarding unit
	register #(5) srcReg1_PipReg_IDEX (.DataIn(ID_srcReg1), .enable(1'b1), .DataOut(EX_srcReg1), .clk, .reset);
	register #(5) srcReg2_PipReg_IDEX (.DataIn(ID_srcReg2), .enable(1'b1), .DataOut(EX_srcReg2), .clk, .reset);
	
	register #(1) alusrc_IDEX (.DataIn(ID_ALUSrc), .enable(1'b1), .DataOut(EX_ALUSrc), .clk, .reset);
	register #(1) memread_IDEX (.DataIn(ID_MemRead), .enable(1'b1), .DataOut(EX_MemRead), .clk, .reset);
	register #(1) memwrite_IDEX (.DataIn(ID_MemWrite), .enable(1'b1), .DataOut(EX_MemWrite), .clk, .reset);
	register #(1) memtoreg_IDEX (.DataIn(ID_MemToReg), .enable(1'b1), .DataOut(EX_MemToReg), .clk, .reset);
	register #(1) immediate_IDEX (.DataIn(ID_Immediate), .enable(1'b1), .DataOut(EX_Immediate), .clk, .reset);
	register #(1) regwrite_IDEX (.DataIn(ID_RegWrite), .enable(1'b1), .DataOut(EX_RegWrite), .clk, .reset);
	register #(1) setflags_IDEX (.DataIn(ID_SetFlags), .enable(1'b1), .DataOut(EX_SetFlags), .clk, .reset);
	register #(1) blbranch_IDEX (.DataIn(ID_BLBranch), .enable(1'b1), .DataOut(EX_BLBranch), .clk, .reset);
	register #(64) incr4_PipReg_IDEX (.DataIn(ID_Incr4), .enable(1'b1), .DataOut(EX_Incr4), .clk, .reset);
	
	
	
	
	//EXECUTE - STAGE 3
	
	logic [63:0] MEM_Dout; //Dout from data mem	
	logic MEM_BLBranch;
			
	EX cpu_EX (.clk(clk),
					.reset(reset),
					.EX_opcode(EX_opcode),
					.EX_Immediate(EX_Immediate),
					.ALUSrc(EX_ALUSrc),
					.SetFlags(EX_SetFlags),
					.ALUOp(EX_ALUOp),
					.Da(EX_Da_in),
					.Db(EX_Db_in),
					.EX_ALUOp_Result(EX_ALUOp_Result),
					.negative(negative),
					.zero(zero),
					.overflow(overflow),
					.carryout(carryout),
					.WB_opcode(WB_opcode),
					.MEM_opcode(MEM_opcode),
					.ID_opcode(ID_opcode),
					.MEM_ALUOp_Result(MEM_ALUOp_Result),
					.WB_ALUOp_Result(WB_ALUOp_Result),
					.Ab(Ab),
					.ID_Immediate(ID_Immediate),
					.EX_srcReg1(EX_srcReg1),
					.EX_srcReg2(EX_srcReg2),
					.WB_RegWrite(WB_RegWrite),
					.MEM_RegWrite(MEM_RegWrite),
					.A(EX_A),
					.B(EX_ALUOp_B)); 
	
	//Set the flags when the SetFlags signal is true (for ADDS/SUBS)
	
	flagRegister cpuFlags (.SetFlags(EX_SetFlags), .inVals({zero,carryout,negative,overflow}),
					.outFlags({zeroFlagTLM,carryoutFlag,negativeFlag,overflowFlag}), .clk(clk), .reset(reset)); 
			
	//EX/MEM PIPELINE REGISTER
	
	register #(1) regwrite_EXMEM (.DataIn(EX_RegWrite), .enable(1'b1), .DataOut(MEM_RegWrite), .clk, .reset);
	register #(5) Aw_PipReg_EXMEM (.DataIn(EX_Aw), .enable(1'b1), .DataOut(MEM_Aw), .clk, .reset);
	register #(32) opcodePipReg_EXMEM (.DataIn(EX_opcode), .enable(1'b1), .DataOut(MEM_opcode), .clk, .reset);
	register #(64) Db_PipReg_EXMEM (.DataIn(EX_Db_in), .enable(1'b1), .DataOut(MEM_Db), .clk, .reset);
	register #(1) blbranch_EXMEM (.DataIn(EX_BLBranch), .enable(1'b1), .DataOut(MEM_BLBranch), .clk, .reset);
	register #(1) memtoreg_EXMEM (.DataIn(EX_MemToReg), .enable(1'b1), .DataOut(MEM_MemToReg), .clk, .reset);
	register #(64) incr4_PipReg_EXMEM (.DataIn(EX_Incr4), .enable(1'b1), .DataOut(MEM_Incr4), .clk, .reset);
	register #(64) aluresult_PipReg_EXMEM (.DataIn(EX_ALUOp_Result), .enable(1'b1), .DataOut(MEM_ALUOp_Result), .clk, .reset);
	register #(1) memwrite_EXMEM (.DataIn(EX_MemWrite), .enable(1'b1), .DataOut(MEM_MemWrite), .clk, .reset);
	register #(1) memread_EXMEM (.DataIn(EX_MemRead), .enable(1'b1), .DataOut(MEM_MemRead), .clk, .reset);
	
	
	
	
	//MEMORY - STAGE 4
	
	logic [63:0] WB_Dout; //Dout from data mem	
	logic WB_BLBranch;
	logic [63:0] InternalWriteData; //InternalWriteData is intermediate value, WriteData is final value to be written

	//Instantiate Memory
	//		- set Dout to be read data out from the data memory
	//		- ALUOp_Result will be the address
	datamem cpuDM(.address(MEM_ALUOp_Result), .write_enable(MEM_MemWrite),
					.read_enable(MEM_MemRead), .write_data(MEM_Db), .clk,
					.xfer_size(4'b1000), .read_data(MEM_Dout));
	
	//2:1 MUX MemToReg - to select DataMem or ALU value will be sent to InternalWriteData
	//		- If MemToReg is 1, value from data memory will be passed through
	//		- If MemToReg is 0, value from ALU will be passed through
	generate
		for(i = 0; i < 64; i++) begin : setIntermediateWriteData
			mux2_1 memToRegMux(.i0(MEM_ALUOp_Result[i]), .i1(MEM_Dout[i]),
								.sel(MEM_MemToReg), .out(InternalWriteData[i]));
		end
	endgenerate

	//2:1 MUX BLBranch to select if X30 or DataMem/ALU value will be set to WriteData
	//		- If BLBranch is 1, Incr4 (return address) will be written to the register X30
	//		- If BLBranch 0, DataMem/ALU value (InternalWriteData) is passed to WriteData
	generate
		for(i = 0; i < 64; i++) begin : setWriteData
			mux2_1 blbranchMux(.i0(InternalWriteData[i]), .i1(MEM_Incr4[i]),
									.sel(MEM_BLBranch), .out(MEM_WriteData[i]));
		end
	endgenerate	
					
	//MEM-WB PIPELINE REGISTER
	
	register #(64) writedata_PipReg_MEMWB (.DataIn(MEM_WriteData), .enable(1'b1), .DataOut(WB_WriteData), .clk, .reset);
	register #(5) Aw_PipReg_MEMWB (.DataIn(MEM_Aw), .enable(1'b1), .DataOut(WB_destReg), .clk, .reset);
	register #(1) regwrite_MEMWB (.DataIn(MEM_RegWrite), .enable(1'b1), .DataOut(WB_RegWrite), .clk, .reset);
	register #(64) Dout_PipReg_MEMWB (.DataIn(MEM_Dout), .enable(1'b1), .DataOut(WB_Dout), .clk, .reset);
	register #(1) blbranch_MEMWB (.DataIn(MEM_BLBranch), .enable(1'b1), .DataOut(WB_BLBranch), .clk, .reset);
	register #(1) memtoreg_MEMWB (.DataIn(MEM_MemToReg), .enable(1'b1), .DataOut(WB_MemToReg), .clk, .reset);
	register #(64) incr4_PipReg_MEMWB (.DataIn(MEM_Incr4), .enable(1'b1), .DataOut(WB_Incr4), .clk, .reset);
	register #(64) aluresult_PipReg_MEMWB (.DataIn(MEM_ALUOp_Result), .enable(1'b1), .DataOut(WB_ALUOp_Result), .clk, .reset);
	register #(1) memwrite_MEMWB (.DataIn(MEM_MemWrite), .enable(1'b1), .DataOut(WB_MemWrite), .clk, .reset);
	register #(1) memread_MEMWB (.DataIn(MEM_MemRead), .enable(1'b1), .DataOut(WB_MemRead), .clk, .reset);
	register #(32) opcodePipReg_MEMWB (.DataIn(MEM_opcode), .enable(1'b1), .DataOut(WB_opcode), .clk, .reset);
	
endmodule

//cpu_tb testbench that tests all expected and unexpected behavior
module cpu_tb(); 
	 logic clk, reset;
 
	//Instantiate an instance of cpu, called dut
	cpu dut (.*); 
	
	// Set up a simulated clock.
	parameter CLOCK_PERIOD=500000;
	initial begin
		 clk <= 0;
		 forever #(CLOCK_PERIOD/2) clk <= ~clk; // Forever toggle the clock
	end
 
	//Begin driving in values to the design
	initial begin 
		
		reset = 0;
		@(posedge clk); 
		@(posedge clk); 
		
		reset = 1;
		@(negedge clk); 
		@(posedge clk); 
		
		reset = 0;
		@(negedge clk); 
		
		repeat(1300) begin
			reset = 0; @(posedge clk); 
		end
		
		$stop; //End the simulation
	end 
endmodule