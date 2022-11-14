`include "library.v"
`include "constants.h"

module CPU(input clock, input reset);

	wire [4:0] raA, raB, wa;
	wire [31:0] rdA, rdB, ALUout, PCout, SIGout, MEMout, InstOut, ALUin2, addr, wd;
	wire zero, RegDest, branch, MemRead, MemtoReg, MemWrite, ALUSrc, RegWrite, BrOUT;
	wire [1:0] ALUop;
	wire [3:0] func;

	assign PCout4 = PCout + 4;
	assign BrOUT = branch & zero;

	assign SIGout = InstOut[15] ? {16'hFFFF, InstOut} : {16'h0000, InstOut};

	assign ALUin2 = ALUSrc ? SIGout : rdB;
	assign wd = MemtoReg ? MEMout : ALUout;
	assign addr = BrOUT ? (SIGout << 2) + PCout4 : PCout4;

	assign wa = RegDest ? InstOut[15:11] : InstOut[20:15];

	PC pc (clock, reset, PCout, addr);
	Memory cpu_IMem (1'b1, 1'b0, PCout, 32'h0, InstOut), mem (MemRead, MemWrite, ALUout, rdB, MEMout);

	Ctrl_unit ctr_uni (RegDest, branch, MemRead, MemtoReg, func, MemWrite, ALUSrc, RegWrite, InstOut[31:26], InstOut[5:0]);

	RegFile cpu_regs (clock, reset, raA, raB, wa, wen, wd, rdA, rdB);

	ALU alu (ALUout, zero, rdA, ALUin2, func);
endmodule
