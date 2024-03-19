global	_start
;	############################### Externs ####################################
extern	strlen
extern	strcopy
extern	strcmp
extern	strconcat
; ##############################################################################
section	.text

_start:
	mov		rdi, str1
	call	strlen
	
	mov		rsi, str2
	
	call	strcmp

	mov		rsi, buffer
	call	strcopy
	call	strcmp

	mov		rdx, buffer
	mov		rsi, str2
	call	strconcat

	xor		rdi, rdi
	mov		rax, 0x3c
	syscall

section .data
str1:	db	"Hello", 0
str2:	db	" World!", 0
section .bss
buffer:	db	20
