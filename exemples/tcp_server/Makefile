as= nasm
FLAG= -felf64 -gdwarf

LD= ld
SRC= main.asm  utils.asm
OBJ= $(SRC:.asm=.o)
EXE= serveur

all: $(OBJ)
	$(LD) $(OBJ) -o $(EXE)

%.o: %.asm
	$(as) $(FLAG) $<

clean:
	$(RM) $(OBJ) $(EXE)
