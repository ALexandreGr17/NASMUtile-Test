global	_start						; entry point

; ################################## imports ###################################
extern	strlen
extern	printString
extern	printError
extern	exit
extern  socket
extern	bind
extern  listen
extern	accept
extern	close
extern	send
extern	recv
; #############################################################################
section .text

_start:
		push	rbp
		mov		rbp, rsp
		sub		rsp, 0x24

		call	socket
		
		cmp		rax, 0x00
		jle		.socket_error

		mov		rdi, rax
		mov		[rsp], rax
		mov		si, 4444
		mov		rdx, rsp
		add		rdx, 4

		call	bind

		cmp		rax, 0x00
		jl		.bind_error

		mov		rsi, 0x05
		call	listen
		cmp		rax, 0x00
		jl		.listen_error	

		mov		rdi, hello_world
		call	printString

		xor		rax, rax
		mov		edi, [rsp]
		mov		rsi, rsp
		add		rsi, 0x14
.L1:	
		call	accept
		cmp		rax, 0
		je		.L1
		jl		.accept_error

		mov		r8, rax

		mov		rdi, new_client
		call	printString

		mov		rdi, r8
		mov		rsi, client_hello
		call	send

		mov		rsi, buffer
.L2:
		call	recv
		cmp		rax, 0x00
		je		.L2
		jl		.recv_error

		mov		rdi, rsi
		call	printString

		mov		rdi, r8
		call	close

		mov		rsp, rbp
		pop		rbp

		xor		rdi, rdi
		call	exit


.socket_error:
		mov		rdi, socket_error_msg
		jmp		.error

.bind_error:
		mov		rdi, bind_error_msg
		jmp		.error

.listen_error:
		mov		rdi, listen_error_msg
		jmp		.error
.accept_error:
		mov		rdi, accept_error_msg
		jmp		.error

.close_error:
		mov		rdi, close_error_msg
		jmp		.error

.recv_error:
		mov		rdi, recv_error_msg
		jmp		.error

.error:
		call	printError
		
		mov		rsp, rbp
		pop		rbp

		mov		rdi, 1
		call	exit



section .data
hello_world:		db	"[SERVER] Server Started on Port 4444", 0xa , 0x00
new_client:			db	"[SERVER] new client", 0x0a, 0x00
socket_error_msg:	db	"Error on Socket Creation", 0xa, 0x00
bind_error_msg:		db  "Error on Bind", 0x0a, 0x00
listen_error_msg:	db  "Error on listen", 0xa, 0x00
accept_error_msg:	db	"Error on accept", 0xa, 0x00
close_error_msg:	db	"Error on close", 0xa, 0x00
recv_error_msg:		db	"Error on recv", 0x0a, 0x00

client_hello:		db	"Hello world", 0xa, 0x00

section	.bss
buffer:				resb	4096
