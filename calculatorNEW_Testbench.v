
module calculatorTestbench;

reg Clear, Enter, Plus, Minus, Equals;
reg [3:0] bcdInput;

wire [3:0] Dig0, Dig1, Dig2, Dig3;	// wire = output of testbench
wire Dig4, DigMinus;

calculator calcTest(Clear, bcdInput, Enter, Plus, Minus, Equals, Dig0, Dig1, Dig2, Dig3, Dig4, DigMinus);

   initial
	begin
		Clear = 1;
		#10 bcdInput = 4'b0000;
		#10 bcdInput = 4'b1000;
		#10 bcdInput = 4'b0011;
		#10 bcdInput = 4'b0111;
		#10 Minus = 1;
		#10 bcdInput = 4'b1001;
		#10 bcdInput = 4'b0010;
		#10 bcdInput = 4'b1001;
		#10 bcdInput = 4'b0011;
		#10 Equals = 1;
		#15;
		#5 $display("Output = %b %b %b %b %b, Negative Value? = %b",
	   	   Dig4,Dig3,Dig2,Dig1,Dig0, DigMinus);

	end

endmodule 