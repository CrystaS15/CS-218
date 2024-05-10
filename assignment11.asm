#; Author: Kristy Nguyen
#; Section: 1001
#; Date Last Modified: 11/11/2020
#; Program Description: 
#;		Assignment 11
#;		This program determines which widgets are within acceptable tolerances and outputs the results
.data
	widgetMeasurements: .word	706, 672, 658, 548, 570, 439, 648, 563, 790, 442
						.word	982, 904, 615, 718, 841, 827, 594, 673, 839, 762
						.word	547, 611, 620, 747, 858, 915, 509, 968, 774, 778
						.word	526, 934, 453, 910, 921, 766, 753, 849, 718, 479
						.word	910, 914, 481, 639, 614, 1049, 517, 501, 777, 860

	widgetTargetSizes:	.word	717, 662, 742, 502, 622, 511, 651, 645, 868, 517
						.word	895, 881, 539, 701, 779, 857, 653, 724, 907, 830
						.word	585, 574, 649, 750, 986, 930, 543, 932, 891, 760
						.word	603, 836, 509, 942, 864, 879, 668, 790, 806, 516
						.word	820, 834, 555, 588, 620, 926, 524, 517, 802, 988

	widgetStatus: .space 200

	WIDGET_COUNT = 50

	messageWidgetHeader: 	.asciiz "Widget #"
	messageWidgetAccepted:	.asciiz ": Accepted\n"
	messageWidgetRejected:	.asciiz ": Rejected\n"
	messageWidgetRework:	.asciiz ": Rework\n"

	SYSTEM_EXIT = 10
	SYSTEM_PRINT_INTEGER = 1
	SYSTEM_PRINT_STRING = 4
	
.text
.globl main
.ent main
main:

	#; Load variables
	la 	$t0, widgetMeasurements 	#; address of widgetMeasurements
	la 	$t1, widgetTargetSizes		#; address of widgetTargetSizes 
	la 	$t2, widgetStatus			#; address of widgetStatus 
	
	li 	$t5, 0						#; widgetStatus
	li 	$t7, 0						#; lower bound
	li 	$t8, 0						#; upper bound
	li 	$t9, WIDGET_COUNT			#; WIDGET_COUNT
	
	#; Check Each Widget
	checkWidget:
		lw 		$t3, ($t0)		#; get widgetMeasurements[i]
		lw 		$t4, ($t1)		#; get widgetTargetSizes[i]
		
		#; Find 8% Thresholds
			
			#; Lower bound = widgetTargetSizes[i] * 92/100
			mul 	$t7, $t4, 92
			div 	$t7, $t7, 100 	#; 92%
			
			#; Upper bound = widgetTargetSizes[i] * 108/100
			mul 	$t8, $t4, 108
			div		$t8, $t8, 100	#; 108%
			
		#; Determine Widget Status
			
			#; Reject (widgetMeasurements[i] < target[i] * 92%) 
				blt 	$t3, $t7, widgetStatusRejected
				
			#; Rework (widgetMeasurements[i] > target[i] * 108%)
				bgt 	$t3, $t8, widgetStatusReworked
				
			#; Accept (92% <= Difference <= 108%)
				li 	$t5, 0
				j 	doneWidget
			
			widgetStatusRejected:
				li 	$t5, -1
				j 	doneWidget
			
			widgetStatusReworked:
				li 	$t5, 1
				j 	doneWidget
			
			doneWidget:
				sw 		$t5, 	($t2)			#; store $t5 into widgetStatus[i]
				addu 	$t0, 	$t0, 	4		#; widgetMeasurements[i+1]
				addu 	$t1, 	$t1, 	4		#; widgetTargetSizes[i+1]
				addu 	$t2, 	$t2, 	4		#; widgetStatus[i+1]
				subu 	$t9, 	$t9, 	1		#; i--
	bnez 	$t9, checkWidget					#; if WIDGET_COUNT=0 -> checkWidget
	
	#; Output Widget Statuses
	la 	$t0, widgetStatus		#; address of widgetStatus
	li 	$t8, 1					#; loop index, i = 1
	
	printLoop:
		lw 	$t1, ($t0) 			#; widgetStatus
	
		li 	$v0, SYSTEM_PRINT_STRING			#; Print
		la 	$a0, messageWidgetHeader 			#; "Widget #"
		syscall
	
		li 		$v0, SYSTEM_PRINT_INTEGER		#; Print
		move 	$a0, $t8						#; loop index
		syscall
		
		beq 	$t1, -1, widgetRejected			#; widgetStatus[i] = -1 >> Rejected
		beq 	$t1, 1, widgetReworked			#; widgetStatus[i] = 1 	>> Rework
		beq 	$t1, 0, widgetAccepted			#; widgetStatus[i] = 0 	>> Accepted
		
		#; widgetStatus[i] = -1 >> Rejected
		widgetRejected:
			li 	$v0, SYSTEM_PRINT_STRING		#; Print
			la 	$a0, messageWidgetRejected		#; ": Rejected\n"
			syscall
			j endWidget
		
		#; widgetStatus[i] = 1 	>> Rework
		widgetReworked:
			li 	$v0, SYSTEM_PRINT_STRING		#; Print
			la 	$a0, messageWidgetRework		#; ": Rework\n"
			syscall
			j endWidget
		
		#; widgetStatus[i] = 0 	>> Accepted
		widgetAccepted:
			li 	$v0, SYSTEM_PRINT_STRING		#; Print
			la 	$a0, messageWidgetAccepted		#; ": Accepted\n"
			syscall
			j endWidget
		
		endWidget:
			add 	$t0, $t0, 4					#; widgetStatus[i+1]
			add 	$t8, $t8, 1					#; i=i+1
	bleu 	$t8, WIDGET_COUNT, printLoop		#; if loop index<=WIDGET_COUNT -> printLoop
	
	#; Ends Program
	li $v0, SYSTEM_EXIT
	syscall
.end main