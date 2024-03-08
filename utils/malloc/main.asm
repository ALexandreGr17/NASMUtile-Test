global	_start:

; ############################### Externs ######################################
extern	exit
extern	printString
extern	my_malloc
extern	my_free
extern  debug_block
extern	init_malloc
extern	close_malloc
; ##############################################################################

section .text
_start:
		;mov		rdi, tes
		;call	printString
		call	init_malloc

		mov		rdi, 0xa
		call	my_malloc
		mov		QWORD [rax], rax
		mov		rsi, rax
		call	my_malloc
		
		mov		rdi, rsi
		call	my_free

        call    close_malloc
		xor		rdi, rdi
		call	exit

section .data
tes:	db	"Hello", 0x0
