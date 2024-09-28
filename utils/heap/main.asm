global	_start
; ############################### Externs ######################################
extern	heap
extern	heap_push
extern	heap_pop
extern	heap_free
extern	close_malloc
extern	init_malloc
; ##############################################################################

_start:
	call	init_malloc

	call	heap
	mov		rdi, rax
	xor		rax, rax

	mov		rsi, 0x10
	mov		rdx, 0
	call	heap_push

	mov		rsi, 0x9
	call	heap_push
	mov		rsi, 0x8
	call	heap_push
	mov		rsi, 0x7
	call	heap_push


	call	heap_free
	
	call	close_malloc
	mov		rdi, 0x0
	mov		rax, 0x3C
	syscall
