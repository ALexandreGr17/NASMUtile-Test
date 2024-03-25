global	queue
global	enqueue
global	dequeue
global	destroy_queue
; ############################### Externs ######################################
extern	my_malloc
extern  my_free
; ##############################################################################
;
;	Queue struct
;		0x00	start		0x08
;		0x08	end			0x08
;		0x10	empty		0x01

%define	QUEUE_STRUCT_SIZE	0x08 * 2 + 0x1
%define QUEUE_START			0x00
%define	QUEUE_END			0x08
%define QUEUE_EMPTY			0x10

;	Item struct
;		0x00	next		0x08
;		0x08	value		0x08

%define	ITEM_STRCUT_SIZE	0x08 * 2
%define ITEM_NEXT			0x00
%define	ITEM_VALUE			0x08
; ##############################################################################


;------------------------------------------------------------------------------;
;																			   ;
;							#####################							   ;
;							#					#							   ;
;							#	   Queue		#							   ;
;							#					#							   ;
;							#####################							   ;
;																			   ;
;	return:																	   ;
;			rax -> ptr to a new queue struct								   ;
;------------------------------------------------------------------------------;

queue:
	push	rdi
	mov		rdi, QUEUE_STRUCT_SIZE
	call	my_malloc
	mov		QWORD [rax + QUEUE_START], 0x00
	mov		QWORD [rax + QUEUE_END], 0x00
	mov		BYTE  [rax + QUEUE_EMPTY], 0x01
	pop		rdi
	ret

;------------------------------------------------------------------------------;
;																			   ;
;							#####################							   ;
;							#					#							   ;
;							#	   enqueue		#							   ;
;							#					#							   ;
;							#####################							   ;
;																			   ;
;	args:																	   ;
;			rdi -> ptr to queue struct										   ;
;			rsi	-> item to be enqueue										   ;
;------------------------------------------------------------------------------;

enqueue:
	push	rax
	push	rsi
	push	rdi

	mov		rdi, ITEM_STRCUT_SIZE
	call	my_malloc
	mov		QWORD [rax + ITEM_VALUE], rsi
	mov		QWORD [rax + ITEM_NEXT], 0x0
	pop		rdi

	cmp		BYTE [rdi + QUEUE_EMPTY], 0x1
	je		.empty_queue
	mov		rsi, QWORD [rdi + QUEUE_END]
	mov		QWORD [rsi + ITEM_NEXT], rax
	mov		QWORD [rdi + QUEUE_END], rax
.continue:
	pop		rsi
	pop		rax
	ret
.empty_queue:
	mov		QWORD [rdi + QUEUE_START], rax
	mov		QWORD [rdi + QUEUE_END], rax
	mov		BYTE  [rdi + QUEUE_EMPTY], 0x0
	jmp		.continue

;------------------------------------------------------------------------------;
;																			   ;
;							#####################							   ;
;							#					#							   ;
;							#	   dequeue		#							   ;
;							#					#							   ;
;							#####################							   ;
;																			   ;
;	args:																	   ;
;			rdi -> ptr to queue struct										   ;
;	return:																	   ;
;			rax	-> item dequeued											   ;
;------------------------------------------------------------------------------;

dequeue:
	push	rsi
	push	rdx
	push	rdi

	mov		rsi, QWORD [rdi + QUEUE_START]
	mov		rax, QWORD [rsi + ITEM_VALUE]
	mov		rdx, QWORD [rsi + ITEM_NEXT]
	mov		QWORD [rdi + QUEUE_START], rdx
	mov		rdi, rsi
	call	my_free
	
	pop		rdi
	pop		rdx
	pop		rsi
	ret

;------------------------------------------------------------------------------;
;																			   ;
;							#####################							   ;
;							#					#							   ;
;							#   destroy_queue	#							   ;
;							#					#							   ;
;							#####################							   ;
;																			   ;
;	args:																	   ;
;			rdi -> ptr to queue struct										   ;
;------------------------------------------------------------------------------;

destroy_queue:
	push	rsi
	push	rdi
	mov		rdi, QWORD [rdi + QUEUE_START]
.L1:
	cmp		rdi, 0x0
	je		.done
	mov		rsi, QWORD [rdi + ITEM_NEXT]
	call	my_free
	mov		rdi, rsi
	jmp		.L1
.done:
	pop		rdi
	call	my_free
	pop		rsi
	ret
