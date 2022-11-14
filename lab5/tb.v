`include "constants.h"
`include "CPU.v"

module cpu_tb;
	integer i;
	reg clock, reset;

	CPU cpu0 (clock, reset);

	initial begin
		clock = 1'b0;
		reset = 1'b0;
		#(`clock_period / 2) reset = 1'b1;

		for (i = 0; i < 32; i = i+1)
			cpu0.cpu_regs.data[i] = i;
	end

	always
		#(`clock_period / 2) clock = ~clock;

	initial begin
		$readmemh("/home/christos/sxolh/3sem/Organosi/Labs/Coa-Lab/lab5/123.txt", cpu0.cpu_IMem.data);

		$dumpvars(0, cpu_tb);

		for (i = 0; i < 32; i = i+1)
			$dumpvars(0, cpu0.cpu_regs.data[i]);

		for (i = 0; i < 4096; i = i + 1)
			$dumpvars(0, cpu0.cpu_IMem.data[i]);

	end  // initial

	initial
		#140 $finish;
endmodule
