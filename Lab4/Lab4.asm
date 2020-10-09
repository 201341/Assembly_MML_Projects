##########################################################################
# Created by:  Lao, Justin
#              jlao3
#              11 May 2020
#
# Assignment:  Lab 4: Sorting Integers
#              CSE012, Computer Systems and Assembly Language
#              UC Santa Cruz, Spring 2020
# 
# Description: Take in Program Arguments and convert them into integers, and then sort them. Printing each time.
#
# Notes:       This program is intended to be run from the MARS IDE.
##########################################################################

##########################################################################
# Psuedocode:
#	access base of program arguments on $sp
#		print current Program Argument that $sp is pointing to
#		increment $sp
#		loop until through with all Program arguments
#	reset back to original base address
#		convert current Program Argument to integer
#			take significant bytes from P.A and convert to correct integer value
#		store integer into array
#		print integer
#		loop until through with all Program arguments
#	access array and loop through it's entirety to sort
#		swap if secondary value pointed by incremented address ptr is smaller than value of current address ptr
#	print entire array
#	system exit
##########################################################################

.data
	programSent: .asciiz "Program arguments:\n"
	space: .asciiz " "
	newline: .asciiz "\n"
	integerSent: .asciiz "\nInteger values:\n"
	sortedSent: .asciiz  "\nSorted values:\n"
	integerArray:
		.align 2
		.space 64
		
.text
	main: NOP
		jal 	stackPointer					#Sets $sp to address of first arguments
		la  	$t0, ($a0)					#$t0 is number of arguments
		
		la 	$a0, programSent
		li 	$v0, 4
		syscall
		
		printArguments: 					#Prints Program Arguments
			lw 	$t7, ($sp)
			addi 	$a0, $t7, 0
			li 	$v0, 4
			syscall
			
			addi 	$sp, $sp, 4				#Increment $sp
			addi 	$t8, $t8, 1				#Increment $t8 until it's equal to number of Program Arguments
			beq 	$t8, $t0, cont 				#which ensures extra space at end of line won't be printed
			
			jal	printSpace
			j 	printArguments 				#Recursive format
			
		cont: 							#Resets everything
			jal 	stackPointer
			jal	printNewline
			li 	$v0, 4
			la 	$a0, integerSent
			syscall
			la	$t9, ($zero)
			b 	printIntegers
		
		printIntegers:
			lw 	$t7, ($sp)				#Loads word pointed to by $sp
			jal	hexLen					#Checks length of HEX argument			
			beq	$s1, 3, multSize3			#Ex: 0xFFF
			beq	$s1, 2, multSize2			#Ex: 0xFF
			beq	$s1, 1, multSize1			#Ex: 0xF
			
			sw	$t4, integerArray($t9)			#Store Integer Into Array
			addi	$t1, $t1, 1				#Increment Size of Array
			addi	$t9, $t9, 4				#Increment Ptr of Array
			
			la	$a0, ($t4)				#Prints Integer
			li 	$v0, 1
			syscall
			
			addi 	$sp, $sp, 4				#Increment $sp
			addi 	$t8, $t8, 1				#Increment $t8 until it's equal to number of Program Arguments
			beq 	$t8, $t0, cont1 			#whic ensures extra space at end of line won't be printed
			
			jal	printSpace
			j 	printIntegers				#Recursive format
			
		cont1: 
			jal 	stackPointer
			jal	printNewline
			li 	$v0, 4
			la 	$a0, sortedSent
			syscall
			mul	$t7, $t1, 4				# 4 bytes per int * size of array = amount to traverse      
			la	$t9, ($zero)				#Reset ptr to 0
			la  	$t0, integerArray($t9)      		#Loads $t0 with base address of integerArray	
    			add 	$t0, $t0, $t7				#$t0 is equal to base address + size of array, which is final point of array
			beq	$t1, 1, printArray
		
		#Version of Bubble Sort
		sortArray:          				#Start of outside loop	
    			add $t2, $zero, $zero     		#value index
    			la  $a0, integerArray($t9)     		#$a0 becomes main ptr
			insideLoop:                  		
    				lw  $t3, 0($a0)         	#Loads integer at current ptr
   				lw  $t4, 4($a0)         	#Loads integer at address next to current ptr
   				beq $t3, $t4, increment
   				blt $t3, $t4, increment
    				add $t2, $zero, 1          	#Indexing
    				sw  $t3, 4($a0)         	#Swap $t3 and $t4
    				sw  $t4, 0($a0)         	
			increment:
    				addi $a0, $a0, 4            		#Increment ptr
    				bne  $a0, $t0, insideLoop		#Return to inside loop if run-through isn't complete
    				bne  $t2, $zero, sortArray		#Return to outside loop if run-through is complete, else cont2                     
			
    				
		cont2:
			la	$t9, ($zero)				#Reset ptr to 0
			addi	$t9, $t9, 4				#Decrement Ptr of Array, needed to correctly access Array
			la	$t5, ($zero)
			
			
		printArray:						#Loop to print out array
			lw	$a0, integerArray($t9)
			li 	$v0, 1
			syscall
			
			addi	$t5, $t5, 1
			addi	$t9, $t9, 4				#Increment Ptr of Array
			beq	$t5, $t1, end
			
			jal	printSpace
			j	printArray
			
		end:							#Exit the program once everything is completed
			jal	printNewline
			li $v0, 10
			syscall
		
		#############################################_HELPER_FUNCTIONS_################################################
		
		#Prints " "
		printSpace:
			li 	$v0, 4
			la 	$a0, space
			syscall
			jr	$ra
		
		#Prints "\n"
		printNewline:
			li 	$v0, 4
			la 	$a0, newline
			syscall
			jr	$ra
			
		#Resets stack pointer to start of arguments
		stackPointer: 
			la  	$sp, ($a1)
			la  	$t8, ($zero)
			jr 	$ra
		
		#Checks if between 0-9 (which is minus by 48), else change to letterChanger
		hexChecker:
			bgt	$t6, 57, letterChanger
			addi 	$t6, $t6, -48
			jr	$ra
		
		#Checks if between A-F (which is minus by 55), return to $ra
		letterChanger:
			addi	$t6, $t6, -55
			jr	$ra
		
		hexLen:
			li $s1, 0 
			checker:
				lb 	$t6, 2($t7)		#Loads each byte of Program Argument
				addi 	$t6, $t6, -48		#Ends after reaching the NULL character
				beq 	$t6, -48, exit		#Which will be -48 after subtracting by -48
				addi 	$s1, $s1, 1 		#Can't use beqz because it won't read value correctly
				lb 	$t6, 3($t7) 		#Thus the -48
				addi 	$t6, $t6, -48		#Every prcoessed byte, adds 1 to size
				beq 	$t6, -48, exit
				addi 	$s1, $s1, 1
				lb 	$t6, 4($t7)
				addi 	$t6, $t6, -48
				beq 	$t6, -48, exit
				addi 	$s1, $s1, 1
			exit:
				jr $ra				#Return

		multSize3:
			la	$s0, 4($ra)			#Loads address of next instruction in callee
			lb 	$t6, 2($t7)			#and then chooses byte out of argument
			jal	hexChecker			#Determines whether it's 0-9 or A-F and will subtract occordingly
			mul	$t4, $t6, 256			#Multiply by 256(16^2) to achieve correct amount
			lb 	$t6, 3($t7)			#and then chooses next byte out of argument
			jal	hexChecker			#Determines whether it's 0-9 or A-F and will subtract occordingly
			mul	$t6, $t6, 16			#Multiply by power 16 to achieve correct amount
			add	$t4, $t4, $t6
			lb 	$t6, 4($t7)			#Does the same, without multiply, since for this byte it'd be by 1
			jal	hexChecker
			add	$t4, $t4, $t6
			la	$ra, ($s0)			#Return Address become saved address (done because jal hexChecker)
			jr	$ra				#Return
			
		multSize2:
			la	$s0, 4($ra)			#Loads address of next instruction in callee
			lb 	$t6, 2($t7)			#and then chooses byte out of argument
			jal	hexChecker			#Determines whether it's 0-9 or A-F and will subtract occordingly
			mul	$t4, $t6, 16			#Multiply by 16 (16^1) to achieve correct amount
			lb 	$t6, 3($t7)			#Does the same, without multiply, since for this byte it'd be by 1
			jal	hexChecker
			add	$t4, $t4, $t6
			la	$ra, ($s0)			#Return Address become saved address (done because jal hexChecker)
			jr	$ra				#Return
			
		multSize1:
			la	$s0, 4($ra)			#Loads address of next instruction in callee
			la	$t4, ($zero)
			lb 	$t6, 2($t7)
			jal	hexChecker			#Determines whether it's 0-9 or A-F and will subtract occordingly
			add	$t4, $t4, $t6			#Set $t4 to value
			la	$ra, ($s0)			#Return Address become saved address (done because jal hexChecker)
			jr	$ra				#Return
