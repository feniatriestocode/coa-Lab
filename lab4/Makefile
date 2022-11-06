CC=iverilog
SRC=testbench.v
BIN=tb

all: 
	rm -rf $(BIN)
	$(CC) -o tb $(SRC)
	vvp $(BIN)
	gtkwave *.vcd
