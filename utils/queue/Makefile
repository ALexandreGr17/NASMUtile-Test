ASM=nasm
AFLAGS=-felf64 -gdwarf
SRC=main.asm queue.asm my_malloc.asm
OBJ=$(SRC:.asm=.o)
EXE=queue


all: $(OBJ)
	ld $(OBJ) -o $(EXE)

%.o: %.asm
	$(ASM) $(AFLAGS) $< -o $@



clean_obj:
	$(RM) $(OBJ)

clean:
	$(RM) $(OBJ) $(EXE) 

