//  Timing constants
`define clock_period	10

// Opcodes 
`define R_FORMAT	6'b000000
`define LW			6'b100011
`define SW			6'b101011
`define BEQ			6'b000100
`define BNE			6'b000101
`define ADDI		6'b001000
`define NOP			6'b010000
`define AND			6'b100100
`define OR			6'b100101
`define ADD			6'b100000
`define SUB			6'b100010
`define SLT			6'b101010
`define NOR			6'b100111
`define SLL			6'b000000
`define SLLV		6'b000100