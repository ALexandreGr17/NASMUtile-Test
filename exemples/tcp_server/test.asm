global	_start						; entry point

; ################################## imports ###################################
extern	printString
extern	printError
extern	exit
extern	fork
; #############################################################################
section .text

_start:

	call	fork
	cmp		rax, 0
	je		.child
	jl		.error
.parrent:
	mov		rdi, parrent_str
	call	printString
	jmp		.done

.child:
	mov		rdi, child_str
	call	printString
	jmp		.done

.error:
	mov		rdi, erro
	call	printError
	jmp		.done

.done:
	xor		rdi, rdi
	call	exit

section	.data
child_str:	db	"Hello from child", 0xa, 0
parrent_str:	db	"Hello from parent", 0x0a, 0x0
erro:			db	"FRaile", 0x0
