#; Author: Kristy Nguyen
#; Section: 1001
#; Date Last Modified: 12/4/2020
#; Program Description: 
#;		Assignment 14
#; 		Compare and contrast different approaches to solving a problem recursively

.data
#; 	System Service Codes
	SYSTEM_EXIT = 10 #; terminate
	SYSTEM_PRINT_INTEGER = 	1 	#; input -> $a0
	SYSTEM_PRINT_STRING = 	4 	#; input -> $a0
	SYSTEM_READ_INTEGER = 	5 	#; output -> $v0
	
#; 	Constants
	MINIMUM_VALUE = 1
	MAXIMUM_VALUE = 46

#; 	Strings
	fibonacciPrompt: .asciiz "Calculate Fibonacci sequence number (1-46): "
	errorFibonacci: .asciiz "Number must be between 1 and 46. \n"
	topDownMessage: .asciiz "Top Down Fibonacci ("
	bottomUpMessage: .asciiz "Bottom Up Fibonacci ("
	parenthesesColon: .asciiz "): "
	functionCallsMessage: .asciiz " function calls required."
	newLine: .asciiz "\n"
	
	testAnswer: .asciiz "Answer: "
	
#; 	Variables
	inputNum:		.word 	0
	n: 				.word 	0
	topDownAnswer: 	.word 	0
	bottomUpAnswer: .word 	0
	topDownCalls:	.word 	0
	bottomUpCalls:	.word	0

.text
.globl main
.ent main
main:

#; 	Prompt user for nth Fibonacci value to calculate
	promptFibonacci:
	li $v0, SYSTEM_PRINT_STRING
	la $a0, fibonacciPrompt
	syscall
	
	#; Read Fibonacci sequence number
	li $v0, SYSTEM_READ_INTEGER
	syscall
	sw $v0, n 		#; store $v0 into n
	
#; 	Ensure value is between 1 and 46
	blt $v0, MINIMUM_VALUE, fibonacciError
	bgt $v0, MAXIMUM_VALUE, fibonacciError
	j validValue
	
	#; 	Print errorFibonacci
	fibonacciError:
	li $v0, SYSTEM_PRINT_STRING
	la $a0, errorFibonacci
	syscall
	
	#; 	Print newLine
	li $v0, SYSTEM_PRINT_STRING
	la $a0, newLine
	syscall
	j promptFibonacci

	validValue:
	
	#; Print Top Down Message
	li $v0, SYSTEM_PRINT_STRING
	la $a0, topDownMessage
	syscall
	
	#; Print n value
	li $v0, SYSTEM_PRINT_INTEGER
	lw $a0, n
	syscall
	
	#; Print "):"
	li $v0, SYSTEM_PRINT_STRING
	la $a0, parenthesesColon
	syscall
	
	#; 	Call Top-Down Fibonacci
	lw $a0, n 					#; loads value memory of n into $a0
	la $a1, topDownCalls
	jal topDownFibonacci
	sw $v0, topDownAnswer 		#; store $v0 into memory of answer
	
	#; Print Top Down Answer
	li $v0, SYSTEM_PRINT_INTEGER
	lw $a0, topDownAnswer
	syscall
	
	#; 	Print newLine
	li $v0, SYSTEM_PRINT_STRING
	la $a0, newLine
	syscall
	
	#; Print top-down recursive function call count
	li $v0, SYSTEM_PRINT_INTEGER
	lw $a0, topDownCalls
	syscall
	
	li $v0, SYSTEM_PRINT_STRING
	la $a0, functionCallsMessage
	syscall
	
	#; 	Print newLine
	li $v0, SYSTEM_PRINT_STRING
	la $a0, newLine
	syscall
	
	#; 	Print newLine
	li $v0, SYSTEM_PRINT_STRING
	la $a0, newLine
	syscall
	
	#; Print Bottom-Up message
	li $v0, SYSTEM_PRINT_STRING
	la $a0, bottomUpMessage
	syscall
	
	#; Print n value
	li $v0, SYSTEM_PRINT_INTEGER
	lw $a0, n
	syscall
	
	#; Print "):"
	li $v0, SYSTEM_PRINT_STRING
	la $a0, parenthesesColon
	syscall
	
	#; Call Bottom-Up Fibonacci
	lw $a0, n
	li $a1, 1
	
	la $t2, bottomUpCalls
	subu $sp, $sp, 4
	sw $t2, ($sp)
	
	jal bottomUpFibonacci
	addu $sp, $sp, 4
	sw $v0, bottomUpAnswer 		#; store $v0 into memory of answer
	
	#; Print Bottom Up Answer
	li $v0, SYSTEM_PRINT_INTEGER
	lw $a0, bottomUpAnswer
	syscall
	
	#; 	Print newLine
	li $v0, SYSTEM_PRINT_STRING
	la $a0, newLine
	syscall

#; 	End Program
	endProgram:
	li $v0, SYSTEM_EXIT
	syscall

.end main

#; 	Top-Down Fibonacci 
#; 	Recursive Definition:
#; 		= 0 					if n = 0
#; 		= 1 					if n = 1
#; 		= fib(n-1) + fib(n-2) 	if n > 2
#; 	Arguments 
#; 		($a0): value n to calculate as an integer
#; 		($a1): number of function calls (la instruction)
#; 	Returns 
#; 		($v0): set to fib(n)
.globl 	topDownFibonacci
.ent 	topDownFibonacci
topDownFibonacci:
	lw $t1, ($a1)
	subu $sp, $sp, 8
	sw $ra, ($sp)
	sw $s0, 4($sp)
	
	move $v0, $a0			#; check for base cases
	ble $a0, 1, topFibDone
	
	move $s0, $a0			#; get fib(n-1)
	sub $a0, $a0, 1
	jal topDownFibonacci
	
	move $a0, $s0
	sub $a0, $a0, 2			#; set n-2
	move $s0, $v0			#; save fib(n-1)
	jal topDownFibonacci	#; get fib(n-2)
	
	add $v0, $s0, $v0		#; fib(n-1) + fib(n-2)
	
	topFibDone:
		add $t1, $t1, 1
		sw $t1, ($a1)
		lw $ra, ($sp)
		lw $s0, 4($sp)
		addu $sp, $sp, 8
		jr $ra
	
.end topDownFibonacci

#; 	Bottom-Up Fibonacci
#; 	Arguments
#; 		($a0) final value n
#; 		($a1) current value n
#; 		($a2) value f(n-1)
#; 		($a3) value f(n-2)
#; 		($fp) number of function calls by reference
.globl bottomUpFibonacci
.ent bottomUpFibonacci
bottomUpFibonacci:
	
	#;subu $sp, $sp, 16
	#;sw $s0, 0($sp)
	#;sw $fp, 4($sp)
	#;sw $ra, 8($sp)
	
	#;addu $fp, $sp, 16
	
	#;lw $t0, ($fp)
	
	li $a2, 0
	li $a3, 1
	
	bne $a0, 0, checkIfOne
	li $v0, 0
	j bottomFibDone
	
	checkIfOne:
	bne $a0, 1, bottomFib
	li $v0, 1
	j bottomFibDone
	
	bottomFib:
	
	add $v0, $a2, $a3
	move $t0, $a3
	move $a3, $v0
	move $a2, $t0
	
	add $a1, $a1, 1 #; current++
	beq $a1, $a0, bottomFibDone
	
	j bottomFib
	
	bottomFibDone:
	#;add $t1, $t1, 1
	#;sw $t1, ($t0)
	
	#;lw $s0, 0($sp)
	#;lw $fp, 4($sp)
	#;lw $ra, 8($sp)
	#;addu $sp, $sp, 16
	
	jr $ra
.end bottomUpFibonacci