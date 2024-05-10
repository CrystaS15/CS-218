#; Author: Kristy Nguyen
#; Section: 1001
#; Date Last Modified: 11/20/2020
#; Program Description: 
#;		Assignment 12
#;		This program entails writing a series of functions and using floating point instructions

.data
#;	System Service Codes
	SYSTEM_EXIT = 10
	SYSTEM_PRINT_INTEGER = 1
	SYSTEM_PRINT_FLOAT = 2
	SYSTEM_PRINT_STRING = 4
	
#;	Function Input Data
	squareRootValue1: .word 1742
	squareRootValue2: .word 4566
	floatSquareRootValue1: .float 15135.0
	floatSquareRootValue2: .float 911560.50
	floatTolerance1: .float 0.01
	floatTolerance2: .float 0.001
	
	printArray: .word 1, 1, 1, 1, 1, 1
				.word 1, 0, 0, 0, 0, 1
				.word 1, 0, 0, 0, 0, 1
				.word 1, 0, 0, 0, 0, 1
				.word 1, 0, 0, 0, 0, 1
				.word 1, 1, 1, 1, 1, 1
				.word 1, 1
	PRINT_ARRAY_LENGTH = 38
	
	arrayValues: .word	377, 148, 641, -486, 828, 456, 192, -742, -658, -139 
				 .word	801, -946, 325, 916, 982, 902, -809, 858, -510, -713
				 .word	-309, 515, 587, 320, 994, 528, -617, -515, -123, 294
				 .word	644, -339, 842, -441, -557, 58, 773, 694, 78, -744
				 .word	-350, -424, -514, -679, 402, -924, -178, 315, 509, 173
				 .word	44, -80, -340, 905, -840, -210, 671, -755, -809, 731
				 .word	-936, -414, 627, -565, -749, -804, -456, -236, 933, 961
				 .word	-675, -9, 653, 581, -567, 916, 738, 343, 684, -184
				 .word	-789, -400, -941, 145, 933, 230, -236, 880, 646, -926
				 .word	982, 221, -451, -783, 331, -157, 193, 940, -818, 270
	ARRAY_LENGTH = 100
	
#;	Labels
	endLabel: .asciiz ".\n"
	newLine: .asciiz "\n"
	space: .asciiz " "
	squareRootLabel1: .asciiz "The square root of 1742 is "
	squareRootLabel2: .asciiz "The square root of 4566 is "
	squareRootFloatLabel1: .asciiz "The square root of 15135.0 is "
	squareRootFloatLabel2: .asciiz "The square root of 911560.50 is "
	printArrayLabel: .asciiz "\nPrint Array Test:\n"
	unsortedLabel: .asciiz "\nUnsorted List:\n"
	sortedLabelAscending: .asciiz "\nSorted List (Ascending):\n"

.text
#;	Function 1: Integer Square Root Estimation
#;	Estimates the square root using Newton's Method
#;	Argument 1: Integer value to find the square root of
#;	Returns: The estimated square root as an integer
.globl estimateIntegerSquareRoot
.ent estimateIntegerSquareRoot
estimateIntegerSquareRoot:
#;	New Estimate = (Old + Value/Old)/2

	move 	$t0, $a0 	#; Old Estimate
	
	estimationLoop:
		divu 	$t1, $a0, $t0 	#; New Estimate = value/old
		add 	$t1, $t1, $t0 	#; New Estimate = value/old + old
		div 	$t1, $t1, 2 	#; New Estimate = (value/old+old)/2
		
		sub 	$t2, $t0, $t1 	#; Difference = Old - New
		move 	$t0, $t1 		#; Old = New
	#; Exit loop if |Difference| <= 1
	blt 	$t2, -1, estimationLoop
	bgt 	$t2, 1, estimationLoop
	
	move 	$v0, $t0 	#; Store estimated square root of value

	jr $ra
.end estimateIntegerSquareRoot

#; Function 2: Float Square Root Estimation
#;	Estimates the square root using Netwon's Method
#;	Argument 1: Float value to find the square root of
#;	Argument 2: Float value representing the tolerance level to stop at
#;	Returns: The estimated square root as a float

#;	Floating Point Comparison
#;	Use c.lt.s FRsrc1, FRsrc2 to set the comparison flag
#;	Use bc1t label to branch if the comparison was true
#;	Example:
#;		c.lt.s $f0, $f1
#;		bc1t estimateLoop #; Branch if $f0 < $f1
#;	In this version of MIPS, there is no greater than comparisons
.globl estimateFloatSquareRoot
.ent estimateFloatSquareRoot
estimateFloatSquareRoot:
#;	New Estimate = (Old + Value/Old)/2

	mov.s $f2, $f12 #; Old Estimate
	
	mov.s $f8, $f14 #; Tolerance
	
	li 			$t0, -1
	mtc1 		$t0, $f10
	cvt.s.w 	$f10, $f10		#; Store -1 in $f10
	
	li 			$t0, 2
	mtc1 		$t0, $f16
	cvt.s.w 	$f16, $f16		#; Store 2 in $f16
	
	div.s 		$f8, $f8, $f10 	#; -Tolerance
	
	floatEstimationLoop:
		div.s 	$f4, $f12, $f2 	#; New Estimate = value/old
		add.s 	$f4, $f4, $f2 	#; New Estimate = value/old + old
		
		
		
		div.s 	$f4, $f4, $f16 	#; New Estimate = (value/old+old)/2
		
		sub.s 	$f6, $f2, $f4	#; Difference = Old - New
		mov.s 	$f2, $f4		#; Old = New
	 
	#; Exit loop if Difference >= -Tolerance OR Difference <= Tolerance
	c.lt.s 		$f6, $f8
	bc1t 		floatEstimationLoop
	
	c.lt.s 		$f14, $f6
	bc1t 		floatEstimationLoop
	
	mov.s 		$f0, $f2	#; Store estimated square root of value

	jr $ra
.end estimateFloatSquareRoot

#;	Function 3: Print Integer Array
#;	Prints the elements of the array to the terminal
#;	On each line, output a number of values equal to the square root of the total number of elements
#;	Use estimateIntegerSquareRoot to determine how many elements should be printed on each line
#;	Argument 1: Address of array to print
#;	Argument 2: Integer count of the number of elements in the array
.globl printIntegerArray
.ent printIntegerArray
printIntegerArray:
#;	Remember to push and pop $ra for non-leaf functions
	subu 	$sp, $sp, 8		#; preserve registers
	sw 		$s0, ($sp)
	sw 		$ra, 4($sp)
	
	move 	$s0, $a0
	
	move 	$a0, $a1		#; square root the total number of elements
	jal 	estimateIntegerSquareRoot
	
	move 	$v0, $t0 		#; save number of elements to print on each line
	
	li 		$t8, 0			#; index (i)
	li 		$t9, 0 			#; counter
	
	printIntegers:
	
		printColumn:
			lw 		$t1, ($s0)
			
			li 		$v0, SYSTEM_PRINT_INTEGER		#; Print
			move 	$a0, $t1						#; array element
			syscall
			
			li 		$v0, SYSTEM_PRINT_STRING 		#; Print
			la 		$a0, space 						#; space
			syscall
			
			addu 	$s0, $s0, 4			#; printArray[i+1]
			add 	$t8, $t8, 1			#; i++
			add 	$t9, $t9, 1
		beq 	$t9, $a1, endPrintColumn 	#; if counter == PRINT_ARRAY_LENGTH, exit printColumn
		blt 	$t8, $t0, printColumn		#; if index < number of elements per line -> printColumn
		
		endPrintColumn:
		
		li 		$v0, SYSTEM_PRINT_STRING	#; Print
		la 		$a0, newLine				#; newLine
		syscall
		
		li 		$t8, 0		#; Reset index
	
	blt $t9, $a1, printIntegers		#; if counter < PRINT_ARRAY_LENGTH --> printIntegers
	
	lw 		$s0, ($sp)		#; Restore registers and return to calling routine
	lw 		$ra, 4($sp)
	addu 	$sp, $sp, 8
	
	jr $ra
.end printIntegerArray

#; Function 4: Integer Comb Sort (Ascending)
#;	Uses the comb sort algorithm to sort a list of integer values in ascending order
#; Argument 1: Address of array to sort
#;	Argument 2: Integer count of the number of elements in the array
#;	Returns: Nothing
.globl sortList
.ent sortList
sortList:
	subu 	$sp, $sp, 20	#; preserve registers
	sw 		$s0, ($sp)
	sw 		$s1, 4($sp)
	sw 		$s2, 8($sp)
	sw 		$ra, 16($sp)
	
	move 	$t7, $a1 		#; Gap Size = Length
	gapLoop:
	#; Adjust Gap Size: gap * 10 / 13
		mul 	$t7, $t7, 10
		div 	$t7, $t7, 13
	
	#; Ensure gap size does not go below 1
		bgt 	$t7, 0, skipFloor
		li 		$t7, 1
		
		skipFloor:
		move 	$t6, $a1 		#; n
		sub 	$t6, $t6, $t7	#; n - gapsize
		li 		$t9, 0			#; i
		li 		$t5, 0 			#; Swaps Done
		
		combSortLoop: 	#; while i < n - gapsize
			mul 	$s1, $t9, 4		#; i*4
			add 	$t0, $a0, $s1 	#; array[i*4]
			lw 		$t3, ($t0)
			
			add 	$t8, $t9, $t7 	#; i+gapsize
			mul 	$s2, $t8, 4		#; (i+gapsize)*4
			add 	$t1, $a0, $s2 	#; array[i+gapsize]
			lw 		$t4, ($t1)
			
			bgt 	$t3, $t4, swap 	#; if array[i] > array[i+gapsize] -> swap
			j 		swapDone
			
			swap:
				lw 		$t2, ($t0) 	#; load array[i] into $t2 (temp)
				sw 		$t4, ($t0) 	#; store $t4 (array[i+gapsize]) into array[i]
				sw 		$t2, ($t1)	#; store $t2 (array[i]) into array[i+gapsize]
			
				add 	$t5, $t5, 1	#; swapsDone++
			swapDone:
			add 	$t9, $t9, 1 	#; i++
		blt 	$t9, $t6, combSortLoop 	#; if i < n - gapsize --> combSortLoop
		
		#; Only check for swaps done when gap size is 1
		bne 	$t7, 1, gapLoop			#; if gapsize != 1 --> gapLoop
		
		beq 	$t5, 0, combSortDone	#; if swapsDone == 0 --> combSortDone
		
	j gapLoop
	combSortDone:
	
	lw 		$s0, ($sp)		#; Restore registers and return to calling routine
	lw 		$s1, 4($sp)
	lw 		$s2, 8($sp)
	lw 		$ra, 16($sp)
	addu 	$sp, $sp, 20

	jr $ra
.end sortList


#; ----------------------------------------------------------------------------------------
#;	------------------------------------DO NOT CHANGE MAIN----------------------------------
#; ----------------------------------------------------------------------------------------
.globl main
.ent main
main:
#;	Square Root Test 1
	li $v0, SYSTEM_PRINT_STRING
	la $a0, squareRootLabel1
	syscall

	lw $a0, squareRootValue1
	jal estimateIntegerSquareRoot

	move $a0, $v0
	li $v0, SYSTEM_PRINT_INTEGER
	syscall

	li $v0, SYSTEM_PRINT_STRING
	la $a0, endLabel
	syscall

#;	Square Root Test 2
	li $v0, SYSTEM_PRINT_STRING
	la $a0, squareRootLabel2
	syscall

	lw $a0, squareRootValue2
	jal estimateIntegerSquareRoot

	move $a0, $v0
	li $v0, SYSTEM_PRINT_INTEGER
	syscall

	li $v0, SYSTEM_PRINT_STRING
	la $a0, endLabel
	syscall
	
#;	Float Square Root Test 1
	li $v0, SYSTEM_PRINT_STRING
	la $a0, squareRootFloatLabel1
	syscall

	l.s $f12, floatSquareRootValue1
	l.s $f14, floatTolerance1
	jal estimateFloatSquareRoot

	li $v0, SYSTEM_PRINT_FLOAT
	mov.s $f12, $f0
	syscall

	li $v0, SYSTEM_PRINT_STRING
	la $a0, endLabel
	syscall

#;	Float Square Root Test 2
	li $v0, SYSTEM_PRINT_STRING
	la $a0, squareRootFloatLabel2
	syscall

	l.s $f12, floatSquareRootValue2
	l.s $f14, floatTolerance2
	jal estimateFloatSquareRoot

	li $v0, SYSTEM_PRINT_FLOAT
	mov.s $f12, $f0
	syscall

	li $v0, SYSTEM_PRINT_STRING
	la $a0, endLabel
	syscall
	
#;	Print Array Test
	li $v0, SYSTEM_PRINT_STRING
	la $a0, printArrayLabel
	syscall

	la $a0, printArray
	li $a1, PRINT_ARRAY_LENGTH
	jal printIntegerArray

#;	Print Unsorted Array
	li $v0, SYSTEM_PRINT_STRING
	la $a0, unsortedLabel
	syscall

	la $a0, arrayValues
	li $a1, ARRAY_LENGTH
	jal printIntegerArray
	
#;	Print Sorted Array (Ascending)
	li $v0, SYSTEM_PRINT_STRING
	la $a0, sortedLabelAscending
	syscall

	la $a0, arrayValues
	li $a1, ARRAY_LENGTH
	jal sortList

	la $a0, arrayValues
	li $a1, ARRAY_LENGTH
	jal printIntegerArray
	
#;	End Program
	li $v0, SYSTEM_EXIT
	syscall
.end main
