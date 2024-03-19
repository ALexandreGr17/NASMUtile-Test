DEFAULT REL
global	exit
global	strlen
global	printError
global	printString
global	itoa
global	htoa
global	ftoa

global	WRITE
global	STDOUT
; ##############################################################################
%define	EXIT	0x3C
%define	WRITE	0x01

%define STDOUT  0x01
%define STDERR  0x02
; ##############################################################################

section	.text
;------------------------------------------------------------------------------;
;																			   ;
;							#####################							   ;
;							#					#							   ;
;							#		exit		#							   ;
;							#					#							   ;
;							#####################							   ;
;																			   ;
;	args:																	   ;
;			rdi -> exit code												   ;
;------------------------------------------------------------------------------;
exit:
			mov		rax, EXIT
			syscall


;------------------------------------------------------------------------------;
;																			   ;
;							#####################							   ;
;							#					#							   ;
;							#		strlen		#							   ;
;							#					#							   ;
;							#####################							   ;
;																			   ;
;	args:																	   ;
;			rdi -> ptr to str												   ;
;	return:																	   ;
;			rax -> len of str												   ;
;------------------------------------------------------------------------------;

strlen:
			push	rdi
			xor		rax, rax
.L1:
			cmp		byte [rdi], 0
			je		.done
			inc		rdi
			inc		rax
			jmp		.L1
.done:
			pop		rdi
			ret

;------------------------------------------------------------------------------;
;																			   ;
;							#####################							   ;
;							#					#							   ;
;							#	printString		#							   ;
;							#					#							   ;
;							#####################							   ;
;																			   ;
;	args:																	   ;
;			rdi -> ptr to str												   ;
;	return																	   ;
;			rax	-> size printed
;------------------------------------------------------------------------------;

printString:
			push	rdx
			push	rsi
			push	rdi

			call	strlen
			mov		rdx, rax
			mov		rsi, rdi
			mov		rdi, STDOUT
			mov		rax, WRITE
			syscall

			mov		rax, rdx
			pop		rdi
			pop		rsi
			pop		rdx
			ret

;------------------------------------------------------------------------------;
;																			   ;
;							#####################							   ;
;							#					#							   ;
;							#	  printError	#							   ;
;							#					#							   ;
;							#####################							   ;
;																			   ;
;	args:																	   ;
;			rdi -> ptr to error str											   ;
;------------------------------------------------------------------------------;

printError:
			push	rdx
			push	rax
			push	rsi
			push	rdi

			call	strlen
			mov		rdx, rax
			mov		rsi, rdi
			mov		rdi, STDERR
			mov		rax, WRITE
			syscall

			pop		rdi
			pop		rsi
			pop		rax
			pop		rdx
	
			ret

;------------------------------------------------------------------------------;
;																			   ;
;							#####################							   ;
;							#					#							   ;
;							#	     itoa		#							   ;
;							#					#							   ;
;							#####################							   ;
;																			   ;
;	args:																	   ;
;			rdi -> nb to convert											   ;
;			rsi -> buffer output											   ;
;	return																       ;
;			rax -> nb of chars												   ;
;------------------------------------------------------------------------------;

itoa:

			push	rdi
			push	rsi
			push	rcx
			push	rdx 

			mov		rax, rdi
			mov		rdi, 0xa
			xor		rcx, rcx
.L1:
			xor		rdx, rdx
			inc		rcx
			div		rdi
			add		rdx, '0'
			mov		BYTE [rsi], dl
			inc		rsi
			cmp		rax, 0x0
			jne		.L1

			push	rsi
			mov		rdi, rsi
			sub		rdi, rcx
			dec		rsi
.L2:
			cmp		rdi, rsi
			jge		.done
			mov		al, BYTE [rdi]
			xchg	al, BYTE [rsi]
			mov		BYTE [rdi], al
			inc		rdi
			dec		rsi
			jmp		.L2

.done:
			pop		rsi
			mov		BYTE [rsi], 0x0
			mov		rax, rcx
			pop		rdx
			pop		rcx
			pop		rsi
			pop		rdi
			ret

;------------------------------------------------------------------------------;
;																			   ;
;							#####################							   ;
;							#					#							   ;
;							#	     htoa		#							   ;
;							#					#							   ;
;							#####################							   ;
;																			   ;
;	args:																	   ;
;			rdi -> nb to convert in hex format								   ;
;			rsi -> buffer output											   ;
;	return																       ;
;			rax -> nb of chars												   ;
;------------------------------------------------------------------------------;

htoa:

			push	rdi
			push	rsi
			push	rcx
			push	rdx 

			mov		rax, rdi
			mov		rdi, 0x10
			mov		BYTE [rsi], '0'
			inc		rsi
			mov		BYTE [rsi], 'x'
			inc		rsi
			xor		rcx, rcx
.L1:
			xor		rdx, rdx
			inc		rcx
			div		rdi
			cmp		rdx, 0xa
			jl		.normal
			sub		rdx, 0xa
			add		rdx, 'A'
			jmp		.continue
.normal:
			add		rdx, '0'
.continue:
			mov		BYTE [rsi], dl
			inc		rsi
			cmp		rax, 0x0
			jne		.L1

			push	rsi
			mov		rdi, rsi
			sub		rdi, rcx
			dec		rsi
.L2:
			cmp		rdi, rsi
			jge		.done
			mov		al, BYTE [rdi]
			xchg	al, BYTE [rsi]
			mov		BYTE [rdi], al
			inc		rdi
			dec		rsi
			jmp		.L2

.done:
			pop		rsi
			mov		BYTE [rsi], 0x0
			mov		rax, rcx
			pop		rdx
			pop		rcx
			pop		rsi
			pop		rdi
			ret


;------------------------------------------------------------------------------;
;																			   ;
;							#####################							   ;
;							#					#							   ;
;							#	     ftoa		#							   ;
;							#					#							   ;
;							#####################							   ;
;																			   ;
;	args:																	   ;
;			xmm0 -> float nb to convert										   ;
;			rsi -> buffer output											   ;
;	return																       ;
;			rax -> nb of chars												   ;
;------------------------------------------------------------------------------;

ftoa:
			push	rsi
			push	rdi

			cvttss2si	rdi, xmm0
			call	itoa
			add		rsi, rax
			mov		BYTE [rsi], ','
			inc		rsi

			cvtsi2ss	xmm1, rdi
			subss		xmm0, xmm1
			movss		xmm2, [float10.0]
.L1:
			cvttss2si	rdi, xmm0
			cvtsi2ss	xmm1, rdi
			movss		xmm3, xmm0
			subss		xmm3, xmm1
			ucomiss		xmm3, [float0.1]
			jb		.done
			mulss		xmm0, xmm2
			jmp			.L1

.done:
			cvttss2si	rdi, xmm0
			call		itoa
			pop		rdi	
			pop		rsi
			ret



section .data
float10.0:	dd	10.0
float0.1:	dd	0.1
