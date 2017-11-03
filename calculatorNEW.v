/*
 * ------- PROJECT 1 -----------
 * 
 * Name: 	Cian O'Dwyer
 * ID Number: 	13127381
 * Module: 	ASICs 1 (EE4407)
 * Date: 	28/11/2016
 *
 * 
 * Description: 
 * A basic 4-digit calculator system is modelled to the block diagram, 
 * pin description, functional table and waveform example. 
 * A sequence of up to 4 BCD (Binary Coded Decimal) inputs is entered, 
 * followed by a + or - operation.
 * Another 4 inputs are entered, and the resulting addition or subtraction 
 * of both numbers is displayed on the 4 1/2 signed digital output. *
 */

module calculator(clr, d_in, ent, pls, mns, eq, q0, q1, q2, q3, q4, qmin);

// CLR  - Input 	- Active high reset pulse, to set all output to 0 and reset the system.
 
// D_IN - Input (4 bit) - A 4-bit Binary Coded Decimal number. Valid number is 0 to 9
 
// ENT  - Input 	- An active high of this signal should indicate to the circuit that the 
//			  value at pin Dig_in is valid for calculation
 
// PLS	- Input		- An active high of this signal indicates that the previous inputs from 
//			  Dig_in should be stored at the first valid number (REG_A). The following
//			  (up to 4) inputs to Dig_in (REG_B) should be added to this number

// MNS	- Input		- An active high of this signal indicates that the previous inputs from 
//			  Dig_in should be stored at the first valid number (REG_A). The following
//			  (up to 4) inputs to Dig_in (REG_B) should be subtracted from this number

// EQ	- Input		- An active high of this signal should perform an addition (REG_A+REG_B) or 
//			  subtraction (REG_A-REG_B), and display the result on pins Dig4, Dig3, Dig2, 
//			  Dig1, Dig0 and DigMinus.

// q0	- Output	- The least significiant digit of the result, or the current least significiant 
//			  digit of the current input.

// q1	- Output	- The 2nd least significiant digit of the result, or the current 2nd least 
//			  significiant digit of the current input.

// q2	- Output	- The 3rd most significiant digit of the result, or the current 3rd most 
// 			  significiant digit of the current input.

// q3	- Output	- The 2nd most significiant digit of the result, or the current 2nd most 
// 			  significiant digit of the current input.

// q4	- Output	- The most significant bit of the result (only occurs when BCD output value > 10,000

// qmin - Output	- 1 indicates the result is negative. 0 indicates result is positive.

input clr, ent, pls, mns, eq;
input [3:0] d_in;

output q4, qmin; 
output [3:0] q0, q1, q2, q3;

reg [15:0] REG_A, REG_B, digit_output;
reg bitshiftFlagA, bitshiftFlagB, plusFlag, minusFlag;
reg carryInPls, carryInMns;
reg coutPls, coutMns;
wire [15:0] sumReg, subReg;
wire carryOutPls, carryOutMns;

assign q4 = coutPls;		// 1 bit register (if 1, Result is >10,000)
assign q3 = digit_output[15:12];	// MSB of the result
assign q2 = digit_output[11:8];
assign q1 = digit_output[7:4];
assign q0 = digit_output[3:0];	// LSB of the result
assign qmin = coutMns;		// 1 bit register (if 1, Result is < 0)

bcdAdder_4BCD addition(REG_A, REG_B, carryInPls, carryOutPls, sumReg);
bcdSubtractor subtraction(REG_A, REG_B, carryInMns, carryOutMns, subReg);

initial 
   begin	// Initialise all values to zero to begin with
	REG_A = 0;	// Register which stores the 16 bit input value A
	REG_B = 0;	// Register which stores the 16 bit input value B
	bitshiftFlagA = 0;
	bitshiftFlagB = 0;
	plusFlag = 0;		// If plus flag enabled, RegA is added with RegB
	minusFlag = 0;		// If minus flag enabled, RegB is negated from RegA (or vice versa - see subtractor module)
	carryInPls = 0;
	carryInMns = 0;
	coutPls = 0;
	coutMns = 0;
   end



always@(ent or eq or pls or mns or clr)
begin

   if(ent)	// CASE OF IF 'ENTER' IS ENABLED, if ent=1, 
    begin
	if(d_in > 4'b1001)
 	    begin
		$display("Invalid BCD input");
	    end 
	
	else
	    begin
		if(plusFlag || minusFlag) // plusFlag OR minusFlag means 4 BCD value incoming from REG_B
		   begin
			if(bitshiftFlagB)
			   begin
				//shift REG_B by 4 bits and assign d_in
				REG_B = REG_B << 4;
				digit_output = digit_output << 4;
				REG_B[3:0] = d_in[3:0];
				digit_output[3:0] = d_in[3:0];
			   end 
			else // case where bitshiftFlagB will not be enabled, i.e. 1st BCD value (M.S. BCD) 
			   begin
				REG_B[3:0] = d_in[3:0];
				bitshiftFlagB = 1;
				digit_output[3:0] = d_in[3:0];	
			   end
			$display("REG_B = %b",REG_B);
		   end
		
		else // else case refers to first 4 BCD value (REG_A values)
		   begin
			if(bitshiftFlagA)
			   begin
				//shift REG_A by 4 bits and assign d_in
				REG_A = REG_A << 4;
				digit_output = digit_output << 4;
				REG_A[3:0] = d_in[3:0];
				digit_output[3:0] = d_in[3:0];
			   end
			else 
			   begin
				REG_A[3:0] = d_in[3:0];
				bitshiftFlagA = 1;
				digit_output[3:0] = d_in[3:0];
		   	   end
			$display("REG_A = %b",REG_A);
		   end
	    end
	
     end

  if(pls)	
     begin
	plusFlag = 1;
	digit_output = 0; // cannot output number while + or - flag enabled
	coutPls = carryOutPls;
     end

  if(mns)
     begin
	minusFlag = 1; // cannot output number while + or - flag enabled
	digit_output = 0;
     end

  if(eq)	// CASE OF IF 'EQUALS' IS ENABLED, result outputted dependent on whether plus_flag or minus_flag was enabled
     begin
	if(plusFlag)
	   begin
		digit_output = sumReg; // sumReg = 16bit wire (line68) 
		coutPls = carryOutPls;
		$display("Digit_Output = %b, with a carry of %b", digit_output, carryOutPls);
	   end
 
	else if(minusFlag)
	   begin
		digit_output = subReg; // subReg = 16bit wire (line68) 
		coutMns = carryOutMns;
		$display("Digit_Output = %b, with a carry of %b", digit_output, carryOutMns);
	   end
    end


  if(clr)	// If case of 'CLR' enabled, every value is initialised to zero
     begin
	REG_A = 0;
	REG_B = 0;
	digit_output = 0;
	bitshiftFlagA = 0;
	bitshiftFlagB = 0;
	plusFlag = 0;
	minusFlag = 0;
	carryInPls = 0;
	carryInMns = 0;
     end

end

endmodule

//__________________________________________________________________________________________________________________________
//BCD Adder for 1 four bit number (BCD value). This function will be used for each BCD for both the addition and subtraction

module bcdAdder_1BCD(InA, InB, Cin, Cout, Out);

input [3:0] InA, InB;
input Cin;
output [3:0] Out;
output Cout;

reg [4:0] sum;	// 5 bit register. sum[3:0] = BCD of interest, sum[4] = carry (to be added to the next significant BCD)

assign Cout = sum[4];
assign Out = sum[3:0];

   always @(*)
	begin
		if(InA > 4'b1001 || InB > 4'b1001)
		    begin
			$display("One or more inputs are not valid BCD digits");
		    end
		else
		    begin
			sum = InA + InB + Cin;
			if (sum > 4'b1001)	// If greater than 9, +6 to the result
			    begin
			      sum = InA + InB + Cin + 4'b0110;
			    end
		    end 
  	end
endmodule
//_________________________________________________________________________________________________________________
// Uses the BCD Adder above to calculate the sum of each BCD when the 4 digit BCD InA is added with 4 digit BCD InB 

module bcdAdder_4BCD(InA,InB,Cin,Cout,Sum); // uses the BCD adder module above to calculate each BCD 

	input [15:0] InA, InB;
	input Cin;
	output Cout;
	output [15:0] Sum;
	wire Cout1, Cout2, Cout3;

	bcdAdder_1BCD bcdadd1(InA[3:0], InB[3:0], Cin, Cout1, Sum[3:0]);	// Cin represents carry into the system
	bcdAdder_1BCD bcdadd2(InA[7:4], InB[7:4], Cout1, Cout2, Sum[7:4]);	// Cin for second BCD is Cout of first BCD, and similarly
	bcdAdder_1BCD bcdadd3(InA[11:8], InB[11:8], Cout2, Cout3, Sum[11:8]);   // Cin for third BCD is Cout of second BCD, etc..
	bcdAdder_1BCD bcdadd4(InA[15:12], InB[15:12], Cout3, Cout, Sum[15:12]);
endmodule

// __________________________________________________________________________________

module bcdSubtractor(InA, InB, Cin, Sign, Sum);

input [15:0] InA, InB;	// Both 4 digit BCD inputs
input Cin;		
output Sign;
output [15:0] Sum;

reg [16:0] diff;
reg [15:0] newNum;
reg negFlag; // Gets set if the output number is negative (InB > InA, 9s compliment of InA required)

wire [15:0] Out1, Out2;
wire SignOut;

assign Sign = negFlag;
assign Sum = diff[15:0];

bcdAdder_4BCD bcd_sub1(newNum,InB,Cin,SignOut,Out1);
bcdAdder_4BCD bcd_sub2(newNum,InA,Cin,SignOut,Out2);

initial
 begin		// initialise values to zero.
   negFlag = 0;
   diff = 0;
 end

always@(*)
   begin
	if(InB > InA)
	   begin
		negFlag = 1;
	   end 
	else
  	   begin
		negFlag = 0;
	   end
	

	if(negFlag) // (For case of InB > InA, 9s compliment of InA required. Answer will be -ve)
		begin
		   newNum[15:12] = (4'b1001 - InA[15:12]);
		   newNum[11:8]  = (4'b1001 - InA[11:8]);
		   newNum[7:4]   = (4'b1001 - InA[7:4]);
		   newNum[3:0]   = (4'b1001 - InA[3:0]);
		end
	else	// (Otherwise InA > InB, 9s compliment of InB required. Answer will be +ve)
		begin
		   newNum[15:12] = (4'b1001 - InB[15:12]);
		   newNum[11:8]  = (4'b1001 - InB[11:8]);
		   newNum[7:4]   = (4'b1001 - InB[7:4]);
		   newNum[3:0]   = (4'b1001 - InB[3:0]);
		end


	if(negFlag) // if negative flag is enabled 
		begin
	  	 diff = Out1 + 1;
		end
  	else
		begin
		   diff = Out2 + 1;
		end     

   end

endmodule
