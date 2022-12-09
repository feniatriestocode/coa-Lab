// Define top-level testbench
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Top level has no inputs or outputs
// It only needs to instantiate CPU, Drive the inputs to CPU (clock, reset)
// and monitor the outputs. This is what all testbenches do

`include "constants.h"
`include "cpu.v"
`timescale 1ns/1ps

module cpu_tb;
	integer   f, i, iter;
	reg       clock, reset;    // Clock and reset signals
	wire  [8*26:1] stringvar;

	// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	// Instantiate CPU
	cpu cpu0(clock, reset);
	string_manipulation pipe0(clock, reset, cpu0.PCSrc, cpu0.bubble_idex, cpu0.instr, cpu0.IFID_instr, stringvar);


	// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	// Initialization and signal generation
	initial  
	begin 
		clock = 1'b0;       
		reset = 1'b0;  // Apply reset for a few cycles
		#(4.25*`clock_period) reset = 1'b1;
		#(50*`clock_period) $finish;     // Need to adjust to the number of executed instructions
	end


	// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	// Clock is here
	always 
	#(`clock_period / 2) clock = ~clock;  // Clock generation 


	// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	// Initialize the Instruction Memory with the MIPS executable
	initial begin 
		$readmemh("C:/iverilog/program.hex", cpu0.cpu_IMem.data);
	end


	// initial  
	// begin 
	//  clock = 1'b0;       
	//  reset = 1'b0;  // Apply reset for a few cycles
	//  #(4.25*`clock_period) reset = 1'b1;
	// Initialize Register File with "random" numbers
	//  for (i = 0; i < 32; i = i+1)
	//     cpu0.cpu_regs.data[i] = i;   // Note that R0 = 0 in MIPS 
	// end


	// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	// Gtkwave stuff to dump the signals to the VCD file
	initial begin
	$dumpfile("tb_dumpfile.vcd");
	$dumpvars(0, cpu_tb);

	for(i = 0; i < 32; i = i + 1) begin
		$dumpvars(1, cpu_tb.cpu0.cpu_regs.data[i]);
		$dumpvars(1, cpu_tb.cpu0.cpu_IMem.data[i]);
		$dumpvars(1, cpu_tb.cpu0.cpu_DMem.data[i]);
	end

	end  

	// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	always@(posedge clock) 
		if (cpu0.PC <= 120) $display ("PC: %4d | %s",cpu0.PC, stringvar);

	// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	initial begin
		f = $fopen("output.txt","w");
		iter = 1;
	end


	reg [31:0] PC_prv;

	always@(posedge clock)  // ASSUME that the register file is written at the POSITIVE edge of the clock
	begin

	PC_prv <= cpu0.PC;

	#(`clock_period/10);
	if ((iter==1)&&(PC_prv==44)&&(cpu0.PC==44)) $fwrite(f,"STALL lw --> beq\n");
	if ((iter==1)&&(PC_prv==72)&&(cpu0.PC==72)) $fwrite(f,"STALL lw --> addi\n");
	if ((iter==2)&&(cpu0.PC==24)&&(cpu0.IFID_instr==32'b0)) $fwrite(f,"FLUSH J \n");
	if ((iter==2)&&(PC_prv==44)&&(cpu0.PC==44)) $fwrite(f,"STALL lw --> beq\n");
	if ((iter==2)&& (cpu0.PC==88)) $fwrite(f,"FLUSH BEQ\n");

	if ((iter == 1) && (PC_prv!=cpu0.PC)) begin
		case (cpu0.PC)
			20: begin 
				$fwrite(f,"add $t0, $t0, $s0  : %s\n", (cpu0.cpu_regs.data[8]==24) ?"PASS" : "FAIL");
				$fwrite(f,"sw $ra, 8($t2)     : %s\n", (cpu0.cpu_DMem.data[18]==31)?"PASS" : "FAIL");
			end
			28: $fwrite(f,"lw $t7, 8($t2)     : %s\n", (cpu0.cpu_regs.data[15]==31)?"PASS" : "FAIL");
			32: $fwrite(f,"sub $t1, $t1, $a0  : %s\n", (cpu0.cpu_regs.data[9]==5)  ?"PASS" : "FAIL");
			36: $fwrite(f,"or $t6, $t7, $t5   : %s\n", (cpu0.cpu_regs.data[14]==31)  ?"PASS" : "FAIL");
			40: $fwrite(f,"and $s3, $s0, $s2  : %s\n", (cpu0.cpu_regs.data[19]==16)  ?"PASS" : "FAIL");
			44:  begin 
					$fwrite(f,"lw $t9, 8($t2)     : %s\n", (cpu0.cpu_regs.data[25]==31)?"PASS" : "FAIL");
					$fwrite(f,"sw $gp, 8($t2)     : %s\n", (cpu0.cpu_DMem.data[18]==28)?"PASS" : "FAIL");
				end
			48: $fwrite(f,"sll $s0, $t5, 1    : %s\n", (cpu0.cpu_regs.data[16]==26)  ?"PASS" : "FAIL");
			52: $fwrite(f,"lw $v0, 8($t2)     : %s\n", (cpu0.cpu_regs.data[2]==28)?"PASS" : "FAIL");
			56: $fwrite(f,"beq $v0, $s0, L2   : %s\n", (cpu0.PC==56)?"PASS" : "FAIL");
			64: $fwrite(f,"addi $t5, $t5, 1   : %s\n", (cpu0.cpu_regs.data[13]==14) ?"PASS" : "FAIL");
			68: $fwrite(f,"and $a0, $v0, $t5  : %s\n", (cpu0.cpu_regs.data[4]==12) ?"PASS" : "FAIL");
			72: $fwrite(f,"or $a0, $a0, $t3   : %s\n", (cpu0.cpu_regs.data[4]==15) ?"PASS" : "FAIL");
			76: $fwrite(f,"add $t1, $a0, $v0  : %s\n", (cpu0.cpu_regs.data[9]==43) ?"PASS" : "FAIL");
			80: $fwrite(f,"slt $sp, $a0, $t1  : %s\n", (cpu0.cpu_regs.data[29]==1) ?"PASS" : "FAIL");
			84: $fwrite(f,"lw $v1, 8($t2)     : %s\n", (cpu0.cpu_regs.data[3]==28)?"PASS" : "FAIL");
			88: begin 
				$fwrite(f,"addi $t4, $v1, -1 020  : %s\n", (cpu0.cpu_regs.data[12]==-992) ?"PASS" : "FAIL");
				iter = 2;
				end
		endcase 
		end  // if iter
		else if ((iter == 2) && (PC_prv!=cpu0.PC)) begin
		case (cpu0.PC)
			24: $fwrite(f,"add $t4, $t4, $t4  : %s\n", (cpu0.cpu_regs.data[12]==-1984) ?"PASS" : "FAIL");
			28: $fwrite(f,"sll $s4, $v0, 12   : %s\n", (cpu0.cpu_regs.data[20]==114688) ?"PASS" : "FAIL");
			32: $fwrite(f,"sllv $s6, $s4, $sp : %s\n", (cpu0.cpu_regs.data[22]==229376) ?"PASS" : "FAIL");
			36: $fwrite(f,"j L1               : %s\n", (cpu0.PC==36)?"PASS" : "FAIL");
			44: begin 
					$fwrite(f,"lw $t9, 8($t2)     : %s\n", (cpu0.cpu_regs.data[25]==28)?"PASS" : "FAIL");
					$fwrite(f,"sw $gp, 8($t2)     : %s\n", (cpu0.cpu_DMem.data[18]==28)?"PASS" : "FAIL");
				end
			48: $fwrite(f,"sll $s0, $t5, 1    : %s\n", (cpu0.cpu_regs.data[16]==28)  ?"PASS" : "FAIL");
			52: $fwrite(f,"lw $v0, 8($t2)     : %s\n", (cpu0.cpu_regs.data[2]==28)?"PASS" : "FAIL");
			88: $fwrite(f,"beq $v0, $s0, L2   : %s\n", (cpu0.PC==88)?"PASS" : "FAIL");
			108: $fwrite(f,"add $t5, $t5, $t5 : %s\n", (cpu0.cpu_regs.data[13]==28)  ?"PASS" : "FAIL");
			112: $fwrite(f,"xor $t0, $t0, $t1 : %s\n", (cpu0.cpu_regs.data[8]==51)  ?"PASS" : "FAIL");
			116: $fwrite(f,"addi $t4, $t3, 2 : %s\n", (cpu0.cpu_regs.data[12]==13)  ?"PASS" : "FAIL");
			120: $fwrite(f,"or  $t6, $t5, $t4 : %s\n", (cpu0.cpu_regs.data[14]==29)  ?"PASS" : "FAIL");
			124: $fclose(f);  
		endcase
		end

	//      add $t0, $t0, $s0   # $t0 = $8 = 24 (Decimal)
	//      sw $ra, 8($t2)      # Mem[$t2+8] = Mem[18] = 31
	//      lw $t7, 8($t2)      # $t7 = $15 = Mem[$t2+8] = Mem[18] = 31
	//      sub $t1, $t1, $a0   # $t1 = $9 = 5
	//      or $t6, $t7, $t5    # $t6 = $14 = 31
	//      and $s3, $s0, $s2   # $s3 = $19 = 16
	// L1:
	//      lw $t9, 8($t2)      # (1st iteration): $t9 = $25 = Mem[$t2+8] = 31,  (2nd iteration): $t9 = $25 = Mem[$t2+8] = 28
	//      sw $gp, 8($t2)      # (1st iteration): Mem[$t2+8] = 28, (2nd iteration): Mem[$t2+8] = 28
	//      sll $s0, $t5, 1     # (1st iteration): $s0 = $16 = 26,  (2nd iteration): $s0 = $16 = 28
	//      lw $v0, 8($t2)      # (1st iteration):$v0 = $2 = 28, (2nd iteration): $v0 = $2 = 28 
	//      beq $v0, $s0, L2    # (2nd iteration): $2, $16.   RAW stall, First pass NOT TAKEN, SECOND PASS TAKEN
	//      addi $t5, $t5, 1    # $t5 = $13 = 14
	//      and $a0, $v0, $t5   # $a0 = $4 = 12
	//      or $a0, $a0, $t3    # bypass from MEM. $a0 = $4 = 15
	//      add $t1, $a0, $v0   # bypass from MEM. $t1 = $9 = 43
	//      slt $sp, $a0, $t1   # bypass from MEM. $sp = $29 = 1
	//      lw $v1, 8($t2)      # $v1 = $3 = Mem[$t2+8] = 28
	//      addi $t4, $v1, -1020   # Stall due to lw. $t4 = $12 = -992
	//      add $t4, $t4, $t4      # bypass from MEM. $t4 = $t4 = -1984
	//      sll $s4, $v0, 12       # $s4 = $20 = 114688
	//      sllv $s6, $s4, $sp     # bypass from MEM. $s6 = $22 = 229376
	//      j L1                   # jump only once
	//  L2: 
	//      add $t5, $t5, $t5      # $t5 = $13 = 28
	//      xor $t0, $t0, $t1      # $t0 = $8 = 51
	//      addi $t4, $t3, 2       # $t4 = $12 = 13
	//      or  $t6, $t5, $t4      # $t6 = $14 = 29
end
endmodule


/*    Module used to display the pipeline status in each clock cycle  */

module string_manipulation(clock, reset, PCSrc, bubble, instr0, instr1, stringvar);
input clock, reset;
input PCSrc, bubble;
input [31:0] instr0, instr1;
output reg [8*26:1] stringvar;
wire [39:0] stringvar0,stringvar1,stringvar2,stringvar3,stringvar4;
reg [39:0] s0, s1, s2, s3,s4;
reg [31:0] instr2, instr3, instr4, PC_prv;
reg PCSrc_d0, PCSrc_d1, PCSrc_d2;
reg bubble_d0, bubble_d1, bubble_d2;

always @(posedge clock) {instr2,instr3,instr4} <= {instr1,instr2,instr3};

instr2str instr2str_0(instr0, stringvar0); 
instr2str instr2str_1(instr1, stringvar1); 
instr2str instr2str_2(instr2, stringvar2); 
instr2str instr2str_3(instr3, stringvar3); 
instr2str instr2str_4(instr4, stringvar4); 


always @ (*)
  begin
    s0 = (PCSrc==1)?"----":stringvar0;
    s1 = ((PCSrc==1)||(PCSrc_d0==1))?"----":stringvar1;
    s2 = ((PCSrc==1)||(PCSrc_d0==1)||(PCSrc_d1==1)||(bubble_d0==1))?"----":stringvar2;
    s3 = ((PCSrc_d0==1)||(PCSrc_d1==1)||(PCSrc_d2==1)||(bubble_d1==1))?"----":stringvar3;
    s4 = ((PCSrc_d1==1)||(PCSrc_d2==1)||(bubble_d2==1))?"----":stringvar4;
    stringvar = {s0, s1, s2, s3, s4};
  end


always @(posedge clock or negedge reset) 
   begin
     if (reset == 1'b0) begin
        PCSrc_d0 <= 1'b0;
        PCSrc_d1 <= 1'b0;
        PCSrc_d2 <= 1'b0;
        bubble_d0 <= 1'b0;
        bubble_d1 <= 1'b0;
        bubble_d2 <= 1'b0;
     end
     else begin
        PCSrc_d0 <= PCSrc;
        PCSrc_d1 <= PCSrc_d0;
        PCSrc_d2 <= PCSrc_d1;
        bubble_d0 <= bubble;
        bubble_d1 <= bubble_d0;
        bubble_d2 <= bubble_d1;
     end
end
endmodule

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

module instr2str(instr, stringvar); 
input  [31:0]   instr;
output reg [39:0]  stringvar;

  always@(*)
    if (instr == 32'b0) stringvar = "---";
    else
    case(instr[31:26])
        6'b000000: 
            case (instr[5:0] )
                6'b000000 : stringvar = "SLL";
                6'b000010 : stringvar = "SRL";
                6'b000100 : stringvar = "SLLV";
                6'b000110 : stringvar = "SRLV";
                6'b100000 : stringvar = "ADD";         
                6'b100010 : stringvar = "SUB";
                6'b100100 : stringvar = "AND";
                6'b100101 : stringvar = "OR";
                6'b100110 : stringvar = "XOR";
                6'b100111 : stringvar = "NOR";
               
                6'b101010 : stringvar = "SLT"; 
                default   : stringvar = "----";  
            endcase
      6'b100011: stringvar = "LW";  
      6'b101011: stringvar = "SW";  
      6'b000100: stringvar = "BEQ";  
      6'b000101: stringvar = "BNE";  
      6'b001000: stringvar = "ADDI"; 
      6'b000010: stringvar = "J";
      default  : stringvar = "----";  
      endcase
endmodule


