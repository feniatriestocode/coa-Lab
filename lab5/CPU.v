`include "constants.h"
`timescale 1ns/1ps

module ALU (out, zero, ALUen, inA, inB, func);
	output signed [31:0] out;
	output zero;
	input ALUen;
	input signed [31:0] inA, inB;
	input [5:0] func;

	reg [31:0] out;

	assign zero = (out == 0);

	always @ (posedge ALUen) begin
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
				out = addr;
		end
endmodule

// Module to control the data path. 
//                          Input: op, func of the inpstruction
//                          Output: all the control signals needed 
module Ctrl_unit (output RegDest, output branch, output MemRead, output MemtoReg, output ALUop, output MemWrite, output ALUSrc, output RegWrite, input [5:0] opcode);

	reg branch, MemRead, MemtoReg, MemWrite, ALUSrc, RegDest, ALUop, RegWrite;

	always @(*) begin
		case (opcode)
			`R_FORMAT:
				begin
					MemRead = 1'b0;
					branch = 1'b0;
					MemtoReg = 1'b0;
					MemWrite = 1'b0;
					ALUSrc = 1'b0;
					RegDest = 1'b1;
					ALUop = 1'b1;
					RegWrite = 1'b1;
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
					ALUop = 1'b1;
					RegWrite = 1'b1;
					#(`clock_period / 2) RegWrite = 1'b0;
				end
			`SW:
				begin
				end
			`BEQ:
				begin
					branch = 1'b1;
				end
			`BNE:
				begin
					branch = 1'b1;
				end
			`ADDI:
				begin
					RegDest = 1'b0;
					branch = 1'b0;
					MemRead = 1'b0;
					MemtoReg = 1'b0;
					MemWrite = 1'b0;
					ALUSrc = 1'b0;
					ALUop = 1'b1;
					RegWrite = 1'b1;
					#(`clock_period / 2) RegWrite = 1'b0;
				end
			`NOP:
				begin
				end
		endcase
	end
endmodule

module CPU(input clock, input reset);

	wire [4:0] raA, raB, wa;
	wire [31:0] rdA, rdB, ALUout, PCout, SIGout, MEMout, InstOut, ALUin2, addr, wd;
	wire zero, ALUop, RegDest, branch, MemRead, MemtoReg, MemWrite, ALUSrc, RegWrite, BrOUT;

	assign PCout4 = PCout + 4;
	assign BrOUT = branch & zero;

	assign SIGout = InstOut[15] ? {16'hFFFF, InstOut} : {16'h0000, InstOut};

	assign ALUin2 = ALUsrc ? SIGout : rdB;
	assign wd = MemtoReg ? MEMout : ALUout;
	assign addr = BrOUT ? (SIGout << 2) + PCout4 : PCout4;

	assign wa = RegDest ? InstOut[15:11] : InstOut[20:15];

	PC pc (clock, reset, PCout, addr);
	Memory cpu_Imem (1'b1, 1'b0, PCout, 32'h0, InstOut);

	Ctrl_unit ctr_uni (RegDest, branch, MemRead, MemtoReg, ALUop, MemWrite, ALUSrc, RegWrite, InstOut[31:26]);

	RegFile cpu_regs (clock, reset, raA, raB, wa, wen, wd, rdA, rdB);

	ALU alu (ALUout, zero, ALUop, rdA, ALUin2, InstOut[5:0]);
endmodule
