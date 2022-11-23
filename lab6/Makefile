CC = iverilog
FLAGS = -Wall -Winfloop
EXE = lab6a.out
SRCS = cpu.v #testbench.v

all:
	$(CC) $(FLAGS) -o $(EXE) $(SRCS)
	vvp $(EXE)
#	gtkwave tb_dumpfile.vcd 

clean:
	rm -rf $(EXE)
