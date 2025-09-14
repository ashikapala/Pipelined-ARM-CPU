// Ashika Palacharla
// 4/11/2025
// EE469
// Lab 1: 32X64 Register File

//Module decoder5_32, which represents a 5:32 decoder,
// with a 1-bit RegWrite input, 5-bit WriteRegister input
// and 32-bit selectReg output.

`timescale 1ns/10ps

module decoder5_32(WriteRegister, RegWrite, selectReg); 
	input logic [4:0] WriteRegister;
	input logic RegWrite;
	output logic [31:0] selectReg;
	
	//Input top two bits of WriteRegister into 2:4 decoder
	logic [3:0] selectDec;
	decoder2_4 firstdec (.i0(WriteRegister[4]), .i1(WriteRegister[3]),
					.enable(RegWrite), .out(selectDec));
	//Output will select which 3:8 decoder to use

	//Each output from the 2:4 decoder controls a 3:8 decoder
	//LSB from selectDec maps to the lowest 8 lines, 0-7
	decoder3_8 dec1 (.i0(WriteRegister[2]), .i1(WriteRegister[1]),
							.i2(WriteRegister[0]), .enable(selectDec[0]),
							.out(selectReg[7:0]));
	
	//Second bit from selectDec maps to the 8-15 lines
	decoder3_8 dec2 (.i0(WriteRegister[2]), .i1(WriteRegister[1]),
							.i2(WriteRegister[0]), .enable(selectDec[1]),
							.out(selectReg[15:8]));
	
	//Third bit from selectDec maps to the 16-23 lines
	decoder3_8 dec3 (.i0(WriteRegister[2]), .i1(WriteRegister[1]),
							.i2(WriteRegister[0]), .enable(selectDec[2]),
							.out(selectReg[23:16]));
	
	//MSB bit from selectDec maps to the 24-31 lines
	decoder3_8 dec4 (.i0(WriteRegister[2]), .i1(WriteRegister[1]),
							.i2(WriteRegister[0]), .enable(selectDec[3]),
							.out(selectReg[31:24]));
endmodule 
 
//decoder5_32_tb testbench that tests all expected and unexpected behavior
module decoder5_32_tb(); 
	 logic [4:0] WriteRegister;
    logic RegWrite;
    logic [31:0] selectReg;
 
	//Instantiate an instance of decoder5_32, called dut
	decoder5_32 dut (.*); 
 
	//Begin driving in values to the design
	initial begin 
		for (int e = 0; e < 2; e++) begin
            RegWrite = e;
            for (int i = 0; i < 32; i++) begin
                WriteRegister = i;
                #10;
            end
        end
        $stop;
	$stop; //end the simulation
	end 
endmodule