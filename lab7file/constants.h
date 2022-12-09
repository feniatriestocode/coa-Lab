//  Timing constants
`define clock_period    20
`define clk_to_q_min	0.1
`define clk_to_q_max	0.2
`define setup		0.2
`define hold		0.1
//
`define alu_delay	1.5
`define mux2_delay	0.2
`define mux4_delay	0.3
`define mux8_delay      0.4
`define nor32_delay     0.3
//
`define mem_data_delay  1.5
`define mem_addr_delay  0.5
`define rf_data_delay   0.7
`define rf_addr_delay   0.5

// Opcodes 
// R-format, FUNC
`define R_FORMAT  6'b0
`define SLL 6'b000000
`define SRL 6'b000010
`define SLLV 6'b000100
`define SRLV 6'b000110
`define ADD 6'b100000            
`define SUB 6'b100010
`define AND 6'b100100
`define OR  6'b100101
`define NOR 6'b100111
`define XOR 6'b100110
`define SLT 6'b101010

// I-format, OPCODE
`define ADDI 6'b001000
`define LW  6'b100011 
`define SW  6'b101011 
`define BEQ  6'b000100 
`define BNE  6'b000101
`define J    6'b000010
`define NOP  6'b0000_0000_0000_0000_0000_0000_0000_0000