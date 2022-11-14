//  Timing constants
`define clock_period	20

// Opcodes 
`define R_FORMAT	6'b000000
`define LW			6'b100011
`define SW			6'b101011
`define BEQ			6'b000100
`define BNE			6'b000101
`define ADDI		6'b001000
`define NOP			6'b010000
`define AND			4'b0000
`define OR			4'b0001
`define ADD			4'b0010
`define SUB			4'b0110
`define SLT			4'b0111
`define NOR			4'b1100