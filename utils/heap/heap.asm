global	heap
global	heap_pop
global	heap_push
global	heap_free
; ############################### Externs ######################################
extern	my_malloc
extern  my_free
extern  my_realloc
extern  init_malloc
; ##############################################################################
; ##############################################################################
;
;		HEAP STRUCT
;	0x00	-> heap vector		QWORD	0x08
;	0x08	-> heap size		QWORD	0x08
;	0x10	-> heap capacity	QWORD	0x08
%define	HEAP_STRUCT_SIZE	0x08 * 3
%define HEAP_VEC			0x00
%define HEAP_SIZE			0x08
%define HEAP_CAP			0x10

;------------------------------------------------------------------------------;
;																			   ;
;							#####################							   ;
;							#					#							   ;
;							#	    heap		#							   ;
;							#					#							   ;
;							#####################							   ;
;																			   ;
;	return:																	   ;
;			rax -> ptr to heap struct										   ;
;------------------------------------------------------------------------------;

heap:
	push	rdi
	
	mov		rdi, HEAP_STRUCT_SIZE
	call	my_malloc
	push	rax

	mov		rdi, 0x10 * 0x08
	call	my_malloc
	pop		rdi
	mov		QWORD [rdi + HEAP_VEC], rax
	mov		QWORD [rdi + HEAP_SIZE], 0
	mov		QWORD [rdi + HEAP_CAP], 0x10 * 0x08
	mov		rax, rdi
	pop		rdi
	ret

;------------------------------------------------------------------------------;
;																			   ;
;							#####################							   ;
;							#					#							   ;
;							#	  heap_push		#							   ;
;							#					#							   ;
;							#####################							   ;
;																			   ;
;	args																	   ;
;			rdi -> ptr to heap struct										   ;
;			rsi -> item to put on the heap									   ;
;			rdx -> ptr to compare func if null normal comparaison will be use  ;
;------------------------------------------------------------------------------;

heap_push:
	push	rax
	push	rdi
	push	rsi
	push	r8
	push	rcx

	mov		rcx, QWORD [rdi + HEAP_SIZE]
	cmp		rcx, QWORD [rdi + HEAP_CAP]
	jge		.expand
.continue:
	mov		rax, QWORD [rdi + HEAP_SIZE]
	mov		r8, 0x8
	mul		r8
	add		rax, QWORD [rdi + HEAP_VEC]
	mov		QWORD [rax], rsi
.L1:
	cmp		rdx, 0
	jne		.new_func
	cmp		rcx, 0
	jle		.done
	mov		r8, QWORD [rax]
	cmp		r8, QWORD [rax - 0x8]
	jge		.done
.swap:
	mov		rdi, QWORD [rax]
	xchg	rdi, QWORD [rax - 0x8]
	mov		QWORD [rax], rdi
	sub		rax, 0x8
	dec		rcx
	jmp		.L1
.done:
	pop		rcx
	pop		r8
	pop		rsi
	pop		rdi
	add		QWORD [rdi + HEAP_SIZE], 1
	pop		rax
	ret
.new_func:
	push	rax
	mov		rdi, QWORD [rax]
	mov		rsi, QWORD [rax - 0x8]
	call	rdx
	cmp		rax, -1
	jne		.done
	pop		rax
	jmp		.swap
.expand:
	push	rdi
	mov		rsi, QWORD [rdi + HEAP_VEC]
	mov		rdi, QWORD [rdi + HEAP_SIZE]
	add		rdi, rdi
	call	my_realloc
	jmp		.continue

;------------------------------------------------------------------------------;
;																			   ;
;							#####################							   ;
;							#					#							   ;
;							#	  heap_pop		#							   ;
;							#					#							   ;
;							#####################							   ;
;																			   ;
;	args																	   ;
;			rdi -> ptr to heap struct										   ;
;	return																	   ;
;			rax -> item at the top of the heap								   ;
;------------------------------------------------------------------------------;

heap_pop:
	push	rcx
	push	rsi
	push	rbx

	mov		rsi, QWORD [rdi + HEAP_VEC]
	mov		rax, QWORD [rsi]
	add		rsi, 0x08
	mov		rcx, 1
.L1:
	cmp		rcx, QWORD [rdi + HEAP_SIZE]
	jge		.done
	mov		rbx, QWORD [rsi]
	mov		QWORD [rsi - 0x8], rbx
	add		rsi, 0x08
	inc		rcx
	jmp		.L1
.done:
	pop		rbx
	pop		rsi
	pop		rcx
	ret

;------------------------------------------------------------------------------;
;																			   ;
;							#####################							   ;
;							#					#							   ;
;							#	  heap_free		#							   ;
;							#					#							   ;
;							#####################							   ;
;																			   ;
;	args:																	   ;
;			rdi -> ptr to heap struct										   ;
;------------------------------------------------------------------------------;

heap_free:
	push	rax
	mov		rax, rdi
	mov		rdi, QWORD [rax + HEAP_VEC]
	call	my_free
	mov		rdi, rax
	call	my_free
	pop		rax
	ret
