; Author: Kristy Nguyen
; Section: 1001
; Date Last Modified: 10/23/2020
; Program Description: This assignment will explore the use of accessing functions from a library 
; 									and processing command line arguments

section .data
; 	System service call values
	SERVICE_EXIT  	equ 	60
	SERVICE_WRITE equ 	1
	EXIT_SUCCESS 	equ 	0
	STANDARD_OUT 	equ 	1
	SYSTEM_WRITE 	equ 	1
	FAILURE 				equ 	0

;	Special Characters
	LINEFEED 	equ 10
	NULL 			equ 0

; 	Strings
	stringLength 		dq 	14
	formatString 		db 	"Halfsphere Volume: %f", LINEFEED, NULL

	; 	Error Messages
	; 		Invalid Instruction Error
	errorInstruction  	db 	"Enter -d <number> after the program name.", LINEFEED, NULL
	
	; 		Invalid Diameter Tag Error
	errorDiameterTag 	db 	"Invalid diameter tag.", LINEFEED, NULL
	
	; 		Numeric Diameter Error
	errorNumericDiameter 	db 	"Invalid numeric format for diameter.", LINEFEED, NULL

; -----
;  Variables for main.
	
	errorVariable 		dq 	0.0
	
	numberTwo		dq 	2.0
	numberThree 	dq 	3.0
	valuePI 			dq 	3.14159

; -----
;  Setting up external function calls
extern atof, printf

section .text
global main
main:

; -----
;  Get command line arguments
;  Based on standard calling convention,
; 		rdi = argc (argument count)
; 		rsi = argv (starting address of argument vector)
	
	mov 	r12, rdi 	; save for later use...
	mov 	r13, rsi
	
	cmp 	r12, 1							; if argc = 1
	je 		instructionError				; 	jmp to error
	jmp 		checkArgumentTwo		; else checkArgumentTwo
	
	instructionError:							; Error:
	mov 	rdi, errorInstruction		; Enter -d <number> after the program name.
	call 		endOnError
	
	checkArgumentTwo:
	mov 	rbx, qword[r13 + 1*8] 		; address to 2nd argument
	cmp 	word[rbx], "-d"					; if diameter tag is invalid...
	jne 		diameterTagError				; 	jmp to error
	cmp 	byte[rbx+2], NULL
	jne 		diameterTagError				
	jmp 		checkArgumentThree			; else checkArgumentThree
	
	diameterTagError:							; Error: 
	mov 	rdi, errorDiameterTag			; Invalid diameter tag.
	call 		endOnError
	
	checkArgumentThree:
	mov 	rdi, qword[r13 + 2*8] 		; address to 3rd argument
	call 		atof 									; convert string to double precision float value (xmm0)
	
	movsd 	xmm1, qword[errorVariable]
	ucomisd 	xmm0, xmm1 							; if atof returns 0.0 in xmm0...
	je 			numericDiameterError				; 	jmp to error
	jmp 			calculateHalfSphereVolume		; else calculateHalfSphereVolume
	
	numericDiameterError:						; Error:
	mov 	rdi, errorNumericDiameter		; Invalid numeric format for diameter.
	call 		endOnError
	
	calculateHalfSphereVolume:
	call 			halfSphereVolume
		
; -----
;  Program done.
	
endProgram:
; ; 	Outputs "Program Done." to the console
	; mov 	rax, SERVICE_WRITE
	; mov 	rdi, STANDARD_OUT
	; mov 	rsi, programDone
	; mov 	rdx, qword[stringLength]
	; syscall

; 	Ends program with success return value
	mov 	rax, SERVICE_EXIT
	mov 	rdi, EXIT_SUCCESS
	syscall
	
; -----
;  Calculates and returns the volume of a half sphere using
; 		radius = diameter / 2
; 		PI = 3.14159
; 		halfSphereVolume = 2 / 3 * PI * radius^3
; 	and print result using printf( )
; 	xmm0 - diameter (float)
global halfSphereVolume
halfSphereVolume:
	; -----
	;  Calculate half sphere volume
	movsd 	xmm1, qword[numberTwo]		; xmm1 = 2.0
	movsd 	xmm2, qword[numberThree]		; xmm2 = 3.0
	divsd 		xmm1, xmm2 							; xmm1 = (2 / 3)
	
	movsd 	xmm2, qword[valuePI]				; xmm2 = valuePI
	mulsd 		xmm1, xmm2 							; xmm1 = (2 / 3 * PI)
	
	movsd 	xmm2, xmm0							; xmm2 = diameter
	
	movsd 	xmm3, qword[numberTwo]		; xmm3 = 2.0
	divsd 		xmm2, xmm3 							; xmm2 = radius = (diameter / 2)
	
	mulsd 		xmm1, xmm2 							; xmm1 = 2 / 3 * PI * radius
	mulsd 		xmm1, xmm2 							; xmm1 = 2 / 3 * PI * radius^2
	mulsd 		xmm1, xmm2 							; xmm1 = 2 / 3 * PI * radius^3
	
	movsd 	xmm0, xmm1 							; xmm0 = xmm1
	
	mov 		rdi, formatString
	mov 		rax, 1
	call 			printf
	
ret
	
;	Counts the number of characters in the null terminated string
;	rdi - string address
;	rax - return # of characters in string (including null)
global stringCount
stringCount:
	mov rax, 1
	
	countCharacterLoop:
		mov 	cl, byte[rdi + rax - 1]
		cmp 	cl, NULL
		je 		countCharacterDone
		
		inc 		rax
	jmp 			countCharacterLoop
	countCharacterDone:
ret

;	Prints the provided null terminated string
;	rdi - string address
global printString
printString:
	push 	rdi
	call 		stringCount
	pop 		rdi
	
	mov 	rdx, rax							; string length
	mov 	rax, SYSTEM_WRITE
	mov 	rsi, rdi
	mov 	rdi, STANDARD_OUT
	syscall
ret

;	Prints an error message and ends the program
;	rdi - string address of error message
global endOnError
endOnError:
	call 		printString

	mov 	rax, SERVICE_EXIT
	mov 	rdi, FAILURE
	syscall
ret