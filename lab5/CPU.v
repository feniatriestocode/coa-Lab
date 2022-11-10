// This file contains library modules to be used in your design. 

`include "constants.h"
`timescale 1ns/1ps

module mux_5 (input [4:0] in0, input [4:0] in1, input sel, output [4:0] out);
	out = sel ? in1 : in0;
endmodule

module mux_32 (input [31:0] in0, input [31:0] in1, input sel, output [31:0] out);
	out = sel ? in1 : in0;
endmodule

module sign_ext (input [15:0] in, output [31:0] out);
	if (in[15])
		out = {16'hFFFF, out};
	else
		out = {16'h0000, out};
endmodule

// Small ALU.
//     Inputs: inA, inB, op.
//     Output: out, zero
// Operations: bitwise and (op = 0)
//             bitwise or  (op = 1)
//             addition (op = 2)
//             subtraction (op = 6)
//             slt  (op = 7)
//             nor (op = 12)
module ALU (out, zero, enable, inA, inB, func);
	output signed [31:0] out;
	output zero;
	input enable;
	input signed [31:0] inA, inB;
	input [5:0] func;

	reg [31:0] out;

	assign zero = (out == 0);

	always @ (posedge enable) begin
		case(func)
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
			default: out = {32{1'BX}};
		endcase
	end
endmodule

// Memory (active 1024 words, from 10 address ).
// Read : enable ren, address addr, data dout
// Write: enable wen, address addr, data din.
module Memory (ren, wen, addr, din, dout);
	input ren, wen;
	input [31:0] addr, din;
	output [31:0] dout;

	reg [31:0] data[4095:0];
	wire [31:0] dout;

	always @(ren or wen)   // It does not correspond to hardware. Just for error detection
		if (ren & wen)
			$display ("\nMemory ERROR (time %0d): ren and wen both active!\n", $time);

	always @(posedge ren or posedge wen) begin // It does not correspond to hardware. Just for error detection
		if (addr[31:10] != 0)
			$display("Memory WARNING (time %0d): address msbs are not zero\n", $time);
	end

	assign dout = ((wen==1'b0) && (ren==1'b1)) ? data[addr[9:0]] : 32'bx;

	always @(din or wen or ren or addr) begin
		if ((wen == 1'b1) && (ren==1'b0))
			data[addr[9:0]] = din;
	end
endmodule
// Register File. Input ports: address raA, data rdA
//                            address raB, data rdB
//                Write port: address wa, data wd, enable wen.
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

module PC (clock, reset, out, addr);
	input [31:0] addr;
	input clock, reset;
	output reg [31:0] out;
	integer i;

	always @(posedge clock, negedge reset)
		begin
			if (~reset)
				out = 32'h0;
		end
	always
		out = addr;
endmodule

// Module to control the data path. 
//                          Input: op, func of the inpstruction
//                          Output: all the control signals needed 
module Ctrl_unit (output branch, output MemRead,
output MemtoReg,
output ALUop,
output MemWrite,
output ALUSrc,
output RegWrite, input [5:0] opcode);

	case (opcode)
		R_FORMAT:
			ALUop = 1'b1;
			ALUSrc = 1'b0;
			RegWrite = 1'b1;
			#(2 * `clock_period / 2) RegWrite = 1'b0;
		LW:

		SW:

		BEQ:
			branch = 1'b1;
		BNE:
			branch = 1'b1;
		ADDI:

		NOP:
	endcase
endmodule

module CPU(clock, reset, );

	PC pc();
	Memory cpu_Imem();
	RegFile cpu_regs();
	Ctrl_unit ctr_uni();
	ALU alu();
endmodule
