`include "control.v"
`include "library.v"
`timescale 1ns/1ps

module cpu(input clock, input reset);
	reg [31:0] PC;
	reg [31:0] IFID_PCplus4;
	reg [31:0] IFID_instr;

	reg [31:0] IDEX_rdA, IDEX_rdB, IDEX_signExtend, IDEX_PCplus4;
	reg [4:0]  IDEX_instr_rt, IDEX_instr_rs, IDEX_instr_rd, IDEX_Shamt;
	reg        IDEX_RegDst, IDEX_ALUSrc;
	reg [1:0]  IDEX_ALUcntrl;
	reg        IDEX_Branch, IDEX_MemRead, IDEX_MemWrite, IDEX_BneEn;
	reg        IDEX_MemToReg, IDEX_RegWrite;

	reg [4:0]  EXMEM_RegWriteAddr, EXMEM_instr_rd;
	reg [31:0] EXMEM_ALUOut, EXMEM_jumpaddr;
	reg        EXMEM_Zero;
	reg [31:0] EXMEM_MemWriteData;
	reg        EXMEM_Branch, EXMEM_MemRead, EXMEM_MemWrite, EXMEM_RegWrite, EXMEM_MemToReg, EXMEM_BneEn;

	reg [31:0] MEMWB_DMemOut;
	reg [4:0]  MEMWB_RegWriteAddr, MEMWB_instr_rd;
	reg [31:0] MEMWB_ALUOut;
	reg        MEMWB_MemToReg, MEMWB_RegWrite;

	wire [31:0] instr, ALUInA, ALUInB, ALUOut, rdA, rdB, signExtend, DMemOut, wRegData, PCIncr, datatowrite;
	wire Zero, RegDst, MemRead, MemWrite, MemToReg, ALUSrc, Branch, BneEn, forwardC, RegWrite, PCEn, IFID_En, NOPEn, PCSrc;
	wire [5:0] opcode, func;
	wire [4:0] instr_rs, instr_rt, instr_rd, RegWriteAddr, shamt;
	wire [3:0] ALUOp;
	wire [1:0] ALUcntrl, forwardA, forwardB;
	wire [15:0] imm;

	/***************** Instruction Fetch Unit (IF) ****************/
	always @(posedge clock or negedge reset)
		begin 
			if (~reset)
				PC = -4;
			else if (PCEn && PCSrc) begin
				PC = EXMEM_jumpaddr; // branch address
			end else if (PCEn) begin
				PC <= PC + 4;
			end
		end

	// IFID pipeline register
	always @(posedge clock or negedge reset)
		begin 
			if (~reset)
				begin
					IFID_PCplus4 <= 32'b0;
					IFID_instr <= 32'h0;
				end
			else if (IFID_En)
				begin
					IFID_PCplus4 <= PC + 32'd4;
					IFID_instr <= instr;
				end
		end

	Memory cpu_IMem(1'b1, 1'b1, 1'b1, 1'b0, PC >> 2, 32'b0, instr);

	/***************** Instruction Decode Unit (ID) ****************/
	assign imm = IFID_instr[15:0];
	assign func = IFID_instr[5:0];
	assign shamt = IFID_instr[10:6];
	assign opcode = IFID_instr[31:26];
	assign instr_rs = IFID_instr[25:21];
	assign instr_rt = IFID_instr[20:16];
	assign instr_rd = IFID_instr[15:11];
	assign signExtend = {{16{imm[15]}}, imm};

	// Register file
	RegFile cpu_regs(clock, reset, instr_rs, instr_rt, MEMWB_RegWriteAddr, MEMWB_RegWrite, wRegData, rdA, rdB);

	// IDEX pipeline register
	always @(posedge clock or negedge reset)
		begin
			if (~reset)
				begin
					IDEX_rdA <= 32'b0;
					IDEX_rdB <= 32'b0;
					IDEX_signExtend <= 32'b0;
					IDEX_instr_rd <= 5'b0;
					IDEX_instr_rs <= 5'b0;
					IDEX_instr_rt <= 5'b0;
					IDEX_RegDst <= 1'b0;
					IDEX_ALUcntrl <= 2'b0;
					IDEX_ALUSrc <= 1'b0;
					IDEX_Branch <= 1'b0;
					IDEX_MemRead <= 1'b0;
					IDEX_MemWrite <= 1'b0;
					IDEX_MemToReg <= 1'b0;
					IDEX_RegWrite <= 1'b0;
					IDEX_BneEn <= 1'b0;
					IDEX_Shamt <= 1'b0;
					IDEX_PCplus4 <= 32'h0;
				end
			else
				begin
					if (~NOPEn)
						begin
							IDEX_ALUcntrl <= 0;
							IDEX_ALUSrc <= 0;
							IDEX_Branch <= 0;
							IDEX_MemRead <= 0;
							IDEX_MemWrite <= 0;
							IDEX_MemToReg <= 0;
							IDEX_RegWrite <= 0;
							IDEX_BneEn <= 0;
						end
					else
						begin
							IDEX_rdA <= rdA;
							IDEX_rdB <= rdB;
							IDEX_signExtend <= signExtend;
							IDEX_instr_rd <= instr_rd;
							IDEX_instr_rs <= instr_rs;
							IDEX_instr_rt <= instr_rt;
							IDEX_RegDst <= RegDst;
							IDEX_ALUcntrl <= ALUcntrl;
							IDEX_ALUSrc <= ALUSrc;
							IDEX_Branch <= Branch;
							IDEX_MemRead <= MemRead;
							IDEX_MemWrite <= MemWrite;
							IDEX_MemToReg <= MemToReg;
							IDEX_BneEn <= BneEn;
							IDEX_RegWrite <= RegWrite;
							IDEX_Shamt <= shamt;
							IDEX_PCplus4 <= IFID_PCplus4;
						end
				end
		end

	// Main Control Unit 
	control_main control_main (RegDst, Branch, MemRead, MemWrite, MemToReg, ALUSrc, RegWrite, BneEn, ALUcntrl, opcode);

	hazard_unit hz_unit (PCEn, IFID_En, NOPEn, IDEX_MemRead, IDEX_instr_rt, instr_rs, instr_rt, instr_rs, instr_rt);

	/***************** Execution Unit (EX) ****************/
	assign ALUInA = (forwardA == 2'b00) ? IDEX_rdA : (forwardA == 2'b01) ? wRegData : EXMEM_ALUOut;
	assign ALUInB = (IDEX_ALUSrc == 1'b1) ? IDEX_signExtend : (forwardB == 2'b00) ? IDEX_rdB : (forwardB == 2'b01) ? wRegData : EXMEM_ALUOut;

	assign jumpaddr = (IDEX_signExtend << 2) + IDEX_PCplus4;

	//  ALU
	ALU cpu_alu(ALUOut, Zero, ALUInA, ALUInB, ALUOp, IDEX_Shamt);

	assign RegWriteAddr = (IDEX_RegDst==1'b0) ? IDEX_instr_rt : IDEX_instr_rd;
	assign PCSrc = EXMEM_Branch && (EXMEM_BneEn ? ~EXMEM_Zero : EXMEM_Zero);

	// EXMEM pipeline register
	always @(posedge clock or negedge reset)
		begin
			if (~reset)
				begin
					EXMEM_Zero <= 1'b0;
					EXMEM_Branch <= 1'b0;
					EXMEM_ALUOut <= 32'b0;
					EXMEM_MemRead <= 1'b0;
					EXMEM_MemWrite <= 1'b0;
					EXMEM_MemToReg <= 1'b0;
					EXMEM_RegWrite <= 1'b0;
					EXMEM_RegWriteAddr <= 5'b0;
					EXMEM_MemWriteData <= 32'b0;
					EXMEM_jumpaddr <=32'h0;
					EXMEM_BneEn <= 1'b0;
				end
			else
				begin
					EXMEM_Zero <= Zero;
					EXMEM_ALUOut <= ALUOut;
					EXMEM_Branch <= IDEX_Branch;
					EXMEM_MemRead <= IDEX_MemRead;
					EXMEM_MemWriteData <= IDEX_rdB;
					EXMEM_MemWrite <= IDEX_MemWrite;
					EXMEM_MemToReg <= IDEX_MemToReg;
					EXMEM_RegWrite <= IDEX_RegWrite;
					EXMEM_RegWriteAddr <= RegWriteAddr;
					EXMEM_jumpaddr <= jumpaddr;
					EXMEM_BneEn <= IDEX_BneEn;
				end
		end

	// ALU control
	control_alu control_alu(ALUOp, IDEX_ALUcntrl, IDEX_signExtend[5:0]);

	forwarding_unit for_unit (forwardA, forwardB, forwardC, IDEX_instr_rs, IDEX_instr_rt, EXMEM_RegWriteAddr, MEMWB_RegWriteAddr, EXMEM_RegWrite, MEMWB_RegWrite, EXMEM_MemWrite);

	/***************** Memory Unit (MEM) ****************/  
	Memory cpu_DMem (clock, reset, EXMEM_MemRead, EXMEM_MemWrite, EXMEM_ALUOut, datatowrite, DMemOut);

	// MEMWB pipeline register
	always @(posedge clock or negedge reset)
		begin
			if (~reset)
				begin
					MEMWB_ALUOut <= 32'b0;
					MEMWB_DMemOut <= 32'b0;
					MEMWB_MemToReg <= 1'b0;
					MEMWB_RegWrite <= 1'b0;
					MEMWB_RegWriteAddr <= 5'b0;
				end
			else
				begin
					MEMWB_DMemOut <= DMemOut;
					MEMWB_ALUOut <= EXMEM_ALUOut;
					MEMWB_MemToReg <= EXMEM_MemToReg;
					MEMWB_RegWrite <= EXMEM_RegWrite;
					MEMWB_RegWriteAddr <= EXMEM_RegWriteAddr;
				end
		end

	/***************** WriteBack Unit (WB) ****************/
	assign wRegData = MEMWB_MemToReg ? MEMWB_DMemOut : MEMWB_ALUOut;
	assign datatowrite = forwardC ? MEMWB_DMemOut : EXMEM_MemWriteData;
endmodule