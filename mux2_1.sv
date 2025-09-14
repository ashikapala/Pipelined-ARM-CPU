// Ashika Palacharla
// 4/18/2025
// EE469
// Lab 2: 64-bit ALU

//Module mux2_1, which represents a 2:1 MUX with 2 inputs, 1 output, and 1 sel (select)
`timescale 1ns/10ps

module mux2_1(i0, i1, sel, out); 
	input logic i0, i1;
	input logic sel;
	output logic out;
	
	//MUX formula for out is out = (i1 & sel) | (i0 & ~sel); 
	
	// NOT the sel
	//Store inverted sel in n1
	logic n1;
	not #(0.05) not1 (n1, sel);
	
	//AND the first input and n1
	logic a1;
	and #(0.05) and1 (a1, i0, n1);
	
	//AND the second input and sel
	logic a2;
	and #(0.05) and2 (a2, i1, sel);
	
	//OR the two AND gates, set output to out
	or #(0.05) or1(out, a1, a2);
endmodule 
 
//mux2_1_tb testbench that tests all expected and unexpected behavior
module mux2_1_tb(); 
	logic i0, i1, sel, out;
 
	//Instantiate an instance of mux2_1, called dut
	mux2_1 dut (.*); 
 
	//Begin driving in values to the design
	initial begin 
	sel=0; i0=0; i1=0; #10; 
	sel=0; i0=0; i1=1; #10; 
	sel=0; i0=1; i1=0; #10; 
	 sel=0; i0=1; i1=1; #10; 
	 sel=1; i0=0; i1=0; #10; 
	 sel=1; i0=0; i1=1; #10; 
	 sel=1; i0=1; i1=0; #10; 
	 sel=1; i0=1; i1=1; #10; 
	end 
endmodule