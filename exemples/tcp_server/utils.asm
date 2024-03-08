global	strlen
global	printString
global	printError
global	exit
global	socket
global  bind
global	listen
global	htons
global	memset
global	accept
global	close
global	send
global	recv
global	strcopy

; ################################ define ######################################

;	---- UTILS ----
%define	WRITE			0x01
%define	STDOUT			0x01
%define STDERR			0x02
%define EXIT			0x3C
%define CLOSE			0x03
%define READ			0x00

;	---- SOCKET ----
%define SOCKET			0x29
%define AF_INET			0x02
%define SOCK_STREAM		0x01
%define	INADDR_ANY		0x00
%define	BIND			0x31
%define LISTEN			0x32
%define ACCEPT			0x2b

; ##############################################################################

section .text

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
;							#		bind		#							   ;
;							#					#							   ;
;							#####################							   ;
;																			   ;
;	args:																	   ;
;			rdi -> socket descriptor										   ;
;			rsi -> port								                           ;
;			rdx -> ptr to struct sock_addr_in								   ;
;	return:																	   ;
;			rax -> error code												   ;
;------------------------------------------------------------------------------;

bind:
		push	rsi
		push	rdx
		push	rdi

		mov		rdi, rsi
		call	htons
		mov		rsi, rdi
		pop		rdi

		mov		word [rdx+0x00], AF_INET
		mov		word [rdx+0x02], si
		mov		dword [rdx+0x04], INADDR_ANY
		mov		qword [rdx+0x08], 0x00

		mov		rax, BIND
		mov		rsi, rdx
		mov		rdx, 0x10
		syscall

		pop		rdx
		pop		rsi
		ret


;------------------------------------------------------------------------------;
;																			   ;
;							#####################							   ;
;							#					#							   ;
;							#		listen		#							   ;
;							#					#							   ;
;							#####################							   ;
;																			   ;
;	args:																	   ;
;			rdi -> socket descriptor										   ;
;			rsi -> backlog								                       ;
;	return:																	   ;
;			rax -> error code												   ;
;------------------------------------------------------------------------------;

listen:
			mov		rax, LISTEN
			syscall
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
;							#		memset		#							   ;
;							#					#							   ;
;							#####################							   ;
;																			   ;
;	args:																	   ;
;			rdi -> ptr start  										           ;
;			rsi	-> val to fill												   ;
;			rdx	-> number of byte											   ;
;------------------------------------------------------------------------------;

memset:
			push	rdi
			push	rdx
.L1:		
			cmp		rdx, 0
			je		.done
			mov		byte [rdi], sil
			dec		rdx
			inc		rdi
			jmp		.L1
.done:
			pop		rdx
			pop		rdi
			ret


;------------------------------------------------------------------------------;
;																			   ;
;							#####################							   ;
;							#					#							   ;
;							#		accept		#							   ;
;							#					#							   ;
;							#####################							   ;
;																			   ;
;	args:																	   ;
;			rdi -> socket descriptor  										   ;
;			rsi	-> struct sock_addr_in										   ;
;	return:																	   ;
;			rax -> client socket											   ;
;------------------------------------------------------------------------------;

accept:
			push	rbp
			mov		rbp, rsp
			sub		rsp, 4

			mov		dword [rsp], 0x10
			mov		rdx, rsp
			mov		rax, ACCEPT
			syscall

			mov		rsp, rbp
			pop		rbp
			ret

;------------------------------------------------------------------------------;
;																			   ;
;							#####################							   ;
;							#					#							   ;
;							#		close		#							   ;
;							#					#							   ;
;							#####################							   ;
;																			   ;
;	args:																	   ;
;			rdi -> socket or file descriptor  								   ;
;	return:																	   ;
;			rax -> error code											       ;
;------------------------------------------------------------------------------;

close:
			mov		rax, CLOSE
			syscall
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
;							#		strcopy		#							   ;
;							#					#							   ;
;							#####################							   ;
;																			   ;
;	args:																	   ;
;			rdi -> ptr to string to copy									   ;
;			rsi -> ptr to dest												   ;
;------------------------------------------------------------------------------;

strcopy:
		push	rdi
		push	rsi
		xor		r8, r8
.L1:
		cmp		byte [rdi], 0x00
		je		.done
		mov		al, byte [rdi]
		mov		byte [rsi], al
		inc		rsi
		inc		rdi
		inc		r8
		jmp		.L1
.done:
		mov		rax, r8
		pop		rsi
		pop		rdi
		ret
