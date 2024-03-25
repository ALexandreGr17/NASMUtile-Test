global	_start
; ################################ Externs ####################################
extern	queue
extern	enqueue
extern	dequeue
extern	destroy_queue
extern	init_malloc
extern	close_malloc
; ##############################################################################
section	.text
_start:
	call	init_malloc
	
	call	queue
	mov		rdi, rax
	
	mov		rsi, 123
	call	enqueue

	mov		rsi, hello
	call	enqueue

	call	dequeue
	call	dequeue

	call	destroy_queue

	call	close_malloc
	xor		rdi, rdi
	mov		rax, 0x3c
	syscall

section	.data
hello:		db		"Hello", 0
