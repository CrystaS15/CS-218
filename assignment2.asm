; Author: Kristy Nguyen
; Section: 1001
; Date Last Modified: 9/3/2020
; Program Description: This program will demonstrate mastery over arithmetic operations in x86 assembly.

section .data
; System service call values
SERVICE_EXIT equ 60
SERVICE_WRITE equ 1
EXIT_SUCCESS equ 0
STANDARD_OUT equ 1
NEWLINE equ 10

programDone db "Program Done.", NEWLINE 
stringLength dq 14

;	Example variables
byteExample1 db 0x10
byteExample2 db 0x32
byteExample3 db 0x00
byteExample4 db 100
wordExample1 dw 0x0002
wordExample2 dw 0x00F0
doubleExample1 dd 0x10101010
doubleExample2 dd 0
 
;	Data variables
doubleVariable2 dd 0x89ABCDEF
byteVariable3 db 250
doubleVariable4 dd 0x12345678
doubleVariable5 dd 0xC1240000
wordVariable6a dw -42
wordVariable6b dw 40
quadVariable8a dq 0xFFFFFFFFFFFFFFFF
quadVariable8b dq 0xF0F0F0F0F0F0F0F0
doubleVariable9 dd 0xC2860000
wordVariable9 dw 0x1234
byteVariable10a db 0x02
byteVariable10b db 0xF0
doubleVariable11a dd 40008
doubleVariable11b dd 12
quadVariable12a dq 0xFFFFFFFFFFFFFFFF
quadVariable12b dq 0x00000000000000F1
byteVariable13 db 0x0A
byteVariable14a db 0xF0
byteVariable14b db 0x02
doubleVariable15 dd 80009
wordVariable15 dw 3050
wordVariable16a dw 0x0497
wordVariable16b dw 0x0002
byteVariable17 db 0xB8
wordVariable18a dw 0x00FF
wordVariable18b dw 0xFFFA
wordVariable18c dw 0x0005
doubleVariable19a dd 0xB0040030
doubleVariable19b dd 0xC0000000
quadVariable20 dq 0x000000039ABCDEF0
doubleVariable20 dd 0xFEDCBA98
   
;	Answer variables
doubleAnswer1 dd 0xFFFFFFFF
doubleAnswer2 dd 0x00000000
quadAnswer3 dq 0xFFFFFFFFFFFFFFFF
quadAnswer4 dq 0xFFFFFFFFFFFFFFFF
quadAnswer5 dq 0
wordAnswer6 dw 0x00000000
doubleAnswer7 dd 0x0FFFFFFD
quadAnswer8 dq 0xFFFFFFFFFFFFFFFF
doubleAnswer9 dd 0x00000000
wordAnswer10 dw 0
quadAnswer11 dq 0
doubleQuadAnswer12 ddq 0
wordAnswer13 dw 0xFFFF
byteAnswer14 db 0x00
byteRemainder14 db 0x00
wordAnswer15 dw 0x0000
wordRemainder16 dw 0xFFFF   
byteAnswer17 db 0x00
wordAnswer18 dw 0x0000
doubleAnswer19 dd -1
doubleRemainder19 dd -1
doubleRemainder20 dd 0x00000000

section .text
global _start
_start:

;=====MOV=====
;  	Moving an immediate value into a register
	mov ax, 0
;  	Copying a value from one register to another
	mov ecx, ebx
;	Copying a value from a variable to a register
	mov edx, dword[doubleExample1]
	
;	1. doubleAnswer1 = 400000
	mov dword[doubleAnswer1], 400000

;	2. doubleAnswer2 = doubleVariable2
	mov eax, dword[doubleVariable2]
	mov dword[doubleAnswer2], eax

;=====MOVZX=====
;	3. quadAnswer3 = byteVariable3
	movzx rax, byte[byteVariable3]
	mov qword[quadAnswer3], rax
	
;	4. quadAnswer4 = doubleVariable4
	movsxd rax, dword[doubleVariable4]
	mov qword[quadAnswer4], rax
	
;=====MOVSX=====
;	5. quadAnswer5 = doubleVariable5
	movsxd rax, dword[doubleVariable5]
	mov qword[quadAnswer5], rax

;=====ADD=====
;  Adding two byte values together
	mov al, byte[byteExample1]
	add al, byte[byteExample2]
	mov byte[byteExample3], al

;	6. wordAnswer6 = wordVariable6a + wordVariable6b
	mov ax, word[wordVariable6a]
	add ax, word[wordVariable6b]
	mov word[wordAnswer6], ax
	
;	7. doubleAnswer7 = doubleAnswer7 + 2
	add dword[doubleAnswer7], 2

;=====SUB=====
;	8. quadAnswer8 = quadVariable8a - quadVariable8b
	mov rax, qword[quadVariable8a]
	sub rax, qword[quadVariable8b]
	mov qword[quadAnswer8], rax

;	9. doubleAnswer9 = doubleVariable9 - wordVariable9
	movzx ebx, word[wordVariable9]
	mov eax, dword[doubleVariable9]
	sub eax, ebx
	mov dword[doubleAnswer9], eax

;=====INC=====
;	Using inc to increment a register
	inc ax

;=====DEC=====
;	Using dec to decrement a variable
	dec byte[byteExample4]
	
;=====MUL=====
;	Multiplying two words and storing the parts into a dword sized variable
	mov ax, word[wordExample1]
	mul word[wordExample2]
	mov word[doubleExample2], ax ; Stores the lower bits
	mov word[doubleExample2+2], dx	; Stores the upper bits

;	10. wordAnswer10 = byteVariable10a x byteVariable10b
	mov al, byte[byteVariable10a]
	mul byte[byteVariable10b] ; result stored in ax
	mov word[wordAnswer10], ax

;	11. quadAnswer11 = doubleVariable11a x doubleVariable11b
	mov eax, dword[doubleVariable11a]
	mul dword[doubleVariable11b] ; result stored in edx:eax
	mov dword[quadAnswer11], eax
	mov dword[quadAnswer11+4], edx

;	12. doubleQuadAnswer12 = quadVariable12a x quadVariable12b
	mov rax, qword[quadVariable12a]
	mul qword[quadVariable12b] ; result stored in rdx:rax
	mov qword[doubleQuadAnswer12], rax
	mov qword[doubleQuadAnswer12+8], rdx

;=====IMUL=====

;	13. wordAnswer13 = byteVariable13 x -3
	movsx ax, byte[byteVariable13]
	imul ax, -3 ; result stored in ax
	mov word[wordAnswer13], ax
	

;=====DIV=====

;	14. byteAnswer14 = byteVariable14a / byteVariable14b
;	      byteRemainder14 =  byteVariable14a % byteVariable14b
	mov ah, 0 ; ah needs to be set before dividing
	mov al, byte[byteVariable14a]
	div byte[byteVariable14b] ; al = ax / byteVariable14b
	mov byte[byteAnswer14], al
	mov byte[byteRemainder14], ah ; ah = ax % byteVariable14b

;	15. wordAnswer15 = doubleVariable15 / wordVariable15
	movzx ebx, word[wordVariable15]
	mov dx, 0
	mov eax, dword[doubleVariable15]
	div ebx
	mov word[wordAnswer15], ax

;	16. wordRemainder16 = wordVariable16a / wordVariable16b
	mov dx, 0
	mov ax, word[wordVariable16a]
	div word[wordVariable16b] ; ax = dx:ax / wordVariable16b
	mov word[wordRemainder16], dx

;=====IDIV=====

;	17. byteAnswer17 = byteVariable17 / 5
	mov ah, 0
	mov al, byte[byteVariable17]
	cbw ; convert byte in al  to word in ax
	mov bl, 5
	idiv bl ; al = ax:al / 5
	mov byte[byteAnswer17], al

;	18. wordAnswer18 = (wordVariable18a x wordVariable18b) / wordVariable18c
	mov dx, 0
	mov ax, word[wordVariable18a]
	imul word[wordVariable18b]
	idiv word[wordVariable18c]
	mov word[wordAnswer18], ax
	
;	19. doubleAnswer19 = doubleVariable19a / doubleVariable19b
;	      doubleRemainder19 = doubleVariable19a % doubleVariable19b
	mov edx, 0
	mov eax, dword[doubleVariable19a]
	cdq ; convert double word in eax to quad word in edx:eax
	idiv dword[doubleVariable19b] ; eax = edx:eax / doubleVariable19b
	mov dword[doubleAnswer19], eax
	mov dword[doubleRemainder19], edx ; edx = edx:eax % doubleVariable19b

;	20. doubleRemainder20 = quadVariable20 % doubleVariable20
	mov rdx, 0
	mov eax, dword[quadVariable20]
	mov edx, dword[quadVariable20+4]
	mov ebx, dword[doubleVariable20]
	idiv ebx ; eax = edx:eax / doubleVariable20
	mov dword[doubleRemainder20], edx
	

endProgram:
; 	Outputs "Program Done." to the console
	mov rax, SERVICE_WRITE
	mov rdi, STANDARD_OUT
	mov rsi, programDone
	mov rdx, qword[stringLength]
	syscall

; 	Ends program with success return value
	mov rax, SERVICE_EXIT
	mov rdi, EXIT_SUCCESS
	syscall
