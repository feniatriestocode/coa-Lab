CC = iverilog
FLAGS = -Wall -Winfloop
EXE = lab6a.out
SRCS = testbench.v

all:
	$(CC) $(FLAGS) -o $(EXE) $(SRCS)
	vvp $(EXE)
	gtkwave tb_dumpfile.vcd template.gtkw

clean:
	rm -rf $(EXE) *.txt
