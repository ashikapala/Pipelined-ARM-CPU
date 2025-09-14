// Ashika Palacharla
// 4/11/2025
// EE469
// Lab 1: 32X64 Register File

//Module decoder2_4, which represents a 2:4 decoder
`timescale 1ns/10ps

module decoder2_4(i0, i1, enable, out); 
	input logic i0, i1;
	input logic enable;
	output logic [3:0] out;
	
	//INVERT the first input
	logic n0;
	not #(0.05) not1 (n0, i0);
	
	//INVERT the second input
	logic n1;
	not #(0.05) not2 (n1, i1);
	
	//4 AND gates total, one gate for each decoder output
	and #(0.05) and1 (out[0], n0, n1, enable); //i0=0, i1=0
	and #(0.05) and2 (out[1], n0, i1, enable); //i0=0, i1=1
	and #(0.05) and3 (out[2], i0, n1, enable); //i0=1, i1=0
	and #(0.05) and4 (out[3], i0, i1, enable); //i0=1, i1=1
	
endmodule 
 
//decoder2_4_tb testbench that tests all expected and unexpected behavior
module decoder2_4_tb(); 
	 logic i0, i1;
	 logic enable;
	 logic [3:0] out;
 
	//Instantiate an instance of decoder2_4, called dut
	decoder2_4 dut (.*); 
 
	//Begin driving in values to the design
	initial begin 
		 for (int e = 0; e < 2; e++) begin
					enable = e;
					for (int a = 0; a < 2; a++) begin
						 i0 = a;
						 
						 for (int b = 0; b < 2; b++) begin
							  i1 = b;
							  #10;
						 end
					end
		end
	$stop; //end the simulation
	end 
endmodule