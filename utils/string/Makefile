ASM=nasm
AFLAGS=-felf64 -gdwarf
SRC=main.asm strings.asm
OBJ=$(SRC:.asm=.o)
EXE=strings


all: $(OBJ)
	ld $(OBJ) -o $(EXE)

%.o: %.asm
	$(ASM) $(AFLAGS) $< -o $@



clean_obj:
	$(RM) $(OBJ)

clean:
	$(RM) $(OBJ) $(EXE) 

