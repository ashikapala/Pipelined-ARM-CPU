// Ashika Palacharla
// 5/26/2025
// EE469
// Lab 4: Pipelined CPU

//Module IF, which represents instruction fetch stage of 5-stage nonpipelined CPU

`timescale 1ns/10ps

module IF(clk, reset, opcode, BRBranch, Db, BrTaken, Incr4, IncrBr, PC_out); 
	//Define input and output ports
	input logic clk, reset;
	input logic BRBranch; //Control signal coming from ID
	input logic [63:0] Db; //When BRBranch is true, Db contains address to go to
	
	input logic BrTaken; //Control signal coming from ID
	input logic [63:0] IncrBr; //When BRTaken is true, branch update to PC	- PC + BranchAddress
	
	output logic [31:0] opcode;
	
	//Output to PC 
	output logic [63:0] PC_out; //Program Counter value
	logic [63:0] PC_in;
	
	//Intermediates to hold 64-bit address from BrTaken 2:1 MUX
	logic [63:0] brTakenAddr64; //input is the 64-bit address from BrTaken 2:1 MUX

	//PC+4 increment value
	output logic [63:0] Incr4; //Track +4 increment update to PC (Incr4)
	
	genvar i;
	
	
	
	//2:1 MUX - BrTaken
	//Choose between Incr4 or IncrBr to set as NextAddr64
	//Choosing whether to go to next instruction or branch instruction as next address
	//if BrTaken is true, then pass in IncrBr
	generate
		for(i = 0; i < 64; i++) begin : setNextAddr64
			mux2_1 brTakenMux(.i0(Incr4[i]), .i1(IncrBr[i]),
										.sel(BrTaken), .out(brTakenAddr64[i]));
		end
	endgenerate
	
	
	
	//if BRBranch is 0, then pass in the Incr4 or IncrBr
	//if BRBranch is 1, then pass in Db
	//		- Db is the return address on the return reg Rd
	generate
		for(i = 0; i < 64; i++) begin : setPCX30
			mux2_1 brBrMux(.i0(brTakenAddr64[i]), .i1(Db[i]),
										.sel(BRBranch), .out(PC_in[i]));
		end
	endgenerate

	
	
	//Register to store PC - sending NextAddr64 to data in, data out is PC
	register64 regPC (.DataIn(PC_in), .WriteEnable(1'b1), .DataOut(PC_out), .clk(clk), .reset(reset));
	
	
	
	//Add 4 to the current PC value, get Incr4, which is PC = PC + 4
	// PC + 4 = Incr4 (default next instruction)
	adderSubtractor64 addNextPC (.A(PC_out), .B(64'd4), .subtract(1'b0),
								.Cout(), .overflow(), .Sum(Incr4));
	
	
	
	//Instantiate instruction memory
	//PC Address will output the instruction (opcode)
	instructmem cpuIM (.address(PC_out), .instruction(opcode), .clk(clk));
	
endmodule