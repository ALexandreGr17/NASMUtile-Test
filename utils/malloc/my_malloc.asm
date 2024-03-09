global	init_malloc
global	my_malloc
global	my_free
global	my_realloc
global	my_calloc
global	close_malloc

; ############################### Externs ######################################
extern	printError
; ##############################################################################

; ##############################################################################
%define MMAP		0x09
%define	MUNMAP		0x0b

%define	PROT_READ	0x1
%define PROT_WRITE	0x2
%define MAP_PRIVATE	0x2
%define	MAP_ANON	0x20

%define SIZE_HEAP_STRUCT    0x8 * 5
%define SIZE_BLOCK_STRUCT   0x8 * 3 + 0x1
%define PAGE_SIZE			0x1000

%define TINY_HEAP_ALLOC_SIZE	        (4 * PAGE_SIZE)
%define TINY_BLOCK_SIZE					(TINY_HEAP_ALLOC_SIZE / 128)
%define SMALL_HEAP_ALLOC_SIZE	        (16 * PAGE_SIZE)
%define SMALL_BLOCK_SIZE				(SMALL_HEAP_ALLOC_SIZE / 128)
; ##############################################################################

;		HEAP_STRUCT
;	0x00	-> prev					QWORD	0x8
;	0x08	-> next					QWORD	0x8
;	0x17	-> total_size	        QWORD	0x8
;	0x1F	-> free_size	        QWORD	0x8
;	0x27	-> block_count	        QWORD	0x8
%define	HEAP_PREV	0x00
%define HEAP_NEXT	0x08
%define	HEAP_TOT_SIZE	0x10
%define	HEAP_FIRST_BLOCK 0x18
%define	HEAP_BLOCK_COUNT 0x20

;		BLOCK_STRUCT
;	0x00	-> prev			QWORD	0x8
;	0x08	-> next			QWORD	0x8
;	0x0F	-> data_size	QWORD	0x8
;	0x17	-> freed		BYTE	0x1
%define	BLOCK_PREV	0x00
%define	BLOCK_NEXT	0x08
%define	BLOCK_DATA_SIZE	0x10
%define	BLOCK_FREED	0x18

; ##############################################################################

section	.text

;------------------------------------------------------------------------------;
;																			   ;
;							#####################							   ;
;							#					#							   ;
;							#	  my_malloc		#							   ;
;							#					#							   ;
;							#####################							   ;
;																			   ;
;	args:																	   ;
;			rdi -> size of block needed   									   ;
;	return:																	   ;
;			rax -> ptr to mem block											   ;
;------------------------------------------------------------------------------;

my_malloc:
			push	rdi
			push	rsi

			mov		rax, QWORD [heap_ptr]
			add		rax, SIZE_HEAP_STRUCT
.SearchFreeBlock:
			cmp		BYTE [rax + BLOCK_FREED], 0x1
			je		.foundFreeBlock
			cmp		QWORD [rax + HEAP_NEXT], 0x0
			jne		.NextBlock
			mov		rdi, QWORD [heap_ptr]
			add		rdi, QWORD [rdi + HEAP_TOT_SIZE]
			cmp		rax, rdi
			jge		.expendHeap

			push	rax
			add		rax, QWORD [rax + BLOCK_DATA_SIZE]
			add		rax, SIZE_BLOCK_STRUCT
			mov		rsi, rdi
			mov		rdi, rax
			call	init_block_struct
			pop		rax
			mov		QWORD [rdi + HEAP_PREV], rax
			mov		QWORD [rax + HEAP_NEXT], rdi
			mov		rax, rdi
			jmp		.foundFreeBlock

.expendHeap:
			call	create_heap_chunk
			mov		rax, QWORD [rax + HEAP_NEXT]
			add		rax, SIZE_HEAP_STRUCT
			jmp		.SearchFreeBlock

.foundFreeBlock:
			cmp		QWORD [rax + BLOCK_DATA_SIZE], rdi
			jl		.SearchFreeBlock
			mov		BYTE [rax + BLOCK_FREED], 0x0
			add		rax, SIZE_BLOCK_STRUCT
			pop		rsi
			pop		rdi
			ret
.NextBlock:
			mov		rax, QWORD [rax + HEAP_NEXT]
			jmp		.SearchFreeBlock

			

;------------------------------------------------------------------------------;
;																			   ;
;							#####################							   ;
;							#					#							   ;
;							#	 init_malloc	#							   ;
;							#					#							   ;
;							#####################							   ;
;																			   ;
;	Will init the heap for malloc must be called at the start				   ;
;------------------------------------------------------------------------------;

init_malloc:
			push	rax
			mov		QWORD [heap_ptr], 0x0
			call	create_heap_chunk
			pop		rax
			ret

;------------------------------------------------------------------------------;
;																			   ;
;							#####################							   ;
;							#					#							   ;
;							# create_heap_chunk	#							   ;
;							#					#							   ;
;							#####################							   ;
;																			   ;
;	Will create and init a chunk of mem for the heap						   ;
;------------------------------------------------------------------------------;

create_heap_chunk:
			push	rdi
			push	rsi
			push	rdx
			push	r10
			push	r8
			push	r9

			mov		rdi, 0x00
			mov		rsi, SMALL_HEAP_ALLOC_SIZE
			mov		rdx, PROT_READ | PROT_WRITE
			mov		r10, MAP_ANON | MAP_PRIVATE
			mov		r8, -1
			mov		r9, 0
			mov		rax, MMAP
			syscall

			mov		rsi, [heap_ptr]
			mov		QWORD [rax + HEAP_PREV], rsi
			mov		QWORD [heap_ptr], rax
			mov		rdi, rax
			call	init_heap
			pop		r9
			pop		r8
			pop		r10
			pop		rdx
			pop		rsi
			pop		rdi
			ret

;------------------------------------------------------------------------------;
;																			   ;
;							#####################							   ;
;							#					#							   ;
;							#  init_heap_struct	#							   ;
;							#					#							   ;
;							#####################							   ;
;																			   ;
;	Will init the heap struct at the start of evry heap chunk				   ;
;------------------------------------------------------------------------------;

init_heap_struct:
			mov     QWORD [rdi + HEAP_NEXT], 0x00
			mov		QWORD [rdi + HEAP_TOT_SIZE], SMALL_HEAP_ALLOC_SIZE
			mov		QWORD [rdi + HEAP_BLOCK_COUNT], 128
			ret

;------------------------------------------------------------------------------;
;																			   ;
;							#####################							   ;
;							#					#							   ;
;							# init_block_struct	#							   ;
;							#					#							   ;
;							#####################							   ;
;																			   ;
;	Will init the block header												   ;
;------------------------------------------------------------------------------;

init_block_struct:
			mov		QWORD [rdi + BLOCK_PREV], 0x00
			mov		QWORD [rdi + BLOCK_NEXT], 0x00
			mov		QWORD [rdi + BLOCK_DATA_SIZE], rsi
			mov		BYTE  [rdi + BLOCK_FREED], 0x1
			ret


;------------------------------------------------------------------------------;
;																			   ;
;							#####################							   ;
;							#					#							   ;
;							#	 init_heap		#							   ;
;							#					#							   ;
;							#####################							   ;
;																			   ;
;	Will init the heap with a first block									   ;
;------------------------------------------------------------------------------;

init_heap:
			push	rdi
			push	rsi

			xor		rsi, rsi
			call	init_heap_struct

			add		rdi, SIZE_HEAP_STRUCT
			mov		rsi, SMALL_BLOCK_SIZE - SIZE_BLOCK_STRUCT
			call	init_block_struct
			
            mov     rsi, QWORD [heap_ptr]
			mov		QWORD [rsi + HEAP_FIRST_BLOCK], rdi
			mov		QWORD [rsi + HEAP_BLOCK_COUNT], 1
		
			pop		rsi
			pop		rdi
			ret

;------------------------------------------------------------------------------;
;																			   ;
;							#####################							   ;
;							#					#							   ;
;							#		my_free		#							   ;
;							#					#							   ;
;							#####################							   ;
;																			   ;
;	args:																	   ;
;		rdi	-> ptr to block to free											   ;
;------------------------------------------------------------------------------;

my_free:
			sub		rdi, SIZE_BLOCK_STRUCT
			mov		BYTE [rdi + BLOCK_FREED], 0x1
			ret

;------------------------------------------------------------------------------;
;																			   ;
;							#####################							   ;
;							#					#							   ;
;							#	close_malloc	#							   ;
;							#					#							   ;
;							#####################							   ;
;																			   ;
;	Will clean the heap with MUNMAP											   ;
;------------------------------------------------------------------------------;

close_malloc:
			push	rdi
			push	rsi
			push	rax
			push	rdx
			mov		rdi, QWORD [heap_ptr]
.L1:
			cmp		rdi, 0x00
			je		.done
			mov		rdx, QWORD [rdi + HEAP_NEXT]
			mov		rsi, QWORD [rdi + HEAP_TOT_SIZE]
			mov		rax, MUNMAP
			syscall
			mov		rdi, rdx
			jmp		.L1
.done:
			pop		rdx
			pop		rax
			pop		rsi
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

;------------------------------------------------------------------------------;
;																			   ;
;							#####################							   ;
;							#					#							   ;
;							#	  my_calloc		#							   ;
;							#					#							   ;
;							#####################							   ;
;																			   ;
;	args:																	   ;
;		rdi	-> nb of bytes													   ;
;------------------------------------------------------------------------------;
my_calloc:
			call	my_malloc
			push	rdi
			push	rax
.L1:
			cmp		rdi, 0
			je		.done
			mov		BYTE [rax], 0
			inc		rax
			dec		rdi
			jmp		.L1
.done:
			pop		rax
			pop		rdi
			ret


;------------------------------------------------------------------------------;
;																			   ;
;							#####################							   ;
;							#					#							   ;
;							#	debug_block		#							   ;
;							#					#							   ;
;							#####################							   ;
;																			   ;
;	args:																	   ;
;		rdi	-> block to be debug											   ;
;------------------------------------------------------------------------------;

debug_block:
            mov     rsi, QWORD [rdi + BLOCK_PREV]
            mov     rdx, QWORD [rdi + BLOCK_NEXT]
            mov     rax, QWORD [rdi + BLOCK_DATA_SIZE]
            mov     rcx, QWORD [rdi + BLOCK_FREED]
            ret

section .bss
heap_ptr:	resq	1
