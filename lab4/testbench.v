`timescale 1ns/1ps
`define clock_period 2
`include "library.v"

module cpu_tb;

reg       clock, reset;    // Clock and reset signals
reg   [4:0] raA, raB, wa;
reg         wen;
wire   [31:0] wd;
wire  [31:0] rdA, rdB;
integer i;

reg [3:0] op;
wire f_zero;
// Instantiate regfile module
RegFile regs(clock, reset, raA, raB, wa, wen, wd, rdA, rdB);

// YOU ALSO NEED TO INSTATIATE THE ALU HERE 
ALU alu(wd, f_zero, rdA, rdB, op);


initial begin  // Ta statements apo ayto to begin mexri to "end" einai seiriaka
    $dumpfile("wave.vcd");
	$dumpvars(0, cpu_tb);
  // Initialize the module 
   clock = 1'b0;       
   reset = 1'b0;  // Apply reset for a few cycles
   #(4.25*`clock_period) reset = 1'b1;
   
   // Force initialization of the Register File
   for (i = 0; i < 32; i = i+1)
      regs.data[i] = i;   // Note that always R0 = 0 in MIPS 

  // Now apply some inputs. 
  // You SHOULD EXTEND this part of the code with extra inputs
   wen = 0; raA = 32'h1; raB = 32'h13; op = 4'h2;
#(2*`clock_period)
   wa = 32'h1E; wen = 1;
#(2*`clock_period)
   wen = 0; raA = 32'hA; raB = 32'h4; op = 4'h6; 
#(2*`clock_period)
   wa = 32'hE; wen = 1'b1;
#(2*`clock_period)
   wen = 0;
end 

always @(*) begin
   $display ("raA: %d raB: %d rdA: %d rdB: %d wa: %d wen: %d, value: %d", raA, raB, rdA, rdB, wa, wen, regs.data[wa]);
	end

initial
	#80 $finish;
// Generate clock by inverting the signal every half of clock period
always 
   #(`clock_period / 2) clock = ~clock;  

endmodule
