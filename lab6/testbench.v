// Define top-level testbench
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Top level has no inputs or outputs
// It only needs to instantiate CPU, Drive the inputs to CPU (clock, reset)
// and monitor the outputs. This is what all testbenches do.


`timescale 1ns/1ps
`define clock_period  10

module cpu_tb;
integer   f, i;
reg       clock, reset;    // Clock and reset signals
wire  [8*26:1] stringvar;


// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Instantiate CPU
cpu cpu0(clock, reset);
string_manipulation pipe0(clock, cpu0.PC, cpu0.instr,cpu0.IFID_instr, stringvar);


// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Initialization and signal generation
initial  
  begin 
   clock = 1'b0;       
   reset = 1'b0;  // Apply reset for a few cycles
   #(4.25*`clock_period) reset = 1'b1;
   #(40*`clock_period) $finish;     // Need to adjust to the number of executed instructions
  end


  // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Clock is here
always 
   #(`clock_period / 2) clock = ~clock;  // Clock generation 


 // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 // Initialize the Instruction Memory with the MIPS executable
initial begin 
  $readmemh("program.hex", cpu0.cpu_IMem.data);
end


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
// Output monitoring and checking  
always@(negedge clock) 
    if (cpu0.PC<200) $display ("PC: %4d | %s",cpu0.PC, stringvar);

initial f = $fopen("output.txt","w");

reg [31:0] PC_prv;

always@(negedge clock) 
 begin
   PC_prv <= cpu0.PC;
   if      ((PC_prv == 40)&&(cpu0.PC==40)) $fwrite(f,"STALL @AND\n");
   else if ((PC_prv == 60)&&(cpu0.PC==60)) $fwrite(f,"STALL @SLL\n");
   else
    #1 case (cpu0.PC)
       16: $fwrite(f,"add $t0, $t0, $s0  : %s\n", (cpu0.cpu_regs.data[8]==24) ?"PASS" : "FAIL");
       20: $fwrite(f,"sw $ra, 4($t2)     : %s\n", (cpu0.cpu_DMem.data[14]==31)?"PASS" : "FAIL");
       24: $fwrite(f,"lw $t5, 4($t2)     : %s\n", (cpu0.cpu_regs.data[13]==31)?"PASS" : "FAIL");
       28: $fwrite(f,"sub $t1, $t1, $a0  : %s\n", (cpu0.cpu_regs.data[9]==5)  ?"PASS" : "FAIL");
       32: $fwrite(f,"or $t6, $t7, $t5   : %s\n", (cpu0.cpu_regs.data[14]==31)  ?"PASS" : "FAIL");
       36: $fwrite(f,"and $s3, $s0, $s2  : %s\n", (cpu0.cpu_regs.data[19]==16)  ?"PASS" : "FAIL");
       40: $fwrite(f,"lw $t6, 4($t2)     : %s\n", (cpu0.cpu_regs.data[14]==31)  ?"PASS" : "FAIL");
       44: $fwrite(f,"sw $gp, 8($t2)     : %s\n", (cpu0.cpu_DMem.data[18]==28)  ?"PASS" : "FAIL");
       48: $fwrite(f,"lw $v0, 8($t2)     : %s\n", (cpu0.cpu_regs.data[2]==28)  ?"PASS" : "FAIL");
       52: $fwrite(f,"and $a0, $v0, $t5  : %s\n", (cpu0.cpu_regs.data[4]==28)  ?"PASS" : "FAIL");
       56: $fwrite(f,"or $a0, $a0, $t0   : %s\n", (cpu0.cpu_regs.data[4]==28)  ?"PASS" : "FAIL");
       60: $fwrite(f,"add $t1, $a0, $v0  : %s\n", (cpu0.cpu_regs.data[9]==56)  ?"PASS" : "FAIL");
       64: $fwrite(f,"slt $sp, $a0, $t1  : %s\n", (cpu0.cpu_regs.data[29]==1)  ?"PASS" : "FAIL");
       68: $fwrite(f,"lw $v0, 8($t2)     : %s\n", (cpu0.cpu_regs.data[2]==28)  ?"PASS" : "FAIL");
       72: $fwrite(f,"sll $s4, $v0, 12   : %s\n", (cpu0.cpu_regs.data[20]==32'h0001c000)  ?"PASS" : "FAIL");
       76: $fwrite(f,"sllv $s6, $s4, $sp : %s\n", (cpu0.cpu_regs.data[22]==32'h00038000)  ?"PASS" : "FAIL");
       80: $fwrite(f,"addi $s6, $s6, -100: %s\n", (cpu0.cpu_regs.data[22]==32'h00037f9c)  ?"PASS" : "FAIL");
       88:   $fclose(f);  
endcase
 // add $t0, $t0, $s0    # $t0 = $8 = 24 (D) 
 // sw $ra, 4($t2)       # Mem[$t2+4] = 31
 // lw $t5, 4($t2)       # $t5 = $13 = 31
 // sub $t1, $t1, $a0    # $t1 = $9 = 5
 // or $t6, $t7, $t5     # $t6 = $14 = 31
 // and $s3, $s0, $s2    # $s3 = $19 = 16
 // lw $t6, 4($t2)       # $t6 = $14 = 31
 // sw $gp, 8($t2)       # Mem[$t2+8] = 28
 // lw $v0, 8($t2)       # $v0 = $2 = 28
 // and $a0, $v0, $t5    # $a0 = $4 = 28, RAW stall
 // or $a0, $a0, $t0     # $a0 = $4 = 28, bypass from ALU
 // add $t1, $a0, $v0    # $t1 = $9 = 56, bypass from ALU 
 // slt $sp, $a0, $t1    # $sp = $29 = 1
 // lw $v0, 8($t2)       # $v0 = $2 = 28
 // sll $s4, $v0, 12     # $s4 = $20 = 0x0001c000, RAW stall
 // sllv $s6, $s4, $sp   # $s6 = $22 = 0x00038000, bypass from ALU
 // addi $s6, $s6, -100  # $s6 = $22 = 0x00037f9c


end
endmodule


// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
module string_manipulation( clock, PC, instr0, instr1, stringvar);
input clock;
input [31:0] PC, instr0, instr1;
output [8*26:1] stringvar;
wire [39:0] stringvar0,stringvar1,stringvar2,stringvar3,stringvar4;
reg [31:0] instr2, instr3, instr4, PC_prv;

always @(posedge clock) {PC_prv,instr2,instr3,instr4} <= {PC,instr1,instr2,instr3};

instr2str instr2str_0(instr0, stringvar0); 
instr2str instr2str_1(instr1, stringvar1); 
instr2str instr2str_2(instr2, stringvar2); 
instr2str instr2str_3(instr3, stringvar3); 
instr2str instr2str_4(instr4, stringvar4); 
assign stringvar = {stringvar0,stringvar1,PC_prv == PC ? "----":stringvar2,stringvar3,stringvar4};
endmodule


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
                6'b100111 : stringvar = "NOR";
                6'b101010 : stringvar = "SLT"; 
                default   : stringvar = "---";  
            endcase
      6'b100011: stringvar = "LW";  
      6'b101011: stringvar = "SW";  
      6'b000100: stringvar = "BEQ";  
      6'b000101: stringvar = "BNE";  
      6'b001000: stringvar = "ADDI"; 
      default  : stringvar = "---";  
      endcase
endmodule 

