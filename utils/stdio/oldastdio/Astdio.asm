global	strlen
global  PrintS
global  PrintI
global	PrintF
global	PrintC
section	.text

;####################
;#					#
;#		STRLEN		#
;#					#
;####################

;	rdi = ptr to str
;	rax -> len(str)

strlen:
			push	rbp
			push	rbx
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
			pop		rbx
			pop		rbp
			ret

;####################
;#					#
;#		PRINTS		#
;#					#
;####################

;	rdi = ptr to str

PrintS:
			push	rbp
			push	rbx
			push	rdx

			call	strlen
			mov		rsi, rdi
			mov		rdi, 1
			mov		rdx, rax
			mov		rax, 1

			syscall

			pop		rdx
			pop		rbx
			pop		rbp
			ret


;####################
;#					#
;#		ITOA		#
;#					#
;####################

;	rdi = number
;	rsi = output buffer
;	rax -> len(str(number))

Itoa:
			push	rbp
			push	rbx
			push	rsi
			push	r8

			xor		r8, r8
;			handle negative value
			call	Iabs
			cmp		rax, 1
			jne		.continue
			mov		byte [rsi], '-'
			inc		rsi
.continue:
			mov		rbx, 0x0A
			push	rsi
			mov		rax, rdi
.L1:		; build the string
			xor		rdx, rdx
			inc		r8
			div		rbx
			add		edx, '0'
			mov		[rsi], edx
			inc		rsi
			cmp		rax, 0
			jnz		.L1
;			reverse the string
			pop		rsi
			mov		rdi, r8
			call reverse

			mov		byte [rsi + r8], 0x00
			mov		rax, r8

			pop		r8
			pop		rsi
			pop		rbx
			pop		rbp
			ret
Iabs:
			xor		rax, rax
			cmp		rdi, 0
			jge		.done
			neg		rdi
			inc		rax

.done:
			ret

reverse:
			push	rsi
			add		rdi, rsi
			dec		rdi
.L1:			
			cmp		rdi, rsi
			jle		.done
			mov		al, byte [rdi]
			xchg	al, byte [rsi]
			mov		byte [rdi], al
			inc		rsi
			dec		rdi
			jmp		.L1
.done:
			pop		rsi
			ret


;####################
;#					#
;#		PRINTI		#
;#					#
;####################

;	rdi = number

PrintI:
			push	rbp
			push	rbx
			push	rdi
			push	rdx
			
			mov		rsi, buffer100
			call	Itoa
			mov		rdi, rsi
			call	PrintS

			pop		rdx
			pop		rdi
			pop		rbx
			pop		rbp
			ret



;####################
;#					#
;#		PRINTC		#
;#					#
;####################

;	rdi = char to print

PrintC:
			push	rdi
			
			mov		rsi, buffer2
			mov		[rsi], dil
			mov		byte [rsi+1], 0x00
			mov		rdi, rsi
			call	PrintS

			pop		rdi
			ret

;####################
;#					#
;#		PRINTF		#
;#					#
;####################

;	xmm0 = float to print

PrintF:
			push	rbp
			push	rbx
			push	rdx
			mov		rbp, rsp

			sub		rsp, 4
			
			cvttss2si	edi, xmm0
			mov		dword [rbp - 4], edi
			call	PrintI
			
			mov		dil, '.'
			call	PrintC

			mov		edi, dword [rbp - 4]
			cvtsi2ss	xmm1, edi
			subss	xmm0, xmm1
			mov			r9, 10
			cvtsi2ss	xmm4, r9

.L1:
			cvttss2si	edi, xmm0
			cvtsi2ss	xmm1, edi
			movss		xmm2, xmm0
			subss		xmm2, xmm1
			ucomiss		xmm2, [float0.1]
			jbe			.done
			mulss		xmm0, xmm4
			jmp			.L1

.done:
			cvttss2si	edi, xmm0
			call	PrintI
			mov		rsp, rbp
			pop		rdx
			pop		rbx
			pop		rbp
			ret


section .bss
buffer100:	resb	100
buffer2:	resb	2

section	.data
float0.1	dd		0.1
