; Author: Kristy Nguyen
; Section: 1001
; Date Last Modified: 10/9/2020
; Program Description: This program will explore creating and using functions in assembly.
; 	* Attempted function 1, could not do function 2, completed functions 3 & 4

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
	findLength %1	; rdx set by macro findLength
	syscall
	
	jmp endProgram
%endMacro

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
	MINIMUM_ARRAY_SIZE equ 2
	MAXIMUM_ARRAY_SIZE equ 10000
	MINIMUM_RANGE_SIZE equ 1
	MAXIMUM_RANGE_SIZE equ 100000
	INPUT_LENGTH equ 20
	; OUTPUT_LENGTH equ 11
	; VALUES_PER_LINE equ 5

	;	Labels / Useful Strings
	labelHeader db "Sorted Random Number Generator", LINEFEED, LINEFEED, NULL
	labelSorted db "Sorted Random Numbers", LINEFEED, LINEFEED, NULL

	;	Prompts
	promptCount db "Number of values to generate (2-10,000): ", NULL
	promptRange db "Maximum Value (1-100,000): ", NULL

	;	Error Messages
	;		Array Length
	errorArrayMinimum db LINEFEED, "Error - Program can only generate at least 2 value.", LINEFEED, LINEFEED, NULL
	errorArrayMaximum db LINEFEED, "Error - Program can only generate at most 10,000 values.", LINEFEED, LINEFEED, NULL
	
	; 		Range Value
	errorRangeMinimum db LINEFEED, "Error - Program can only generate maximum value of at least 1.", LINEFEED, LINEFEED, NULL
	errorRangeMaximum db LINEFEED, "Error - Program can only generate minimum value of at most 100,000.", LINEFEED, LINEFEED, NULL
							 
	;		Decimal String Conversion
	errorStringUnexpected db LINEFEED,"Error - Unexpected character found in input." , LINEFEED, LINEFEED, NULL
	errorStringNoDigits db LINEFEED,"Error - Value must contain at least one numeric digit." , LINEFEED, LINEFEED, NULL
	
	;		Input Length
	errorStringTooLong db LINEFEED, "Error - Input can be at most 20 characters long." , LINEFEED, LINEFEED, NULL

	;	Other
	arrayLength dd 0
	rangeValue dd 0
	
	; 	Function 1 Constants
	multiplierValue dd 48271
	modulusValue dd 2147483647
	seedValue dd 1

section .bss
	;	Array of integer values, not all will necessarily be used
	array resd 1000
	inputString resb 21
	outputString resb 11

section .text
global _start
_start:

	;	Output Header
	mov rax, SYSTEM_WRITE
	mov rdi, STANDARD_OUT
	mov rsi, labelHeader
	findLength	labelHeader 		; rdx set by function findLength
	syscall

	;	Output Array Length Prompt
	mov rax, SYSTEM_WRITE
	mov rdi, STANDARD_OUT
	mov rsi, promptCount
	findLength	promptCount 	; rdx set by function findLength
	syscall
	
	;	Read in Array Length - one character at a time
	mov r8, inputString
	mov r9, INPUT_LENGTH
	call readString

	;	Convert Array Length
	mov rdi, inputString
	mov esi, arrayLength
	call convertDecimalToInteger

	;	Check that Array Length is Valid - output error message and end program if not
	cmp dword[arrayLength], MINIMUM_ARRAY_SIZE
	jl arrayLengthErrorMinimum
	cmp dword[arrayLength], MAXIMUM_ARRAY_SIZE
	jg arrayLengthErrorMaximum
	jmp arrayLengthVerified
	
	arrayLengthErrorMinimum:
		endOnError errorArrayMinimum
	arrayLengthErrorMaximum:
		endOnError errorArrayMaximum
	arrayLengthVerified:
	
	; 	Output Range Prompt
	mov rax, SYSTEM_WRITE
	mov rdi, STANDARD_OUT
	mov rsi, promptRange
	findLength promptRange
	syscall
	
	; 	Read in Range Value - one character at a time
	mov r8, inputString
	mov r9, INPUT_LENGTH
	call readString
	
	; 	Convert Range Value
	mov rdi, inputString
	mov esi, rangeValue
	call convertDecimalToInteger
	
	; 	Check that Range Value is Valid - output error message and end program if not
	cmp dword[rangeValue], MINIMUM_RANGE_SIZE
	jl rangeErrorMinimum
	cmp dword[rangeValue], MAXIMUM_RANGE_SIZE
	jg rangeErrorMaximum
	jmp rangeVerified
	
	rangeErrorMinimum:
		endOnError errorRangeMinimum
	rangeErrorMaximum:
		endOnError errorRangeMaximum
	rangeVerified:
	
	; 	Output Sorted Random Numbers
	mov rax, SYSTEM_WRITE
	mov rdi, STANDARD_OUT
	mov rsi, labelSorted
	findLength labelSorted
	syscall
	
	; mov edi, seedValue
	; call function1

endProgram:
; 	Ends program with success return value
	mov rax, SYSTEM_EXIT
	mov rdi, SUCCESS
	syscall

; ;	 Function 1: Random number generator using a linear congruential generator
; ;	 rdi: previous lcg value
; global function1
; function1:
	
	; push rbx
	; push r12
	; mov r13, array
	; push r13
	
	; mov eax, dword[rdi]					; Copy doubleword value (seed = 1) into eax ( lcg(0) )
	; mov r10, 0 								; Copy 0 into r10 (counter)
	; ; mov r13, array						 	; Copy address of array into r13
	; mov r11d, dword[rangeValue]	; Copy doubleword value (range) into r11d
	
	; lcgLoop:
	; mov rbx, multiplierValue			; Copy constant a into rbx
	; mul rbx 									; Multiply previous lcg value ( lcg(n-1) ) by multiplier (a) 
													; ; 	and store value in eax ( lcg(n) )
	
	; mov r12, modulusValue
	; div r12										; Take modulus of eax and prime value (m)
	; mov eax, edx 							; 	and store value in edx to eax ( lcg(n) )
	; mov dword[rdi], eax 				; return current lcg / update lcg value
	
	; inc r11d 									; Add 1 to range
	; mov edx, 0
	; div r11d 									; Take modulus of eax ( lcg(n) ) and r11d (range+1)
	; mov eax, edx
	; mov dword[r13 + r10*4], eax 	; 	and store value in edx to array
	; inc r10
	
	; cmp r10, rangeValue 				; If counter = range
	; je lcgDone 								; 	Jump to lcgDone
	; jmp lcgLoop							; Otherwise, go to lcgLoop
	
	; lcgDone:
	
	; pop r13
	; pop r12
	; pop rbx
	
; ret

; 	Function 3: Modifies the decimal to integer macro from assignments 4/5
; 	and turn it into a function.
; 	rdi: null terminated string (byte array)
; 	rsi: dword integer variable
global convertDecimalToInteger
convertDecimalToInteger:
	
	push rbx

	mov eax, 0
	mov rbx, rdi
	mov r9d, 1	; sign
	mov r8d, 10 ; base
	mov r10, 0 ; digits processed
	
	checkForSpaces1:
		mov cl, byte[rbx]
		cmp cl, " "
		jne nextCheck1
		
		inc rbx
	jmp checkForSpaces1
	nextCheck1:

	cmp cl, "+"
	je checkForSpaces2Adjust
	cmp cl, "-"
	jne checkNumerals
	mov r9d, -1
	
	checkForSpaces2Adjust:
		inc rbx
	checkForSpaces2:
		mov cl, byte[rbx]
		cmp cl, " "
		jne nextCheck2
		
		inc rbx
	jmp checkForSpaces2
	nextCheck2:

	checkNumerals:
		movzx ecx, byte[rbx]
		cmp cl, NULL
		je finishConversion

		cmp cl, " "
		je checkForSpaces3
		
		cmp cl, "0"
		jb errorUnexpectedCharacter
		cmp cl, "9"
		ja errorUnexpectedCharacter
		jmp convertCharacter
		errorUnexpectedCharacter:
			endOnError errorStringUnexpected
			
		convertCharacter:
		sub cl, "0"
		mul r8d
		add eax, ecx
		inc r10

		inc rbx
	jmp checkNumerals
	
	checkForSpaces3:
		mov cl, byte[rbx]
		cmp cl, " "
		jne checkNull
		
		inc rbx
	jmp checkForSpaces3
	
	checkNull:
		cmp cl, NULL
		je finishConversion
			endOnError errorStringUnexpected
	
	finishConversion:
		cmp r10, 0
		jne applySign
			endOnError errorStringNoDigits
	applySign:
		mul r9d
		mov dword[rsi], eax
		
	pop rbx
	
ret

;	Function 4: Modifies the integer to hexadecimal string macro from assignments 4/5
; 	and turn it into a function.
; 	edi: dword integer variable rdi
; 	rsi: string (11 byte array) rsi
global convertIntegerToHexadecimal
convertIntegerToHexadecimal:
	
	push rbx

	mov byte[rsi], "0"
	mov byte[rsi+1], "x"
	mov byte[rsi+10], NULL
	
	mov rbx, rsi
	add rbx, 9
	
	mov r8d, 16 ;base
	mov rcx, 8
	mov eax, dword[edi]
	convertHexLoop:
		mov edx, 0
		div r8d
		
		cmp dl, 10
		jae addA
			add dl, "0" ; Convert 0-9 to "0"-"9"
		jmp nextDigit
		
		addA:
			add dl, 55 ; 65 - 10 = 55 to convert 10 to "A"
			
		nextDigit:
			mov byte[rbx], dl
			dec rbx
			dec rcx
	cmp eax, 0
	jne convertHexLoop

	addZeroes:
		cmp rcx, 0
		je endConversion
		mov byte[rbx], "0"
		dec rbx
		dec rcx
	jmp addZeroes
	endConversion:
	
	pop rbx

ret

; 	Clears input buffer
; 	No arguments
global clearInputBuffer
clearInputBuffer:

	clearBufferLoop:
		mov rax, SYSTEM_READ
		mov rdi, STANDARD_IN
		lea rsi, byte[inputString]
		mov rdx, 1
		syscall
	cmp byte[inputString], LINEFEED
	jne clearBufferLoop

ret

;	Reads a string in from standard in
;	r8: Address of location to place string
;	r9: Integer max length of string
global readString
readString:
	
	push rbx
	
	mov rbx, 0
	readLengthLoop:
		mov rax, SYSTEM_READ
		mov rdi, STANDARD_IN
		lea rsi, byte[r8 + rbx]
		mov rdx, 1
		syscall
				
		inc rbx
		cmp byte[r8 + rbx - 1], LINEFEED
		je readLengthDone
	
	inc r9
	cmp rbx, r9
	jb readLengthLoop
		call clearInputBuffer
		endOnError errorStringTooLong
	readLengthDone:
	mov byte[r8 + rbx - 1], NULL

	pop rbx

ret