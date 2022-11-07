  `timescale 1ns/1ps

// ALU Module. Inputs: inA, inB. Output: out. 
// Operations: bitwise and (op = 0)
//             bitwise or  (op = 1)
//             addition (op = 2)
//             subtraction (op = 6)
//             slt  (op = 7)
//             nor (op = 12)

module ALU (out, zero, inA, inB, op);
  parameter N = 32;
  output    [N-1:0] out;
  output    zero;
  input     [N-1:0] inA, inB;
  input     [3:0] op;

  reg       [N-1:0] out;

parameter AND = 4'B0000,
          OR  = 4'B0001,
          ADD = 4'B0010,
          SUB = 4'B0110,
          SLT = 4'B0111,
          NOR = 4'B1100;

//Assign out to its corresponding value depending on the operation
 always @ (*) begin
  case(op)
    AND:
      out = inA & inB;
    OR:
      out = inA | inB;
    ADD:
      out = inA + inB;
    SUB:
      out = inA + ~(inB);
    SLT:
      out = ((inA < inB) ? 1:0);
    NOR:
      out =  ~(inA | inB);

    default: out = {N{1'BX}};

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
	output reg[31:0] rdA, rdB;

	integer i;
	reg [4:0] data[31:0];

	always @(negedge clock, negedge reset)
		begin
			if (~reset)
				for (i = 0; i < 32; i = i + 1) 
					data[i] = 0;
			else begin
				if (wen)
					data[wa] = wd;
				else
					rdA = data[raA];
					rdB = data[raB];
				end
		end

endmodule
