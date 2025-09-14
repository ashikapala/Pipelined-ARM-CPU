// Ashika Palacharla
// 4/11/2025
// EE469
// Lab 1: 32X64 Register File

// Module regfile is the top-level module for the 32x64 ARM Register File.

// The module instantiates the 5x32 enabled decoder and two large 32x64 to 64 multiplexors.
//
// The module inputs are:
//			- 64-bit WriteData
//			- 1-bit RegWrite, clk
//			- 5-bit ReadRegister1, ReadRegister2, WriteRegister
// The module outputs are:
//			- 64-bit ReadData1, ReadData2
`timescale 1ns/10ps

module regfile (ReadData1, ReadData2, WriteData, ReadRegister1, ReadRegister2,
						WriteRegister, RegWrite, clk, reset);
							
	//Define ports
	input logic [4:0] ReadRegister1, ReadRegister2, WriteRegister;
	input logic [63:0] WriteData;
	input logic RegWrite, clk, reset;
	output logic [63:0] ReadData1, ReadData2;
	
	//Instantiates an instance of the 5x32 decoder,
	// to select which register will be written to based on the
	// WriteRegister 5-bit address
	logic [31:0] selectReg;
	decoder5_32 dec5x32(.WriteRegister(WriteRegister),
							.RegWrite(RegWrite), .selectReg(selectReg));
	
	//Store the register data in an array, of 32 registers each 64-bits width
	logic [31:0][63:0] regDataArray;
	
	//Store each bit of the registers in an array, so 32:1 mux can read from it
	logic [63:0][31:0] bitArray;
	
	//Instantiates 31 registers, labeled from 0-30
	//		WriteData is data in for each register
	//		Store each data out at the index for the register in the regDataArray
	genvar i, j, k, l;
	generate
		for(i = 0; i < 31; i++) begin : allreg
			register64 reg0_30 (.DataIn(WriteData), .WriteEnable(selectReg[i]),
									.DataOut(regDataArray[i]), .clk(clk), .reset(1'b0));
		end
	endgenerate
	
	//Register 31 is hardwired to 0, store data in as 64-bit 0's to regDataArray[31]
	register64 reg31 (.DataIn(64'b0), .WriteEnable(1'b1),
									.DataOut(regDataArray[31]), .clk(clk), .reset(1'b0));
	
	//Convert registersxbits to bitsxregisters
	//Place values from regDataArray into bitArray
	//		- placing LSB from regDataArray to MSB at bitArray
	//		- does mux inputs in reversed bit order
	generate
		for (j = 0; j < 32; j++) begin : loop32j
			for (k = 0; k < 64; k++) begin : loop64k
				assign bitArray[63 - k][j] = regDataArray[j][k];
			end 
		end 
	endgenerate
	
	//Use 32:1 mux to pick one of the 32 registers and output the 64 bits for the register
	// For two of the read registers: register 1 and register 2
	// Fill output of mux from MSB to LSB to ReadData1 and ReadData2
	generate 
		for(l = 0; l < 64; l++) begin : loop64l
			mux32_1 readReg1 (.in(bitArray[l]), .sel(ReadRegister1), .out(ReadData1[63 - l])); 
			mux32_1 readReg2 (.in(bitArray[l]), .sel(ReadRegister2), .out(ReadData2[63 - l])); 
		end 
	endgenerate 
 
endmodule //regfile

module regfile_tb;
	logic clk, RegWrite, reset;
	logic [4:0] ReadRegister1, ReadRegister2, WriteRegister;
	logic [63:0] WriteData;
	logic [63:0] ReadData1, ReadData2;
	
	regfile dut(.*);
	
	//Set up a simulated clock
	parameter ClockDelay = 10;
	initial clk = 0;
	always #(ClockDelay / 2) clk = ~clk;

	initial begin
		RegWrite = 0;
		WriteRegister = 0;
		WriteData = 64'h0;
		ReadRegister1 = 0;
		ReadRegister2 = 0;
		@(posedge clk);
		
		//write to reg 31
		WriteRegister = 5'd31;
		WriteData = 64'hDEADBEEFCAFEBABE;
		RegWrite = 1;
		@(posedge clk);
		RegWrite = 0;
		
		//read 31 on both read registers
		ReadRegister1 = 5'd31;
		ReadRegister2 = 5'd31;
		@(posedge clk);
		
		// Write to reg 0 to 30
		for (int i = 0; i < 31; i++) begin
			WriteRegister = i;
			WriteData = 64'hAAAA000000000000 + i;
			RegWrite = 1;
			@(posedge clk);
			RegWrite = 0;
			@(posedge clk);
		end
		
		//read all registers 
		for (int i = 0; i < 32; i++) begin
			ReadRegister1 = i;
			ReadRegister2 = i;
			@(posedge clk);
		end
		
		$stop; //end the simulation
	end
endmodule
		
	