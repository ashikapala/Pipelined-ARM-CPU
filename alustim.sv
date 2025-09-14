// Ashika Palacharla
// 4/11/2025
// EE469
// Lab 2: 64-bit ALU
// Test bench for ALU
`timescale 1ns/10ps

// Meaning of signals in and out of the ALU:

// Flags:
// negative: whether the result output is negative if interpreted as 2's comp.
// zero: whether the result output was a 64-bit zero.
// overflow: on an add or subtract, whether the computation overflowed if the inputs are interpreted as 2's comp.
// carry_out: on an add or subtract, whether the computation produced a carry-out.

// cntrl			Operation						Notes:
// 000:			result = B						value of overflow and carry_out unimportant
// 010:			result = A + B
// 011:			result = A - B
// 100:			result = bitwise A & B		value of overflow and carry_out unimportant
// 101:			result = bitwise A | B		value of overflow and carry_out unimportant
// 110:			result = bitwise A XOR B	value of overflow and carry_out unimportant

module alustim();

	parameter delay = 100000;

	logic		[63:0]	A, B;
	logic		[2:0]		cntrl;
	logic		[63:0]	result;
	logic					negative, zero, overflow, carry_out ;

	parameter ALU_PASS_B=3'b000, ALU_ADD=3'b010, ALU_SUBTRACT=3'b011, ALU_AND=3'b100, ALU_OR=3'b101, ALU_XOR=3'b110;
	

	alu dut (.A, .B, .cntrl, .result, .negative, .zero, .overflow, .carry_out);

	// Force %t's to print in a nice format.
	initial $timeformat(-9, 2, " ns", 10);

	integer i;
	logic [63:0] test_val;
	initial begin
	
		$display("%t testing PASS_A operations", $time);
		cntrl = ALU_PASS_B; //uses pass B for ALU control, so result should be B
		for (i=0; i<100; i++) begin
			A = $random(); B = $random();
			#(delay);
			assert(result == B && negative == B[63] && zero == (B == '0));
		end
		
		$display("%t testing addition", $time);
		cntrl = ALU_ADD;
		A = 64'h0000000000000001; B = 64'h0000000000000001;
		#(delay);
		assert(result == 64'h0000000000000002
					&& carry_out == 0 && overflow == 0 && negative == 0 && zero == 0);
		
		$display("%t testing overflow addition, adding 1 to max value", $time);
		cntrl = ALU_ADD;
		A = 64'h7FFFFFFFFFFFFFFF; B = 64'h0000000000000001;
		#(delay);
		assert(carry_out == 0 && overflow == 1 && negative == 1 && zero == 0);
		
		$display("%t 12+256 = 268 testing addition", $time);
		cntrl = ALU_ADD;
		A = 64'd12; B = 64'd256;
		#(delay);
		assert(result == 64'd268 &&
					carry_out == 0 && overflow == 0 && negative == 0 && zero == 0);
		
		$display("%t testing 0+0 = 0 addition", $time);
		cntrl = ALU_ADD;
		A = 64'h0000000000000000; B = 64'h0000000000000000;
		#(delay);
		assert(result == 64'h0000000000000000
					&& carry_out == 0 && overflow == 0 && negative == 0 && zero == 1);
				
			
		$display("%t testing 10-8=2 subtraction", $time);
		cntrl = ALU_SUBTRACT;
		A = 64'd10; B = 64'd8;
		#(delay);
		$display("\t\tA: %h, B: %h, Result: %h, Overflow: %b, CarryOut: %b", A, B, result, overflow, carry_out);
		assert(result == (A-B) && negative == result[63] && zero == (A-B == '0));	

		$display("%t testing 100-57 subtraction", $time);
		cntrl = ALU_SUBTRACT;
		A = 64'd100; B = 64'd57;
		#(delay);
		assert(result == (A-B) && negative == result[63] && zero == (A-B == '0));	
					
		//Running multiple loops of the below tests:
		
		//Testing addition with random numbers, 100x
		$display("%t testing addition 50x", $time);
        cntrl = ALU_ADD;
        for (i=0; i<50; i++) begin
            A = $random(); B = $random();
            #(delay);
            assert(result == (A+B) && negative == result[63] && zero == (A+B == '0));
        end
	 
		 //Testing subtraction with random numbers, 100x
		$display("%t testing subtraction 50x", $time);
        cntrl = ALU_SUBTRACT;
        for (i=0; i<50; i++) begin
            A = $random(); B = $random();
            #(delay);
            assert(result == (A-B) && negative == result[63] && zero == (A-B == '0));
        end
		  
		 //Testing AND with random numbers, 100x
		$display("%t testing AND 50x", $time);
        cntrl = ALU_AND;
        for (i=0; i<50; i++) begin
            A = $random(); B = $random();
            #(delay);
            assert(result == (A&B) && negative == result[63] && zero == ((A&B) == '0));
        end
		  
		 //Testing OR with random numbers, 100x
		$display("%t testing AND 50x", $time);
        cntrl = ALU_OR;
        for (i=0; i<50; i++) begin
            A = $random(); B = $random();
            #(delay);
            assert(result == (A|B) && negative == result[63] && zero == ((A|B) == '0));
        end
		  
		 //Testing XOR with random numbers, 100x
		$display("%t testing XOR 50x", $time);
        cntrl = ALU_XOR;
        for (i=0; i<50; i++) begin
            A = $random(); B = $random();
            #(delay);
            assert(result == (A^B) && negative == result[63] && zero == ((A^B) == '0));
        end
		
	end
endmodule
