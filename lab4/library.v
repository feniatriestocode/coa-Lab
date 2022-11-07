  `timescale 1ns/1ps

// ALU Module. Inputs: inA, inB. Output: out. 
// Operations: bitwise and (op = 0)
//             bitwise or  (op = 1)
//             addition (op = 2)
//             subtraction (op = 6)
//             slt  (op = 7)
//             nor (op = 12)
module ALU (out, zero, inA, inB, op);
	parameter	N 		= 32,
				AND		= 4'b0000,
				OR		= 4'b0001,
				ADD		= 4'b0010,
				SUB		= 4'b0110,
				SLT		= 4'b0111,
				NOR		= 4'b1100;

	output reg [N-1:0] out;
	output zero;
	input  [N-1:0] inA, inB;
	input    [3:0] op;

	always @(*)
		begin
			case (op)
				AND:		out = inA & inB;		// bit and
				OR:			out = inA | inB;		// bit or
				ADD: 		out = inA + inB;		// add
				SUB:		out = inA - inB;		// sub
				SLT:		out = (inA < inB)?1:0;	// slt
				NOR:		out = ~(inA | inB);		// nor
				default: 	out = {N{1'bx}};		// no op
			endcase
		end

	assign zero = (out == 0);

endmodule

// Register File Module. Read ports: address raA, data rdA
//                            address raB, data rdB
//                Write port: address wa, data wd, enable wen.
module RegFile (clock, reset, raA, raB, wa, wen, wd, rdA, rdB);
	input clock, reset, wen;
	input [4:0] raA, raB, wa;
	input  [31:0] wd;
	output [31:0] rdA, rdB;

	integer i;
	reg [31:0] data [32];

	assign rdA = data[raA];
	assign rdB = data[raB];

	always @(negedge clock, negedge reset)
		begin
			if (~reset)
				for (i = 0; i < 32; i = i + 1) 
					data[i] = 0;
			else if (wen) begin
				data[wa] = wd;
			end
	end

endmodule
