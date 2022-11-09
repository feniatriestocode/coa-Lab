`timescale 1ns/1ps

module ALU (out, zero, inA, inB, op);
	parameter N = 32;
    output signed [N-1:0] out;
	output    zero;
	input signed [N-1:0] inA, inB;
	input [3:0] op;

	reg [N-1:0] out;

	parameter AND = 4'B0000,
			  OR  = 4'B0001,
	          ADD = 4'B0010,
	          SUB = 4'B0110,
			  SLT = 4'B0111,
			  NOR = 4'B1100;

	//Assign out to its corresponding value depending on the
	//operation

	assign zero = (out == 0);

	always @ (*) begin
		case(op)
			AND:
				out = inA & inB;
			OR:
		    	out = inA | inB;
			ADD:
		    	out = inA + inB;
			SUB:
				out = inA + (~inB + 1);
			SLT:
		    	out = (inA + (~inB + 1) >= 0) ? 0 : 1;
			NOR:
		    	out = ~(inA | inB);
			default: out = {N{1'BX}};
		endcase
	end

endmodule

module RegFile (clock, reset, raA, raB, wa, wen, wd, rdA, rdB);
	input clock, reset, wen;
	input [4:0] raA, raB, wa;
	input signed [31:0] wd;
	output signed [31:0] rdA, rdB;
	integer i;
	reg signed [31:0] data[32];

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

