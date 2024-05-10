; Author: Kristy Nguyen
; Section: 1001
; Date Last Modified: 9/27/2020
; Program Description: This program reads in decimal values and outputs their hex equivalents
; Extra Credit Attempted - Yes

;	Determines the number of characters (including null) of the provided string
;	Argument 1: Address of string
;	Returns length in rdx
%macro findLength 1
	push rcx
	
	mov rdx, 1
	%%countLettersLoop:
		mov cl, byte[%1 + rdx - 1]
		cmp cl, NULL
		je %%countLettersDone
		
		inc rdx
	loop %%countLettersLoop
	%%countLettersDone:
	
	pop rcx
%endmacro

;	Outputs error message and stops program execution
;	Argument 1: Address of error message
%macro endOnError 1
	mov rax, SYSTEM_WRITE
	mov rdi, STANDARD_OUT
	mov rsi, %1
	findLength %1						; rdx set by macro findLength
	syscall
	
	jmp endProgram
%endMacro

; Macro 3 - Convert a Decimal String to Integer
; Argument 1: null terminated string (byte array)
; Argument 2: dword integer variable
%macro convertDecimalToInteger 2
	; YOUR CODE HERE
	mov rbx, %1
	
	; -----
	; 	Step 1: 0 or more spaces (1)
	
	%%skipSpaces1:
		mov cl, byte[rbx]	; current char
		inc rbx 				; next char
		cmp cl, " "
	je %%skipSpaces1
	
	dec rbx 					; reset pointer to current char
	
	mov r8, 1 				; positive sign
	
	; -----
	; 	Step 2: A '+' or '-' may appear
	
	cmp cl, "+" 
		je %%signDone 
	cmp cl, "-" 					; if char is not "+" or "-"
		jne %%skipSpaces2 ; go to next step
	mov r8, -1 					; negative sign
		
	%%signDone:
		inc rbx 					; next char
	
	; -----
	; 	Step 3: 0 or more spaces (2)
	%%skipSpaces2:
		mov cl, byte[rbx]	; current char
		inc rbx 				; next char
		cmp cl, " " 
	je %%skipSpaces2 
	
	dec rbx 					; reset to current char
	
	cmp cl, NULL								; errorStringNoDigits
	jne %%checkUnexpected
	endOnError errorStringNoDigits
	
	%%checkUnexpected:
	cmp cl, '0'
		jb %%errorUnexpected
	cmp cl, '9'
		jbe %%startDigit
	
	%%errorUnexpected:						; errorUnexpected
	endOnError errorStringUnexpected
	
	%%startDigit:
	; Step 4: 1 or more numerals ('0' to '9')
	mov eax, 0 						; value = 0
	mov r10d, 10
	%%digitLoop:
		mul r10d 						; value = value * 10
		movzx ecx, byte[rbx]
		sub ecx, 30h 				; ascii to decimal
		add eax, ecx 				; value = value + digit
		inc rbx 						; next char
		
		mov cl, byte[rbx]
		
		cmp cl, NULL 				; end digitLoop if NULL
		je %%digitLoopDone
		
		cmp cl, " "
		jne %%digitLoop
		endOnError errorStringUnexpected
		
	jmp %%digitLoop
	
	%%digitLoopDone:
		dec rbx 						; reset to current char
		cmp r8, -1
			je %%negativeValue
	
	%%negativeValue:
		mul r8
	
	; Extra Credit - Signed Double Word Integer Error
	mov r15d, eax

	cmp eax, 0
	jl %%signedDoubleMinimum
	
	; Adding 1 to 2147483647 makes value below minimum
	inc eax
	cmp eax, 0
	jl %%errorOutOfSignedRange
	jmp %%storeIntegerValue
	
	; Subtract 1 to -2147483648 makes value above maximum
	%%signedDoubleMinimum:
	dec eax
	cmp eax, 0
	jg %%errorOutOfSignedRange
	jmp %%storeIntegerValue
	
	%%errorOutOfSignedRange:
	endOnError errorSignedDoubleRange
	
	%%storeIntegerValue:
	mov eax, r15d
	mov dword[%2], eax	; store answer in provided variable
	
	; Step 5: 0 or more spaces (3)
	%%skipSpaces3:
		mov cl, byte[rbx]
		inc rbx						; next char
		cmp cl, " "
	je %%skipSpaces3
		
	dec rbx						; reset to current char
	
	; Step 6: A NULL character
	mov rax, 0
	%%readLoop:
		mov bl, byte[%1 + rax]
		inc rax
		cmp bl, NULL 				; if current char is null
			je %%endReadLoop	; stop reading the string
		jmp %%readLoop 			; repeat loop	
	%%endReadLoop:
%endmacro

; Macro 4 - Convert an Integer to a Hexadecimal String
; Argument 1: dword integer variable
; Argument 2: string (11 byte array)
%macro convertIntegerToHexadecimal 2
	; YOUR CODE HERE
	mov eax, dword[%1]			; move dword integer variable into eax
	mov rsi, 9
	mov byte[%2 + 10], NULL 	; place null char
	mov ebx, 16
	%%hexLoop:
		cmp eax, 0 						; if value = 0, fill in remainder of hex digits
			je %%fillHex
		cmp rsi, 2 						; if index < 2, hex digits are fully converted
			jl %%hexDone
	
		mov edx, 0
		div ebx 							; divide value by 16
		cmp edx, 9
			jg %%convert10to15
		
		add edx, 48						; If remainder is between 0 and 9, convert to '0' - '9'
		mov cl, dl 						; copy remainder in byte to cl
		mov byte[%2 + rsi], cl		; copy cl to byte array
		dec rsi 							; move to previous byte
		jmp %%hexLoop
		
		%%convert10to15: 			; else convert to 'A' - 'F'
			add edx, 55
			mov cl, dl
			mov byte[%2 + rsi], cl
			dec rsi
			jmp %%hexLoop
		
		%%fillHex:
			cmp rsi, 2					; if index < 2, hex digits are fully converted
				jl %%hexDone
			mov byte[%2 + rsi], '0'
			dec rsi
			jmp %%fillHex
			
	%%hexDone: 						; display "0x" before hex digits
		mov byte[%2 + 1], 'x'
		mov byte[%2], '0'
		
%endmacro

section .data
	; 	System Service Call Constants
	SYSTEM_EXIT equ 60
	SUCCESS equ 0
	SYSTEM_WRITE equ 1
	SYSTEM_READ equ 0
	STANDARD_OUT equ 1
	STANDARD_IN equ 0

	;	ASCII Values
	NULL equ 0
	LINEFEED equ 10
	
	;	Program Constraints
	MINIMUM_ARRAY_SIZE equ 1
	MAXIMUM_ARRAY_SIZE equ 1000
	INPUT_LENGTH equ 20
	OUTPUT_LENGTH equ 11
	VALUES_PER_LINE equ 5
	
	; Variables
	totalNumToConvert dd 0
	tempInteger dd 0
	; tempStr db ""
	
	;	Labels / Useful Strings
	labelHeader db "Number Converter (Decimal to Hexadecimal)", LINEFEED, LINEFEED, NULL
	labelConverted db "Converted Values", LINEFEED, NULL
	endOfLine db LINEFEED, NULL
	space db " "
	
	;	Prompts
	promptCount db "Enter number of values to convert (1-1000):", LINEFEED, NULL
	promptDataEntry db "Enter decimal value:", LINEFEED, NULL
	
	;	Error Messages
	;		Array Length
	errorArrayMinimum db LINEFEED, "Error - Program can only convert at least 1 value.", LINEFEED, LINEFEED, NULL
	errorArrayMaximum db LINEFEED, "Error - Program can only convert at most 1,000 values.", LINEFEED, LINEFEED, NULL
	
	errorSignedDoubleRange db LINEFEED, "Error - Value is not within valid range for signed double word integer.", LINEFEED, LINEFEED, NULL
							 
	;		Decimal String Conversion
	errorStringUnexpected db LINEFEED,"Error - Unexpected character found in input." , LINEFEED, LINEFEED, NULL
	errorStringNoDigits db LINEFEED,"Error - Value must contain at least one numeric digit." , LINEFEED, LINEFEED, NULL
	
	;		Input Length
	errorStringTooLong db LINEFEED, "Error - Input can be at most 20 characters long." , LINEFEED, LINEFEED, NULL
	
	;	Other
	arrayLength dd 0

section .bss
	;	Array of integer values, not all will necessarily be used
	array resd 1000
	inputString resb 22 					; changed from 21 to 22
	outputString resb 11
	
	chr resb 1
	inLine resb INPUT_LENGTH+2	; total of 22

section .text
global _start
_start:
	
	; -----
	;	Output Header
		
		mov rdi, labelHeader
		call printString
	
	; -----
	;	Output Array Length Prompt
	
		mov rdi, promptCount
		call printString
	
	; -----
	;	Read in Array Length - one character at a time
	
		mov rbx, inputString		; inLine address
		mov r12, 0 					; char count
		readArrayLength:
			mov rax, SYSTEM_READ
			mov rdi, STANDARD_IN
			lea rsi, byte[chr] 		; address of chr
			mov rdx, 1
			syscall
			
			mov al, byte[chr] 		; get character just read
			cmp al, LINEFEED 	; if linefeed, input done
			je readArrayDone
			
			inc r12 					; count++
			cmp r12, inputString	; if # chars >= inLine
			jae readArrayLength	; 	stop placing in buffer
			
			mov byte[rbx], al		; inputString[i] = chr
			inc rbx						; update tempStr address
			
			jmp readArrayLength
		readArrayDone:
			mov byte[rbx], NULL	; add NULL termination
	
		findLength inputString
		cmp rdx, INPUT_LENGTH + 2
		jle convertArrayLength
		endOnError errorStringTooLong
	
	convertArrayLength:
	; -----
	;	Convert Array Length	
	
	convertDecimalToInteger inputString, arrayLength
	
	; -----
	;	Check that Array Length is Valid - output error message and end program if not
	
	cmp dword[arrayLength], 1 		; errorArrayMinimum
	jge minimumCheckDone
	endOnError errorArrayMinimum
	
	minimumCheckDone:
	
	cmp dword[arrayLength], 1000	; errorArrayMaximum
	jle maximumCheckDone
	endOnError errorArrayMaximum
	
	maximumCheckDone:
	
	findLength inputString				; errorStringTooLong
	cmp rdx, INPUT_LENGTH+2
	jle startReadingValues
	endOnError errorStringTooLong 
	
	startReadingValues:
	; mov rcx, arrayLength
	readInValues:
		; -----
		;	Read in Array Values
		mov rdi, promptDataEntry
		call printString
		
		mov rbx, inputString		; inLine address
		mov r12, 0 					; char count
		readArrayValues:
			mov rax, SYSTEM_READ
			mov rdi, STANDARD_IN
			lea rsi, byte[chr] 		; address of chr
			mov rdx, 1
			syscall
			
			mov al, byte[chr] 		; get character just read
			cmp al, LINEFEED 	; if linefeed, input done
			je readValuesDone
			
			inc r12 					; count++
			cmp r12, inputString	; if # chars >= inLine
			jae readArrayValues	; 	stop placing in buffer
			
			mov byte[rbx], al		; inputString[i] = chr
			inc rbx						; update tempStr address
			
			jmp readArrayValues
		readValuesDone:
			mov byte[rbx], NULL	; add NULL termination
	
		findLength inputString
		cmp rdx, INPUT_LENGTH + 2
		jle convertArrayValues
		endOnError errorStringTooLong	; errorStringTooLong
	
		convertArrayValues:
		convertDecimalToInteger inputString, tempInteger
		; convertIntegerToHexadecimal tempInteger, outputString
	
	; dec rcx	
	; cmp rcx, 0
	; jne readInValues
	
		mov rdi, labelConverted
		call printString
	
endProgram:
	mov rax, SYSTEM_EXIT
	mov rdi, SUCCESS
	syscall

; ************************************************************	
;  Generic function to display a string to the screen.
;  String must be NULL terminated.
;  Algorithm:
;    Count characters in string (excluding NULL)
;    Use syscall to output characters

;     Arguments:
;     1) addresss, string
;     Returns:
;     nothing

	global printString
	printString:
		push rbx
	; -----
	; Count characters in string.
	
		mov rbx, rdi
		mov rdx, 0
	strCountLoop:
		cmp byte[rbx], NULL
		je strCountDone
		inc rdx
		inc rbx
		jmp strCountLoop
	strCountDone:
		
		cmp rdx, 0
		je prtDone
		
	; -----
	; Call OS to output string.
	
		mov rax, SYSTEM_WRITE
		mov rsi, rdi
		mov rdi, STANDARD_OUT
	
		syscall
	
	; -----
	; String Printed, return to calling routine.
	
	prtDone:
		pop rbx
		ret
	
	; -----