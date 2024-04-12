global	vector
global	vec_push
global	vec_pop
global	vec_len
global	vec_get
; ############################### Externs ######################################
extern	my_free
extern	my_malloc
extern	my_realloc
; ##############################################################################
;
;		VECTOR STRUCT
;	0x00	data	QWORD	0x08
;	0x08	len		QWORD	0x08
;	0x10	capacity QWORD	0x08
%define	VECTOR_STRUCT_SIZE	3*0x08
%define	VECTOR_DATA			0x00
%define	VECTOR_LEN			0x08
%define	VECTOR_CAP			0x10
; ##############################################################################

section	.text

;------------------------------------------------------------------------------;
;																			   ;
;							#####################							   ;
;							#					#							   ;
;							#	   vector		#							   ;
;							#					#							   ;
;							#####################							   ;
;																			   ;
;	return:																	   ;
;			rax -> ptr to vector struct										   ;
;------------------------------------------------------------------------------;

vector:
	push	rsi
	mov		rdi, VECTOR_STRUCT_SIZE
	call	my_malloc
	mov		rsi, rax
	mov		rdi, 10*0x8
	call	my_malloc
	mov		QWORD [rsi + VECTOR_DATA], rax
	mov		QWORD [rsi + VECTOR_LEN], 0x0
	mov		QWORD [rsi + VECTOR_CAP], 0xa
	mov		rax, rsi
	pop		rsi
	ret

;------------------------------------------------------------------------------;
;																			   ;
;							#####################							   ;
;							#					#							   ;
;							#	   vec_push		#							   ;
;							#					#							   ;
;							#####################							   ;
;																			   ;
;	args:																	   ;
;			rdi -> ptr to vector struct										   ;
;			rsi	-> item to append											   ;
;------------------------------------------------------------------------------;

vec_push:
	push	r8
	push	rax
	mov		r8, QWORD [rdi + VECTOR_LEN]
	cmp		r8, QWORD [rdi + VECTOR_CAP]
	jge		.expand
.continue:
	mov		rax, r8
	mov		r8, 0x8
	mul		r8
	add		rax, QWORD [rdi + VECTOR_DATA]
	mov		QWORD [rax], rsi
	add		QWORD [rdi + VECTOR_LEN], 1
	pop		rax
	pop		r8
	ret
.expand:
	push	rax
	push	rsi
	push	r8
	mov		r8, 0x8
	mov		rax, QWORD [rdi + VECTOR_CAP]
	add		rax, rax
	mov		QWORD [rdi + VECTOR_CAP], rax
	mul		r8
	mov		rsi, QWORD [rdi + VECTOR_DATA]
	push	rdi
	mov		rdi, rax
	call	my_realloc
	pop		rdi
	mov		QWORD [rdi + VECTOR_DATA], rax
	pop		r8
	pop		rsi
	pop		rax
	jmp		.continue
	
;------------------------------------------------------------------------------;
;																			   ;
;							#####################							   ;
;							#					#							   ;
;							#	   vec_pop		#							   ;
;							#					#							   ;
;							#####################							   ;
;																			   ;
;	args:																	   ;
;			rdi -> ptr to vector struct										   ;
;	return:																	   ;
;			rax	-> item value												   ;
;------------------------------------------------------------------------------;

vec_pop:
	push	r8
	cmp		QWORD [rdi + VECTOR_LEN], 0
	je		.done
	sub		QWORD [rdi + VECTOR_LEN], 1
	mov		rax, QWORD [rdi + VECTOR_LEN]
	mov		r8, 0x8
	mul		r8
	add		rax, QWORD [rdi + VECTOR_DATA]
	mov		rax, QWORD [rax]
.done:
	pop		r8
	ret

;------------------------------------------------------------------------------;
;																			   ;
;							#####################							   ;
;							#					#							   ;
;							#	   vec_len		#							   ;
;							#					#							   ;
;							#####################							   ;
;																			   ;
;	args:																	   ;
;			rdi -> ptr to vector struct										   ;
;	return:																	   ;
;			rax	-> len of vec												   ;
;------------------------------------------------------------------------------;

vec_len:
	mov		rax, QWORD [rdi + VECTOR_LEN]
	ret

;------------------------------------------------------------------------------;
;																			   ;
;							#####################							   ;
;							#					#							   ;
;							#	   vec_get		#							   ;
;							#					#							   ;
;							#####################							   ;
;																			   ;
;	args:																	   ;
;			rdi -> ptr to vector struct										   ;
;			rsi	-> item position
;	return:																	   ;
;			rax	-> item value												   ;
;------------------------------------------------------------------------------;

vec_get:
	cmp		rsi, QWORD [rdi + VECTOR_LEN]
	jge		.done
	mov		rax, 0x8
	mul		rsi
	add		rax, QWORD [rdi + VECTOR_DATA]
	mov		rax, QWORD [rax]
.done:
	ret

