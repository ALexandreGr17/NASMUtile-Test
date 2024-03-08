global	AprintF
extern	PrintI
extern	PrintS
extern	PrintF
;extern	PrintC

section	.text

;
;
;
;

;	rdi = str formated
;	rdx	= array of args

error:
			mov		rax, 60
			syscall

AprintF:
			push	rdi
			push	rdi
			;push	rsp
.L1:
			cmp		byte [rdi], '%'
			je		.testFormat
.continue:			
			inc		rdi
			cmp		byte[rdi], 0x00
.done:			
			jne		.L1
			pop		rdi
			call PrintS
			;pop		rsp
			pop		rdi
			ret		

.testFormat:
			mov		byte [rdi], 0x00
			inc		rdi
			cmp		rdi, 0x00
			je		.done
			cmp		byte [rdi], 'f'
			je		.printf
			cmp		byte [rdi], 'i'
			je		.printi
			cmp		byte [rdi], 's'
			je		.prints
			;cmp		byte [rdi], 'c'
			;je		.printc
			call	error

.printf:
			mov		r8, rdi
			pop		rdi
			call	PrintS

			movss	xmm0, dword [rdx]
			call	PrintF
			mov		rdi, r8
			inc		rdi
			add		rdx, 8
			push	rdi
			jmp		.continue

.printi:
			mov		r8, rdi
			pop		rdi
			call	PrintS

			mov		rdi, qword [rdx]
			call	PrintI
			mov		rdi, r8
			inc		rdi
			add		rdx, 8
			push	rdi
			jmp		.continue

.prints:
			mov		r8, rdi
			pop		rdi
			call	PrintS

			mov		rdi, [rdx]
			call	PrintS
			mov		rdi, r8
			inc		rdi
			add		rdx, 8
			push	rdi
			jmp		.continue
