`include "library.v"
`include "constants.h"

module CPU(input clock, input reset);

	wire [4:0] wa;
	wire [31:0] rdA, rdB, ALUout, SIGout, MEMout, InstOut, ALUin2, wd;
	wire zero, RegDest, branch, MemRead, MemtoReg, MemWrite, ALUSrc, RegWrite, BrOUT, BneEn;
	wire [1:0] ALUop;
	wire [3:0] func;
	reg [31:0] PCout;

	// PC.
	always @(posedge clock, negedge reset)
		begin
			if (~reset)
				PCout = -4;
			else if (BrOUT) begin
 				PCout = (SIGout << 2) + PCout + 4;
			end else
				PCout = PCout + 4;
		end

	// Branch signal for multiplexer.
	assign BrOUT = branch & (BneEn ? ~zero : zero);

	// Sign extension.
	assign SIGout = InstOut[15] ? {16'hFFFF, InstOut[15:0]} : {16'h0000, InstOut[15:0]};

	// Choosing Source for ALU input.
	assign ALUin2 = ALUSrc ? SIGout : rdB;

	// Which data we would like to right to a register
	assign wd = MemtoReg ? MEMout : ALUout;

	// Determine either there is a third register for result storage or not.
	assign wa = RegDest ? InstOut[15:11] : InstOut[20:16];

	Memory cpu_IMem (1'b1, 1'b1, 1'b0, PCout >> 2, 32'h0, InstOut), cpu_DMem (clock, MemRead, MemWrite, ALUout, rdB, MEMout);

	Ctrl_unit ctr_uni (RegDest, branch, MemRead, MemtoReg, func, MemWrite, ALUSrc, RegWrite, BneEn, InstOut[31:26], InstOut[5:0]);

	RegFile cpu_regs (clock, reset, InstOut[25:21], InstOut[20:16], wa, RegWrite, wd, rdA, rdB);

	ALU alu (ALUout, zero, rdA, ALUin2, func);
endmodule
