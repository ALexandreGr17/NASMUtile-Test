ASM=nasm
AFLAGS=-gdwarf -felf64
SRC= ./hello.asm ./triangle.asm
OBJ= $(SRC:.asm=.o)
EXE= $(SRC:.asm=E)
SUBDIR= ./tcp_client ./tcp_server
SUBDIR_CLEAN= ./tcp_client ./tcp_server

Exemples: $(OBJ) $(EXE) $(SUBDIR)
	$(RM) $(OBJ)

$(SUBDIR):
	$(MAKE) -C $@

%.o: %.asm
	$(ASM) $(AFLAGS) $< -o $@

%E: %.o
	ld $< -o $(<:.o=)

clean: $(SUBDIR_CLEAN)
	$(RM) $(EXE:E=)
	$(MAKE) clean -C ./tcp_client
	$(MAKE) clean -C ./tcp_server

.PHONY: $(SUBDIR)
