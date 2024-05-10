; Author: Kristy Nguyen
; Section: 1001
; Date Last Modified: 9/20/2020
; Program Description: This program involves working with macros to perform a variety of tasks

; Macro 1 - Returns the length of a given string in rax
; Argument 1: null terminated string
%macro stringLength 1
	; YOUR CODE HERE
	mov rax, 0
	
	%%readLoop:
		mov bl, byte[%1 + rax]
		inc rax
		cmp bl, NULL ; if current char is null
			je %%endReadLoop ; stop reading the string
		jmp %%readLoop ; repeat loop
	
	%%endReadLoop:
%endmacro

; Macro 2 - Convert letters in a string to uppercase
; Argument 1: null terminated string
%macro toUppercase 1
	; YOUR CODE HERE
	mov rax, 0
	
	%%readLoop:
		mov bl, byte[%1 + rax]
		
		cmp bl, NULL ; if current char is null
			je %%endReadLoop ; stop reading
			
		cmp bl, "a" ; if char is < a
			jb %%notLowercase 
		cmp bl, "z" ; if char is > z
			ja %%notLowercase ; go to next char in string
		sub bl, 20h ; otherwise, subtract 20h
		
		mov byte[%1 + rax], bl
		
		%%notLowercase: ; if char is not lowercase
			inc rax ; go to next char
			jmp %%readLoop ; repeat loop
			
	%%endReadLoop:
%endmacro

; Macro 3 - Convert a Decimal String to Integer
; Argument 1: null terminated string (byte array)
; Argument 2: dword integer variable
%macro convertDecimalToInteger 2
	; YOUR CODE HERE
	mov rbx, %1 ; start rbx at 0th index of Argument 1
	
	; Step 1: 0 or more spaces (1)
	%%skipSpaces1:
		mov cl, byte[rbx] ; current char
		inc rbx ; next char
		cmp cl, " "
	je %%skipSpaces1
	
	dec rbx ; reset pointer to current char
	
	mov r8, 1 ; positive sign
	
	; Step 2: A '+' or '-' may appear
	cmp cl, "+" 
		je %%signDone 
	cmp cl, "-" ; if char is not "+" or "-"
		jne %%skipSpaces2 ; go to next step
	mov r8, -1 ; negative sign
		
	%%signDone:
		inc rbx ; next char
	
	; Step 3: 0 or more spaces (2)
	%%skipSpaces2:
		mov cl, byte[rbx] ; current char
		inc rbx ; next char
		cmp cl, " " 
	je %%skipSpaces2 
	
	dec rbx ; reset to current char
	
	; Step 4: 1 or more numerals ('0' to '9')
	mov eax, 0 ; value = 0
	mov r10d, 10
	%%digitLoop:
		mul r10d ; value = value * 10
		movzx ecx, byte[rbx]
		sub ecx, 30h ; ascii to decimal
		add eax, ecx ; value = value + digit
		inc rbx ; next char
		
		mov cl, byte[rbx]
		cmp cl, NULL ; end digitLoop if NULL or " "
			je %%digitLoopDone
		cmp cl, " "
			je %%digitLoopDone
		
	jmp %%digitLoop
	
	%%digitLoopDone:
		dec rbx ; reset to current char
		cmp r8, -1
			je %%negativeValue
	
	%%negativeValue:
		mul r8
	
	mov dword[%2], eax ; store answer in provided variable
	
	; Step 5: 0 or more spaces (3)
	%%skipSpaces3:
		mov cl, byte[rbx]
		inc rbx ; next char
		cmp cl, " "
	je %%skipSpaces3
		
	dec rbx ; reset to current char
	
	; Step 6: A NULL character
	mov rax, 0
	%%readLoop:
		mov bl, byte[%1 + rax]
		inc rax
		cmp bl, NULL ; if current char is null
			je %%endReadLoop ; stop reading the string
		jmp %%readLoop ; repeat loop	
	%%endReadLoop:
%endmacro

; Macro 4 - Convert an Integer to a Hexadecimal String
; Argument 1: dword integer variable
; Argument 2: string (11 byte array)
%macro convertIntegerToHexadecimal 2
	; YOUR CODE HERE
	mov eax, dword[%1] ; move dword integer variable into eax
	mov rsi, 9
	mov byte[%2 + 10], NULL ; place null char
	mov ebx, 16
	%%hexLoop:
		cmp eax, 0 ; if value = 0, fill in remainder of hex digits
			je %%fillHex
		cmp rsi, 2 ; if index < 2, hex digits are fully converted
			jl %%hexDone
	
		mov edx, 0
		div ebx ; divide value by 16
		cmp edx, 9
			jg %%convert10to15
		
		; if remainder is between 0 and 9, convert to '0' - '9'
		add edx, 48
		mov cl, dl ; copy remainder in byte to cl
		mov byte[%2 + rsi], cl ; copy cl to byte array
		dec rsi ; move to previous byte
		jmp %%hexLoop
		
		%%convert10to15: ; else convert to 'A' - 'F'
			add edx, 55
			mov cl, dl
			mov byte[%2 + rsi], cl
			dec rsi
			jmp %%hexLoop
		
		%%fillHex:
			cmp rsi, 2 ; if index < 2, hex digits are fully converted
				jl %%hexDone
			mov byte[%2 + rsi], '0'
			dec rsi
			jmp %%fillHex
			
	%%hexDone: ; display "0x" before hex digits
		mov byte[%2 + 1], 'x'
		mov byte[%2], '0'
		
%endmacro

section .data
; System Service Call Constants
SYSTEM_WRITE equ 1
SYSTEM_EXIT equ 60
SUCCESS equ 0
STANDARD_OUT equ 1

; Special Characters
LINEFEED equ 10
NULL equ 0

; Macro 1 Variable
macro1Message db "This is the string that never ends, it goes on and on my friends.", LINEFEED, NULL

; Macro 1 Test Variables
macro1Label db "Macro 1: "
macro1Pass db "Pass", LINEFEED
macro1Fail db "Fail", LINEFEED
macro1Expected dq 67

; Macro 2 Variables
macro2Message db "Did you read Chapters 8, 9, and 11 yet?", LINEFEED, NULL

; Macro 2 Test Variable
macro2Label db "Macro 2: "

; Macro 3 Variables
macro3Number1 db "12345", NULL
macro3Number2 db "      +19", NULL
macro3Number3 db " -    1468     ", NULL
macro3Integer1 dd 0
macro3Integer2 dd 0
macro3Integer3 dd 0

; Macro 3 Test Variables
macro3Label1 db "Macro 3-1: "
macro3Label2 db "Macro 3-2: "
macro3Label3 db "Macro 3-3: "
macro3Pass db "Pass", LINEFEED
macro3Fail db "Fail", LINEFEED
macro3Expected1 dd 12345
macro3Expected2 dd 19
macro3Expected3 dd -1468

; Macro 4 Variables
macro4Integer1 dd 255
macro4Integer2 dd 1988650
macro4Integer3 dd -7

; Macro 4 Test Variables
macro4Label1 db "Macro 4-1: "
macro4Label2 db "Macro 4-2: "
macro4Label3 db "Macro 4-3: "
macro4NewLine db LINEFEED

section .bss
; Macro 4 Strings
macro4String1 resb 11
macro4String2 resb 11
macro4String3 resb 11

section .text
global _start
_start:

	; DO NOT ALTER _start in any way.

	mov rax, 0
	
	; Macro 1 - Do not alter
	; Invokes the macro using macro1Message as the argument
	stringLength macro1Message

	; Macro 1 Test - Do not alter
	push rax
	mov rax, SYSTEM_WRITE
	mov rdi, STANDARD_OUT
	mov rsi, macro1Label
	mov rdx, 9
	syscall
	
	mov rdi, STANDARD_OUT
	mov rsi, macro1Fail
	mov rdx, 5
	pop rax
	cmp rax, qword[macro1Expected]
	jne macro1_Fail
		mov rsi, macro1Pass
	macro1_Fail:
	mov rax, SYSTEM_WRITE
	syscall
	
	; Macro 2 - Do not alter
	; Invokes the macro using macro2message as the argument
	toUppercase macro2Message
	
	; Macro 2 Test - Do not alter
	mov rax, SYSTEM_WRITE
	mov rdi, STANDARD_OUT
	mov rsi, macro2Label
	mov rdx, 9
	syscall
	
	mov rax, SYSTEM_WRITE
	mov rdi, STANDARD_OUT
	mov rsi, macro2Message
	mov rdx, 41
	syscall
	
	; Macro 3 - 1 - Do not alter
	; Invokes the macro with macro3Number1 and macro3Integer1
	convertDecimalToInteger macro3Number1, macro3Integer1

	; Macro 3 - 2 - Do not alter
	; Invokes the macro with macro3Number2 and macro3Integer2
	convertDecimalToInteger macro3Number2, macro3Integer2
	
	; Macro 3 - 3 - Do not alter
	; Invokes the macro with macro3Number3 and macro3Integer3
	convertDecimalToInteger macro3Number3, macro3Integer3

	; Macro 3 Test - Do not alter
	mov rax, SYSTEM_WRITE
	mov rdi, STANDARD_OUT
	mov rsi, macro3Label1
	mov rdx, 11
	syscall
	
	mov rax, SYSTEM_WRITE
	mov rdi, STANDARD_OUT
	mov rsi, macro3Fail
	mov rdx, 5
	mov ebx, dword[macro3Integer1]
	cmp ebx, dword[macro3Expected1]
	jne macro3_1_Fail
		mov rsi, macro3Pass
	macro3_1_Fail:
	syscall
	
	mov rax, SYSTEM_WRITE
	mov rdi, STANDARD_OUT
	mov rsi, macro3Label2
	mov rdx, 11
	syscall
	
	mov rax, SYSTEM_WRITE
	mov rdi, STANDARD_OUT
	mov rsi, macro3Fail
	mov rdx, 5
	mov ebx, dword[macro3Integer2]
	cmp ebx, dword[macro3Expected2]
	jne macro3_2_Fail
		mov rsi, macro3Pass
	macro3_2_Fail:
	syscall
	
	mov rax, SYSTEM_WRITE
	mov rdi, STANDARD_OUT
	mov rsi, macro3Label3
	mov rdx, 11
	syscall
	
	mov rax, SYSTEM_WRITE
	mov rdi, STANDARD_OUT
	mov rsi, macro3Fail
	mov rdx, 5
	mov ebx, dword[macro3Integer3]
	cmp ebx, dword[macro3Expected3]
	jne macro3_3_Fail
		mov rsi, macro3Pass
	macro3_3_Fail:
	syscall
	
	; Macro 4 - 1 - Do not alter
	convertIntegerToHexadecimal macro4Integer1, macro4String1
	
	; Macro 4 - 2 - Do not alter
	convertIntegerToHexadecimal macro4Integer2, macro4String2
	
	; Macro 4 - 3 - Do not alter
	convertIntegerToHexadecimal macro4Integer3, macro4String3

	; Macro 4 Test - Do not alter	
	; Test 1
	mov rax, SYSTEM_WRITE
	mov rdi, STANDARD_OUT
	mov rsi, macro4Label1
	mov rdx, 11
	syscall
	
	mov rax, SYSTEM_WRITE
	mov rdi, STANDARD_OUT
	mov rsi, macro4String1
	mov rdx, 11
	syscall	
		
	mov rax, SYSTEM_WRITE
	mov rdi, STANDARD_OUT
	mov rsi, macro4NewLine
	mov rdx, 1
	syscall	
	
	; Test 2
	mov rax, SYSTEM_WRITE
	mov rdi, STANDARD_OUT
	mov rsi, macro4Label2
	mov rdx, 11
	syscall
	
	mov rax, SYSTEM_WRITE
	mov rdi, STANDARD_OUT
	mov rsi, macro4String2
	mov rdx, 11
	syscall	
		
	mov rax, SYSTEM_WRITE
	mov rdi, STANDARD_OUT
	mov rsi, macro4NewLine
	mov rdx, 1
	syscall	
	
	; Test 3
	mov rax, SYSTEM_WRITE
	mov rdi, STANDARD_OUT
	mov rsi, macro4Label3
	mov rdx, 11
	syscall
	
	mov rax, SYSTEM_WRITE
	mov rdi, STANDARD_OUT
	mov rsi, macro4String3
	mov rdx, 11
	syscall	
		
	mov rax, SYSTEM_WRITE
	mov rdi, STANDARD_OUT
	mov rsi, macro4NewLine
	mov rdx, 1
	syscall	
	
endProgram:
	mov rax, SYSTEM_EXIT
	mov rdi, SUCCESS
	syscall