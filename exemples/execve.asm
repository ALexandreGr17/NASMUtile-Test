global	_start
section .text
_start:
	mov		rdi, test_ls
	mov		rsi, 0
	mov		rdx, 0
	mov		rax, 0x3B
	syscall

	mov		rax, 0x3C
	xor		rdi, rdi
	syscall	

section .data
test_ls:	db	"/bin/bc", 0
