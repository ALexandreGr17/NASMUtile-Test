global	_start
;	############################### Externs ####################################
extern	exit
extern	printInt
extern	printHex
extern	printFloat
extern	aprintf
; ##############################################################################
section	.text

_start:
		push	rbp
		mov		rbp, rsp
		sub		rsp, 0x4 + 0x8 + 0x8 + 0x4
		mov		rsi, rsp
		mov		rdi, teststr
		mov		DWORD [rsi], 123456
		mov		QWORD [rsi + 0x4], helo
		mov		QWORD [rsi + 0x4 + 0x8], floatTest
		mov		DWORD [rsi + 0x4 + 0x8 + 0x8], 0xA1
		call	aprintf

		xor		rdi, rdi
		call	exit

section	.data
floatTest:	dd	123.456
teststr:	db	"test int: %i", 0xa, "test str: %s", 0xa, "test float: %f", 0xa, "test hex: %h", 0xa, 0x0
helo:		db	"Hello world!" 
section .bss
buffer:		resb	100

