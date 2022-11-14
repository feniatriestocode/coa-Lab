`include "constants.h"
`timescale 1ns/1ps

module ALU (out, zero, inA, inB, func);
	output signed [31:0] out;
	output zero;
	input signed [31:0] inA, inB;
	input [3:0] func;

	reg [31:0] out;

	assign zero = (out == 0);

	always @ (*) begin
		case(func)
			`AND:
				out = inA & inB;
			`OR:
				out = inA | inB;
			`ADD:
				out = inA + inB;
			`SUB:
				out = inA + (~inB + 1);
			`SLT:
				out = (inA + (~inB + 1) >= 0) ? 0 : 1;
			`NOR:
				out = ~(inA | inB);
			default: out = {32{1'BX}};
		endcase
	end
endmodule

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

module RegFile (clock, reset, raA, raB, wa, wen, wd, rdA, rdB);
	input clock, reset, wen;
	input [4:0] raA, raB, wa;
	input signed [31:0] wd;
	output signed [31:0] rdA, rdB;
	integer i;
	reg signed [31:0] data[31:0];

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
			else
				#(`clock_period) out = addr + 1;
		end
endmodule

module Ctrl_unit (output RegDest, output branch, output MemRead, output MemtoReg, output [3:0] ALUctr, output MemWrite, output ALUSrc, output RegWrite, input [5:0] opcode, input [5:0] func, input reset);

	reg branch, MemRead, MemtoReg, MemWrite, ALUSrc, RegDest, RegWrite;
	reg [3:0] ALUctr;
	reg [1:0] ALUop;

	always @(*) begin
		if (~reset)
			begin
				MemRead = 1'b0;
				branch = 1'b0;
				MemtoReg = 1'b0;
				MemWrite = 1'b0;
				ALUSrc = 1'b0;
				RegDest = 1'b0;
				RegWrite = 1'b0;
				ALUop = 2'b00;
			end
		else
			begin
				case (opcode)
					`R_FORMAT:
						begin
							MemRead = 1'bX;
							branch = 1'b0;
							MemtoReg = 1'b0;
							MemWrite = 1'b0;
							ALUSrc = 1'b0;
							RegDest = 1'b1;
							ALUop = 2'b10;
							#(`clock_period / 4)RegWrite = 1'b1;
							#(`clock_period / 2) RegWrite = 1'b0;
						end
					`LW:
						begin
							MemRead = 1'b1;
							branch = 1'b0;
							MemtoReg = 1'b1;
							MemWrite = 1'b0;
							ALUSrc = 1'b1;
							RegDest = 1'b0;
							ALUop = 2'b00;
							#(`clock_period / 4)RegWrite = 1'b1;
							#(`clock_period / 2) RegWrite = 1'b0;
						end
					`SW:
						begin
							MemRead = 1'b0;
							branch = 1'b0;
							MemtoReg = 1'bX;
							MemWrite = 1'b1;
							ALUop = 2'b00;
							ALUSrc = 1'b1;
							RegDest = 1'bX;
							RegWrite = 1'b0;
						end
					`BEQ:
						begin
							branch = 1'b1;
							MemRead = 1'b0;
							MemtoReg = 1'bX;
							MemWrite = 1'b1;
							ALUop = 2'b01;
							ALUSrc = 1'b0;
							RegDest = 1'bX;
							RegWrite = 1'b0;
						end
					`BNE:
						begin
							branch = 1'b1;
							ALUop = 2'b01;
						end
					`ADDI:
						begin
							RegDest = 1'b0;
							branch = 1'b0;
							MemRead = 1'b0;
							MemtoReg = 1'b0;
							MemWrite = 1'b0;
							ALUSrc = 1'b1;
							ALUop = 2'b00;
							#(`clock_period / 4) RegWrite = 1'b1;
							#(`clock_period / 2) RegWrite = 1'b0;
						end
					`NOP:
						begin
						end
				endcase
			end
	end

	always @(*)
		begin
			case (ALUop)
				2'b00: ALUctr = `ADD;
				2'b01: ALUctr = `SUB;
				2'b10:
						case (func[3:0])
							4'b0000: ALUctr = `ADD;
							4'b0010: ALUctr = `SUB;
							4'b0100: ALUctr = `AND;
							4'b0101: ALUctr = `OR;
							4'b1010: ALUctr = `SLT;
						endcase
			endcase
		end
endmodule
