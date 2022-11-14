// Define top-level testbench
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Top level has no inputs or outputs
// It only needs to instantiate CPU, Drive the inputs to CPU (clock, reset)
// and monitor the outputs. This is what all testbenches do

`include "constants.h"
`include "CPU.v"

module cpu_tb;
	integer i;
	reg clock, reset;
	reg [31:0] data [31:0];

	CPU cpu0 (clock, reset);

	initial begin
		clock = 1'b0;
		reset = 1'b0;
		#(4.25*`clock_period) reset = 1'b1;
	end

always
	#(`clock_period / 2) clock = ~clock;

initial
	begin
		for (i = 0; i < 32; i = i+1)
			cpu0.cpu_regs.data[i] = i;

	$readmemh("program.hex", cpu0.cpu_IMem.data);

	$dumpvars;

end  // initial

initial
	#80 $finish;
endmodule
