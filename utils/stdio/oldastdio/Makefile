AS= nasm
FLAGS= -felf64 -gdwarf

LD= ld

CC= gcc

SRC_TEST= ./test.asm
SRC= ./Astdio.asm ./aprintf.asm
SRC_C= ./ftoa.c

OBJ_TEST= $(SRC_TEST:.asm=.o)
OBJ_C= $(SRC_C:.c=.o)
OBJ= $(SRC:.asm=.o)
EXE= Astdio
LIB_SH= libAstdio.so
LIB_ST= libAstdio.a

test: $(OBJ) $(OBJ_TEST)
	$(LD) $(OBJ) $(OBJ_TEST) -o $(EXE)

shared_lib: $(OBJ) 
	$(CC) -shared -o $(LIB_SH) $(OBJ) 
 
static_lib: $(OBJ) 
	ar -rc $(LIB_ST) $(OBJ) 
	ranlib $(LIB_ST)



%.o:%.asm
	$(AS) $(FLAGS) $< 

%.o:%.c
	$(CC) -c $<

clean:
	$(RM) $(OBJ) $(EXE) $(LIB_ST) $(OBJ_C) $(OBJ_TEST) $(LIB_SH)
