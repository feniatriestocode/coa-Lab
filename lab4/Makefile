CC=iverilog
FLAGS= -Wall -Winfloop -g2005-sv
SRC=testbench.v
BIN=tb

all: 
	rm -rf $(BIN)
	$(CC) $(FLAGS) -o tb $(SRC)
	vvp $(BIN)
	gtkwave *.vcd
