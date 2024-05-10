; Author: Kristy Nguyen
; Section: 1001
; Date Last Modified: 10/16/2020
; Program Description: This program is designed to explore the use of floating points and local variables to calculate 
; 										triangle hypotenuses and find the median hypotenuse

section .data
	SYSTEM_EXIT equ 60
	SUCCESS equ 0

	aSides 	dd 	4.57, 8.47, 10.25, 9.42, 8.67
				dd	8.63, 10.06, 10.97, 7.60, 6.00
				dd	1.65, 10.23, 10.26, 10.77, 11.48
				dd	4.48, 11.06, 8.06, 1.52, 7.57
				dd	11.48, 8.78, 2.08, 10.43, 5.91
				dd	7.10, 2.85, 10.97, 5.49, 10.55
				dd	11.16, 6.14, 0.86, 9.14, 3.33
				dd	3.36, 8.86, 9.11, 8.49, 10.32
				dd	7.87, 5.10, 6.81, 0.34, 1.30
				dd	7.52, 1.48, 5.68, 3.97, 3.35
				dd	4.84, 9.29, 2.61, 7.49, 8.83
				dd	7.34, 10.94, 5.08, 11.67, 11.13
				dd	11.65, 1.96, 8.51, 9.46, 0.80
				dd	2.58, 6.79, 1.55, 7.83, 4.46
				dd	6.59, 5.32, 6.31, 3.73, 11.06

	bSides	dd	5, 5, 6, 10, 13
				dd	8, 5, 1, 7, 8
				dd	6, 7, 15, 8, 9
				dd	6, 11, 13, 15, 13
				dd	8, 8, 15, 7, 11
				dd	5, 9, 1, 7, 2
				dd	10, 12, 4, 9, 9
				dd	5, 14, 8, 9, 3
				dd	10, 3, 8, 1, 3
				dd	4, 2, 14, 4, 12
				dd	8, 6, 1, 5, 15
				dd	5, 3, 12, 8, 5
				dd	1, 14, 10, 2, 10
				dd	6, 7, 5, 9, 4
				dd	5, 13, 5, 2, 6

section .bss
	median dd 1
	ARRAY_SIZE equ 75
	
section .text
global _start
_start:
	mov rdi, aSides
	mov rsi, bSides
	call findHypotenuses
		
	movss dword[median], xmm0
	
	endProgram:
		mov rax, SYSTEM_EXIT
		mov rdi, SUCCESS
		syscall

;	Calculates the hypotenuses of triangles based on the other two sides
;	Finds the median length and the total of all lengths
;	Arguments
;	rdi:	&a sides[] (floats)
;	rsi:	&b sides[] (dword integers)
;	Local Variables
;	rbp - 300:	Float array of hypotenuses (75 floats)
;	Better Alternative: rbp - ARRAY_SIZE * 4
;	Constants
;	Array size provided by constant ARRAY_SIZE
global findHypotenuses
findHypotenuses:
;	Establish Base Pointer
	push	rbp				; Save base pointer to stack
									; rsp decremented by 8
	mov 	rbp, rsp		; Establish stack frame
									; rsp decremented by 8
							
;	Local Variable Allocation
	sub 		rsp, ARRAY_SIZE * 4
						
;	Preserved Registers
	push 	rbx
	
;	Calculate Hypotenuses
;	C[i] = sqrt(A[i]^2 + B[i]^2)
	mov 	rcx, ARRAY_SIZE
	mov 	rbx, 0
	hypotenusesLoop:
		movss 		xmm1, dword[rdi+rbx*4] 		; store A[i] into 32-bit float reg
		mov			eax, dword[rsi+rbx*4] 			; store B[i] into 32-bit float reg
		mulss 		xmm1, xmm1 						; A[i]^2
		mul 			eax 										; B[i]^2
		cvtsi2ss 	xmm2, eax 							; convert B[i]^2 into 32-bit float reg
		addss		xmm1, xmm2 						; A[i]^2 + B[i]^2
		sqrtss 		xmm1, xmm1 						; sqrt( A[i]^2 + B[i]^2 )
;		Store in local array
		movss 		dword[rbp - ARRAY_SIZE*4 + rbx*4], xmm1 		; Store C[i] (32-bit float reg) into Float array
		inc 			rbx
	loop 	hypotenusesLoop

;	Sort List
;		Call combSort with address to list in stack
	mov 	rdi, rbp
	sub 		rdi, ARRAY_SIZE*4
	mov 	esi, ARRAY_SIZE
	call 		combSort

;	Find Median
	mov 	rbx, ARRAY_SIZE/2
	
;	Restore Argument
;		Median is in sorted list at Length / 2 (odd length lists)
;		Store Median in Return Register
	movss 		xmm0, dword[rbp - ARRAY_SIZE*4 + rbx*4]
	
;	Set Breakpoint HERE for debug script

;	Restore Preserved Registers
	pop 		rbx
;	Clear Local Variables
	mov 	rsp, rbp
;	Restore RBP
	pop 		rbp
ret

;	Function 2 - Combsort
;	rdi - array reference (dwords)
;	rsi - array length by value (dword)
global combSort
combSort:
	push 	rbx
	
	mov 	eax, esi													; Gap Size = Length
	mov 	r10d, 10
	mov 	r11d, 13
	gapLoop:
;		Adjust Gap Size:  gap * 10 / 13
		mul 		r10d
		div 		r11d
		
;		Ensure gap size does not go below 1
		cmp 		eax, 0
		ja 			skipFloor
			mov 	eax, 1
		skipFloor:
		
		mov 	ecx, esi		; n
		sub 		ecx, eax		; n - gapsize
		mov 	rdx, 0			; i
		mov 	r8, 0				; Swaps Done
		combSortLoop:													; while i < n - gapsize
			movss 		xmm1, dword[rdi + rdx * 4]
			add 			edx, eax										; i + gapsize
			ucomiss 	xmm1, dword[rdi + rdx * 4]
			ja 	swap
				sub 		edx, eax										; i
			jmp 	swapDone
			swap:
				movss 		xmm2,  dword[rdi + rdx * 4]
				movss 		dword[rdi + rdx * 4], xmm1
				sub 			edx, eax	; i
				movss 		dword[rdi + rdx * 4], xmm2
				inc 			r8													; add to swap count
			swapDone:
			inc 	edx	; i++
		dec 		rcx
		cmp 	rcx, 0
		jne 		combSortLoop
		
;		Only check for swaps done when gap size is 1
		cmp 	eax, 1
		jne 		gapLoop
		
		cmp 	r8, 0
		je 		combSortDone
	jmp 		gapLoop
	combSortDone:
	
	pop 		rbx
ret