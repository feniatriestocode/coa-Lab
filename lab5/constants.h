//  Timing constants
`define clock_period    20

// Opcodes 
`define R_FORMAT  6'b0 
`define LW  6'b100011 
`define SW  6'b101011 
`define BEQ  6'b000100 
`define BNE  6'b000101 
`define ADDI 6'b001000
`define NOP  32'b0000_0000_0000_0000_0000_0000_0010_0000
