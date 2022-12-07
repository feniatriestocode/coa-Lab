`include "constants.h"
`timescale 1ns/1ps

/************** Main control in ID pipe stage *************/
module control_main(output reg RegDst, output reg Branch, output reg jump, output reg MemRead, output reg MemWrite, output reg MemToReg, output reg ALUSrc, output reg RegWrite, output reg BneEn, output reg [1:0] ALUcntrl, input [5:0] opcode);
	always @(opcode)
		begin
			case (opcode)
				`R_FORMAT:
					begin
						RegDst 		= 1'b1;
						MemRead 	= 1'b0;
						MemWrite 	= 1'b0;
						MemToReg 	= 1'b0;
						ALUSrc 		= 1'b0;
						Branch 		= 1'b0;
						ALUcntrl 	= 2'b10;
						BneEn		= 1'b0;
						RegWrite    = 1'b1;
						jump 		= 1'b0;
					end
				`LW:
					begin
						RegDst 		= 1'b0;
						MemRead 	= 1'b1;
						MemWrite 	= 1'b0;
						MemToReg 	= 1'b1;
						ALUSrc 		= 1'b1;
						Branch 		= 1'b0;
						ALUcntrl 	= 2'b00;
						BneEn		= 1'b0;
						RegWrite    = 1'b1;
						jump 		= 1'b0;
					end
				`SW:
					begin 
						RegDst 		= 1'b0;
						MemRead 	= 1'b0;
						MemWrite 	= 1'b1;
						MemToReg 	= 1'b0;
						ALUSrc 		= 1'b1;
						Branch 		= 1'b0;
						ALUcntrl 	= 2'b00;
						BneEn		= 1'b0;
						RegWrite    = 1'b0;
						jump 		= 1'b0;
					end
				`BEQ:
					begin 
						RegDst 		= 1'b0;
						MemRead 	= 1'b0;
						MemWrite 	= 1'b0;
						MemToReg 	= 1'b0;
						ALUSrc 		= 1'b0;
						Branch 		= 1'b1;
						ALUcntrl 	= 2'b01;
						BneEn		= 1'b0;
						RegWrite    = 1'b0;
						jump 		= 1'b0;
					end
				`BNE:
					begin 
						RegDst 		= 1'b0;
						MemRead 	= 1'b0;
						MemWrite 	= 1'b0;
						MemToReg 	= 1'b0;
						ALUSrc 		= 1'b0;
						Branch 		= 1'b1;
						ALUcntrl 	= 2'b01;
						BneEn		= 1'b1;
						RegWrite    = 1'b0;
						jump 		= 1'b0;
					end
				`ADDI:
					begin 
						RegDst 		= 1'b0;
						MemRead 	= 1'b0;
						MemWrite 	= 1'b0;
						MemToReg 	= 1'b0;
						ALUSrc 		= 1'b1;
						Branch 		= 1'b0;
						ALUcntrl 	= 2'b00;
						BneEn		= 1'b0;
						RegWrite    = 1'b1;
						jump 		= 1'b0;
					end
				`J: begin
						RegDst 		= 1'b0;
						MemRead 	= 1'b0;
						MemWrite 	= 1'b0;
						MemToReg 	= 1'b0;
						ALUSrc 		= 1'b0;
						Branch 		= 1'b0;
						ALUcntrl 	= 2'b00;
						BneEn		= 1'b0;
						RegWrite    = 1'b0;
						jump 		= 1'b1;
					end
				default:
					begin
						RegDst 		= 1'b0;
						MemRead 	= 1'b0;
						MemWrite 	= 1'b0;
						MemToReg 	= 1'b0;
						ALUSrc 		= 1'b0;
						Branch 		= 1'b0;
						ALUcntrl 	= 2'b00;
						BneEn		= 1'b0;
						RegWrite    = 1'b0;
						jump 		= 1'b0;
					end
			endcase
		end
endmodule

/**************** Module for Bypass Detection in EX pipe stage goes here *********/
module forwarding_unit (output [1:0] forwardA, output [1:0] forwardB, output forwardC, input [4:0] IDEX_RegisterRs, input [4:0] IDEX_RegisterRt, input [4:0] EXMEM_RegisterRd, input [4:0] MEMWB_RegisterRd , input EXMEM_RegWrite, input MEMWB_RegWrite, input EXMEM_MemWrite);
		assign forwardA = (EXMEM_RegWrite && (EXMEM_RegisterRd != 0) && (IDEX_RegisterRs == EXMEM_RegisterRd)) ? 2 :
			(MEMWB_RegWrite && (MEMWB_RegisterRd != 0) && (MEMWB_RegisterRd == IDEX_RegisterRs) && ((IDEX_RegisterRs != EXMEM_RegisterRd) || ~EXMEM_RegWrite)) ? 1 : 0;

		assign forwardB = (EXMEM_RegWrite && (EXMEM_RegisterRd != 0) && (IDEX_RegisterRt == EXMEM_RegisterRd)) ? 2 :
			(MEMWB_RegWrite && (MEMWB_RegisterRd != 0) && (MEMWB_RegisterRd == IDEX_RegisterRt) && ((IDEX_RegisterRt != EXMEM_RegisterRd) || ~EXMEM_RegWrite)) ? 1 : 0;

		assign forwardC = (EXMEM_MemWrite && (EXMEM_RegisterRd == MEMWB_RegisterRd)) ? 1 : 0;
endmodule

/**************** Module for Stall Detection in ID pipe stage goes here *********/
module hazard_unit(output PCwrite, output IFID_write, output JumpFlush, output NOPen, input IDEX_MemRead, 
					input [4:0] IDEX_RegisterRt, input [4:0] IFID_RegisterRs, 
					input [4:0] IFID_RegisterRt, input [5:0] opcode);
					
	assign NOPen = (IDEX_MemRead && ((IDEX_RegisterRt == IFID_RegisterRs) || (IFID_RegisterRt == IDEX_RegisterRt))) ? 0 : 1;
	assign JumpFlush = opcode == `J ? 1 : 0;
	assign PCwrite = NOPen;
	assign IFID_write = NOPen;
endmodule
					
/************** control for ALU control in EX pipe stage *************/
module control_alu(output reg [3:0] ALUOp, input [1:0] ALUcntrl, input [5:0] func);
	always @(ALUcntrl or func)
		begin
			case (ALUcntrl)
				2'b10:
					begin
						case (func)
							6'b100000: ALUOp = 4'b0010;// add
							6'b100010: ALUOp = 4'b0110;// sub
							6'b100100: ALUOp = 4'b0000;// and
							6'b100101: ALUOp = 4'b0001;// or
							6'b100111: ALUOp = 4'b1100;// nor
							6'b101010: ALUOp = 4'b0111;// slt
							6'b000000: ALUOp = 4'b1111;// sll
							6'b000100: ALUOp = 4'b1000;// sllv
							6'b100110: ALUOp = 4'b1010;// xor
							default: ALUOp = 4'b0000;
						endcase 
					end
				2'b00:
					ALUOp  = 4'b0010; // add
				2'b01:
					ALUOp = 4'b0110; // sub
				default:
					ALUOp = 4'b0000;
			endcase
		end
endmodule
