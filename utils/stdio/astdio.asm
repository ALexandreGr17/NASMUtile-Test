global	printInt
global	printHex
global	printFloat
global	aprintf
; ############################### Externs ######################################
extern	printString
extern	printError
extern	strlen
extern	STDOUT
extern	STDERR
extern	itoa
extern	htoa
extern	ftoa
; ##############################################################################


;------------------------------------------------------------------------------;
;																			   ;
;							#####################							   ;
;							#					#							   ;
;							#	   printInt		#							   ;
;							#					#							   ;
;							#####################							   ;
;																			   ;
;	args:																	   ;
;			rdi -> nb to convert											   ;
;------------------------------------------------------------------------------;

printInt:
	push	rdi
	push	rsi
	push	rbp
	mov		rbp, rsp
	sub		rsp, 0x1E

	mov		rsi, rsp
	call	itoa
	mov		rdi, rsi
	call	printString

	mov		rsp, rbp
	pop		rbp
	pop		rsi
	pop		rdi
	ret

;------------------------------------------------------------------------------;
;																			   ;
;							#####################							   ;
;							#					#							   ;
;							#	   printHex		#							   ;
;							#					#							   ;
;							#####################							   ;
;																			   ;
;	args:																	   ;
;			rdi -> nb to convert											   ;
;------------------------------------------------------------------------------;

printHex:
	push	rdi
	push	rsi
	push	rbp
	mov		rbp, rsp
	sub		rsp, 0x1E

	mov		rsi, rsp
	call	htoa
	mov		rdi, rsi
	call	printString

	mov		rsp, rbp
	pop		rbp
	pop		rsi
	pop		rdi
	ret

;------------------------------------------------------------------------------;
;																			   ;
;							#####################							   ;
;							#					#							   ;
;							#	 printFloat		#							   ;
;							#					#							   ;
;							#####################							   ;
;																			   ;
;	args:																	   ;
;			xmm0 -> nb to convert											   ;
;------------------------------------------------------------------------------;

printFloat:
	push	rsi
	push	rdi
	push	rbp
	mov		rbp, rsp
	sub		rsp, 0x100
	mov		rsi, rsp
	call	ftoa
	mov		rdi, rsi
	call	printString

	mov		rsp, rbp
	pop		rbp
	pop		rdi
	pop		rsi
	ret

;------------------------------------------------------------------------------;
;																			   ;
;							#####################							   ;
;							#					#							   ;
;							#	   aprintf		#							   ;
;							#					#							   ;
;							#####################							   ;
;																			   ;
;	args:																	   ;
;		rdi	-> string to be formated										   ;
;		rsi	-> vector of value to be inserted								   ;
;------------------------------------------------------------------------------;

aprintf:
	push	rsi
	push	rdi

.L1:
	cmp		BYTE [rdi], 0x0
	je		.done
	cmp		BYTE [rdi], '%'
	je		.format
	inc		rdi
	jmp		.L1

.format:
	cmp		BYTE [rdi + 1], 'i'
	je		.pritnint
	cmp		BYTE [rdi + 1], 's'
	je		.pritnstr
	cmp		BYTE [rdi + 1], 'f'
	je		.printfloat
	cmp		BYTE [rdi + 1], 'h'
	je		.printhex
	cmp		BYTE [rdi + 1], 'c'
	je		.printchar
	jmp		.L1

.pritnint:
	mov		BYTE [rdi], 0
	pop		rdi
	call	printString
	add		rdi, rax
	push	rdi
	mov		edi, DWORD [rsi]
	call	printInt
	add		rsi, 4
	pop		rdi
	add		rdi, 2
	push	rdi
	jmp		.L1

.pritnstr:
	mov		BYTE [rdi], 0
	pop		rdi
	call	printString
	add		rdi, rax
	push	rdi
	mov		rdi, QWORD [rsi]
	call	printString
	add		rsi, 8
	pop		rdi
	add		rdi, 2
	push	rdi
	jmp		.L1

.printfloat:
	mov		BYTE [rdi], 0
	pop		rdi
	call	printString
	add		rdi, rax
	push	rdi
	mov		rax, QWORD [rsi]
	movss	xmm0, [rax]
	call	printFloat
	add		rsi, 8
	pop		rdi
	add		rdi, 2
	push	rdi
	jmp		.L1

.printhex:
	mov		BYTE [rdi], 0
	pop		rdi
	call	printString
	add		rdi, rax
	push	rdi
	mov		edi, DWORD [rsi]
	call	printHex
	add		rsi, 4
	pop		rdi
	add		rdi, 2
	push	rdi
	jmp		.L1

.printchar:
	mov		BYTE [rdi], 0
	pop		rdi
	call	printString
	add		rdi, rax
	push	rdi
	mov		edi, DWORD [rsi]
	call	printInt
	add		rsi, 4
	pop		rdi
	add		rdi, 2
	push	rdi
	jmp		.L1

.done:
	pop		rdi
	call	printString
	pop		rsi
	ret
