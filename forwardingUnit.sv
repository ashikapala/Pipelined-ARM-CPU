// Ashika Palacharla
// 5/9/2025
// EE469
// Lab 4: pipelined CPU

//Module forwardingUnit

`timescale 1ns/10ps

module forwardingUnit(ID_opcode, EX_opcode, MEM_opcode, WB_opcode, 
							EX_MEM_RegWrite,
							MEM_WB_RegWrite,
							ForwardA, ForwardB, ForwardFlags, Ab, EX_Immediate, srcReg1, srcReg2); 

	//Define input and output ports
	input logic [31:0] ID_opcode, EX_opcode, MEM_opcode, WB_opcode;
	input logic [4:0] Ab;
	input logic EX_Immediate;
	//Source registers and destination registers being compared 
	input logic [4:0] srcReg1, srcReg2;
	logic [4:0] EX_MEM_destReg, MEM_WB_destReg, EX_srcReg1, EX_srcReg2;
	
	//assign srcReg1 = ID_opcode[9:5];
	//assign srcReg2 = Ab;
	assign EX_MEM_destReg = MEM_opcode[4:0];
	assign MEM_WB_destReg = WB_opcode[4:0];
	
	//RegWrite for EX/MEM and MEM/WB stages
	input logic EX_MEM_RegWrite, MEM_WB_RegWrite;
	output logic [1:0] ForwardA, ForwardB;
	output logic ForwardFlags;
	
	//no forwarding is 00 (from ID/EX pipeline reg)
	//EX_MEM forwarding is 10
	//MEM_WB forwarding is 01
	
	always_comb begin
		//If EX_MEM Rd = src register 1 --> forward from EX_MEM
		if((EX_MEM_RegWrite == 1'b1) && (EX_MEM_destReg != 31) && (EX_MEM_destReg == srcReg1)) begin
			ForwardA = 2'b10;
		end
		
		//If MEM_WB Rd = src register 1 --> forward from MEM_WB
		else if((MEM_WB_RegWrite == 1'b1) && (MEM_WB_destReg != 31) && (MEM_WB_destReg == srcReg1)) begin
			ForwardA = 2'b01;
		end else begin
			ForwardA = 2'b00;
		end
		
//		if(EX_Immediate == 1'b1) begin
//			ForwardB = 2'b00;
//		end 
//		//If EX_MEM Rd = src register 2 --> forward from EX_MEM
//		else if((EX_MEM_RegWrite == 1'b1) && (EX_MEM_destReg != 31) && (EX_MEM_destReg == srcReg2)) begin
//			ForwardB = 2'b10;
//		end

		//If EX_MEM Rd = src register 2 --> forward from EX_MEM
		if((EX_MEM_RegWrite == 1'b1) && (EX_MEM_destReg != 31) && (EX_MEM_destReg == srcReg2)) begin
			ForwardB = 2'b10;
		end
		
		//If MEM_WB Rd = src register 2 --> forward from MEM_WB
		else if((MEM_WB_RegWrite == 1'b1) && (MEM_WB_destReg != 31) && (MEM_WB_destReg == srcReg2)) begin
			ForwardB = 2'b01;
		end else begin
			ForwardB = 2'b00;
		end
								
		//If previous instruction in EX sets flags (SUBS or ADDS),
		// and current instruction in RF uses flags (BLT),
		// forward the newest flags from EX to RF
		//bc i passed in one earlier - this is comparing BLT from IF opcode to ADDS from ID opcode
		//anytime a subs or adds occurs previously, then forward the flags in case - they might be used. they might not be used?
		if((MEM_opcode[31:21] == 11'b10101011000) || (MEM_opcode[31:21] == 11'b11101011000)) begin
		//if((EX_opcode[31:24] == 8'b01010100) && ((MEM_opcode[31:21] == 11'b10101011000) || (MEM_opcode[31:21] == 11'b11101011000))) begin
			ForwardFlags = 1'b1;
		end else begin
			ForwardFlags = 1'b0;
		end
		
	
	end
	
endmodule