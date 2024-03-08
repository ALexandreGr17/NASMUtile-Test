global	_start
section	.text

_start:						
		mov		rax, 1			; Syscall code for write
		mov		rdi, 1			; file descriptor of stdout
		mov		rsi, message	; message
		mov		rdx, 13			; size of message
		syscall
		mov		rax, 60			; Syscall for exit
		xor		rdi, rdi		; exit status = 0
		syscall

section .data
	message: db		"Hello, World", 10

