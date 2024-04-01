global	strlen
global	strcmp
global	strcopy
global	strconcat
global	strsplit

%define TRUE 1
%define FALSE 0

section	.text
;------------------------------------------------------------------------------;
;																			   ;
;							#####################							   ;
;							#					#							   ;
;							#	   strlen		#							   ;
;							#					#							   ;
;							#####################							   ;
;																			   ;
;	args:																	   ;
;			rdi -> string													   ;
;	return:																	   ;
;			rax -> len of string										       ;
;------------------------------------------------------------------------------;

strlen:
	push	rdi
	xor		rax, rax
.L1:
	cmp		BYTE [rdi], 0x00
	je		.done
	inc		rax
	inc		rdi
	jmp		.L1
.done:
	pop		rdi
	ret

;------------------------------------------------------------------------------;
;																			   ;
;							#####################							   ;
;							#					#							   ;
;							#	   strcmp		#							   ;
;							#					#							   ;
;							#####################							   ;
;																			   ;
;	args:																	   ;
;			rdi -> first string												   ;
;			rsi -> second string											   ;
;	return:																	   ;
;			rax -> bool value on egality									   ;
;------------------------------------------------------------------------------;

strcmp:
	push	rdi
	push	rsi
	xor		rax, rax
.L1:
	mov		al, BYTE [rsi]
	cmp		al, 0
	je		.secondDone
	cmp		BYTE [rdi], 0
	je		.firstDone
	cmp		al, BYTE [rdi]
	jne		.differentString
	inc		rsi
	inc		rdi
	jmp		.L1
.firstDone:
	cmp		BYTE [rsi], 0
	je		.sameStrings
	jmp		.differentString
.secondDone:
	cmp		BYTE [rdi], 0
	je		.sameStrings
	jmp		.differentString
.differentString:
	mov		rax, FALSE
	jmp		.done
.sameStrings:
	mov		rax, TRUE
.done:
	pop		rsi
	pop		rdi
	ret

;------------------------------------------------------------------------------;
;																			   ;
;							#####################							   ;
;							#					#							   ;
;							#	   strcopy		#							   ;
;							#					#							   ;
;							#####################							   ;
;																			   ;
;	args:																	   ;
;			rdi -> first string												   ;
;			rsi -> buffer output											   ;
;	return:																	   ;
;			rax -> nb of bytes copied										   ;
;------------------------------------------------------------------------------;

strcopy:
	push	rdi
	push	rsi
	push	rcx
	xor		rcx, rcx
.L1:
	cmp		BYTE [rdi], 0
	je		.done
	mov		al, BYTE [rdi]
	mov		BYTE [rsi], al
	inc		rsi
	inc		rdi
	inc		rcx
	jmp		.L1
.done:
	mov		BYTE [rsi], 0
	mov		rax, rcx
	pop		rcx
	pop		rsi
	pop		rdi
	ret

;------------------------------------------------------------------------------;
;																			   ;
;							#####################							   ;
;							#					#							   ;
;							#	  strconcat		#							   ;
;							#					#							   ;
;							#####################							   ;
;																			   ;
;	args:																	   ;
;			rdi -> first string												   ;
;			rsi	-> second string											   ;
;			rdx -> buffer output											   ;
;------------------------------------------------------------------------------;

strconcat:
	push	rdi
	push	rsi
	push	rdx
	push	rax

	xchg	rsi, rdx
	call	strcopy
	add		rsi, rax
	xchg	rdi, rdx
	call	strcopy

	pop		rax
	pop		rdx
	pop		rsi
	pop		rdi
	ret

;------------------------------------------------------------------------------;
;																			   ;
;							#####################							   ;
;							#					#							   ;
;							#	  strsplit		#							   ;
;							#					#							   ;
;							#####################							   ;
;																			   ;
;	args:																	   ;
;			rdi -> ptr to string											   ;
;			sil	-> char to split on											   ;
;	reutrn:																	   ;
;			rax -> nb of chunk splited										   ;
;------------------------------------------------------------------------------;

strsplit:
	push	rdi
	mov		rax, 1
.L1:
	cmp		BYTE [rdi], 0
	je		.done
	cmp		BYTE [rdi], sil
	je		.spliting
.conitnue:
	inc		rdi
	jmp		.L1
.spliting:
	mov		BYTE [rdi], 0
	inc		rax
	jmp		.conitnue
.done:
	pop		rdi
	ret
