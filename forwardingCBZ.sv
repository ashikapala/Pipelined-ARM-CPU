// Ashika Palacharla
// 5/9/2025
// EE469
// Lab 4: pipelined CPU

//Module forwardingUnit

`timescale 1ns/10ps

module forwardingCBZ(ID_opcode, EX_opcode, MEM_opcode,
							EX_MEM_RegWrite,
							MEM_WB_RegWrite, ID_Db, ID_valueCBZ, MEM_ALUOp_Result, EX_ALUOp_Result); 

	//Define input and output ports
	input logic [31:0] ID_opcode, EX_opcode, MEM_opcode;
	output logic [63:0] ID_valueCBZ; //this is the value that will be considered for CBZ, output of the mux after forwarding
	input logic [63:0] ID_Db; //this is the Db (original data being read from Rd/no hazards)
	
	//Source registers and destination registers being compared 
	logic [4:0] srcReg, EX_MEM_destReg, MEM_WB_destReg;
	
	assign srcReg = ID_opcode[4:0];
	assign EX_MEM_destReg = EX_opcode[4:0];
	assign MEM_WB_destReg = MEM_opcode[4:0];
	
	//RegWrite for EX/MEM and MEM/WB stages
	input logic EX_MEM_RegWrite, MEM_WB_RegWrite;
	logic [1:0] ForwardCBZ;
	input logic [63:0] MEM_ALUOp_Result, EX_ALUOp_Result;
	
	genvar i;
	
	//no forwarding is 00 (from ID/EX pipeline reg)
	//EX_MEM forwarding is 10
	//MEM_WB forwarding is 01
	
	always_comb begin
		//If EX_MEM Rd = src register 1 --> forward from EX_MEM
		if((EX_MEM_RegWrite == 1'b1) && (EX_MEM_destReg != 31) && (EX_MEM_destReg == srcReg)) begin
			ForwardCBZ = 2'b10;
		end
		
		//If MEM_WB Rd = src register 1 --> forward from MEM_WB
		else if((MEM_WB_RegWrite == 1'b1) && (MEM_WB_destReg != 31) && (MEM_WB_destReg == srcReg)) begin
			ForwardCBZ = 2'b01;
		end else begin
			ForwardCBZ = 2'b00;
		end
	end
	
	generate
		for(i = 0; i < 64; i++) begin : setmuxCBZ
			mux4_1 muxCBZ_input (.out(ID_valueCBZ[i]), .i00(ID_Db[i]), .i01(MEM_ALUOp_Result[i]), .i10(EX_ALUOp_Result[i]),
										.i11(1'b0), .sel0(ForwardCBZ[0]), .sel1(ForwardCBZ[1])); 
		end
	endgenerate
	
endmodule