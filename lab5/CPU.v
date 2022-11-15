`include "library.v"
`include "constants.h"

module CPU(input clock, input reset);

	wire [4:0] wa;
	wire [31:0] rdA, rdB, ALUout, PCout, SIGout, MEMout, InstOut, ALUin2, addr, wd, PCout4;
	wire zero, RegDest, branch, MemRead, MemtoReg, MemWrite, ALUSrc, RegWrite, BrOUT, BneEn, jump;
	wire [1:0] ALUop;
	wire [3:0] func;

	assign PCout4 = PCout + 4;

	assign BrOUT = branch & (BneEn ? ~zero : zero);

	assign SIGout = InstOut[15] ? {16'hFFFF, InstOut[15:0]} : {16'h0000, InstOut[15:0]};

	assign ALUin2 = ALUSrc ? SIGout : rdB;
	assign wd = MemtoReg ? MEMout : ALUout;
	assign addr = jump ? InstOut[25:0] : BrOUT ? SIGout + PCout4 : PCout4;

	assign wa = RegDest ? InstOut[15:11] : InstOut[20:16];

	PC pc (clock, reset, PCout, addr);
	Memory cpu_IMem (1'b1, 1'b1, 1'b0, PCout, 32'h0, InstOut), mem (clock, MemRead, MemWrite, ALUout, rdB, MEMout);

	Ctrl_unit ctr_uni (RegDest, branch, MemRead, MemtoReg, func, MemWrite, ALUSrc, RegWrite, BneEn, jump, InstOut[31:26], InstOut[5:0], reset);

	RegFile cpu_regs (clock, reset, InstOut[25:21], InstOut[20:16], wa, RegWrite, wd, rdA, rdB);

	ALU alu (ALUout, zero, rdA, ALUin2, func);
endmodule
