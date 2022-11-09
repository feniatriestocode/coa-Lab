`timescale 1ns/1ps
`define clock_period 2
`include "library.v"

module cpu_tb;

reg clock, reset;
reg [4:0] raA, raB, wa;
reg wen;
wire signed  [31:0] wd;
wire signed [31:0] rdA, rdB;
integer i;

reg [3:0] op;
wire f_zero;

RegFile regs(clock, reset, raA, raB, wa, wen, wd, rdA, rdB);

ALU alu(wd, f_zero, rdA, rdB, op);

initial begin
	$dumpfile("wave.vcd");
	$dumpvars(0, cpu_tb);

	for (i = 0; i < 32; i = i+1)
		$dumpvars(0, regs.data[i]);

	clock = 1'b0;
	reset = 1'b0;
	#(4.25*`clock_period) reset = 1'b1;

	for (i = 0; i < 32; i = i+1)
		regs.data[i] = i;

   wen = 0; raA = 32'h0; raB = 32'h13; op = 4'h6;
#(2*`clock_period)
   wa = 32'h1E; wen = 1;
#(2*`clock_period)
   wen = 0; raA = 32'h1E; raB = 32'h4; op = 4'h7; 
#(2*`clock_period)
   wa = 32'hE; wen = 1'b1;
#(2*`clock_period)
   wen = 0;
end 

always @(*) begin
   $display ("time: %2d raA: %d raB: %d rdA: %d rdB: %d wa: %d wen: %d, value: %d", $time, raA, raB, rdA, rdB, wa, wen, regs.data[wa]);
	end

initial
	#80 $finish;

always 
   #(`clock_period / 2) clock = ~clock;  

endmodule
