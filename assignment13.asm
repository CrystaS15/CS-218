#; Author: Kristy Nguyen
#; Section: 1001
#; Date Last Modified: 12/4/2020
#; Program Description: 
#;		Assignment 13
#; 		Implements Conway's Game of Life on a wraparound board

.data
#;	System Service Codes
	SYSTEM_EXIT = 10
	SYSTEM_PRINT_INTEGER = 1
	SYSTEM_PRINT_STRING = 4
	SYSTEM_READ_INTEGER = 5
	
#;	Board Parameters
	MAXIMUM_WIDTH = 80
	MINIMUM_WIDTH = 5
	MAXIMUM_HEIGHT = 40
	MINIMUM_HEIGHT = 5
	MINIMUM_GENERATIONS = 1
	WORD_SIZE = 4
	gameBoard: .space MAXIMUM_WIDTH * MAXIMUM_HEIGHT * WORD_SIZE
	
#;	Strings
	heightPrompt: .asciiz "Board Height: "
	widthPrompt: .asciiz "Board Width: "
	generationsPrompt: .asciiz "Generations to Simulate: "
	errorWidth: .asciiz "Board width must be between 5 and 80.\n"
	errorHeight: .asciiz "Board height must be between 5 and 40.\n"
	errorGenerations: .asciiz "Generation count must be at least 1.\n"
	initialGenerationLabel: .asciiz "Initial Generation\n"
	generationLabel: .asciiz "Generation #"
	newLine: .asciiz "\n"
	livingCell: .asciiz "¤"
	deadCell: .asciiz "•"
	
.text
.globl main
.ent main
main:
#;	Ask for width of gameboard
	promptWidth:
	
		li 	$v0, SYSTEM_PRINT_STRING
		la 	$a0, widthPrompt
		syscall
		
		#; 	Read width
		li 	$v0, SYSTEM_READ_INTEGER
		syscall
		
	#;	Check that width is within specified bounds
		blt 	$v0, MINIMUM_WIDTH, widthError
		bgt 	$v0, MAXIMUM_WIDTH, widthError
		
		move 	$a1, $v0 	#; store $v0 into $a1
		j 		widthDone
		
		widthError:
			li 	$v0, SYSTEM_PRINT_STRING
			la 	$a0, errorWidth
			syscall
		j 	promptWidth
	
	widthDone:
	
#;	Ask for height of gameboard
	promptHeight:
	
		li 	$v0, SYSTEM_PRINT_STRING
		la 	$a0, heightPrompt
		syscall
		
		#; 	Read height
		li 	$v0, SYSTEM_READ_INTEGER
		syscall
		
	#;	Check that height is within specified bounds
		blt 	$v0, MINIMUM_HEIGHT, heightError
		bgt 	$v0, MAXIMUM_HEIGHT, heightError
		
		move 	$a2, $v0	#; store $v0 into $a2
		j 		heightDone
		
		heightError:
			li 	$v0, SYSTEM_PRINT_STRING
			la 	$a0, errorHeight
			syscall
		j 	promptHeight
	
	heightDone:

#;	Initialize Board Elements to 0
	la 		$a0, gameBoard
	li 		$t8, 0 #; value of 0
	li 		$t9, 0 #; loop index
	
	mul 	$t1, $a1, $a2			#; Array Size
	#;mul $t5, $t5, WORD_SIZE		#; width * height * WORD_SIZE
	
	initializeElements:
		mul 	$t2, $t9, WORD_SIZE #; $t2 = loop index($t9) * WORD_SIZE
		add 	$t3, $a0, $t2		#; baseAddress + $t2
		sw 		$t8, ($t3)
		
	add $t9, $t9, 1 #; i ++
	blt $t9, $t1, initializeElements

#;	Insert Glider at 2,2
	#; la $a0, gameBoard
	#; move $a1, $s0
	#; li $a2, 2
	#; li $a3, 2
	#; jal insertGlider
	
#;	Ask for generations to calculate
	promptGenerations:
		li $v0, SYSTEM_PRINT_STRING
		la $a0, generationsPrompt
		syscall
		
		#; Read generations
		li $v0, SYSTEM_READ_INTEGER
		syscall
		
	#;	Ensure # of generations is positive
		blt $v0, 1, generationsError
		j 	generationsDone
		
		generationsError:
			li $v0, SYSTEM_PRINT_STRING
			la $a0, errorGenerations
			syscall
		j promptGenerations
	generationsDone:
	
#;	Print Initial Board
	la 	$a0, gameBoard
	jal printGameBoard

#;	For each generation:
#;		Play 1 Turn
#;		Print Generation Label
#;		Print Board
	
	endProgram:
	li $v0, SYSTEM_EXIT
	syscall
.end main

#;  Insert Glider Pattern
#;	••¤
#;	¤•¤
#;	•¤¤
#;	0,0 is in the top left of the gameboard
#;	Assume all cells are dead in the 3x3 space to start with.
#;	Argument 1: Address of Game Board
#;	Argument 2: Width of Game Board
#;	Argument 3: X Position of Top Left Square of Glider "•"
#;	Argument 4: Y Position of Top Left Square of Glider "•"
.globl insertGlider
.ent insertGlider
insertGlider:

	#; move $t3, $a2	#; X Position (2)
	#; move $t4, $a3	#; Y Position (2)
	
	#; li 	$t9, 0 		#; counter
	#; gliderLoop:
		#; mul $t1, $t3, $a2 		#; rowIdx * numberOfCols
		#; add $t1, $t1, $t4 		#; 		+ colIdx
		
		#; mul $t1, $t1, WORD_SIZE #; 	* dataSize
		#; add $t2, $a0, $t1		#; + baseAddress
		
		#; lw	$t5, ($t2) 			#; get gameboard[y][x]
		
		#; beq $t5, 1, printLivingCell2
		#; j skipLiving
		
		#; printLivingCell2:
		#; li $v0, SYSTEM_PRINT_STRING
		#; la $a0, livingCell
		#; syscall
		
		#; skipLiving:
		#; add $t4, $t4, 1 			#; colIdx++
		#; blt $t4, 5, gliderLoop 		#; colIdx < 5 --> gliderLoop
		
		#; add $t3, $t3, 1 			#; rowIdx++
		#; beq $t3, 5, endGliderLoop	#; row=5 --> endGliderLoop
		#; li 	$t4, 2					#; reset colIdx, colIdx=2
	#; j 	gliderLoop
	#; endGliderLoop:
	
	jr $ra
.end insertGlider

#;	Updates the state of the gameboard
#;	For each Cell:
#;	Living: 2-3 Living Neighbors -> Stay Alive, otherwise Change to Dead
#;	Dead: Exactly 3 Living Neighbors -> Change to Alive 
#;	Cell States:
#;		0: Currently Dead, Stay Dead (00b)
#;		1: Currently Living, Change to Dead (01b)
#;		2: Currently Dead, Change to Living (10b)
#;		3: Currently Living, Stay Living (11b)
#;	Right Bit: Current State
#;	Left Bit: Next State
#;	All cells must maintain their current state until all next states have been determined.
#;	Argument 1: Address of Game Board
#;	Argument 2: Width of Game Board
#;	Argument 3: Height of Game Board
.globl playTurn
.ent playTurn
playTurn:
#;	For each cell on the gameboard:
#;		Count the number of living neighbors (including diagonals)
#;			The board wraps around, use remainder to find wrapped indice
#;			Start each width/height register value offset by the size of the board
#;				i.e. currentWidth = width instead of 0
#;		Use the remainder instruction to extract current state
#;		Update cell state
#;			if cell is currently alive with 2-3 neighbors, change next bit to alive
#;			if cell is currently dead with exactly 3 neighbors, change next bit to alive

#;	For each cell on the gameboard:
#;		Update each cell to its new state by dividing by 2

	jr $ra
.end playTurn

#;	Prints the array using the specified dimensions
#;	For values of 1, print as a livingCell "¤"
#;	For values of 0, print as a deadCell "•"
#;	Argument 1: Address of Array
#;	Argument 2: Width of Array
#;	Argument 3: Height of Array
.globl printGameBoard
.ent printGameBoard
printGameBoard:
	
	subu 	$sp, $sp, 8 	#; preserve registers
	sw 		$s0, ($sp)
	sw 		$ra, 4($sp)
	
	move 	$s0, $a0
	mul 	$t1, $a1, $a2	#; array size
	li 		$t8, 0 			#; counter
	li 		$t9, 0 			#; loop index, i=0
	printLoop:
		li $t9, 0 			#; reset index, i=0
		
		printRow:
			lw 	$t2, ($s0) 	#; get gameBoard[y][x]
			
			beq $t2, 0, printDeadCell
			beq $t2, 1, printLivingCell
			
			#; Print Dead Cell if gameBoard[y][x]=0
			printDeadCell:
			li $v0, SYSTEM_PRINT_STRING
			la $a0, deadCell
			syscall
			j 	continue
			
			#; Print Living Cell if gameBoard[y][x]=1
			printLivingCell:
			li $v0, SYSTEM_PRINT_STRING
			la $a0, livingCell
			syscall
			j continue
			
			continue:
			addu $s0, $s0, WORD_SIZE 	#; next element in gameBoard[y][x]
			add $t8, $t8, 1 			#; counter++
			add $t9, $t9, 1 			#; i ++
		
			blt $t9, $a1, printRow		#; if index<width --> printRow (loop)
		
		#; Print newLine if counter!=arraySize & index=width
		li 	$v0, SYSTEM_PRINT_STRING
		la 	$a0, newLine
		syscall
		
		beq $t8, $t1, endPrintLoop	#; if counter=arraySize --> endPrintLoop
	j 	printLoop
	
	endPrintLoop:
	
	lw 		$s0, ($sp)		#; Restore registers
	lw 		$ra 4($sp)		#; and return to calling routine
	addu 	$sp, $sp, 8
	
	jr $ra
.end printGameBoard
