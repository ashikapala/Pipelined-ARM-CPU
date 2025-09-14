// Ashika Palacharla
// 4/11/2025
// EE469
// Lab 1: 32X64 Register File

//Module decoder3_8, which represents a 3:8 decoder
`timescale 1ns/10ps

module decoder3_8(i0, i1, i2, enable, out); 
	input logic i0, i1, i2;
	input logic enable;
	output logic [7:0] out;
	
	//INVERT the first input
	logic n0;
	not #(0.05) not1 (n0, i0);
	
	//INVERT the second input
	logic n1;
	not #(0.05) not2 (n1, i1);
	
	//INVERT the third input
	logic n2;
	not #(0.05) not3 (n2, i2);
	
	//4 AND gates total, one gate for each decoder output
	and #(0.05) and1 (out[0], n0, n1, n2, enable); //i0=0, i1=0, i2=0
	and #(0.05) and2 (out[1], n0, n1, i2, enable); //i0=0, i1=0, i2=1
	and #(0.05) and3 (out[2], n0, i1, n2, enable); //i0=0, i1=1, i2=0
	and #(0.05) and4 (out[3], n0, i1, i2, enable); //i0=0, i1=1, i2=1
	and #(0.05) and5 (out[4], i0, n1, n2, enable); //i0=1, i1=0, i2=0
	and #(0.05) and6 (out[5], i0, n1, i2, enable); //i0=1, i1=0, i2=1
	and #(0.05) and7 (out[6], i0, i1, n2, enable); //i0=1 i1=1, i2=0
	and #(0.05) and8 (out[7], i0, i1, i2, enable); //i0=1 i1=1, i2=1
	
endmodule 
 
//decoder3_8_tb testbench that tests all expected and unexpected behavior
module decoder3_8_tb(); 
	 logic i0, i1, i2;
	 logic enable;
	 logic [7:0] out;
 
	//Instantiate an instance of decoder3_8, called dut
	decoder3_8 dut (.*); 
 
	//Begin driving in values to the design
	initial begin 
		 for (int e = 0; e < 2; e++) begin
					enable = e;
					for (int a = 0; a < 2; a++) begin
						 i0 = a;
						 
						 for (int b = 0; b < 2; b++) begin
							  i1 = b;
							  for (int c = 0; c < 2; c++) begin
                        i2 = c;
								#10;
								end
						 end
					end
		end
	$stop; //end the simulation
	end 
endmodule