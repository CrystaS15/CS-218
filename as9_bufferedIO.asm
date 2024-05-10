; Author: Kristy Nguyen
; Section: 1001
; Date Last Modified: 10/27/2020
; Program Description: (Part 1) Use buffered I/O to read & process file efficiently

section .data
; 	System service call values
	SERVICE_EXIT 	equ 	60		; terminate
	EXIT_SUCCESS 	equ 	0 			; success code
	STANDARD_OUT 	equ 	1 			; standard output
	FAILURE 				equ 	0			; failure code
	
	SYS_read 			equ 	0 			; read
	SYS_write 			equ 	1 			; write
	SYS_open			equ 	2 			; file open
	SYS_close			equ 	3 			; file close
	SYS_creat 			equ 	85 		; file open/create
	
	O_RDONLY 			equ 	000000q 	; read only
	
	OWNER_READ		equ 	00400q
	OWNER_WRITE	equ 	00200q
	
	BUFFER_SIZE 		equ 	100000
	; BUFFER_SIZE 		equ 	1000
	; BUFFER_SIZE 		equ 	1

;	Special Characters
	LINEFEED 	equ 10
	NULL 			equ 0

; 	Variables/constants for main
	stringLength 				dq 	14
	programDone 			db 	"Program Done.", LINEFEED
	
	findString 					db 	0
	
	charactersBuffered 	dd 	0
	charactersRead 		dd 	0
	endOfFileReached 	dd 	0
	
	fileDesc 					dq 	0
	outputString				db 	"Line 0x######## Column 0x########", LINEFEED
	
	; 	Error Messages
	errorMsgOpen 			db 	"Error, opening file.", LINEFEED, NULL
	errorMsgRead			db	"Error reading from file.", LINEFEED, NULL
	errorMsgWrite 			db 	"Error writing to file.", LINEFEED, NULL
	errorInstruction			db 	"Enter <fileName> <searchString> after the program name.", LINEFEED, NULL

section .bss
	inputBuffer 	resb 		BUFFER_SIZE
	bufferArray	resb 		20
	character		resb 		1
	
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
	
	cmp 	r12, 3							; if argc = 1
	jl	 		instructionError				; 		jmp to error
	jmp 		openInputFile				; else openInputFile
	
	instructionError:							; Error:
	mov 	rdi, errorInstruction		; Enter -d <number> after the program name.
	call 		endOnError
	
; -----
;  Check that file to read/write opens successfully
	
	openInputFile:
	mov 	rax, 	SYS_open				; file open
	; mov 	r10, qword[rsi + 1*8]
	mov 	rdi, 	qword[r13 + 1*8]		; file name (argv[1])
	mov 	rsi, 	O_RDONLY				; read only
	syscall
	
	cmp 	rax, 0								; check for success
	jl 			errorOnOpen
	
	mov 	qword[fileDesc], rax			; save descriptor
	
	bufferAlgorithm:
	
	lea	 	rdi, byte[character]
	call 		getCharacter						; fill bufferArray char by char
	
	cmp 	rax, -1
	je 		errorOnRead
	
	cmp 	rax, 0
	je 		stopBuffer
	
	cmp 	rax, 1
	je 		bufferAlgorithm
	
	stopBuffer:
	
	
	
	; mov 	rdi, 	qword[r13 + 2*8]		; string to search for (argv[2])
	; ; mov 	qword[findString], 	rdi	
	; call 		cmpStrToCircularBuffer
	
; -----
;  Close the file.
	mov 	rax, 	SYS_close
	mov 	rdi, 	qword[fileDesc]
	syscall
	jmp endProgram
	
	errorOnOpen:
	mov 	rdi, errorMsgOpen
	call 		endOnError
	
	errorOnRead:
	mov 	rdi, errorMsgRead
	call 		endOnError
	
	; mov qword[fileDesc], rax				; save descriptor
	
	; mov rax, SYS_write
	; mov rdi, qword[fileDesc]
	; ; mov rsi, 
	; ; mov rdx, 
	; syscall
	
	; cmp rax, 0
	; jl errorOnWrite
	
	; errorOnWrite:
	; mov 	rdi, errorMsgWrite
	; call 		endOnError


endProgram:
; 	Outputs "Program Done." to the console
	mov rax, SYS_write
	mov rdi, STANDARD_OUT
	mov rsi, programDone
	mov rdx, qword[stringLength]
	syscall

; 	Ends program with success return value
	mov rax, SERVICE_EXIT
	mov rdi, EXIT_SUCCESS
	syscall

; Get a character from the file I/O buffer
; rdi: circularBuffer array (by reference)
; Return in rax
; 		1 	if read was successful
; 		0 	if no more characters are available
; 	   -1 	if there was an error
global getCharacter
getCharacter:
	
	startFunction:
	
	mov 	r8d,	dword[charactersRead]
	mov 	r9d,	dword[charactersBuffered]
	
	cmp 	r8, r9									; if (charactersRead < charactersBuffered)
	jae 		skip
		
		mov 	r10b, 	byte[inputBuffer + r8]		;	r8 = inputBuffer[charactersRead]
		mov 	byte[rdi], 	r10b							; 	set character from circularBuffer to r8
		inc 		dword[charactersRead]				; 	charactersRead++
		mov 	rax, 	1										;	return 1 (in rax)
		jmp 		endFunction
	
	skip:
		
		checkCharactersRead:
		push 	rdi									; preserve &char 
		mov 	rax, 	SYS_read
		mov 	rdi, 	qword[fileDesc]
		mov 	rsi, 	inputBuffer
		mov 	rdx, 	BUFFER_SIZE 			; file input buffer
		syscall
		pop 		rdi									; retrieve &char
		
		cmp 	rax, 	0								; 	ERROR
		jae 		checkBufferSize				; 	if (rax < 0)
			mov 	rax, 	-1							; 		return -1 (in rax)
			jmp 		endFunction
	
		checkBufferSize: 
		cmp 	rax, 	BUFFER_SIZE						; 	Check if end of file is reached
		jae 		continueFunction							; 	if (rax < BUFFER_SIZE)
			mov 	dword[endOfFileReached], 	1 	; 		endOfFileReached = 1
			
			checkEndOfFile:
			cmp 	dword[endOfFileReached], 1		; 	if (endOfFileReached == 1)
			jne 		checkCharactersRead
				mov 	rax, 	0									; 		return 0 (in rax)
				jmp 		endFunction
	
		continueFunction:
		mov 	dword[charactersBuffered], 	eax		; 	charactersBuffered = rax
		mov 	dword[charactersRead], 		0			; 	charactersRead = 0
		jmp 		startFunction
	
	endFunction:
	
ret

; Compare string to circular buffer
; rdi: string to search for
global cmpStrToCircularBuffer
cmpStrToCircularBuffer:
	
	mov r10, rdi 	; string to search for index
	mov r11, 0 		; circularBuffer index
	

ret

;	Convert integer to hexadecimal string
;	rdi: dword integer variable by reference
;	rsi: string (11 byte array) by reference
global convertIntegerToHexString
convertIntegerToHexString:
	push rbx

	mov byte[rsi], "0"
	mov byte[rsi+1], "x"
	mov byte[rsi+10], NULL
	
	mov rbx, rsi
	add rbx, 9
	
	mov r8d, 16 ;base
	mov rcx, 8
	mov eax, dword[rdi]
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
		je endHexConversion
		mov byte[rbx], "0"
		dec rbx
		dec rcx
	jmp addZeroes
	endHexConversion:

	pop rbx
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
	mov 	rax, SYS_write
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