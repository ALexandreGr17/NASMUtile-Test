ASM=nasm
AFLAGS=-gdwarf -felf64
SRC=main.asm utils.asm my_malloc.asm
OBJ_DIR=./obj/
OBJ=$(foreach objfile,$(SRC:.asm=.o),$(OBJ_DIR)$(objfile))
EXE=mymalloc

all: test $(OBJ_DIR) $(OBJ)
	ld $(OBJ) -o $(EXE)

$(OBJ_DIR)%.o: %.asm
	$(ASM) $(AFLAGS) $< -o $@ 

$(OBJ_DIR):
	mkdir -p $(OBJ_DIR)

clean: 
	$(RM) -rf $(OBJ_DIR)
	$(RM) $(EXE)
test: 
	echo $(OBJ)
	echo $(SRC)
