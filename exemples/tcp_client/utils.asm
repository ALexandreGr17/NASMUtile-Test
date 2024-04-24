global	exit
global	printString
global	printError
global	str2ip
global	htons
global	init_structaddr_in
global	socket
global	connect
global	send
global	recv
global	read_stdin
; ################################ define ######################################
%define	EXIT				0x3c
%define STDIN				0x00
%define STDOUT				0x01
%define STDERR				0x02
%define SOCKET				0x29
%define AF_INET				0x02
%define SOCK_STREAM			0x01
%define	INADDR_ANY			0x00
%define	CONNECT				0x2A
%define	WRITE				0x01
%define READ				0x00


%define	SIZE_STRCUTADDR_IN	0x10
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
;			rdi -> exit code   											       ;
;------------------------------------------------------------------------------;

exit:
		mov		rax, EXIT					; syscall for exit
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
;			rdi -> ptr to string											   ;
;	return:																	   ;
;			rax -> len of string											   ;
;------------------------------------------------------------------------------;

strlen:
		push	rdi					; save rdi
		xor		rax, rax			; init counter
.L1:
		cmp		byte [rdi], 0x00	; test if null
		je		.done
		inc		rax					; inc counter
		inc		rdi					; next char
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
;			rdi -> ptr to string											   ;
;------------------------------------------------------------------------------;

printString:
		push	rdi							; save registers
		push	rax
		push	rsi
		push	rdx 

		call	strlen						; get str size
		mov		rdx, rax					
		mov		rsi, rdi
		mov		rdi, STDOUT						; stdout
		mov		rax, WRITE				
		syscall
		
		pop		rdx
		pop		rsi
		pop		rax
		pop		rdi
		ret

;------------------------------------------------------------------------------;
;																			   ;
;							#####################							   ;
;							#					#							   ;
;							#	 printError		#							   ;
;							#					#							   ;
;							#####################							   ;
;																			   ;
;	args:																	   ;
;			rdi -> ptr to string											   ;
;------------------------------------------------------------------------------;

printError:
		push	rdi							; save registers
		push	rax
		push	rsi
		push	rdx 

		call	strlen						; get str size
		mov		rdx, rax					
		mov		rsi, rdi
		mov		rdi, STDERR						
		mov		rax, WRITE				
		syscall
		
		pop		rdx
		pop		rsi
		pop		rax
		pop		rdi
		ret

;------------------------------------------------------------------------------;
;																			   ;
;							#####################							   ;
;							#					#							   ;
;							#		socket		#							   ;
;							#					#							   ;
;							#####################							   ;
;																			   ;
;	return:																	   ;
;			rax -> socket descriptor										   ;
;------------------------------------------------------------------------------;

socket:
		mov		rax, SOCKET
		mov		rdi, AF_INET
		mov		rsi, SOCK_STREAM
		mov		rdx, 0x00
		syscall
		ret

;------------------------------------------------------------------------------;
;																			   ;
;							#####################							   ;
;							#					#							   ;
;							#	   connect		#							   ;
;							#					#							   ;
;							#####################							   ;
;																			   ;
;	args:																	   ;
;			rdi -> socket descriptor										   ;
;			rsi	-> struct socket_addr										   ;
;	return:																	   ;
;			rax -> error code												   ;
;------------------------------------------------------------------------------;

connect:
			mov		rax, CONNECT
			mov		rdx, SIZE_STRCUTADDR_IN
			syscall
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
;							#	   str2ip		#							   ;
;							#					#							   ;
;							#####################							   ;
;																			   ;
;	args:																	   ;
;			rdi -> str rep of ip	 										   ;
;	return:																	   ;
;			rax -> int rep of ip											   ;
;------------------------------------------------------------------------------;

str2ip:
    push    rdi
    push    rbp
    push    rsi
    mov     rbp, rsp
    sub     rsp, 0xC
    mov     QWORD [rsp], rdi
    mov     DWORD [rsp + 8], 0x0
.L1:
    cmp     BYTE [rdi], 0
    je      .done
    cmp     BYTE [rdi], '.'
    je      .conv
    inc     rdi
    jmp     .L1

.conv:
    mov     BYTE [rdi], 0
    mov     rsi, rdi
    mov     rdi, QWORD [rsp]
    call    atoi
    add     DWORD [rsp + 8], eax
    shl     DWORD [rsp + 8], 8
    mov     rdi, rsi
    inc     rdi
    mov     QWORD [rsp], rdi
    jmp     .L1

.done:
    mov     rdi, QWORD [rsp]
    call    atoi
    add     eax, DWORD [rsp + 8]
    mov     rsp, rbp
    pop     rsi
    pop     rbp
    pop     rdi
    ret

;------------------------------------------------------------------------------;
;																			   ;
;						   ########################							   ;
;						   #					  #							   ;
;						   #  init_structaddr_in  #							   ;
;						   #					  #							   ;
;						   ########################							   ;
;																			   ;
;	args:																	   ;
;			rdi -> ptr to struct  	 									       ;
;			rsi -> int representtion of ip addr								   ;
;			rdx -> port														   ;
;------------------------------------------------------------------------------;

init_structaddr_in:
		push	rdi
		mov		rdi, rdx
		call	htons
		mov		rdx, rdi
		pop		rdi

		mov		WORD [rdi], AF_INET
		mov		WORD [rdi+2], dx
		bswap	esi
		mov		DWORD [rdi+4], esi
		ret

;------------------------------------------------------------------------------;
;																			   ;
;							#####################							   ;
;							#					#							   ;
;							#		htons		#							   ;
;							#					#							   ;
;							#####################							   ;
;																			   ;
;	args:																	   ;
;			rdi -> unmber to convert										   ;
;	return:																	   ;
;			rdi -> host byte order number									   ;
;------------------------------------------------------------------------------;

htons:
			push	rax
			push	rdx

			movzx	edx, di
			mov		eax, edx
			shl		dx, 8
			shr		eax, 8
			or		ax, dx
			mov		edi, eax
			
			pop		rdx
			pop		rax
			ret


;------------------------------------------------------------------------------;
;																			   ;
;							#####################							   ;
;							#					#							   ;
;							#		send		#							   ;
;							#					#							   ;
;							#####################							   ;
;																			   ;
;	args:																	   ;
;			rdi -> socket or file descriptor								   ;
;			rsi -> ptr to string											   ;
;	return:																	   ;
;			rax -> error code											       ;
;------------------------------------------------------------------------------;

send:
		push	rdi
		mov		rdi, rsi
		call	strlen
		mov		rdx, rax
		pop		rdi
		mov		rax, WRITE
		syscall
		ret


;------------------------------------------------------------------------------;
;																			   ;
;							#####################							   ;
;							#					#							   ;
;							#		recv		#							   ;
;							#					#							   ;
;							#####################							   ;
;																			   ;
;	args:																	   ;
;			rdi -> socket or file descriptor								   ;
;			rsi -> ptr to buffer											   ;
;	return:																	   ;
;			rax -> size read or error code									   ;
;------------------------------------------------------------------------------;

recv:
		mov		rax, READ
		mov		rdx, 4096
		syscall
		ret


;------------------------------------------------------------------------------;
;																			   ;
;							#####################							   ;
;							#					#							   ;
;							#    read_stdin		#							   ;
;							#					#							   ;
;							#####################							   ;
;																			   ;
;	args:																	   ;
;			rdi -> ptr to output buffer										   ;
;	return:																	   ;
;			rax -> size read or error code									   ;
;------------------------------------------------------------------------------;

read_stdin:
		push	rsi
		push	rdi

		mov		rax, READ
		mov		rsi, rdi
		mov		rdi, STDIN
		mov		rdx, 4096
		syscall
		
		pop		rdi
		pop		rsi
		ret
