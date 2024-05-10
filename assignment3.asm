; Author: Kristy Nguyen
; Section: 1001
; Date Last Modified: 9/12/2020
; Program Description: Use of loops and conditional code created from jump instructions to work with arrays.

section .data
; System service call values
SERVICE_EXIT equ 60
SERVICE_WRITE equ 1
EXIT_SUCCESS equ 0
STANDARD_OUT equ 1
NEWLINE equ 10

programDone db "Program Done.", NEWLINE 
stringLength dq 14

; Variables
listOne dd 2078, 3854, 6593, 947, 5252, 1190, 716, 3587, 8014, 9563
			dd 9821, 3195, 1051, 6454, 5752, 980, 9015, 2478, 5624, 7251
			dd 2936, 1073, 1731, 5376, 4452, 792, 2375, 2542, 5666, 2228
			dd 454, 2379, 6066, 3340, 2631, 9138, 3530, 7528, 7152, 1551
			dd 9537, 9590, 2168, 9647, 5362, 2728, 5939, 4620, 1828, 5736

listTwo dd 5087, 6614, 6035, 6573, 6287, 5624, 4240, 3198, 5162, 6972
			dd 6219, 1331, 1039, 23, 4540, 2950, 2758, 3243, 1229, 8402
			dd 8522, 4559, 1704, 4160, 6746, 5289, 2430, 9660, 702, 9609
			dd 8673, 5012, 2340, 1477, 2878, 2331, 3652, 2623, 4679, 6041
			dd 4160, 2310, 5232, 4158, 5419, 2158, 380, 5383, 4140, 1874
			
sum dq 0

minimum dd 0
maximum dd 0
average dd 0

oddCount db 0
evenCount db 0

LIST_LENGTH equ 50

section .bss
calculatedList resd 50

section .text
global _start
_start:

; List 3
mov ecx, LIST_LENGTH ; loop counter
mov esi, 0 ; index
calculateLoop:
	mov eax, dword[listOne+esi*4]
	add eax, dword[listTwo+esi*4]
	cdq ; convert eax (double) to edx:eax (quad)
	mov ebx, 2
	idiv ebx ; eax = eax / ebx
	mov dword[calculatedList+esi*4], eax
	inc esi
loop calculateLoop

; Sum
mov ecx, LIST_LENGTH ; loop counter
mov esi, 0 ; index
mov rax, qword[sum]
sumLoop:
	movsxd rbx, dword[calculatedList+esi*4]
	add rax, rbx
	inc esi
loop sumLoop
mov qword[sum], rax

; Average
mov rax, qword[sum]
mov rbx, LIST_LENGTH
div rbx ; rax = rax / rbx
mov dword[average], eax

; Minimum/Maximum
mov ecx, LIST_LENGTH ; loop counter
mov esi, 0 ; index
mov eax, dword[calculatedList+esi*4] ; set current value
mov dword[minimum], eax ; set min to current value
mov dword[maximum], eax ; set max to current value

beginMinMax:
	mov eax, dword[calculatedList+esi*4] ; set next value
	
	minimumLoop:
		cmp eax, dword[minimum] ; if current value < min
		jge notLess
		mov dword[minimum], eax ; set min
	
notLess: ; if currentValue > max
	maximumLoop:
		cmp eax, dword[maximum]
		jle notGreater
		mov dword[maximum], eax ; set max
		
notGreater:
	inc esi ; inc index
	cmp esi, LIST_LENGTH
	je minMaxDone
	jmp beginMinMax

minMaxDone:

mov ecx, LIST_LENGTH ; loop counter
mov esi, 0 ; index
mov ebx, 2

beginEvenOdd:

	; Check to see if a value is even
	; If after dividing by 2, the remainder is 0, then it is even
	mov eax, dword[calculatedList+esi*4] ; current value
	mov edx, 0 ; set edx to 0 for div
	div ebx ; eax = eax / ebx
	cmp edx, 0 ; if remainder = 0
	jne isOdd
	inc byte[evenCount] ; inc evenCount
	jmp evenOddDone
	
isOdd: ; if remainder != 0, inc oddCount
	inc byte[oddCount]
	
evenOddDone:
	inc esi ; inc index
	cmp esi, LIST_LENGTH
	je endProgram
	jmp beginEvenOdd


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