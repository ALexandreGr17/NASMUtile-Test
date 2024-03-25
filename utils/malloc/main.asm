global	_start:

; ############################### Externs ######################################
extern	exit
extern	printString
extern	my_malloc
extern	my_free
extern  debug_block
extern	init_malloc
extern	close_malloc
extern	my_calloc
; ##############################################################################

section .text
_start:
		;mov		rdi, tes
		;call	printString
		call	init_malloc

		mov		rdi, 0x10
		call	my_calloc
		mov		QWORD [rax], rax
		mov		rsi, rax
		call	my_malloc
		

		mov		rdi, 0x10
		call	my_malloc

        call    close_malloc
		xor		rdi, rdi
		call	exit

section .data
tes:	db	"Hello", 0x0
