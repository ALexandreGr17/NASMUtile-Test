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


; ############################### MACRO ########################################

; put_elt:
;   1: ptr to array
;   2: pos
;   3: elt

%macro put_elt 3
    push    %1
    push    %2

    shl     %2, 3
    add     %1, %2
    mov     QWORD [%1], %3

    pop     %1
    pop     %2

%endmacro

; get_elt:
;   1: ptr to array
;   2: pos
;   3: return

%macro get_elt 3
    push    %1
    push    %2

    shl     %2, 3
    add     %1, %2
    mov     %3, QWORD [%1]

    pop     %1
    pop     %2

%endmacro

; ############################### FUNCTION #####################################

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
	mov		QWORD [rdi + HEAP_SIZE], 1
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
    inc     rcx
	cmp		rcx, QWORD [rdi + HEAP_CAP]
	jge		.expand
.continue:
    mov     QWORD [rdi + HEAP_SIZE], rcx
    dec     rcx

    mov     rdi, QWORD [rdi + HEAP_VEC]

    put_elt rdi, rcx, rsi

.L1:
    mov     r8, rcx
    shr     r8, 1

    get_elt rdi, r8, rax

    cmp     rax, rsi
    jge     .done

    put_elt rdi, rcx, rax
    put_elt rdi, r8, rsi

    mov     rcx, r8
    jmp     .L1

.expand:
    push    rdi
    push    rsi

    mov     rsi, QWORD [rdi + HEAP_VEC]
    mov     rdi, QWORD [rdi + HEAP_CAP]
    add     rdi, 10
    call    my_realloc

    pop     rsi
    pop     rdi
    mov     QWORD [rdi + HEAP_VEC], rax
    jmp     .continue


.done:

    pop     rcx
    pop     r8
    pop     rsi
    pop     rdi
    pop     rax
    ret
	
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
    push    rbp
    mov     rbp, rsp
    sub     rsp, 8

	push	rcx
	push	rsi
	push	rbx

    mov     rcx, QWORD [rdi + HEAP_SIZE]
    mov     rdi, QWORD [rdi + HEAP_VEC]

    mov     rsi, 1

    get_elt rdi, rsi, rax
    mov     QWORD [rsp], rax

.L1:
    push    rsi

    shl     rsi, 1
    cmp     rsi, rcx
    jg      .done

    get_elt rdi, rsi, rax
    inc     rsi
    get_elt rdi, rsi, rbx

    cmp     rax, rbx
    jge     .first
    pop     rsi
    put_elt rdi, rsi, rbx
    shl     rsi, 1
    inc     rsi
    jmp     .L1

.first:
    pop     rsi
    put_elt rdi, rsi, rax
    shl     rsi
    jmp     .L1


    
.done:
    mov     rax, QWORD [rsp]
	pop     rbx
    pop     rsi
    pop     rcx

    mov     rsp, rbp
    pop     rbp
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
