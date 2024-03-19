global	exit
global	strlen
global	printError
global	printString

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
;------------------------------------------------------------------------------;

printString:
			push	rdx
			push	rax
			push	rsi
			push	rdi

			call	strlen
			mov		rdx, rax
			mov		rsi, rdi
			mov		rdi, STDOUT
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
;							#	   atoi 		#							   ;
;							#					#							   ;
;							#####################							   ;
;																			   ;
;	args:																	   ;
;			rdi -> str to convert	 										   ;
;	return:																	   ;
;			rax -> int     											           ;
;------------------------------------------------------------------------------;

atoi:
		push	rdi
		push	rbx
		xor		rax, rax
.L1:
		cmp		byte [rdi], 0x00
		je		.done
		imul	rax, 0x0a
		mov		bl, byte [rdi]
		sub		bl, '0'
		add     rax, rbx
		inc		rdi
		jmp		.L1
.done:
		pop		rbx
		pop		rdi
		ret

;------------------------------------------------------------------------------;
;																			   ;
;							#####################							   ;
;							#					#							   ;
;							#	   memcpy		#							   ;
;							#					#							   ;
;							#####################							   ;
;																			   ;
;	args:																	   ;
;		rdi	-> ptr src														   ;
;		rsi	-> ptr dst														   ;
;		rdx	-> nb bytes														   ;
;------------------------------------------------------------------------------;

memcpy:
			push	rdi
			push	rsi
			push	rdx
			push	rax
.L1:
			cmp		rdx, 0
			je		.done
			mov		al, BYTE [rdi]
			mov		BYTE [rsi], al
			inc		rdi
			inc		rsi
			dec		rdx
			jmp		.L1
.done:
			pop		rax
			pop		rdx
			pop		rsi
			pop		rdi
			ret


