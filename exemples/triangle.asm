global	_start
section	.text

_start:
		mov		rdx, output
		mov		r8, 1
		mov		r9, 0
line:
		mov		byte [rdx], '*'
		inc		rdx
		inc		r9
		cmp		r9, r8
		jne		line
lineDone:
		mov		byte [rdx], 0x0A
		inc		r8
		inc		rdx
		xor		r9, r9
		cmp		r8, maxLines
		jle		line
done:
		mov		byte [rdx], 0x00
		mov		rax, 1
		mov		rdi, 1
		mov		rsi, output
		mov		rdx, dataSize
		syscall
		mov		rax, 60
		xor		rdi, rdi
		syscall

section .bss
maxLines equ	8
dataSize equ	65
output:	 resb	dataSize

