global	_start
; ############################### Externs ######################################
extern	vector
extern	vec_push
extern	vec_pop
extern	vec_get
extern	vec_len
extern	init_malloc
extern	close_malloc
; ##############################################################################
section .text

_start:
	call	init_malloc
	
	call	vector
	mov		rdi, rax
	mov		rsi, 0x0
.L1:
	cmp		rsi, 0x10
	jg		.done
	call	vec_push
	inc		rsi
	jmp		.L1
.done:
	call	vec_len

	mov		rsi, 0x3
	call	vec_get
	
	call	close_malloc
	mov		rax, 0x3C
	xor		rdi, rdi
	syscall
