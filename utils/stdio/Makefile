ASM=nasm
AFLAGS=-felf64 -gdwarf
SRC=main.asm astdio.asm utils.asm
OBJ=$(SRC:.asm=.o)
EXE=astdio

all: $(OBJ)
	ld $(OBJ) -o $(EXE)

%.o: %.asm
	$(ASM) $(AFLAGS) $< -o $@

clean:
	$(RM) $(OBJ) $(EXE)

