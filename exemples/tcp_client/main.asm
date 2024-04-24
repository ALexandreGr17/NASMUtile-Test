global	_start		; entry point

; ################################## extern ####################################
extern	exit
extern	printString
extern	printError
extern	str2ip
extern	htons
extern	init_structaddr_in
extern	socket
extern	connect
extern	send
extern	recv
extern	read_stdin
; ##############################################################################

section	.text

_start:
		push	rbp
		mov		rbp, rsp
		sub		rsp, 0x10
		
		mov		rdi, iptest
		call	str2ip
		
		mov		esi, eax
		mov		dx, 4444
		mov		rdi, rsp
		call	init_structaddr_in
		
		call	socket
		mov		r8, rax
		mov		rdi, rax
		mov		rsi, rsp
		call	connect
		mov		rdi, r8
		mov		rsi, buffer
.L1:
		call	recv
		cmp		rax, 0x00
		je		.L1

		mov		rdi, rsi
		call	printString

		mov		rdi, buffer_input
		call	read_stdin
		mov		BYTE [rdi + rax], 0
		call	printString

		mov		rdi, r8

		mov		rsi, buffer_input
		call	send
		
		mov		rsp, rbp
		pop		rbp
		xor		rdi, rdi
		call	exit

section .data
iptest:		db		"127.0.0.1", 0x0
hello:		db		"hello world", 0xa, 0x0

section	.bss
buffer:		resb	4096
buffer_input: resb	4096
