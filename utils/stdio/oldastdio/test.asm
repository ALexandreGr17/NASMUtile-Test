extern  strlen
extern  PrintI
extern  PrintS
extern  AprintF
extern  PrintF

global  _start
section .text
 
_start:
;        mov     rdi, message
;        call    PrintS
        
;        mov     rdi, -123456
;        call    PrintI
  
;        movss   xmm0,[float_value]
;        call    PrintF

        mov     rdi, message_test
        mov     rdx, buffer
        mov     qword [rdx], 10
        mov     qword [rdx + 8], message
        movss     xmm0, [float_value]
        movss     dword [rdx + 16], xmm0

        call    AprintF

        xor     rdi, rdi        ; exit status = 0
        mov     rax, 60
        syscall

section .data
message: db     "Hello, World", 0
float_value:   dd     132.654        
message_test:   db      "test int: %i", 0x0A, "test string: %s", 0x0A, "test float: %f", 0x0A, 0

buffer         dq    10 dup(0)
